// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IERC4626.sol';
import 'openzeppelin-contracts/token/ERC20/ERC20.sol';
import 'BENQI-Smart-Contracts/sAVAX/IStakedAvax.sol';
import '../lib/forge-std/src/console.sol';

/***
    * @title sAVAXvault
    * @author Oleksii Novykov
    * @notice sAVAXvault is wrapper for Benqi liquid staking (sAVAX). 
    * Users can deposit AVAX or sAVAX and recieve sfuAVAX. Staking rewards 
    * are donated to NGOs supporting Ukraine.
 */

contract sAVAXvault is ERC20 {

    /* ========== STATE VARIABLES ========== */

    IStakedAvax public sAVAXcontract;

    /// @notice Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries)
    address payable public harvestManagerAddress;

    /// @notice Address of the sAVAX ERC-20 contract;
    address payable public sAVAXaddress; 

    /// @notice Total amount of sfuAVAX issued by this contract to depositors of AVAX/sAVAX
    uint256 public totalShares;
    /// @notice Total amount deposited by all users in AVAX to this contract minus amount withdrawn by all users
    uint256 public totalAssets;
    
    /// @notice Balances of each individual users in AVAX
    mapping (address => uint256) public totalDeposit; //summary of all deposits minus of all withdrawals for one user;

    /* ========== EVENTS ========== */

    /// @notice Emitted when a user deposits AVAX
    /// @param caller Address of the user who deposited AVAX
    /// @param amount Amount of AVAX deposited
    event Deposit(address caller, uint256 amount);

    /// @notice Emitted when a user withdraws AVAX
    /// @param caller Address of the user who withdrew AVAX
    /// @param receiver Address of the user who received AVAX
    /// @param amount Amount of AVAX withdrawn
    /// @param shares Amount of sfuAVAX burned
    event Withdraw(address caller, address receiver, uint256 amount, uint256 shares);

    /// @notice Emitted when harvest function is triggered and staking rewards are harvested
    /// @param caller Address of the user who triggered harvest function
    /// @param amount Amount harvested (in AVAX)
    event Harvested(address caller, uint256 amount);

    /// @notice Emitted when available AVAX is staked
    /// @param caller Address of the user who triggered stake function
    /// @param amount Amount staked (in AVAX)
    event Staked(address caller, uint256 amount);


    /// @notice Contract constructor sets initial parameters when contract is deployed.
    /// @param _harvestManagerAddress Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries)
    /// @param _sAVAXaddress Address of the sAVAX ERC-20 contract;
    constructor(address payable _harvestManagerAddress, address payable _sAVAXaddress) ERC20("Stake AVAX for Ukraine", "sfuAVAX") {
        sAVAXaddress = _sAVAXaddress;
        sAVAXcontract = IStakedAvax(sAVAXaddress);
        harvestManagerAddress = _harvestManagerAddress;

        totalAssets = 0;
        totalShares = 0;
    }

    /* ========== MAIN FUNCTIONALITY ========== */

    /// @notice Allows users to deposit AVAX to the contract and mints sfuAVAX in return
    /// @param _receiver Address of the user who will receive sfuAVAX
    function deposit(address _receiver) external payable returns (uint256 _shares) {
        require(msg.value > 0, "Amount must be greater than 0");
        require(msg.sender.balance > msg.value, "Vault: deposit amount must be greater than 0");
        require(_receiver != address(0), "Vault: receiver address must be non-zero address");

        if (totalShares == 0) {
            _shares = msg.value;
        } else {
            _shares = msg.value * totalShares / totalAssets;
        }

        totalDeposit[msg.sender] += msg.value;
        totalAssets += msg.value;
        totalShares += _shares;

        _mint(_receiver, _shares);

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Allows users to withdraw sAVAX from the contract and burns sfuAVAX in return
    /// @param _shares Amount of sfuAVAX to burn
    /// @param _receiver Address of the user who will receive sAVAX
    function withdraw(uint256 _shares, address payable _receiver) external payable {
        uint256 _AVAXtoWithdraw;
        uint256 _sAVAXtoWithdraw;
        require(_receiver != address(0), "Vault: receiver address must be non-zero address");
        require(_shares > 0, "Vault: withdraw amount must be greater than 0");
        require(totalDeposit[msg.sender] >= _shares, "Vault: withdraw amount must be less than or equal to balance");

        _AVAXtoWithdraw = _shares * totalAssets / totalShares;


        if (_AVAXtoWithdraw <= totalAssets) {
                _safeTransfer(_receiver, _AVAXtoWithdraw);
            } else {
                _sAVAXtoWithdraw = this.checksAVAXinAVAX(_AVAXtoWithdraw);
                sAVAXcontract.approve(_receiver, _sAVAXtoWithdraw);
                sAVAXcontract.transferFrom(address(this), _receiver, _sAVAXtoWithdraw);
        }

        totalDeposit[msg.sender] -= _AVAXtoWithdraw;
        totalAssets -= _AVAXtoWithdraw;
        totalShares -= _shares;

        _burn(msg.sender, _shares);

        emit Withdraw(msg.sender, _receiver, _AVAXtoWithdraw, _shares);
    }

    /// @notice Allows users to stake available AVAX in the contract with Benqi.fi sAVAX staking contract
    function stake() external payable returns (uint256) {
        uint256 _availableAVAX = address(this).balance; //Check how much of the baseAsset is not invested (if any)
        uint256 _sAVAXrecieved; //amount of sAVAX returned from the staking contract after submiting the _availableBaseAsset

        if (_availableAVAX > 0){
            _sAVAXrecieved = sAVAXcontract.submit{value: _availableAVAX}();
            emit Staked(msg.sender, _availableAVAX);
            return _sAVAXrecieved; //Deposit the baseAsset into the sAvax contract and save in variable amlount of sAVAX shares recieved
        } else {
            return 0; //Return 0 if there is no baseAsset to invest

        }
    }

    /** 
        @notice Allows to harvest staking rewards earned from user's deposit to Benqi.fi sAVAX staking contract. 
        Harvested rewards are sent to the Harvest Manager contract. 
    */
    function harvest() external payable {

        //Amount of rewards that are not harvested (in AVAX)
        uint256 _unharvestedRewards;
        _unharvestedRewards = this.checkAVAXinsAVAX(totalShares) - totalAssets;

         //Check how much of the sAVAX is not harvested (if any)
        if (_unharvestedRewards > 0){
            sAVAXcontract.transfer(harvestManagerAddress, this.checksAVAXinAVAX(_unharvestedRewards));
            emit Harvested(msg.sender, _unharvestedRewards);
        }


    }

    /* ========== HELPER FUNCTIONS ========== */

    /// @notice Converts AVAX to sAVAX
    /// @param _amount Amount of AVAX to convert
    function checkAVAXinsAVAX(uint256 _amount) external view returns (uint256) {
        return sAVAXcontract.getPooledAvaxByShares(_amount);
    }

    /// @notice Converts sAVAX to AVAX
    /// @param _amount Amount of sAVAX to convert
    function checksAVAXinAVAX(uint256 _amount) external view returns (uint256) {
        return sAVAXcontract.getSharesByPooledAvax(_amount);
    }

    /// @notice Standard fallback function that allows contract to recieve native tokens (AVAX)
    receive() external payable {
        this.deposit{value: msg.value}(msg.sender);
    }

    /// @notice Standard fallback function that allows contract to recieve native tokens (AVAX)
    fallback() external payable {
        revert();
    }

    /// @notice Helper function that transfer AVAX to given address, internal, only used in this contract
    /// @param _to Address of the address that will receive AVAX
    /// @param _amount Amount of AVAX to transfer
    function _safeTransfer(address payable _to, uint _amount) internal {
        require(_to != address(0), "Can't transfer to zero address");
        require(_amount <= address(this).balance, "Not enough funds");
        _to.transfer(_amount);
    }


    function checkFallback(address payable to) external returns (bool) {
        // Send 0 AVAX to the target address and check if it reverts
        (bool success,) = to.call{value: 0}("");
        return success;
    }

}

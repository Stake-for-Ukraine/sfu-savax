// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IERC4626.sol';
import 'openzeppelin-contracts/token/ERC20/ERC20.sol';
import './interfaces/IStakedAvax.sol';
import '../lib/forge-std/src/console.sol';

/***
    * @title sAVAXvault
    * @author Oleksii Novykov
    * @notice sAVAXvault is wrapper for Benqi liquid staking (sAVAX). 
    * Users can deposit AVAX or sAVAX and recieve sfuAVAX. Staking rewards 
    * are donated to NGOs supporting Ukraine.
 */

contract SfuAVAXvault is ERC20 {
    /* ========== STATE VARIABLES ========== */
    IStakedAvax public sAVAXcontract;

    /// @notice Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries)
    address payable public harvestManagerAddress;

    /// @notice Address of the sAVAX ERC-20 contract;
    address payable public sAVAXaddress; 

    /// @notice Address of the owner of the contract
    address public owner;

    /// @notice When true means that contract is in emergency mode and deposits are disabled, staking of available AVAX is disabled, withdrawals are enabled.
    bool public emergencyMode;
    
    /// @notice Balances of each individual users in AVAX
    // mapping (address => uint256) public balances; //summary of all deposits minus of all withdrawals for one user;

    /* ========== EVENTS ========== */

    /// @notice Emitted when a user deposits AVAX
    /// @param caller Address of the user who deposited AVAX
    /// @param amount Amount of AVAX deposited
    event Deposit(address caller, uint256 amount);

    /// @notice Emitted when a user withdraws AVAX
    /// @param caller Address of the user who withdrew AVAX
    /// @param receiver Address of the user who received AVAX
    /// @param amount Amount of AVAX withdrawn
    event Withdraw(address caller, address receiver, uint256 amount);

    /// @notice Emitted when harvest function is triggered and staking rewards are harvested
    /// @param caller Address of the user who triggered harvest function
    /// @param amount Amount harvested (in AVAX)
    event Harvested(address caller, uint256 amount);

    /// @notice Emitted when available AVAX is staked
    /// @param caller Address of the user who triggered stake function
    /// @param amount Amount staked (in AVAX)
    event Staked(address caller, uint256 amount);

    /// @notice modifier that is used to restrict access to the function only to the manager;
    modifier onlyOwner() {

        require(msg.sender == owner, "Only owner can call this function.");
        _;

    }


    /// @notice Contract constructor sets initial parameters when contract is deployed.
    /// @param _harvestManagerAddress Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries)
    /// @param _sAVAXaddress Address of the sAVAX ERC-20 contract;
    constructor(address payable _harvestManagerAddress, address payable _sAVAXaddress) ERC20("SFU alfa version", "alfuAVAX") {

        emergencyMode = false;
        sAVAXaddress = _sAVAXaddress;
        sAVAXcontract = IStakedAvax(sAVAXaddress);
        harvestManagerAddress = _harvestManagerAddress;
        owner = msg.sender;

    }

    /* ========== MAIN FUNCTIONALITY ========== */

    /// @notice Allows users to deposit AVAX to the contract and mints sfuAVAX in return
    /// @param _receiver Address of the user who will receive sfuAVAX
    function deposit(address _receiver) external payable returns (uint256 _shares) {
        require(!emergencyMode, "Vault: emergency mode is active");
        require(msg.value > 0, "Amount must be greater than 0");
        require(msg.sender.balance > msg.value, "Vault: deposit amount must be greater than 0");
        require(_receiver != address(0), "Vault: receiver address must be non-zero address");

        // balances[msg.sender] += msg.value;
        _mint(_receiver, msg.value);
        emit Deposit(msg.sender, msg.value);
        return msg.value;
    }

    /// @notice Allows users to withdraw sAVAX from the contract and burns sfuAVAX in return
    /// @param _amount Amount of sfuAVAX to burn
    /// @param _receiver Address of the user who will receive sAVAX
    function withdraw(uint256 _amount, address payable _receiver) external {
        uint256 _sAVAXtoWithdraw;
        require(_receiver != address(0), "Vault: receiver address must be non-zero address");
        require(_amount > 0 && _amount <= this.totalSupply(), "Vault: withdraw amount must be greater than 0 and less than totalSupply");

        if (_amount <= address(this).balance) {
            _receiver.transfer(_amount);
        } else {
            _sAVAXtoWithdraw = this.checkAVAXinsAVAX(_amount);
            // sAVAXcontract.approve(_receiver, _sAVAXtoWithdraw);
            assert(sAVAXcontract.transfer(_receiver, _sAVAXtoWithdraw));
        }

        _burn(msg.sender, _amount);
        emit Withdraw(msg.sender, _receiver, _amount);
    }

    /// @notice Allows users to stake available AVAX in the contract with Benqi.fi sAVAX staking contract
    function stake() external returns (uint256) {

        require(!emergencyMode, "Vault: emergency mode is active");

        /// Check how much of the baseAsset is not invested (if any)
        uint256 _availableAVAX = address(this).balance;

        /// Amount of sAVAX returned from the staking contract after submiting the _availableBaseAsset
        uint256 _sAVAXrecieved;

        if (_availableAVAX > 0){
            _sAVAXrecieved = sAVAXcontract.submit{value: _availableAVAX}();
            emit Staked(msg.sender, _availableAVAX);
            ///Deposit the baseAsset into the sAvax contract and save in variable amlount of sAVAX shares recieved
            return _sAVAXrecieved;
        } else {
            /// Return 0 if there is no baseAsset to invest
            return 0;

        }
    }

    /** 
        @notice Allows to harvest staking rewards earned from staked sAVAX from user's deposits to the vault. 
        Harvested rewards are sent to the Harvest Manager contract. 
    */
    function harvest() external {
        require(!emergencyMode, "Vault: emergency mode is active"); 

        uint256 allAVAX = this.checksAVAXinAVAX(sAVAXcontract.balanceOf(address(this)));

        if (allAVAX > totalSupply()){
            uint256 AVAXToHarvest = allAVAX - totalSupply();
            sAVAXcontract.transfer(harvestManagerAddress, this.checksAVAXinAVAX(AVAXToHarvest));
            emit Harvested(msg.sender, AVAXToHarvest);
        }
    }

    /* ========== MANAGEMENT FUNCTIONS ========== */

    /// @notice Allows Manager to put the vault in shutdown mode. No new deposits are allowed. Withdrawals only.
    function shutdown() external onlyOwner {
        emergencyMode = true;
    }

    /* ========== HELPER FUNCTIONS ========== */

    /// @notice Converts AVAX to sAVAX
    /// @param _amount Amount of AVAX to convert
    function checkAVAXinsAVAX(uint256 _amount) external view returns (uint256) {
        return sAVAXcontract.getSharesByPooledAvax(_amount);
    }

    /// @notice Converts sAVAX to AVAX
    /// @param _amount Amount of sAVAX to convert
    function checksAVAXinAVAX(uint256 _amount) external view returns (uint256) {
        return sAVAXcontract.getPooledAvaxByShares(_amount);
    }

    /// @notice Standard fallback function that allows contract to recieve native tokens (AVAX)
    receive() external payable {
        require(!emergencyMode, "Vault: emergency mode is active");
        this.deposit{value: msg.value}(msg.sender);
    }

    /// @notice Standard fallback function that allows contract to recieve native tokens (AVAX)
    fallback() external payable {
        revert();
    }

    /// @notice The function that owner calls to transfer ownership of the contract.
    /// @param _newOwner The address of the new owner.
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}
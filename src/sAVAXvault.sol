// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interfaces/IERC4626.sol';
import 'openzeppelin-contracts/token/ERC20/ERC20.sol';
import 'BENQI-Smart-Contracts/sAVAX/IStakedAvax.sol';
import '../lib/forge-std/src/console.sol';

contract sAVAXvault is ERC20 {

    event Deposit(address caller, uint256 amount);
    event Withdraw(address caller, address receiver, uint256 amount, uint256 shares);
    event Harvested(address caller, uint256 amount);
    event Staked(address caller, uint256 amount);


    IStakedAvax public sAVAXcontract;
    address payable public distributionAddress; //address of the distribution contract
    address payable public sAVAXaddress; //address of the token that we invest in
    uint256 public totalShares; //summary of all shares for all users
    uint256 public totalAssets; //summary of all deposits minus of all withdrawals
    

    mapping (address => uint256) public totalDeposit; //summary of all deposits minus of all withdrawals for one user;

    constructor(address payable _distributionAddress, address payable _sAVAXaddress) ERC20("Vault", "VLT") {
        sAVAXaddress = _sAVAXaddress;
        sAVAXcontract = IStakedAvax(sAVAXaddress);
        distributionAddress = _distributionAddress;

        totalAssets = 0;
        totalShares = 0;
    }

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

    function harvest() external payable {

        uint256 _unharvestedRewards; //Amount of rewards that are not harvested

        _unharvestedRewards = this.checkAVAXinsAVAX(totalShares) - totalAssets; //this is AVAX

         //Check how much of the sAVAX is not harvested (if any)
        if (_unharvestedRewards > 0){
            sAVAXcontract.transfer(distributionAddress, this.checksAVAXinAVAX(_unharvestedRewards));
            emit Harvested(msg.sender, _unharvestedRewards);
        }


    }

    function checkAVAXinsAVAX(uint256 _amount) external view returns (uint256) {
        return sAVAXcontract.getPooledAvaxByShares(_amount);
    }

    function checksAVAXinAVAX(uint256 _amount) external view returns (uint256) {
        return sAVAXcontract.getSharesByPooledAvax(_amount);
    }

    receive() external payable {
        this.deposit{value: msg.value}(msg.sender);
    }

    fallback() external payable {
        revert();
    }

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'openzeppelin-contracts/token/ERC20/ERC20.sol';
import './interfaces/IStakedAvax.sol';
import '../lib/forge-std/src/console.sol';

/**
    * @title sAVAXvault
    * @author Oleksii Novykov
    * @notice sfuAVAX is a vault that allows users to deposit AVAX that will be staked with sAVAX contract fron Benqi.fi
    * And in return users will receive sfuAVAX tokens that represent their share of the total staked AVAX.
    * 100% of the staking rewards will be harvested and donated to charities active in Ukraine. 
    * The list of beneficieries is decided by multisig signers in the beginning, and governance in the future. 
    * The contract is immutable and owner of the contract does not have access to user's deposits. 
    * Users can withdraw their stake at any time in the form of AVAX or sAVAX (depends on availability).
 */

contract SfuAVAXvault is ERC20 {

    IStakedAvax public sAVAXcontract;

    /**
        @notice Address of the Harvest Manager - contract that recieves harvested rewards and swaps / disitirbutes 
        them to beneficiaries, according to active strategies logic.
    */
    address payable public harvestManagerAddress;

    /// @notice Address of the sAVAX ERC-20 contract;
    address payable public sAVAXaddress; 

    /// @notice Address of the owner of the contract
    address public owner;

    /// @notice When true means that contract is in emergency mode and deposits are disabled, staking of available AVAX is disabled, withdrawals are enabled.
    bool public emergencyMode;

    /**  
        @notice Emitted when a user deposits AVAX
        @param caller Address of the user who deposited AVAX
        @param amount Amount of AVAX deposited
    */
    event Deposit(address caller, uint256 amount);

    /**
        @notice Emitted when a user withdraws AVAX
        @param caller Address of the user who withdrew AVAX
        @param receiver Address of the user who received AVAX
        @param amount Amount of AVAX withdrawn
    */
    event Withdraw(address caller, address receiver, uint256 amount);

    /**
        @notice Emitted when harvest function is triggered and staking rewards are harvested
        @param caller Address of the user who triggered harvest function
        @param amount Amount harvested (in AVAX)
    */
    event Harvested(address caller, uint256 amount);

    /**
        @notice Emitted when available AVAX is staked
        @param caller Address of the user who triggered stake function
        @param amount Amount staked (in AVAX)
    */
    event Staked(address caller, uint256 amount);

    /**
        @notice Emitted when emergency mode is switched
        @param emergencyMode Boolean value of the emergencyMode
    */
    event EmergencyModeSwitched(bool emergencyMode);

    /**
        @notice Emitted when owner is updated;
        @param oldOwner Address of the old owner;
        @param newOwner Address of the new owner;
    */
    event OwnerUpdated(address oldOwner, address newOwner);
    
    /** 
        @notice Emitted when Harvest Manager address is updated;
        @param oldHarvestManagerAddress Address of the old Harvest Manager;
        @param newHarvestManagerAddress Address of the new Harvest Manager;
    */
    event HarvestManagerAddressUpdated(address oldHarvestManagerAddress, address newHarvestManagerAddress);

    /**
        @notice Emitted whenowner sweeps the remaining sAVAX after all users withdraw their deposits
        @param _amount Amount of sAVAX swept.
    */
    event Sweep(uint256 _amount);

    /// @notice Modifier that is used to restrict access to the function only to the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }


    /** 
        @notice Contract constructor sets initial parameters when contract is deployed.
        @param _harvestManagerAddress Address of the Harvest Manager - contract that recieves harvested rewards 
        and disitirbutes them to beneficiaries.
        @param _sAVAXaddress Address of the sAVAX ERC-20 contract;
    */
    constructor(address payable _harvestManagerAddress, address payable _sAVAXaddress) ERC20("Stake for Ukraine AVAX", "sfuAVAX") {
        emergencyMode = false;
        sAVAXaddress = _sAVAXaddress;
        sAVAXcontract = IStakedAvax(sAVAXaddress);
        harvestManagerAddress = _harvestManagerAddress;
        owner = msg.sender;
    }

    /**
        @notice Allows users to deposit AVAX to the contract and mints sfuAVAX in return.
        @param _receiver Address of the user who will receive sfuAVAX.
    */
    function deposit(address _receiver) external payable returns (uint256 _shares) {
        require(!emergencyMode, "Vault: emergency mode is active");
        require(msg.value > 0, "Amount must be greater than 0");
        require(msg.sender.balance > msg.value, "Vault: deposit amount must be greater than 0");
        require(_receiver != address(0), "Vault: receiver address must be non-zero address");

        _mint(_receiver, msg.value);
        emit Deposit(msg.sender, msg.value);
        return msg.value;
    }

    /** 
        @notice Allows users to withdraw sAVAX from the contract and burns sfuAVAX in return. If vault does not have enough AVAX, 
        it will withdraw sAVAX from the staking contract.
        @param _amount Amount of AVAX/sAVAX user wants to withdraw.
        @param _receiver Address of the user who will receive AVAX or sAVAX.
    */
    function withdraw(uint256 _amount, address payable _receiver) external {
        uint256 _sAVAXtoWithdraw;
        require(_receiver != address(0), "Vault: receiver address must be non-zero address");
        require(_amount > 0 && _amount <= this.totalSupply(), "Vault: withdraw amount must be greater than 0 and less than totalSupply");

        if (_amount <= address(this).balance) {
            _receiver.transfer(_amount);
        } else {
            _sAVAXtoWithdraw = sAVAXcontract.getSharesByPooledAvax(_amount);
            // sAVAXcontract.approve(_receiver, _sAVAXtoWithdraw);
            assert(sAVAXcontract.transfer(_receiver, _sAVAXtoWithdraw));
        }

        _burn(msg.sender, _amount);
        emit Withdraw(msg.sender, _receiver, _amount);
    }

    /// @notice Allows users to stake available AVAX in the contract with Benqi.fi sAVAX staking contract.
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

        uint256 allAVAX = sAVAXcontract.getPooledAvaxByShares(sAVAXcontract.balanceOf(address(this)));

        if (allAVAX > totalSupply()){
            uint256 AVAXToHarvest = allAVAX - totalSupply();
            sAVAXcontract.transfer(harvestManagerAddress, sAVAXcontract.getPooledAvaxByShares(AVAXToHarvest));
            emit Harvested(msg.sender, AVAXToHarvest);
        }
    }

    /** 
        @notice Because sAVAX is non-rebasing token, it is possible that some breadcrumbs of sAVAX are left in the contract
        after all users withdraw their deposits. This function allows for the owner to make a clean up and transfer this remainders 
        to the Harvest Manager so they can be donated as well.
    */
    function sweep() external onlyOwner {
        require(totalSupply() == 0, "Vault: outstanding totalSupply must be 0");
        emit Sweep(sAVAXcontract.balanceOf(address(this)));
        sAVAXcontract.transfer(harvestManagerAddress, sAVAXcontract.balanceOf(address(this)));
    }

    /** 
        @notice Allows owner to put the vault in an emergency mode. No new deposits are allowed. Withdrawals only. 
        The onwer can turn the emergency mode off.
    */
    function emergencyModeSwitch() external onlyOwner {
        if (emergencyMode == false) {
            emergencyMode = true;
        } else {
            emergencyMode = false;
        }
        emit EmergencyModeSwitched(emergencyMode);
    }


    /// @notice Standard fallback function that allows contract to recieve native tokens (AVAX). Sending AVAX to the contract will deposit it, same as calling deposit().
    receive() external payable {
        require(!emergencyMode, "Vault: emergency mode is active");
        this.deposit{value: msg.value}(msg.sender);
    }

    /// @notice Standard fallback function that allows contract to recieve native tokens (AVAX)
    fallback() external payable {
        revert();
    }

    /**
        @notice The function that owner calls to transfer ownership of the contract to the new owner.
        @param _newOwner The address of the new owner.
    */
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit OwnerUpdated(msg.sender, _newOwner);
    }

    /**
        @notice The function that owner calls to change the address of the Harvest Manager contract.
        @param _newHarvestManagerAddress The address of the new Harvest Manager contract.
    */
    function changeHarvestManagerAddress(address payable _newHarvestManagerAddress) external onlyOwner {
        address _oldHarvestManagerAddress = harvestManagerAddress;
        harvestManagerAddress = _newHarvestManagerAddress;
        emit HarvestManagerAddressUpdated(_oldHarvestManagerAddress, _newHarvestManagerAddress);
    }
}
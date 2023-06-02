# SfuAVAXvault
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/4abe733a8bb81cbd2da7e5ae098ba601cebf8962/src/SfuAVAXvault.sol)

**Inherits:**
ERC20

**Author:**
Oleksii Novykov

sfuAVAX is a vault that allows users to deposit AVAX that will be staked with sAVAX contract fron Benqi.fi
And in return users will receive sfuAVAX tokens that represent their share of the total staked AVAX.
100% of the staking rewards will be harvested and donated to charities active in Ukraine.
The list of beneficieries is decided by multisig signers in the beginning, and governance in the future.
The contract is immutable and owner of the contract does not have access to user's deposits.
Users can withdraw their stake at any time in the form of AVAX or sAVAX (depends on availability).


## State Variables
### sAVAXcontract

```solidity
IStakedAvax public sAVAXcontract;
```


### harvestManagerAddress
Address of the Harvest Manager - contract that recieves harvested rewards and swaps / disitirbutes
them to beneficiaries, according to active strategies logic.


```solidity
address payable public harvestManagerAddress;
```


### sAVAXaddress
Address of the sAVAX ERC-20 contract;


```solidity
address payable public sAVAXaddress;
```


### owner
Address of the owner of the contract


```solidity
address public owner;
```


### emergencyMode
When true means that contract is in emergency mode and deposits are disabled, staking of available AVAX is disabled, withdrawals are enabled.


```solidity
bool public emergencyMode;
```


## Functions
### onlyOwner

Modifier that is used to restrict access to the function only to the owner of the contract.


```solidity
modifier onlyOwner();
```

### constructor

Contract constructor sets initial parameters when contract is deployed.


```solidity
constructor(address payable _harvestManagerAddress, address payable _sAVAXaddress)
    ERC20("SFU alfa version", "alfuAVAX");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_harvestManagerAddress`|`address payable`|Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries.|
|`_sAVAXaddress`|`address payable`|Address of the sAVAX ERC-20 contract;|


### deposit

Allows users to deposit AVAX to the contract and mints sfuAVAX in return.


```solidity
function deposit(address _receiver) external payable returns (uint256 _shares);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receiver`|`address`|Address of the user who will receive sfuAVAX.|


### withdraw

Allows users to withdraw sAVAX from the contract and burns sfuAVAX in return. If vault does not have enough AVAX,
it will withdraw sAVAX from the staking contract.


```solidity
function withdraw(uint256 _amount, address payable _receiver) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of AVAX/sAVAX user wants to withdraw.|
|`_receiver`|`address payable`|Address of the user who will receive AVAX or sAVAX.|


### stake

Allows users to stake available AVAX in the contract with Benqi.fi sAVAX staking contract.


```solidity
function stake() external returns (uint256);
```

### harvest

Check how much of the baseAsset is not invested (if any)
Amount of sAVAX returned from the staking contract after submiting the _availableBaseAsset
Deposit the baseAsset into the sAvax contract and save in variable amlount of sAVAX shares recieved
Return 0 if there is no baseAsset to invest

Allows to harvest staking rewards earned from staked sAVAX from user's deposits to the vault.
Harvested rewards are sent to the Harvest Manager contract.


```solidity
function harvest() external;
```

### sweep

Because sAVAX is non-rebasing token, it is possible that some breadcrumbs of sAVAX are left in the contract
after all users withdraw their deposits. This function allows for the owner to make a clean up and transfer this remainders
to the Harvest Manager so they can be donated as well.


```solidity
function sweep() external onlyOwner;
```

### emergencyModeSwitch

Allows owner to put the vault in an emergency mode. No new deposits are allowed. Withdrawals only.
The onwer can turn the emergency mode off.


```solidity
function emergencyModeSwitch() external onlyOwner;
```

### receive

Standard fallback function that allows contract to recieve native tokens (AVAX). Sending AVAX to the contract will deposit it, same as calling deposit().


```solidity
receive() external payable;
```

### fallback

Standard fallback function that allows contract to recieve native tokens (AVAX)


```solidity
fallback() external payable;
```

### changeOwner

The function that owner calls to transfer ownership of the contract to the new owner.


```solidity
function changeOwner(address _newOwner) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|The address of the new owner.|


### changeHarvestManagerAddress

The function that owner calls to change the address of the Harvest Manager contract.


```solidity
function changeHarvestManagerAddress(address payable _newHarvestManagerAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newHarvestManagerAddress`|`address payable`|The address of the new Harvest Manager contract.|


## Events
### Deposit
Emitted when a user deposits AVAX


```solidity
event Deposit(address caller, uint256 amount);
```

### Withdraw
Emitted when a user withdraws AVAX


```solidity
event Withdraw(address caller, address receiver, uint256 amount);
```

### Harvested
Emitted when harvest function is triggered and staking rewards are harvested


```solidity
event Harvested(address caller, uint256 amount);
```

### Staked
Emitted when available AVAX is staked


```solidity
event Staked(address caller, uint256 amount);
```

### EmergencyModeSwitched
Emitted when emergency mode is switched


```solidity
event EmergencyModeSwitched(bool emergencyMode);
```

### OwnerUpdated
Emitted when owner is updated;


```solidity
event OwnerUpdated(address oldOwner, address newOwner);
```

### HarvestManagerAddressUpdated
Emitted when Harvest Manager address is updated;


```solidity
event HarvestManagerAddressUpdated(address oldHarvestManagerAddress, address newHarvestManagerAddress);
```

### Sweep
Emitted whenowner sweeps the remaining sAVAX after all users withdraw their deposits


```solidity
event Sweep(uint256 _amount);
```


# DistributeStrategy1
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/1e5f9b7d7b2ef6672dfad852e7feb508635caac7/src/strategies/DistributeStrategy1.sol)

**Inherits:**
[IdistStrategy](/src/interfaces/IdistStrategy.sol/contract.IdistStrategy.md)

DistributeStrategy1 contract is an execution contract that is used by Harvest Manager to distribute funds to beneficiaries.


## State Variables
### beneficiaries
Array of addresses of beneficiaries who recieve funding


```solidity
address[] public beneficiaries;
```


### percentages
Array of percentages of how available funds should be splitted between beneficiaries

*Percentages must be between 0 and 100. Sum of percentages must be equal to 100.*


```solidity
uint8[] public percentages;
```


### manager
Address of the owner of the contract


```solidity
address public manager;
```


## Functions
### onlyManager

modifier that is used to restrict access to the function only to the manager;


```solidity
modifier onlyManager();
```

### constructor

Contract constructor.


```solidity
constructor(address _manager, address[] memory _beneficiaries, uint8[] memory _percentages);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_manager`|`address`||
|`_beneficiaries`|`address[]`|Array of addresses of beneficiaries who recieve funding|
|`_percentages`|`uint8[]`|Array of percentages of how available funds should be splitted between beneficiaries|


### distribute

Function that is called by Harvest Manager to distribute funds to beneficiaries.


```solidity
function distribute(address _distributionToken) external onlyManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_distributionToken`|`address`|Address of the ERC-20 token that is distributed|


## Events
### Distribute
Event emitted when funds are distributed to beneficiaries


```solidity
event Distribute(address indexed _distributionToken, uint256 _amount);
```

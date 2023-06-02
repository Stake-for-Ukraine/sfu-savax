# DistributeToTreasury
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/03270bceaef27c69d5d3d7e923812533ffff9ed9/src/strategies/TempStrat.sol)

**Inherits:**
[IDistributionStrategy](/src/interfaces/IDistributionStrategy.sol/contract.IDistributionStrategy.md)

DistributeStrategy1 contract is an execution contract that is used by Harvest harvestManager to distribute funds to beneficiaries.


## State Variables
### treasuryAddress
Address of the treasury where sAVAX will be sent fot future distribution to beneficiaries


```solidity
address public treasuryAddress;
```


### harvestManager
Address of the owner of the contract


```solidity
address public harvestManager;
```


### sAVAXAddress
sAVAX address


```solidity
address public sAVAXAddress;
```


## Functions
### onlyHarvestManager

modifier that is used to restrict access to the function only to the harvestManager;


```solidity
modifier onlyHarvestManager();
```

### constructor

Contract constructor.


```solidity
constructor(address _harvestManager, address _sAVAXAddress, address _treasuryAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_harvestManager`|`address`|Address of the HarvestharvestManager of the contract|
|`_sAVAXAddress`|`address`|Address of the sAVAX token|
|`_treasuryAddress`|`address`|Address of the treasury where sAVAX will be sent fot future distribution to beneficiaries|


### distribute

Function that is called by Harvest harvestManager to send sAVAX (or any other token) to the treasury


```solidity
function distribute(address _distributionToken) external onlyHarvestManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_distributionToken`|`address`|Address of the ERC-20 token that is distributed|


## Events
### SentToTreasury
Event emitted when funds are distributed to beneficiaries


```solidity
event SentToTreasury(address treasuryAddress, uint256 _amount);
```


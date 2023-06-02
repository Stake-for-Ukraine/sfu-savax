# DistributeToTreasury
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/4abe733a8bb81cbd2da7e5ae098ba601cebf8962/src/strategies/TempStrat.sol)

**Inherits:**
[IDistributionStrategy](/src/interfaces/IDistributionStrategy.sol/contract.IDistributionStrategy.md)

DistributeToTreasury contract is an execution contract that is used by Harvest Manager.
This is a simplified version of the strategy that is used to distribute funds to the treasury. Treasury is a multi-sig wallet.
While there is some risk in using a multi-sig wallet, it is a temporary solution until governenace is implemented
and more sofisiticated harvest management strategies are developed. It is important to mention, that only harvested
rewards are collected in the treasury. User's deposits are stored in the vault and nor multi-sig,
nor future governance will not be able to acces those funds.


## State Variables
### treasuryAddress
Address of the treasury where sAVAX will be sent fot future distribution to beneficiaries.


```solidity
address public treasuryAddress;
```


### harvestManager
Address of the owner of the contract.


```solidity
address public harvestManager;
```


### sAVAXAddress
sAVAX address.


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
|`_harvestManager`|`address`|Address of the Harvest Manager contract.|
|`_sAVAXAddress`|`address`|Address of the sAVAX token contract.|
|`_treasuryAddress`|`address`|Address of the treasury where sAVAX will be sent fot future distribution to beneficiaries|


### distribute

Function that is called by Harvest Manager to send sAVAX (or any other token) to the treasury.


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


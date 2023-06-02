# HarvestManager
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/03270bceaef27c69d5d3d7e923812533ffff9ed9/src/HarvestManager.sol)

HarvetsManager is a proxy contract. Unlike the vault contract that is immutable,
Manager is an upgradable contract owned by governance. When called, it will call the execution function
on the implementation contract.

*Swap and distribute strategies are stored in the /strategies folder. Since this contract supports swaping any WRC-20 tokens,
it is required to provide address of both tokens (in and out) to perform a swap.*


## State Variables
### owner
The owner of the contract. It can be changed by calling changeOwner() function.


```solidity
address public owner;
```


### activeSwapStrategyAddress
The address of the active swap strategy. It can be changed by calling updateSwapStrategy() function.


```solidity
address public activeSwapStrategyAddress;
```


### activeDistributeStrategyAddress
The address of the active distributing strategy. It can be changed by calling updateDistributeStrategy() function.


```solidity
address public activeDistributeStrategyAddress;
```


## Functions
### constructor


```solidity
constructor();
```

### onlyOwner

Modifier to check if the caller is the owner of the contract.


```solidity
modifier onlyOwner();
```

### swap

The function that users (keepers) call to swap harvested yield for an assets suitable for donation (e.g. stablecoin). This contract doesn't have a logic to exscute transfer. Instead, it calls the swap function on the active swap strategy contract.


```solidity
function swap(address _token0, address _token1, ISwapStrategy) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0`|`address`|The address of the token that is swapped (usually sAVAX, but also can be used to swap any other ERC-20 tokens sent to manager by mistake).|
|`_token1`|`address`|The address of the token that is received after swap (e.g. USDC)|
|`<none>`|`ISwapStrategy`||


### distribute

The function that users (keepers) call to distribute harvested yield to beneficiaries after it was swapped to more stable asset (e.g. stablecoin). This contract doesn't have a logic to exscute transfer. Instead, it calls the distribute function on the active distribute strategy contract.


```solidity
function distribute(address _distributionToken) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_distributionToken`|`address`|The address of the token that is distributed (usually USDC, but also can be used to distribute any other ERC-20 tokens sent to manager by mistake).|


### updateSwapStrategy

The function to update the address of the active swap strategy.


```solidity
function updateSwapStrategy(address _newSwapStrategyAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newSwapStrategyAddress`|`address`|The address of the new swap strategy contract.|


### updateDistributeStrategy

The function that owner calls to update the address of the active distribution strategy.


```solidity
function updateDistributeStrategy(address _newDistributeStrategyAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newDistributeStrategyAddress`|`address`|The address of the new distribution strategy contract.|


### changeOwner

The function that owner calls to transfer ownership of the contract.


```solidity
function changeOwner(address _newOwner) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|The address of the new owner.|


## Events
### Swap
The event emitted when swap function is called.


```solidity
event Swap(address _token0, address _token1, uint256 _amount, address _swapStrategy);
```

### Distribute
The event emitted when distribute function is called.


```solidity
event Distribute(address _distributionToken, uint256 _amount);
```


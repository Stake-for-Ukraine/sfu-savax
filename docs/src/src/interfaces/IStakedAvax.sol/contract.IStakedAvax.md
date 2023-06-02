# IStakedAvax
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/4abe733a8bb81cbd2da7e5ae098ba601cebf8962/src/interfaces/IStakedAvax.sol)

**Inherits:**
IERC20Upgradeable


## Functions
### getSharesByPooledAvax


```solidity
function getSharesByPooledAvax(uint256 avaxAmount) external view returns (uint256);
```

### getPooledAvaxByShares


```solidity
function getPooledAvaxByShares(uint256 shareAmount) external view returns (uint256);
```

### submit


```solidity
function submit() external payable returns (uint256);
```

### totalPooledAvax


```solidity
function totalPooledAvax() external returns (uint256);
```


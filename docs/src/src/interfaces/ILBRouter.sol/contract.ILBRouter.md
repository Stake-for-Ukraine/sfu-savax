# ILBRouter
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/1e5f9b7d7b2ef6672dfad852e7feb508635caac7/src/interfaces/ILBRouter.sol)


## Functions
### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    uint256[] memory pairBinSteps,
    IERC20[] memory tokenPath,
    address to,
    uint256 deadline
) external returns (uint256 amountOut);
```

### getSwapOut


```solidity
function getSwapOut(ILBPair LBPair, uint256 amountIn, bool swapForY)
    external
    view
    returns (uint256 amountOut, uint256 feesIn);
```


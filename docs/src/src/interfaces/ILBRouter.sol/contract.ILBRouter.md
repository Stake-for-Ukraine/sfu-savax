# ILBRouter
<<<<<<< Updated upstream
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/eca56343487ca867355097dbb6758c96361fe876/src/interfaces/ILBRouter.sol)
=======
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/855c70d84d498aafbcd341621f3e2d0d874da8ba/src/interfaces/ILBRouter.sol)
>>>>>>> Stashed changes


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


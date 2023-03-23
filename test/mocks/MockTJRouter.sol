// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import '../../src/interfaces/ILBRouter.sol';
import '../../src/interfaces/ILBPair.sol';
import './MockERC20.sol';

contract MockTJRouter is ILBRouter{

    IERC20 public USDC;

    function getSwapOut(
        ILBPair LBPair,
        uint256 amountIn,
        bool swapForY
    ) external view returns (uint256 amountOut, uint256 feesIn) {
        amountOut = amountIn;
        feesIn = 30000000000;
    }

    function swapExactTokensForTokens(
        
        uint256 amountIn,
        uint256 amountOutMin,
        uint256[] memory pairBinSteps,
        IERC20[] memory tokenPath,
        address to,
        uint256 deadline

    ) external returns (uint256 amountOut) {
        
        USDC = tokenPath[1];
        amountOut = amountOutMin;
        USDC.transferFrom(address(this), to, amountOut);

    }
}
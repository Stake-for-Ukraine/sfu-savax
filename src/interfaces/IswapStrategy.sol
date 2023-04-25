// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ISwapStrategy {
    function swap(uint256 amount, address token0, address token1) external returns (uint256 amountOutReal);
}
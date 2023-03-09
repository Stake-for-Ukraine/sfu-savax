// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Quote {
    address[] route;
    address[] pairs;
    uint256[] binSteps;
    uint256[] amounts;
    uint256[] virtualAmountsWithoutSlippage;
    uint256[] fees;
}

interface ILBQuoter {
    function findBestPathFromAmountIn(
        address[] calldata _route,
        uint256 _amountIn
    ) external view returns (Quote memory quote);
}
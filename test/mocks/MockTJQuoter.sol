// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import '../../src/interfaces/ILBQuoter.sol';


contract MockTJQuoter {

    function findBestPathFromAmountIn(
        address[] calldata _route,
        uint256 _amountIn
    ) external pure returns (Quote memory quote) {
        quote.route = _route;
        quote.pairs = new address[](1);
        quote.binSteps = new uint256[](1);
        quote.amounts = new uint256[](1);
        quote.pairs[0] = 0x2EE9555962d3757c3083924381D6e227638Bc843;
        quote.binSteps[0] = 0;
        quote.amounts[0] = _amountIn;
    }
}
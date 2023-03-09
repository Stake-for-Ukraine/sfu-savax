// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '../../lib/forge-std/src/console.sol';

contract MockDistribution {
    receive() external payable {
        //uint256 amount = msg.value;
        //console.log("Received ", amount, " AVAX");
     }

    fallback() external payable {
        revert();
    }

}
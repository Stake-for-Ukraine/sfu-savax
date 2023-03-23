// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '../../src/interfaces/IStakedAvax.sol';
import 'openzeppelin-contracts/token/ERC20/ERC20.sol';
import '../../lib/forge-std/src/console.sol';

contract MockLSDVault is ERC20 {
    constructor() ERC20 ("Mock StakedAvax", "sAVAX") {
        
    }

    function getSharesByPooledAvax(uint avaxAmount) external pure returns (uint) {
        return avaxAmount;
    }

    function getPooledAvaxByShares(uint shareAmount) external pure returns (uint) {
        return shareAmount + 10;
    }

    function submit() external payable returns (uint256) {
        address sender = msg.sender;
        uint256 amount = msg.value;


        require(amount != 0, "ZERO_DEPOSIT");

        _mint(sender, amount);

        return amount;

    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    receive() external payable {
        uint256 amount = msg.value;
        console.log("Received ", amount, " AVAX");
    }

    fallback() external payable {
        revert();
    }
}
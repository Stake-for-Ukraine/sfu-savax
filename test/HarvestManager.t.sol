// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarvestManager.sol";
import "../src/strategies/SwapStrategy1.sol";
import "./mocks/MockLSDVault.sol";
import "./mocks/MockERC20.sol";

contract HarvestManagerTest is Test {
    HarvestManager public harvestManager;
    SwapStrategy1 public swapStrategy1;
    MockLSDVault public mockLSDVault;
    MockERC20 public USDC;

    function setUp() public {
        harvestManager = new HarvestManager();
        swapStrategy1 = new SwapStrategy1();
        mockLSDVault = new MockLSDVault();
        USDC = new MockERC20();
    }

    //test that we can swap sAVAX to some asset, e.g. stablecoin
    function testSwap() public {
        mockLSDVault.mint(address(harvestManager), 100);
        USDC.approve(address(harvestManager), 100);
        harvestManager.swap(address(mockLSDVault), address(USDC), swapStrategy1);
        
        assertEq(mockLSDVault.balanceOf(address(harvestManager)), 0);
        assertEq(USDC.balanceOf(address(swapStrategy1)), 100);
    }


}
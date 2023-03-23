// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarvestManager.sol";
import "../src/strategies/SwapStrategy1.sol";
import "../src/strategies/DistributeStrategy1.sol";
import "./mocks/MockLSDVault.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockTJQuoter.sol";
import "./mocks/MockTJRouter.sol";

contract HarvestManagerTest is Test {
    HarvestManager public harvestManager;
    SwapStrategy1 public swapStrategy1;
    MockLSDVault public mockLSDVault;
    MockERC20 public USDC;
    MockTJQuoter public mockTJQuoter;
    MockTJRouter public mockTJRouter;

    function setUp() public {
        harvestManager = new HarvestManager();
        mockTJQuoter = new MockTJQuoter();
        mockTJRouter = new MockTJRouter();
        swapStrategy1 = new SwapStrategy1(address(harvestManager), address(mockTJRouter), address(mockTJQuoter));
        mockLSDVault = new MockLSDVault();
        USDC = new MockERC20();
    }

    //test that we can swap sAVAX to some asset, e.g. stablecoin
    function testSwap() public {

        harvestManager.updateSwapStrategy(address(swapStrategy1));
        mockLSDVault.mint(address(harvestManager), 100);
        USDC.mint(address(mockTJRouter), 100);
        USDC.approve(address(harvestManager), 100);
        harvestManager.swap(address(mockLSDVault), address(USDC), swapStrategy1);
        
        assertEq(mockLSDVault.balanceOf(address(harvestManager)), 0);
        assertEq(USDC.balanceOf(address(harvestManager)), 99);
    }
}
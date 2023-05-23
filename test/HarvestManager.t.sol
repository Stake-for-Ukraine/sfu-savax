// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarvestManager.sol";
import "./mocks/MockLSDVault.sol";
import "./mocks/MockERC20.sol";
import {DistributeToTreasury} from "../src/strategies/TempStrat.sol";

contract HarvestManagerTest is Test {
    HarvestManager public harvestManager;
    MockLSDVault public mockLSDVault;
    MockERC20 public USDC;
    DistributeToTreasury public distributeToTreasury;

    address[] beneficiaries = new address[](2);
    uint8[] percentages = new uint8[](2);

    function setUp() public {
        harvestManager = new HarvestManager();
        mockLSDVault = new MockLSDVault();
        USDC = new MockERC20();
    }

    function testDistribution() public {
        distributeToTreasury = new DistributeToTreasury(address(harvestManager), address(USDC), address (mockLSDVault));
        harvestManager.updateDistributeStrategy(address(distributeToTreasury));
        mockLSDVault.mint(address(harvestManager), 100);
        
    }
}
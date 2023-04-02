// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../test/mocks/MockERC20.sol";
import "../test/mocks/MockLSDVault.sol";
import "../test/mocks/MockTJQuoter.sol";
import "../test/mocks/MockTJRouter.sol";
import "../src/HarvestManager.sol";
import "../src/strategies/SwapStrategy1.sol";
import "../src/strategies/DistributeStrategy1.sol";



contract SFUScript is Script {

    //HarvestManager public harvestManager;
    //SwapStrategy1 public swapStrategy1;
    //DistributeStrategy1 public distributeStrategy1;
    MockERC20 public USDC;
    MockLSDVault public mockLSDVault;
    MockTJQuoter public mockTJQuoter;
    MockTJRouter public mockTJRouter;
    HarvestManager public harvestManager;
    SwapStrategy1 public swapStrategy1;
    DistributeStrategy1 public distributeStrategy1;


    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        USDC = new MockERC20();
        mockLSDVault = new MockLSDVault();

        harvestManager = new HarvestManager();
        mockTJQuoter = new MockTJQuoter();
        mockTJRouter = new MockTJRouter();
        swapStrategy1 = new SwapStrategy1(address(harvestManager), address(mockTJRouter), address(mockTJQuoter));
        distributeStrategy1 = new DistributeStrategy1(address(harvestManager), beneficiaries, percentages);
        mockLSDVault = new MockLSDVault();

        vm.stopBroadcast();
        
}

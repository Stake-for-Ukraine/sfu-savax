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
import "../src/SfuAVAXvault.sol";
import "../src/strategies/TempStrat.sol";

contract SFUScript is Script {

    MockERC20 public USDC;
    MockLSDVault public mockLSDVault;
    MockTJQuoter public mockTJQuoter;
    MockTJRouter public mockTJRouter;
    SfuAVAXvault public vault;
    HarvestManager public harvestManager;
    SwapStrategy1 public swapStrategy1;
    DistributeToTreasury public distributeToTreasury;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address[] memory beneficiaries = new address[](2);
        uint8[] memory percentages = new uint8[](2);

        beneficiaries[0] = vm.envAddress("BENEFICIARY1");
        beneficiaries[1] = vm.envAddress("BENEFICIARY2");
        
        percentages[0] = 50;
        percentages[1] = 50;


        vm.startBroadcast(deployerPrivateKey);

        USDC = new MockERC20();
        mockLSDVault = new MockLSDVault();
        mockTJQuoter = new MockTJQuoter();
        mockTJRouter = new MockTJRouter();
        harvestManager = new HarvestManager();
        vault = new SfuAVAXvault(payable(address(harvestManager)), payable(address(mockLSDVault)));
        
        swapStrategy1 = new SwapStrategy1(address(harvestManager), address(mockTJRouter), address(mockTJQuoter));
        distributeToTreasury = new DistributeToTreasury(0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9, 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512, 0x90F79bf6EB2c4f870365E785982E1f101E93b906);

        vm.stopBroadcast();
        
    }

}
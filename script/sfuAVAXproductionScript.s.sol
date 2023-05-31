// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/HarvestManager.sol";
import "../src/SfuAVAXvault.sol";
import "../src/strategies/TempStrat.sol";

contract SFUScript is Script {
    SfuAVAXvault public vault;
    HarvestManager public harvestManager;
    DistributeToTreasury public distributeToTreasury;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        harvestManager = new HarvestManager();
        distributeToTreasury = new DistributeToTreasury(address(harvestManager), 0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE, 0xf6Df9dcF3e3D07437e3e583d1cC41d9C8FB53Ae8);
        vault = new SfuAVAXvault (payable(address(harvestManager)), payable(0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE));
        harvestManager.updateDistributeStrategy(address(distributeToTreasury));

        vm.stopBroadcast();
    }
}
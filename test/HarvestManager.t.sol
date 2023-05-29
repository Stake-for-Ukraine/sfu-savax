// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarvestManager.sol";
import "../src/interfaces/IStakedAvax.sol";
import {DistributeToTreasury} from "../src/strategies/TempStrat.sol";

contract HarvestManagerTest is Test {
    HarvestManager public harvestManager;
    DistributeToTreasury public distributeToTreasury;
    IStakedAvax public sAVAXcontract;

    address payable public sAVAXaddress;
    address payable public treasuryAddress;

    function setUp() public {
        uint256 forkId = vm.createFork("mainnet");
        vm.selectFork(forkId);


        sAVAXaddress = payable(0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE);
        treasuryAddress = payable(0xf6Df9dcF3e3D07437e3e583d1cC41d9C8FB53Ae8);
        sAVAXcontract = IStakedAvax(sAVAXaddress);

        harvestManager = new HarvestManager();
        distributeToTreasury = new DistributeToTreasury(address(harvestManager), sAVAXaddress, treasuryAddress);
    }

    function testDistribution() public {
        harvestManager.updateDistributeStrategy(address(distributeToTreasury));
        console.log("my AVAX balance:", address(this).balance);
        sAVAXcontract.submit{value: 100 ether}();
        console.log("my AVAX balance:", address(this).balance);
        console.log("my sAVAX balance:", sAVAXcontract.balanceOf(address(this)));
        sAVAXcontract.transfer(address(harvestManager), 100);
        harvestManager.distribute(sAVAXaddress);

        assertEq(sAVAXcontract.balanceOf(address(harvestManager)), 0);
        assertEq(sAVAXcontract.balanceOf(address(distributeToTreasury)), 0);
        require (sAVAXcontract.balanceOf(treasuryAddress) > 0);
    }

}
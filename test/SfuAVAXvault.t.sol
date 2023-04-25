// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SfuAVAXvault.sol";
import './mocks/MockERC20.sol';
import './mocks/MockLSDVault.sol';
import './mocks/MockDist.sol';
import '../lib/forge-std/src/console.sol';


contract VaultTest is Test {
    SfuAVAXvault public vault;
    MockERC20 public mockToken;
    MockLSDVault public mockLSDVault;
    MockDistribution public mockDistribution;

    address payable public mockLSDVaultAddress;
    address payable public mockDistAddress;

    function setUp() public {
        mockToken = new MockERC20();
        mockLSDVault = new MockLSDVault();
        mockDistribution = new MockDistribution();
        mockLSDVaultAddress = payable(address(mockLSDVault));
        mockDistAddress = payable(address(mockDistribution));
        vault = new SfuAVAXvault(mockDistAddress, mockLSDVaultAddress);
    }

    function testDeposit() public {
        vault.deposit{value: 100}(address(this));
        console.log("Deposit 100");
        assertEq(address(vault).balance, 100);
        assertEq(vault.totalSupply(), 100);
        assertEq(vault.balanceOf(address(this)), 100);
        console.log("Asserted", address(vault));
    }

    function testWithdraw() public {
        uint myAVAXbalance = address(this).balance;
        vault.deposit{value: 200}(address(this));
        vault.withdraw(100, payable(address(this)));

        assertEq(address(vault).balance, 100);
        assertEq(vault.totalSupply(), 100);
        assertEq(address(this).balance, myAVAXbalance - 100);
        //assertEq(mockLSDVault.balanceOf(address(this)), 100);
    }

    function testStake() public {
        vault.deposit{value: 100}(address(this));
        vault.stake();
        assertEq(address(vault).balance, 0);
        assertEq(vault.totalSupply(), 100);
        assertEq(vault.balanceOf(address(this)), 100);
        assertEq(mockLSDVault.balanceOf(address(vault)), 100);
    }

    function testHarvest() public {
        vault.deposit{value: 100}(address(this));
        vault.stake();
        vault.harvest();
        assertEq(vault.totalSupply(), 100);
        assertEq(vault.balanceOf(address(this)), 100);
        assertEq(mockLSDVault.balanceOf(mockDistAddress), 10);
    }

    function testShutdown() public {
        vault.shutdown();
        assertEq(vault.emergencyMode(), true);
    }


    receive() external payable {
    }

    fallback() external payable {
        revert();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SfuAVAXvault.sol";
import './mocks/MockERC20.sol';
import './mocks/MockLSDVault.sol';
import './mocks/MockDist.sol';
import '../lib/forge-std/src/console.sol';
import 'openzeppelin-contracts/token/ERC20/ERC20.sol';
import "../src/interfaces/IStakedAvax.sol";


contract VaultTest is Test {
    SfuAVAXvault public vault;
    MockDistribution public mockDistribution;
    ERC20 public sAVAX;

    address payable public mockLSDVaultAddress;
    address payable public mockDistAddress;
    address payable public sAVAXAddress;
    using stdStorage for StdStorage;

    function setUp() public {
        uint256 forkId = vm.createFork("mainnet");
        vm.selectFork(forkId);

        sAVAXAddress = payable(0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE);
        // mockLSDVault = new MockLSDVault();
        sAVAX = ERC20(sAVAXAddress);
        mockDistribution = new MockDistribution();
        mockDistAddress = payable(address(mockDistribution));
        vault = new SfuAVAXvault(mockDistAddress, sAVAXAddress);
        console.logBytes32(keccak256(abi.encode("totalPooledAvax()")));
    }

    function increasePooledAVAX(uint amount) public {
        (, bytes memory totalPooledAvaxData) = address(sAVAX).call(
            abi.encodeWithSelector(IStakedAvax(sAVAXAddress).totalPooledAvax.selector)
        );
        uint256 prevTotalPooledAvax = abi.decode(totalPooledAvaxData, (uint256));

        // update balance
        stdstore.target(address(sAVAX)).sig(
            IStakedAvax(sAVAXAddress).totalPooledAvax.selector
        ).checked_write(prevTotalPooledAvax + amount);
    }

    function testDeposit() public {
        vault.deposit{value: 100}(address(this));
        console.log("Deposit 100");
        assertEq(address(vault).balance, 100);
        assertEq(vault.totalSupply(), 100);
        assertEq(vault.balanceOf(address(this)), 100);
        console.log("Asserted", address(vault));
    }

    function testWithdraw_inAVAX() public {
        uint myAVAXbalance = address(this).balance;
        vault.deposit{value: 200}(address(this));
        vault.withdraw(100, payable(address(this)));

        assertEq(address(vault).balance, 100);
        assertEq(vault.totalSupply(), 100);
        assertEq(address(this).balance, myAVAXbalance - 100);
        //assertEq(mockLSDVault.balanceOf(address(this)), 100);
    }

    function testWithdraw_inSAVAX() public {
        // uint myAVAXbalance = address(this).balance;
        vault.deposit{value: 200 ether}(address(this));
        vault.stake();
        vault.withdraw(200 ether, payable(address(this)));

        assertEq(vault.totalSupply(), 0);
        assertEq(IERC20(sAVAXAddress).balanceOf(
            address(this)), 
            IStakedAvax(sAVAXAddress).getSharesByPooledAvax(200 ether)
        );
    }

    function testStake() public {
        vault.deposit{value: 100 ether}(address(this));
        vault.stake();
        assertEq(address(vault).balance, 0);
        assertEq(vault.totalSupply(), 100 ether);
        assertEq(vault.balanceOf(address(this)), 100 ether);
        assertEq(sAVAX.balanceOf(address(vault)), IStakedAvax(sAVAXAddress).getSharesByPooledAvax(100 ether));
    }

    function testHarvest() public {
        vault.deposit{value: 100 ether}(address(this));
        vault.stake();
        increasePooledAVAX(100 ether);
        vault.harvest();
        assertEq(vault.totalSupply(), 100 ether);
        assertEq(vault.balanceOf(address(this)), 100 ether);
        require(sAVAX.balanceOf(mockDistAddress) > 0);
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

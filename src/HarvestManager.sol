// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../lib/forge-std/src/console.sol';
import './interfaces/IswapStrategy.sol';
import './interfaces/IdistStrategy.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';

//HarvetsManager is a proxy contract. When called, it will call the execution function on the implementation contract
contract HarvestManager {

    address public owner;
    address public activeSwapStrategyAddress;
    address public activeDistributeStrategyAddress;


    event Swap(address _token0, address _token1, uint256 _amount);
    event Distribute(address _distributionToken, uint256 _amount);

    modifier onlyOwner() {

        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    
    function initialize(address _activeSwapStrategyAddress, address _activeDistributeStrategyAddress) public {

        activeSwapStrategyAddress = _activeSwapStrategyAddress;
        activeDistributeStrategyAddress = _activeDistributeStrategyAddress;

    }

    function swap(address _token0, address _token1, IswapStrategy) external {

        uint256 _amount = IERC20(_token0).balanceOf(address(this));
        IswapStrategy(activeSwapStrategyAddress).swap(_amount, _token0, _token1);
        emit Swap(_token0, _token1, _amount);

    }

    function distribute(address _distributionToken) external onlyOwner {

        IERC20(_distributionToken).approve(address(activeDistributeStrategyAddress), IERC20(_distributionToken).balanceOf(address(this)));
        IERC20(_distributionToken).transferFrom(address(this), address(activeDistributeStrategyAddress), IERC20(_distributionToken).balanceOf(address(this)));
        IdistStrategy(activeDistributeStrategyAddress).distribute(_distributionToken);
        emit Distribute(_distributionToken, IERC20(_distributionToken).balanceOf(address(this)));

    }

    function updateSwapStrategy(address _newSwapStrategyAddress) external onlyOwner {

        activeSwapStrategyAddress = _newSwapStrategyAddress;

    }

    function updateDistributeStrategy(address _newDistributeStrategyAddress) external onlyOwner {

        activeDistributeStrategyAddress = _newDistributeStrategyAddress;

    }

    function changeOwner(address _newOwner) external onlyOwner {

        owner = _newOwner;

    }

    //function to swap sAVAX to some asset, e.g. stablecoin

    //function to redeem sAVAX for AVAX

    //function to swap AVAX for some asset, e.g. stablecoin

    //function to send stablecoin to the list of beneficiaries

    //manage list of beneficiaries

    //function to change owner
}
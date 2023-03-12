// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../lib/forge-std/src/console.sol';
import './interfaces/IswapStrategy.sol';
import './interfaces/IdistStrategy.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';

/** 
    @title HarvestManager
    @notice HarvetsManager is a proxy contract. Unlike the vault contract that is immutable, 
    Manager is an upgradable contract owned by governance.When called, it will call the execution function 
    on the implementation contract.
    @dev Swap and distribute strategies are stored in the /strategies folder
*/

contract HarvestManager {

    /// @notice The owner of the contract. It can be changed by the owner calling changeOwner()
    address public owner;
    /// @notice The address of the active swap strategy. It can be changed by the owner calling updateSwapStrategy()
    address public activeSwapStrategyAddress;
    /// @notice The address of the active distributing strategy. It can be changed by the owner calling updateDistributeStrategy()
    address public activeDistributeStrategyAddress;

    /// @notice The event emitted when swap function is called.
    /// @param _token0 The address of the token that is swapped (usually sAVAX, but also can be used to swap any other ERC-20 tokens sent to manager by mistake).
    /// @param _token1 The address of the token that is received after swap (e.g. USDC)
    /// @param _amount The amount of tokens that is swapped
    event Swap(address _token0, address _token1, uint256 _amount);

    /// @notice The event emitted when distribute function is called.
    /// @param _distributionToken The address of the token that is distributed (usually USDC, but also can be used to distribute any other ERC-20 tokens sent to manager by mistake).
    /// @param _amount The amount of tokens that is distributed
    event Distribute(address _distributionToken, uint256 _amount);

    constructor(address _activeSwapStrategyAddress, address _activeDistributeStrategyAddress) {

        owner = msg.sender;
        activeSwapStrategyAddress = _activeSwapStrategyAddress;
        activeDistributeStrategyAddress = _activeDistributeStrategyAddress;

    }

    /* ========== MODIFIERS ========== */

    /// @notice Modifier to check if the caller is the owner of the contract.
    modifier onlyOwner() {

        require(msg.sender == owner, "Only owner can call this function.");
        _;

    }

    /* ========== PUBLIC FUNCTIONS ========== */

    /// @notice The function that users (keepers) call to swap harvested yield for an assets suitable for donation (e.g. stablecoin). This contract doesn't have a logic to exscute transfer. Instead, it calls the swap function on the active swap strategy contract.
    /// @param _token0 The address of the token that is swapped (usually sAVAX, but also can be used to swap any other ERC-20 tokens sent to manager by mistake).
    /// @param _token1 The address of the token that is received after swap (e.g. USDC)
    function swap(address _token0, address _token1, IswapStrategy) external {

        uint256 _amount = IERC20(_token0).balanceOf(address(this));
        IswapStrategy(activeSwapStrategyAddress).swap(_amount, _token0, _token1);
        emit Swap(_token0, _token1, _amount);

    }

    /// @notice The function that users (keepers) call to distribute harvested yield to beneficiaries after it was swapped to more stable asset (e.g. stablecoin). This contract doesn't have a logic to exscute transfer. Instead, it calls the distribute function on the active distribute strategy contract.
    /// @param _distributionToken The address of the token that is distributed (usually USDC, but also can be used to distribute any other ERC-20 tokens sent to manager by mistake).
    function distribute(address _distributionToken) external onlyOwner {

        IERC20(_distributionToken).approve(address(activeDistributeStrategyAddress), IERC20(_distributionToken).balanceOf(address(this)));
        IERC20(_distributionToken).transferFrom(address(this), address(activeDistributeStrategyAddress), IERC20(_distributionToken).balanceOf(address(this)));
        IdistStrategy(activeDistributeStrategyAddress).distribute(_distributionToken);
        emit Distribute(_distributionToken, IERC20(_distributionToken).balanceOf(address(this)));

    }

    /* ========== OWNER FUNCTIONS ========== */

    /// @notice The function that owner calls to update the address of the active swap strategy.
    /// @param _newSwapStrategyAddress The address of the new swap strategy contract.
    function updateSwapStrategy(address _newSwapStrategyAddress) external onlyOwner {

        activeSwapStrategyAddress = _newSwapStrategyAddress;

    }

    /// @notice The function that owner calls to update the address of the active distribution strategy.
    /// @param _newDistributeStrategyAddress The address of the new distribution strategy contract.
    function updateDistributeStrategy(address _newDistributeStrategyAddress) external onlyOwner {

        activeDistributeStrategyAddress = _newDistributeStrategyAddress;

    }

    /// @notice The function that owner calls to transfer ownership of the contract.
    /// @param _newOwner The address of the new owner.
    function changeOwner(address _newOwner) external onlyOwner {

        owner = _newOwner;

    }
}
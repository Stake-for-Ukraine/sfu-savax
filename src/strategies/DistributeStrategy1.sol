// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '../interfaces/IdistStrategy.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';
import '../../lib/forge-std/src/console.sol';

/**
 * @title DistributeStrategy1
 * @notice DistributeStrategy1 contract is an execution contract that is used by Harvest Manager to distribute funds to beneficiaries. 
 */
contract DistributeStrategy1 is IdistStrategy {

    /// @notice Array of addresses of beneficiaries who recieve funding
    address[] public beneficiaries;

    /// @notice Array of percentages of how available funds should be splitted between beneficiaries
    /// @dev Percentages must be between 0 and 100. Sum of percentages must be equal to 100.

    uint8[] public percentages;
    /// @notice Address of the owner of the contract
    address public manager;

    /// @notice Event emitted when funds are distributed to beneficiaries
    /// @param _distributionToken Address of the token that is distributed
    /// @param _amount Amount of the token that is distributed
    event Distribute(address indexed _distributionToken, uint256 _amount);

    /// @notice modifier that is used to restrict access to the function only to the manager;
    modifier onlyManager() {

        require(msg.sender == manager, "Only manager can call this function.");
        _;

    }

    /// @notice Contract constructor.
    /// @param _beneficiaries Array of addresses of beneficiaries who recieve funding
    /// @param _percentages Array of percentages of how available funds should be splitted between beneficiaries
    constructor (address _manager, address[] memory _beneficiaries, uint8[] memory _percentages) {

        manager = _manager;
        require(_beneficiaries.length == _percentages.length, "Lengths must be equal");
        beneficiaries = _beneficiaries;
        percentages = _percentages;
        
    }

    /// @notice Function that is called by Harvest Manager to distribute funds to beneficiaries.
    /// @param _distributionToken Address of the ERC-20 token that is distributed
    function distribute(address _distributionToken) external onlyManager {

        require(beneficiaries.length == percentages.length, "Lengths must be equal");
        for(uint i = 0; i < percentages.length; i++) {
            require(percentages[i] >= 0 && percentages[i] <= 100, "Value must be between 0 and 100");
         }

        uint256 _fundsToDistribute = IERC20(_distributionToken).balanceOf(address(manager));

        for (uint8 i = 0; i < beneficiaries.length; i++) {
            if (i == beneficiaries.length - 1) {

                IERC20(_distributionToken).transferFrom(manager, beneficiaries[i], _fundsToDistribute);
                emit Distribute(_distributionToken, _fundsToDistribute);

            } else {

                uint256 _amount = _fundsToDistribute * percentages[i] / 100;
                IERC20(_distributionToken).transferFrom(manager, beneficiaries[i], _amount);
                emit Distribute(_distributionToken, _amount);
                
            }
        }
    }
}
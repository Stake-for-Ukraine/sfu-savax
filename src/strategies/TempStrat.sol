// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '../interfaces/IDistributionStrategy.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';
import '../../lib/forge-std/src/console.sol';

/**
 * @title DistributeStrategy1
 * @notice DistributeStrategy1 contract is an execution contract that is used by Harvest harvestManager to distribute funds to beneficiaries. 
 */
contract DistributeToTreasury is IDistributionStrategy {

    /// @notice Address of the treasury where sAVAX will be sent fot future distribution to beneficiaries
    address public treasuryAddress;

    /// @notice Address of the owner of the contract
    address public harvestManager;

    /// @notice sAVAX address
    address public sAVAXAddress;

    /// @notice Event emitted when funds are distributed to beneficiaries
    /// @param treasuryAddress Address of the Treasury where sAVAX is sent
    /// @param _amount Amount of the token that is distributed
    event SentToTreasury(address treasuryAddress, uint256 _amount);

    /// @notice modifier that is used to restrict access to the function only to the harvestManager;
    modifier onlyHarvestManager() {

        require(msg.sender == harvestManager, "Only harvestManager can call this function.");
        _;

    }

    /// @notice Contract constructor.
    /// @param _harvestManager Address of the HarvestharvestManager of the contract
    /// @param _sAVAXAddress Address of the sAVAX token
    /// @param _treasuryAddress Address of the treasury where sAVAX will be sent fot future distribution to beneficiaries
    constructor (address _harvestManager, address _sAVAXAddress, address _treasuryAddress) {

        harvestManager = _harvestManager;
        sAVAXAddress = _sAVAXAddress;
        treasuryAddress = _treasuryAddress;
        
    }

    /// @notice Function that is called by Harvest harvestManager to send sAVAX (or any other token) to the treasury
    /// @param _distributionToken Address of the ERC-20 token that is distributed
    function distribute(address _distributionToken) external onlyHarvestManager {
        uint256 _fundsToDistribute = IERC20(sAVAXAddress).balanceOf(address(harvestManager));

        require(_fundsToDistribute > 0, "No funds to distribute");

        IERC20(_distributionToken).transferFrom(harvestManager, treasuryAddress, _fundsToDistribute);
        emit SentToTreasury(treasuryAddress, _fundsToDistribute);

    }
}
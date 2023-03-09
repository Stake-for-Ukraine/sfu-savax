// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '../interfaces/IdistStrategy.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';

contract DistributeStrategy1 is IdistStrategy {
    address[] public beneficiaries;
    uint8[] public percentages;
    address public owner;

    event Distribute(address indexed _distributionToken, uint256 _amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function initialize(address[] memory _beneficiaries, uint8[] memory _percentages) external {
        require(_beneficiaries.length == _percentages.length, "Lengths must be equal");
        beneficiaries = _beneficiaries;
        percentages = _percentages;
    }

    function distribute(address _distributionToken) external onlyOwner {
        require(beneficiaries.length == percentages.length, "Lengths must be equal");
        for(uint i = 0; i < percentages.length; i++) {
            require(percentages[i] >= 0 && percentages[i] <= 100, "Value must be between 0 and 100");
         }

        uint256 _fundsToDistribute = IERC20(_distributionToken).balanceOf(address(this));

        for (uint8 i = 0; i < beneficiaries.length; i++) {
            if (i == beneficiaries.length - 1) {
                IERC20(_distributionToken).transfer(beneficiaries[i], _fundsToDistribute);
                emit Distribute(_distributionToken, _fundsToDistribute);
            } else {
                uint256 _amount = _fundsToDistribute * percentages[i] / 100;
                IERC20(_distributionToken).transfer(beneficiaries[i], _amount);
                emit Distribute(_distributionToken, _amount);
            }
        }
    }
}
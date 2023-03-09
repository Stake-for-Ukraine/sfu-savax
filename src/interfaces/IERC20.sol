// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";


interface IbaseAsset {

    function transferFrom(address A, address B, uint C) external view returns(bool);

    function approve() external view returns(uint256);

    function decimals() external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function transfer(address D, uint amount) external ;
}
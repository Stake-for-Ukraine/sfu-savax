// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../lib/forge-std/src/console.sol';
import '../interfaces/IswapStrategy.sol';
import '../interfaces/ILBQuoter.sol';
import '../interfaces/ILBRouter.sol';
import '../interfaces/ILBPair.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';

/**
 * @title SwapStrategy1
 * @notice SwapStrategy1 contract is an execution contract that is mainly used by Harvest Manager to swap sAVAX for a stablecoin.
 This strategy is using Trader Joe exchange's router to find a path from sAVAX to a stablecoin and performs the swap. User(keeper) is expected to cover gas costs.
 */



contract SwapStrategy1 is IswapStrategy {
    
    /// @notice address of the Harvest manager, which is also should be an owner of this contract;
    address public manager;

    /// @notice Trader Joe Router address;
    ILBRouter public router;
    /// @notice Trader Joe Quoter contract address that we will be using to calculate minimum amount of stablecoin that we will receive for sAVAX;
    ILBQuoter public quoter;

    /// @notice event that is emitted when swap is performed;
    /// @param _token0 address of the token that is being swapped;
    /// @param _token1 address of the token that is being swapped for;
    /// @param _amount amount of the _token0 that is being swapped;
    event Swap(address _token0, address _token1, uint256 _amount);

    /// @notice constructor of the contract;
    /// @param _manager address of the Harvest manager;
    /// @param _router address of the Trader Joe Router;
    /// @param _quoter address of the Trader Joe Quoter;    
    constructor (address _manager, address _router, address _quoter) {

        manager = _manager;
        router = ILBRouter(_router);
        quoter = ILBQuoter(_quoter);

    }

    /// @notice modifier that is used to restrict access to the function only to the manager;
    modifier onlyManager() {

        require(msg.sender == manager, "Only manager can call this function.");
        _;

    }

    /**
     * @notice When called, this function will perform a swap from token0 to token1. First it will calculate the minimum amount of token1 that we will receive for token0.
     * Then it will perform the swap allowing up to 1% slippage and emit a swap event.
     * @param _amount amount of the token0 that is being swapped;
     * @param _token0 address of the token that is being swapped;
     * @param _token1 address of the token that is being swapped for;
     */
    function swap(uint256 _amount, address _token0, address _token1) external onlyManager returns (uint256 amountOutReal) {

        address[] memory _tokenPathaddress = new address[](2);
        _tokenPathaddress[0] = _token0;
        _tokenPathaddress[1] = _token1;

        IERC20[] memory _tokenPath = new IERC20[](2);
        _tokenPath[0] = IERC20(_token0);
        _tokenPath[1] = IERC20(_token1);
        uint256[] memory pairBinSteps = new uint256[](1); // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        pairBinSteps[0] = 1;

        Quote memory quote;
        quote = Quote({
            route: new address[](2),
            pairs: new address[](2),
            binSteps: new uint256[](0),
            amounts: new uint256[](0),
            virtualAmountsWithoutSlippage: new uint256[](0),
            fees: new uint256[](0)
        });

        quote = quoter.findBestPathFromAmountIn(_tokenPathaddress, _amount);


        if (quote.pairs.length > 0) {

            address pairAddress = quote.pairs[0];
            (uint256 amountOut, ) = router.getSwapOut(ILBPair(pairAddress), _amount, true);
            uint256 amountOutWithSlippage = amountOut * 99 / 100; // We allow for 1% slippage
            IERC20(_tokenPathaddress[0]).approve(address(router), _amount);
            router.swapExactTokensForTokens(_amount, amountOutWithSlippage, pairBinSteps, _tokenPath, address(manager), block.timestamp);
            emit Swap(_token0, _token1, _amount);

        return amountOutReal; 
        } else {
        // handle the case where quote.pairs is empty
            console.log("SwapStrategy1: No pairs found");
        }   

        //get address of the pair and save it in variable


        
    }
}
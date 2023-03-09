// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../lib/forge-std/src/console.sol';
import '../interfaces/IswapStrategy.sol';
import '../interfaces/ILBQuoter.sol';
import '../interfaces/ILBRouter.sol';
import '../interfaces/ILBPair.sol';
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';

contract SwapStrategy1 is IswapStrategy {
    
    address public manager;

    ILBRouter public router;
    ILBQuoter public quoter;

    event Swap(address _token0, address _token1, uint256 _amount);

    //initialisation function
    function initialize(address _manager, address _router, address _quoter) public {

        manager = _manager;
        router = ILBRouter(_router);
        quoter = ILBQuoter(_quoter);

    }

    modifier onlyManager() {

        require(msg.sender == manager, "Only manager can call this function.");
        _;

    }

    function swap(uint256 _amount, address _token0, address _token1) external onlyManager returns (uint256 amountOutReal) {

        IERC20(_token0).approve(address(router), _amount);

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
            route: new address[](0),
            pairs: new address[](0),
            binSteps: new uint256[](0),
            amounts: new uint256[](0),
            virtualAmountsWithoutSlippage: new uint256[](0),
            fees: new uint256[](0)
        });

        //get address of the pair and save it in variable
        quote = quoter.findBestPathFromAmountIn(_tokenPathaddress, _amount);
        address pairAddress = quote.pairs[0];

        (uint256 amountOut, ) = router.getSwapOut(ILBPair(pairAddress), _amount, true);
        uint256 amountOutWithSlippage = amountOut * 99 / 100; // We allow for 1% slippage
        
        emit Swap(_token0, _token1, _amount);

        return amountOutReal = router.swapExactTokensForTokens(_amount, amountOutWithSlippage, pairBinSteps, _tokenPath, address(manager), block.timestamp);
    }

}
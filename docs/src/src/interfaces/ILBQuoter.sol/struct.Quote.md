# Quote
<<<<<<< Updated upstream
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/eca56343487ca867355097dbb6758c96361fe876/src/interfaces/ILBQuoter.sol)
=======
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/855c70d84d498aafbcd341621f3e2d0d874da8ba/src/interfaces/ILBQuoter.sol)
>>>>>>> Stashed changes


```solidity
struct Quote {
    address[] route;
    address[] pairs;
    uint256[] binSteps;
    uint256[] amounts;
    uint256[] virtualAmountsWithoutSlippage;
    uint256[] fees;
}
```


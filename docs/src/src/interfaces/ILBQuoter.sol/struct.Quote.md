# Quote
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/eca56343487ca867355097dbb6758c96361fe876/src/interfaces/ILBQuoter.sol)


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


# Quote
[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/1e5f9b7d7b2ef6672dfad852e7feb508635caac7/src/interfaces/ILBQuoter.sol)


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


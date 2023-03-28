---
description: sfuAVAX is a wrapper around sAVAX (staked AVAX) developed by Benq.finance
---

# About sfuAVAX

<figure><img src="../../.gitbook/assets/Stake for Ukraine.jpg" alt=""><figcaption></figcaption></figure>

There are 3 core components of the sfuAVAX system: Vault, Manager and Strategies.

## Vault

[sfuAVAXvault](src/contract.savaxvault.md) - is wrapper around sAVAX Benqi liquid staking contract. Users can deposit AVAX or sAVAX and receive sfuAVAX representing their stake in sfuAVAX. The sfuAVAX vault contract is immutable. This improves security of user's deposits

## Manager

[HarvestManager](src/contract.harvestmanager.md) - smart contract that manages swapping harvested yield to some assets suitable to be donated  to beneficiaries (e.g. Stablecoins), and distributing it to the list of beneficiaries. The logic for swapping and distribution lives in separate smart contract and can be updated through governance.

## Strategies

There are two types of strategies that Manager needs - swap and distribution.

**Swap strategy** contains a logic of swapping harvested yield in sAVAX to some ERC-20 token that makes sense to transger to beneficiaries. [SwapStrategy1](../../readme/src/src/stake-for-ukraine-sfu-savax.md) is an example of a strategy that implements logic of swapping sAVAX using Trader Joe DEX. In the future new strategies leveraging other DEXes can be implemented, based on where the best liquidity is available.

Distirbution strategy contains logic of transferring tokens to beneficiaries, list of beneficiaries' addresses and their shares. [DistributeStrategy1.sol](src/contract.distributestrategy1.md) implements logic that transfers yield to two benefieciaries with 50/50 split between them. &#x20;

By calling `function updateDistributeStrategy()` or `function updateSwapStrategy()` of Manager contract it can be instructed new strategies implementing new logic, through governance.

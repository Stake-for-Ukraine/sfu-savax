---
description: sfuAVAX is a wrapper around sAVAX (staked AVAX) developed by Benq.finance
---

# About sfuAVAX

<figure><img src="../../.gitbook/assets/Stake for Ukraine.jpg" alt=""><figcaption></figcaption></figure>

The sfuAVAX system is made up of three key components: the Vault, Manager, and Strategies.

## Vault

The Vault, called [sfuAVAXvault](src/contract.savaxvault.md), is a wrapper around the sAVAX Benqi liquid staking contract. By depositing AVAX or sAVAX, users can receive sfuAVAX tokens that represent their stake in sfuAVAX. The sfuAVAX vault contract is immutable, providing enhanced security for user deposits.

## Manager

The [HarvestManager](src/contract.harvestmanager.md) is a smart contract that manages the swapping of harvested yield for suitable assets to be donated to beneficiaries (such as Stablecoins), and distributes them to a list of beneficiaries. The logic for swapping and distribution resides in a separate smart contract, and can be updated through governance.

## Strategies

There are two types of strategies that the Manager needs: swap and distribution.&#x20;

**Swap strategies** determine how harvested yield in sAVAX is swapped to a specific ERC-20 token for transfer to beneficiaries. For example, [SwapStrategy1](../../readme/src/src/stake-for-ukraine-sfu-savax.md) uses Trader Joe DEX for swapping sAVAX, but in the future, other strategies leveraging different DEXes can be implemented.&#x20;

**Distribution strategies** determine how tokens are transferred to beneficiaries, and include a list of beneficiary addresses and their respective shares. [DistributeStrategy1](src/contract.distributestrategy1.md) is an example of a distribution strategy that transfers yield to two beneficiaries with a 50/50 split.

By calling `function updateDistributeStrategy()` or `function updateSwapStrategy()` of [Manager](src/contract.harvestmanager.md) contract it can be instructed new strategies implementing new logic, through governance.

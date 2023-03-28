---
description: sfuAVAX is a wrapper around sAVAX (staked AVAX) developed by Benq.finance
---

# SUMMARY

<figure><img src="../../.gitbook/assets/Stake for Ukraine.jpg" alt=""><figcaption></figcaption></figure>

There are 3 core components of the sfuAVAX system: Vault, Manager and Strategies.

## Vault

[sfuAVAXvault](src/contract.savaxvault.md) - is wrapper around sAVAX Benqi liquid staking contract. Users can deposit AVAX or sAVAX and receive sfuAVAX representing their stake in sfuAVAX. The sfuAVAX vault contract is immutable. This improves security of user's deposits

## Manager

[HarvestManager](SUMMARY.md) - smart contract that manages swapping harvested yield to some assets suitable to be donated  to beneficiaries (e.g. Stablecoins), and distributing it to the list of beneficiaries. The logic for swapping and distribution lives in separate smart contract and can be updated through governance.

## Strategies

Strategy&#x20;

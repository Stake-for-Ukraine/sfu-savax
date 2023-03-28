---
description: Strategy that swaps sAVAX to ERC-20 token using Trader Joe's router
---

# SwapStrategy1.sol

[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/855c70d84d498aafbcd341621f3e2d0d874da8ba/src/strategies/SwapStrategy1.sol)

**Inherits:** IswapStrategy

SwapStrategy1 contract is an execution contract that is mainly used by Harvest Manager to swap sAVAX for a stablecoin. This strategy is using Trader Joe exchange's router to find a path from sAVAX to a stablecoin and performs the swap. User(keeper) is expected to cover gas costs.

### State Variables

#### manager

address of the Harvest manager, which is also should be an owner of this contract;

#### router

Trader Joe Router address;

#### quoter

Trader Joe Quoter contract address that we will be using to calculate minimum amount of stablecoin that we will receive for sAVAX;

### Functions

#### constructor

constructor of the contract;

```
constructor(address _manager, address _router, address _quoter);
```

**Parameters**

| Name       | Type      | Description                       |
| ---------- | --------- | --------------------------------- |
| `_manager` | `address` | address of the Harvest manager;   |
| `_router`  | `address` | address of the Trader Joe Router; |
| `_quoter`  | `address` | address of the Trader Joe Quoter; |

#### onlyManager

modifier that is used to restrict access to the function only to the manager;

#### swap

When called, this function will perform a swap from token0 to token1. First it will calculate the minimum amount of token1 that we will receive for token0. Then it will perform the swap allowing up to 1% slippage and emit a swap event.

```
function swap(uint256 _amount, address _token0, address _token1) external onlyManager returns (uint256 amountOutReal);
```

**Parameters**

| Name      | Type      | Description                                     |
| --------- | --------- | ----------------------------------------------- |
| `_amount` | `uint256` | amount of the token0 that is being swapped;     |
| `_token0` | `address` | address of the token that is being swapped;     |
| `_token1` | `address` | address of the token that is being swapped for; |

### Events

#### Swap

event that is emitted when swap is performed;

```
event Swap(address _token0, address _token1, uint256 _amount);
```

# sAVAXvault.sol

[Git Source](https://github.com/Stake-for-Ukraine/sfu-savax/blob/855c70d84d498aafbcd341621f3e2d0d874da8ba/src/sAVAXvault.sol)

**Inherits:** ERC20

**Author:** Oleksii Novykov

sAVAXvault is wrapper for Benqi liquid staking (sAVAX). Users can deposit AVAX or sAVAX and recieve sfuAVAX. Staking rewards are donated to NGOs supporting Ukraine.

### State Variables

#### sAVAXcontract

```solidity
IStakedAvax public sAVAXcontract;
```

#### harvestManagerAddress

Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries)

```solidity
address payable public harvestManagerAddress;
```

#### sAVAXaddress

Address of the sAVAX ERC-20 contract;

```solidity
address payable public sAVAXaddress;
```

#### owner

Address of the owner of the contract

```solidity
address public owner;
```

#### totalShares

Total amount of sfuAVAX issued by this contract to depositors of AVAX/sAVAX

```solidity
uint256 public totalShares;
```

#### totalAssets

Total amount deposited by all users in AVAX to this contract minus amount withdrawn by all users

```solidity
uint256 public totalAssets;
```

#### emergencyMode

When true means that contract is in emergency mode and deposits are disabled, staking of available AVAX is disabled, withdrawals are enabled.

```solidity
bool public emergencyMode;
```

#### totalDeposit

Balances of each individual users in AVAX

```solidity
mapping(address => uint256) public totalDeposit;
```

### Functions

#### onlyOwner

modifier that is used to restrict access to the function only to the manager;

```solidity
modifier onlyOwner();
```

#### constructor

Contract constructor sets initial parameters when contract is deployed.

```solidity
constructor(address payable _harvestManagerAddress, address payable _sAVAXaddress)
    ERC20("Stake AVAX for Ukraine", "sfuAVAX");
```

**Parameters**

| Name                     | Type              | Description                                                                                                       |
| ------------------------ | ----------------- | ----------------------------------------------------------------------------------------------------------------- |
| `_harvestManagerAddress` | `address payable` | Address of the Harvest Manager - contract that recieves harvested rewards and disitirbutes them to beneficiaries) |
| `_sAVAXaddress`          | `address payable` | Address of the sAVAX ERC-20 contract;                                                                             |

#### deposit

Allows users to deposit AVAX to the contract and mints sfuAVAX in return

```solidity
function deposit(address _receiver) external payable returns (uint256 _shares);
```

**Parameters**

| Name        | Type      | Description                                  |
| ----------- | --------- | -------------------------------------------- |
| `_receiver` | `address` | Address of the user who will receive sfuAVAX |

#### withdraw

Allows users to withdraw sAVAX from the contract and burns sfuAVAX in return

```solidity
function withdraw(uint256 _shares, address payable _receiver) external payable;
```

**Parameters**

| Name        | Type              | Description                                |
| ----------- | ----------------- | ------------------------------------------ |
| `_shares`   | `uint256`         | Amount of sfuAVAX to burn                  |
| `_receiver` | `address payable` | Address of the user who will receive sAVAX |

#### stake

Allows users to stake available AVAX in the contract with Benqi.fi sAVAX staking contract

```solidity
function stake() external payable returns (uint256);
```

#### harvest

Check how much of the baseAsset is not invested (if any) Amount of sAVAX returned from the staking contract after submiting the \_availableBaseAsset Deposit the baseAsset into the sAvax contract and save in variable amlount of sAVAX shares recieved Return 0 if there is no baseAsset to invest

Allows to harvest staking rewards earned from user's deposit to Benqi.fi sAVAX staking contract. Harvested rewards are sent to the Harvest Manager contract.

```solidity
function harvest() external payable;
```

#### shutdown

Allows Manager to put the vault in shutdown mode. No new deposits are allowed. Withdrawals only.

```solidity
function shutdown() external onlyOwner;
```

#### checkAVAXinsAVAX

Converts AVAX to sAVAX

```solidity
function checkAVAXinsAVAX(uint256 _amount) external view returns (uint256);
```

**Parameters**

| Name      | Type      | Description               |
| --------- | --------- | ------------------------- |
| `_amount` | `uint256` | Amount of AVAX to convert |

#### checksAVAXinAVAX

Converts sAVAX to AVAX

```solidity
function checksAVAXinAVAX(uint256 _amount) external view returns (uint256);
```

**Parameters**

| Name      | Type      | Description                |
| --------- | --------- | -------------------------- |
| `_amount` | `uint256` | Amount of sAVAX to convert |

#### receive

Standard fallback function that allows contract to recieve native tokens (AVAX)

```solidity
receive() external payable;
```

#### fallback

Standard fallback function that allows contract to recieve native tokens (AVAX)

```solidity
fallback() external payable;
```

#### \_safeTransfer

Helper function that transfer AVAX to given address, internal, only used in this contract

```solidity
function _safeTransfer(address payable _to, uint256 _amount) internal;
```

**Parameters**

| Name      | Type              | Description                                   |
| --------- | ----------------- | --------------------------------------------- |
| `_to`     | `address payable` | Address of the address that will receive AVAX |
| `_amount` | `uint256`         | Amount of AVAX to transfer                    |

#### checkFallback

```solidity
function checkFallback(address payable to) external returns (bool);
```

### Events

#### Deposit

Emitted when a user deposits AVAX

```solidity
event Deposit(address caller, uint256 amount);
```

#### Withdraw

Emitted when a user withdraws AVAX

```solidity
event Withdraw(address caller, address receiver, uint256 amount, uint256 shares);
```

#### Harvested

Emitted when harvest function is triggered and staking rewards are harvested

```solidity
event Harvested(address caller, uint256 amount);
```

#### Staked

Emitted when available AVAX is staked

```solidity
event Staked(address caller, uint256 amount);
```

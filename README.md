# Proveably a random Raffle Contract 

## About 
This code is use to create a proveably random smart contract lottery. 
As we have seen many cases that there is some lottery in which they don't give funds , there is some sort of manipulation . 

# What we want to do it ?
 1. User can enter by paying for a ticket 
    1. The ticket fee are going to go to winner during the draw .
 2. After X period of time lottery will automatically draw a winner.
    1. This will be done progamitically . 
 3. Using chainLink VRF and chainLink Automation 
    chainLink VRF - It will be used to find randomness (number)
    chainLink Automation - Time based trigger 
    
    
    
    
## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

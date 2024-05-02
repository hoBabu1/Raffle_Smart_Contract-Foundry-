# Lottery Smart Contract 

## Overview

The above code sample is written in solidity, Traditional lotteries often lack transparency, leaving room for manipulation.
 So, I have created a project that is a decentralized lottery system using ensures fairness and transparency for all participants. Players can participate by paying for tickets. Integrating it with Chainlink VRF ensures a truly random winner is picked. Automating it by using chainlink automation, ensures that automatically winner will be picked and the winning amount will be transferred to the winner automatically, hence making is more advanced.

# What I wanted to do  ?
 1. User can enter by paying for a ticket. The ticket fee are going to go to winner during the draw .
 2. After X period of time lottery will automatically draw a winner.
 3. Using chainLink VRF and chainLink Automation.
 ChainLink VRF - It will be used to find randomness (number)
    ChainLink Automation - Time based trigger 

 ## Requirements 
   ### [Git](https://git-scm.com/)
        You'll know you did it right, if can run git --version and you see a response like  git version x.x.x .
   ### [Foundry](https://getfoundry.sh/)
       You'll know you did it right if you can run  forge --version  and you see a response like  forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z) 

## QuickStart
   To clone this Repo use command -
   ``` git clone https://github.com/hoBabu1/Raffle_Smart_Contract-Foundry-.git ```

## Deployed On Sepolia Testnet 
 [Interact with Raffel](https://sepolia.etherscan.io/address/0xe7ae1641191a407b98638c5b2fbcc879f7ec5a92 )
## Library 

If you're having a hard time installing the chainlink library, you can optionally run this command.

``` forge install smartcontractkit/chainlink-brownie-contracts@0.8.0 --no-commit ```

## Deploy on Local Network (Anvil)
This will default to your local node. You need to have it running in another terminal in order for it to deploy.

``` make deploy ```



##  Deployment to a testnet or mainnet 

1. Setup environment variables

You'll want to set your ``` SEPOLIA_RPC_URL ``` and ``` PRIVATE_KEY ``` as environment variables. You can add them to a .env file.

```PRIVATE_KEY```: The private key of your account (like from metamask). NOTE: FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.

```SEPOLIA_RPC_URL```: This is url of the sepolia testnet node you're working with. You can get setup with one for free from Alchemy.

Optionally, add your ``` ETHERSCAN_API_KEY ``` if you want to verify your contract on Etherscan.

1. Get testnet ETH
Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy on Sepolia testnet, just run this command (make sure you have rpc url , private key in your .env file)

``` make deploy ARGS="--network sepolia" ```

3. Register a Chainlink Automation Upkeep

Go to [automation.chain.link](https://automation.chain.link/new) and register a new upkeep. Choose Custom logic as your trigger mechanism for automation. 

# Thank You 
If you think there could be some changes feel free to create a issue . 

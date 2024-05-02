# Lottery Smart Contract

## Overview

The above code sample is written in solidity, Traditional lotteries often lack transparency, leaving room for manipulation.
 So, I have created a project that is a decentralized lottery system using ensures fairness and transparency for all participants. Players can participate by paying for tickets. Integrating it with Chainlink VRF ensures a truly random winner is picked. Automating it by using chainlink automation, ensures that automatically winner will be picked and the winning amount will be transferred to the winner automatically, hence making is more advanced.

# What I wanted to do  ?
 1. User can enter by paying for a ticket 
    1. The ticket fee are going to go to winner during the draw .
 2. After X period of time lottery will automatically draw a winner.
    1. This will be done progamitically . 
 3. Using chainLink VRF and chainLink Automation 
    chainLink VRF - It will be used to find randomness (number)
    chainLink Automation - Time based trigger 

# Getting Started 
 ## Requirements 
   ### [Git](https://git-scm.com/)
        You'll know you did it right if you can run - ``` git --version ``` and you see a response like ``` git version x.x.x ```.
   ### [Foundry](https://getfoundry.sh/)
       You'll know you did it right if you can run ``` forge --version ``` and you see a response like ``` forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z) ```
 
 ## QuickStart
   To clone this Repo use command -
   ``` git clone https://github.com/hoBabu1/Raffle_Smart_Contract-Foundry-.git ```

# Deployed On Sepolia Testnet 
 [Interact With Contract](https://sepolia.etherscan.io/address/0xe7ae1641191a407b98638c5b2fbcc879f7ec5a92 )

![alt text](image.png)

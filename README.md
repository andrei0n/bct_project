# Bootstrapping smart contract governance using governor contracts

_Note: the smart contracts in this repository have not been extensively reviewed for bugs. Use at your own risk!_

This repository contains several smart contracts intended to demonstrate approaches to governance of smart contracts.
We focus on upgradeability of a contract's code, data storage and ether storage.
In addition, we provide several examples of how to authorize upgrades, and how to change the policies that are used to check if someone is allowed to perform an upgrade.

In each of the use cases in this repository, there is a primary (proxy) contract that does not change after deployment. This proxy contract will forward any method invocation to the registered logic contract. Currently we support two types of proxy contracts:

1. A proxy that uses "delegatecall" to forward unknown methods. This means that the call will execute in the context of the proxy contract. This means that any upgrade needs to be compatible with the existing storage layout!
2. A proxy that uses a regular "call" to forward unknown methods. With this approach the logic contract manages its own storage, which will need to be transfered when the logic code is upgraded. An important downside is that `msg.sender` is set to the proxy contract, making some functionality unfeasible.

In addition, each proxy contract has one vernor contracts.
A governor is a contract that controls access to some or all functionality of the proxy contract, such as upgrades of the contract's logic contract.
In addition, the governor can be asked to replace itself by a new governor (possibly with different access control policies).
The proxy contract will only allow such requests from the governor, so unauthorized use of these governed functions is prevented.

## Types of governors

For each use case, we implement some examples of governor contracts.
These are referred to by common names, which is explained below.

* _Governor_ – The default Governor allows everything.
  * _Governor-Owned_ – The governor where only the owner has the power to make updates.
  * _Governor-Nobody_ – This governor does not allow anything. Setting it as the update governor will prevent future updates.
  * _Governor-Admined_ – The governor where only the admin has the power to make updates.
* _Governor-Any_ renamed from _Governor-VoteOne-NoLeader_ – This is a governor that will let anyone on a list of voters perform the update, and even add or remove people from the group. Anybody can join or leave the voters group.
  * _Governor-Any-Owned_ renamed from _Governor-VoteOne_ – Same as _Governor-Any_, but here only the Owner can add or remove voters from the group.
  * _Governor-Any-Admined_ – Same as _Governor-Any_, but here anybody of the admins group can add or remove voters from the group.
* _Governor-Cohort_ based on _Governor-VoteAll_ – This is a governor that requires a subgroup (can be 100%, initially only 100%) of voters to agree to a governor update (and to the new governor) or a logic update (and to the new logic). Anybody can join or leave the voters group
  * _Governor-Cohort-Admined_ – Same as _Governor-Cohort_, but here anybody of admins group can add or remove voters from the group.
  * _Governor-Cohort-Owned_ – Same as _Governor-Cohort_, but here the Owner can add or remove voters from the group.
  * _Governor-Cohort-Consortium_ based on _Governor-VoteAll-NoLeader_ – This is a governor that requires all voters to agree to a governor update (and to the new governor), a logic update (and to the new logic), the addition of voters or removal of voters (except the one removed).
    * _Governor-Cohort-Consortium-Mintable_ – Same as _Governor-Cohort-Consortium_, but additional votes can be bought.
    * _Governor-Cohort-Consortium-Delegate_ – Same as _Governor-Cohort-Consortium_, but vote can be delegated.
  * _Governor-Cohort-Delegate_ – Same as _Governor-Cohort_, but votes can be delegated to other voters.
  * _Governor-Cohort-Delegate-Owned_ – Same as _Governor-Cohort-Delegate_, but only the owner can add or remove voters from the group.
  * _Governor-Cohort-Delegate-Admined_ – Same as _Governor-Cohort-Delegate_, but only admins from the group can add or remove voters.
* _Governor-Richest_ – This governor gives the entire power to the person that has the most ether donated.
* _Governor-Mintable_ – Same as _Governor-Cohort_, but additional votes can be bought. 
  * _Governor-Mintable-Owned_ – Same as _Governor-Mintable_, but only the owner can add or remove voters from the group.
  * _Governor-Mintable-Admined_ – Same as _Governor-Mintable_, but only admins from the group can add or remove voters.

## Usage

We use Truffle and Ganache to compile, deploy and test these smart contracts.
In addition, we use Yarn to keep track of dependencies.

In a given contract directory, `yarn install` or `npm install` will download and install a contract's dependencies for you.
Have `ganache-cli` running in a separate terminal when you enter `truffle test` to compile and deploy a contract and run its tests.

For example, you might run the following steps to test all contracts using Truffle and NPM:

```sh
# Install ganache and truffle
npm install -g ganache-cli
npm install -g truffle

# Start Ganache
ganache-cli > /dev/null &

# Test each of the contracts
for d in computer database erc20; do
  ( cd $d; npm install; truffle test )
done

# Stop Ganache
kill -9 $(jobs -p)
```


## Acknowledgements

The code in this repository is based on [the project of TNO](https://github.com/TNO/smartcontract-governance-bootstrap)
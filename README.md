# Bootstrapping smart contract governance using governor contracts

_Note: the smart contracts in this repository have not been extensively reviewed for bugs. Use at your own risk!_

This repository contains several smart contracts intended to demonstrate approaches to governance of smart contracts.
We focus on upgradeability of a contract's code, data storage and ether storage.
In addition, we provide several examples of how to authorize upgrades, and how to change the policies that are used to check if someone is allowed to perform an upgrade.

In each of the use cases in this repository, there is a primary (proxy) contract that does not change after deployment. This proxy contract will forward any method invocation to the registered logic contract. Currently we support two types of proxy contracts:

1. A proxy that uses "delegatecall" to forward unknown methods. This means that the call will execute in the context of the proxy contract. This means that any upgrade needs to be compatible with the existing storage layout!
2. A proxy that uses a regular "call" to forward unknown methods. With this approach the logic contract manages its own storage, which will need to be transfered when the logic code is upgraded. An important downside is that `msg.sender` is set to the proxy contract, making some functionality unfeasible.

In addition, each proxy contract has one or more governor contracts.
A governor is a contract that controls access to some or all functionality of the proxy contract, such as upgrades of the contract's logic contracts.
In addition, the governor can be asked to replace itself by a new governor (possibly with different access control policies).

If someone wishes to access one of the governed functions of the proxy contract, they must use the corresponding function in the governor contract; the governor will check the policies, and if the request is allowed, it will forward the request to the proxy contract.
The proxy contract will only allow such requests from the governor, so unauthorized use of these governed functions is prevented.

## Types of governors

For each use case, we implement a few examples of governor contracts.
These are referred to by common names, which is explained below.

* _Nobody_ will not allow anyone to do anything.
* _Owner_ will allow only its creator to do everything.
* _VoteOne_ will allow its creator to add people to a group of valid users (and remove them). Everyone in the group is allowed to do everything.
* _VoteAll_ is like _VoteOne_, but everyone in the group needs to agree before anything can be done. Proposal and agreement is done via a `vote` function.
* The above _VoteSomething_ contracts have _NoLeader_ variants, in which the special role of the creator is removed.
  - _VoteOneNoLeader_ is an anarchy, and should only be used by groups of mutually trusted agents, since anyone can add anyone else to the group (or remove them).
  - _VoteAllNoLeader_ is meant for un-trusting groups, as the owner can no longer kick out anyone on its own. Voting takes place for any change to the group composition.

## Use cases

These are the use cases currently available.

### Computer
The computer contract is a simple example: it has a `compute` function, which emits an event.
We pretend that this function is worthy of protection.

The computer has two governors, which can be changed to any of the available variants independently.
The *update* governor is allowed to control who gets to replace any of the two governors.
The *execute* governor is allowed to control who gets to execute the `compute` function.

The computer contract is initialized with an _Owner_ governor as its *update* governor, and a _Nobody_ governor as its *execute* governor.
We consider this to be the minimal viable set of governors; to actually use the `compute` functionality, a governor update is needed.

### Database
The database example showcases the possibility of placing also the contract's storage in a different contract, called the `Storage`.
The primary contract calls into the Storage contract to read and write data, and the Storage contract provides this functionality only to the primary contract.

This allows upgrade of even the proxy without having to recreate the data.
The database offers a facility, guarded by the *update* governor, to transfer the ownership of the Storage to a new primary contract.

### ERC-20 token
The token example shows how a standard Ethereum ERC-20 token could be governed by our governor contracts.
This example has a primary contract acting as a proxy, a secondary contract implementing the ERC-20 interface, and a Storage contract that survives updates of the secondary contract and provides storage of the token database, analogously to the database example above.

Since the ERC-20 standard provides its own functional access control, there is only one governor, which acts as the *update* governor.
In addition to replacing itself, the governor can replace the ERC-20 token contract, transferring the Storage ownership to the replacement ERC-20 contract.

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

The code in this repository was developed in the context of the [Techruption programme](https://www.techruption.org/) and a research project by the [Dutch Blockchain Coalition (DBC)](https://dutchblockchaincoalition.org/en).

In addition, this activity is partially funded from the "PPS-toeslag onderzoek en innovatie" from the Dutch Ministry of Economic Affairs and Climate Policy.

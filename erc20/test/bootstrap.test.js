const Proxy          = artifacts.require('Proxy');
const Governor_Nobody = artifacts.require('Governor_Nobody');
const Governor_Owner = artifacts.require('Governor_Owner');
const Governor_VoteOne = artifacts.require('Governor_VoteOne');
const Governor_VoteOne_NoLeader = artifacts.require('Governor_VoteOne_NoLeader');
const Governor_VoteAll = artifacts.require('Governor_VoteAll');
const Governor_VoteAll_NoLeader = artifacts.require('Governor_VoteAll_NoLeader');
const GovernedToken  = artifacts.require('GovernedToken');
const ReplacementTok = artifacts.require('GovernedReplacementToken');
const Storage        = artifacts.require('TokenStorage')

const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract('Governor replacement', (accounts) => {
    const ownerAccount = accounts[0];
    const friendAccount = accounts[1];

    var governor, token, proxy, proxiedToken;

    it("should pass setup", async () => {
        // Find the contract addresses
        proxy = await Proxy.deployed();
        token = await GovernedToken.deployed();
        proxiedToken = await GovernedToken.at(proxy.address);
        await truffleAssert.passes(
            proxiedToken.initialize(
                /* supply   */ 1000000,
                /* name     */ "TestToken",
                /* symbol   */ "TEST",
                /* decimals */ 8)
        );

        let govAddr = await proxy._governor();
        governor = await Governor_Owner.at(govAddr);
    });

    it("should provide ERC20 functionality", async () => {
        // Send some tokens to someone else
        await truffleAssert.passes(
            proxiedToken.transfer(friendAccount, 10)
        );
        let friendStartBalance= await proxiedToken.balanceOf(friendAccount);
        assert.equal(friendStartBalance, 10, "Transfer failed");
    });

    it("should allow bootstrapping: owner -> VoteOne", async () => {
        // Make a new governor pointing to existing proxy
        let newGovernor = await Governor_VoteOne.new(proxy.address);

        // Ask old governor to update the governor
        await truffleAssert.passes(
            governor.updateGovernor(newGovernor.address)
        );

        // Remember the new governor
        governor = newGovernor;
    });

    it("should allow adding voters to VoteOne", async () => {
        // Add a few friends as voters
        await truffleAssert.passes(governor.modifyVoter(accounts[1], true));
        await truffleAssert.passes(governor.modifyVoter(accounts[2], true));
        await truffleAssert.passes(governor.modifyVoter(accounts[3], true));
    });

    it("should allow bootstrapping: VoteOne -> VoteOne NoLeader (as voter 2)", async () => {
        let newGovernor = await Governor_VoteOne_NoLeader.new(proxy.address);

        await truffleAssert.passes(
            governor.updateGovernor(newGovernor.address, {from: accounts[2]})
        );

        governor = newGovernor;
    });

    it("should allow adding voters to VoteOne NoLeader", async () => {
        await truffleAssert.passes(governor.modifyVoter(accounts[1], true));
        await truffleAssert.passes(governor.modifyVoter(accounts[2], true, {from: accounts[1]}));
        await truffleAssert.passes(governor.modifyVoter(accounts[3], true));
    });

    it("should allow bootstrapping: VoteOne NoLeader -> VoteAll (as voter 3)", async () => {
        let newGovernor = await Governor_VoteAll.new(proxy.address);

        await truffleAssert.passes(
            governor.updateGovernor(newGovernor.address, {from: accounts[3]})
        );

        governor = newGovernor;
    });

    it("should allow adding voters to VoteAll", async () => {
        await truffleAssert.passes(governor.modifyVoter(accounts[1], true));
        await truffleAssert.passes(governor.modifyVoter(accounts[2], true));
        await truffleAssert.passes(governor.modifyVoter(accounts[3], true));
    });

    it("should allow bootstrapping: VoteAll -> VoteAll NoLeader", async () => {
        let newGovernor = await Governor_VoteAll_NoLeader.new(proxy.address, [accounts[0], accounts[1], accounts[2], accounts[3]]);

        // We have to vote on this "proposal" before we can execute it
        let action = 1; // replace governor
        let executor = accounts[1];
        let newAddress = newGovernor.address;

        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[0]}));
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[1]}));
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[2]}));
        
        // Now actually do it
        await truffleAssert.fails(
            governor.updateGovernor(newAddress, {from: executor})
        );

        // Oops forgot a vote
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[3]}));

        // Try again
        await truffleAssert.passes(
            governor.updateGovernor(newAddress, {from: executor})
        );

        governor = newGovernor;
    });

    it("should allow replacing the logic address (with VoteAll)", async () => {
        let newToken = await ReplacementTok.new();

        // We have to vote on this "proposal" before we can execute it
        let action = 0; // replace logic 
        let executor = accounts[1];
        let newAddress = newToken.address;

        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[0]}));
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[1]}));
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[2]}));
        
        // Now actually do it
        await truffleAssert.fails(
            governor.updateLogic(newAddress, {from: executor})
        );

        // Oops forgot a vote
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[3]}));

        // Try again
        await truffleAssert.passes(
            governor.updateLogic(newAddress, {from: executor})
        );

    });

    it("should have updated logic after replacement", async () => {
        // The new code has and odd feature: if you check the balance it will return the value + 1.
        // Let's see whether that works.
        let friendBalance = await proxiedToken.balanceOf(friendAccount);
        assert.equal(friendBalance, 11, "Friend lost their money during the update!");
    });


    it("should allow bootstrapping: VoteAll NoLeader -> Nobody", async () => {
        let newGovernor = await Governor_Nobody.new(proxy.address);

        // We have to vote on this "proposal" before we can execute it
        let action = 1; // replace governor
        let executor = accounts[0];
        let newAddress = newGovernor.address;

        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[0]}));
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[1]}));
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[2]}));
        
        // Now actually do it
        await truffleAssert.fails(
            governor.updateGovernor(newAddress, {from: executor})
        );

        // Oops forgot a vote
        await truffleAssert.passes(governor.vote(action, executor, newAddress, {from: accounts[3]}));

        // Try again
        await truffleAssert.passes(
            governor.updateGovernor(newAddress, {from: executor})
        );

        governor = newGovernor;
    });
});

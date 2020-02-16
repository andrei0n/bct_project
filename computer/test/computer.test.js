const Computer = artifacts.require('Computer');
const Proxy = artifacts.require('CallProxy');
const CallProxy = artifacts.require('CallProxy');
const Governor_Owner = artifacts.require('Governor_Owner');
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract('Computer', (accounts) => {
    const ownerAccount = accounts[0];

    it("should work", async () => {
        // Deploy the contract and find the governor-update address
        let computer = await Computer.deployed();
        let proxy = await CallProxy.deployed();
        let govAddr = await proxy._governor();
        let governor = await Governor_Owner.at(govAddr);
        let computerProxied = await Computer.at(proxy.address)

        // Replace the governor-execute by itself
        await truffleAssert.passes(
            governor.updateGovernor(govAddr)
        );

        // Try to execute
        await truffleAssert.passes(
            computerProxied.compute()
        );
    });
});

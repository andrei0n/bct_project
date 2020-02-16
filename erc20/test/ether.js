const Proxy          = artifacts.require('Proxy');
const ERC20_Token    = artifacts.require('ERC20_Token');
const Governor_Owner = artifacts.require('Governor_Owner');
const GovernedToken  = artifacts.require('GovernedToken');
const ReplacementTok = artifacts.require('GovernedReplacementToken');
const Storage        = artifacts.require('TokenStorage')

const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract('Ether sending should fail', (accounts) => {
    const ownerAccount = accounts[0];

    it("Proxy", async () => {
        let proxy = await Proxy.deployed();

        await truffleAssert.fails(
            proxy.send(10, {from: ownerAccount})
        );
    });

    it("Governor", async () => {
        let proxy = await Proxy.deployed();
        let govAddr = await proxy._governor();
        let governor = await Governor_Owner.at(govAddr);

        await truffleAssert.fails(
            governor.send(10, {from: ownerAccount})
        );
    });

    it("GovernedToken at Proxy", async () => {
        // Deploy the contract and find the governor-update address
        let proxy = await Proxy.deployed();
        let govAddr = await proxy._governor();
        let governor = await Governor_Owner.at(govAddr);

        // Let's use the proxy for the GovernedToken
        let proxiedToken = await GovernedToken.at(proxy.address);

        await truffleAssert.fails(
            proxiedToken.send(10, {from: ownerAccount})
        );
    });

    it("GovernedToken directly", async () => {
        // Deploy the contract and find the governor-update address
        let proxy = await Proxy.deployed();
        let govAddr = await proxy._governor();
        let governor = await Governor_Owner.at(govAddr);

        // Let's use the proxy for the GovernedToken
        let tokenAddr = await(proxy._logic());
        let proxiedToken = await GovernedToken.at(tokenAddr);

        await truffleAssert.fails(
            proxiedToken.send(10, {from: ownerAccount})
        );
    });

    it("ReplacementToken", async () => {
        // Deploy the contract and find the governor-update address
        let proxy = await Proxy.deployed();
        let govAddr = await proxy._governor();
        let governor = await Governor_Owner.at(govAddr);

        // Let's use the proxy for the GovernedToken
        let proxiedToken = await GovernedToken.at(proxy.address);

        await truffleAssert.passes(
            proxiedToken.initialize(
                /* supply   */ 1000000,
                /* name     */ "TestToken",
                /* symbol   */ "TEST",
                /* decimals */ 8)
        );

        // Let's now deploy alternative code for the token 
        let newToken = await ReplacementTok.new();
        // And ask the governor to replace it
        await truffleAssert.fails(
            newToken.send(10, {from: ownerAccount})
        );
    });
});

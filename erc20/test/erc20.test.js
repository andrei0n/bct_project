const Proxy          = artifacts.require('Proxy') 
const ERC20_Token    = artifacts.require('ERC20_Token') 
const Governor_Owned = artifacts.require('Governor_Owned') 
const GovernedToken  = artifacts.require('GovernedToken') 
const ReplacementTok = artifacts.require('GovernedReplacementToken') 
const Storage        = artifacts.require('TokenStorage')

const assert = require("chai").assert 
const truffleAssert = require('truffle-assertions') 

contract('Proxy and logic replacement', (accounts) => {
    const ownerAccount = accounts[0] 

    it("should work", async () => {
        // Deploy the contract and find the governor-update address
        let proxy = await Proxy.deployed() 
        let govAddr = await proxy._governor() 
        let governor = await Governor_Owned.at(govAddr) 

        // Try to execute
        await truffleAssert.passes(proxy._logic()) 
    }) 

    it("should allow replacement", async () => {
        // Deploy the contract and find the governor-update address
        let proxy = await Proxy.deployed() 
        let govAddr = await proxy._governor() 
        let governor = await Governor_Owned.at(govAddr) 

        // Let's use the proxy for the GovernedToken
        let proxiedToken = await GovernedToken.at(proxy.address) 

        await truffleAssert.passes(proxiedToken.initialize(
                /* supply   */ 1000000,
                /* name     */ "TestToken",
                /* symbol   */ "TEST",
                /* decimals */ 8)) 

        // Send some tokens to someone else
        const friendAccount = accounts[1] 
        await truffleAssert.passes(proxiedToken.transfer(friendAccount, 10)) 

        // Check whether the transfer proxy works
        let friendStartBalance= await proxiedToken.balanceOf(friendAccount) 
        assert.equal(friendStartBalance, 10, "Transfer failed") 

        // Let's transfer some more
        await truffleAssert.passes(proxiedToken.transfer(friendAccount, 12)) 

        let friendNewBalance= await proxiedToken.balanceOf(friendAccount) 
        assert.equal(friendNewBalance, 22, "Transfer failed") 

        // Let's now deploy alternative code for the token 
        let newToken = await ReplacementTok.new() 
        // And ask the governor to replace it
        await truffleAssert.passes(governor.updateLogic(newToken.address)) 

        // The new code has and odd feature: if you check the balance it will return the value + 1.
        // Let's see whether that works.
        let friendBalance = await proxiedToken.balanceOf(friendAccount) 
        assert.equal(friendBalance, 23, "Friend lost their money during the update!") 
    }) 
}) 

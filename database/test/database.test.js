const Database       = artifacts.require('Database') 
const CallProxy      = artifacts.require('CallProxy') 
const Governor_Owned = artifacts.require('Governor_Owned') 

const assert = require("chai").assert 
const truffleAssert = require('truffle-assertions') 

contract('Database', (accounts) => {
    const ownerAccount = accounts[0] 

    it("should work", async () => {
        // Deploy the contract and find the governor-update address
        let database = await Database.deployed() 
        let proxy = await CallProxy.deployed() 
        let govAddr = await proxy._governor() 
        let governor = await Governor_Owned.at(govAddr) 
        let proxiedDatabase = await Database.at(proxy.address) 

        // Try to set a value 
        await truffleAssert.passes(proxiedDatabase.set(govAddr, 16)) 

        // Replace the governor-execute by itself
        await truffleAssert.passes(governor.updateGovernor(govAddr)) 

        let value = await proxiedDatabase.get(govAddr) 
        assert.equal(value, 16, "Could not retrieve stored value from database")

        let valueDirect = await database.get(govAddr) 
        assert.equal(valueDirect, 16, "Could not retrieve stored value from database")

    }) 
}) 

const Computer = artifacts.require('Computer')
const CallProxy = artifacts.require('CallProxy')

const Governor = artifacts.require('Governor')
const Governor_Admined = artifacts.require('Governor_Admined')
const Governor_Owned = artifacts.require('Governor_Owned')
const Governor_Any = artifacts.require('Governor_Any')
const Governor_Any_Admined = artifacts.require('Governor_Any_Admined')
const Governor_Any_Owned = artifacts.require('Governor_Any_Owned')
const Governor_Cohort = artifacts.require('Governor_Cohort')
const Governor_Cohort_Consortium = artifacts.require('Governor_Cohort_Consortium')
const Governor_Cohort_Delegate = artifacts.require('Governor_Cohort_Delegate')

const assert = require("chai").assert
const truffleAssert = require('truffle-assertions')


contract('Computer', (accounts) => {
    const ownerAccount = accounts[0]

    it("governor test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var governor = await Governor.new(proxy.address)

        await truffleAssert.passes(governor_owned.updateGovernor(governor.address))

        var logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.passes(governor.updateLogic(computer2.address, { from: accounts[1] }))

        logic = await proxy._logic()
        assert.equal(logic, computer2.address)
    })

    it("owned governor test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()

        await truffleAssert.passes(governor_owned.updateLogic(computer2.address))

        var logic = await proxy._logic()
        assert.equal(logic, computer2.address)

        await truffleAssert.reverts(
            governor_owned.updateLogic(computer.address, { from: accounts[1] }))
        await truffleAssert.passes(governor_owned.transferOwnership(accounts[1]))
        await truffleAssert.reverts(
            governor_owned.updateLogic(computer.address, { from: accounts[0] }))
        await truffleAssert.passes(governor_owned.updateLogic(computer.address, { from: accounts[1] }))
    })

    it("admined governor test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var governor_admined = await Governor_Admined.new(proxy.address, [accounts[1]])

        await truffleAssert.passes(governor_owned.updateGovernor(governor_admined.address))

        var logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.reverts(
            governor_admined.updateLogic(computer2.address, { from: accounts[0] }))

        var logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.passes(governor_admined.updateLogic(computer.address, { from: accounts[1] }))

        logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.fails(governor_admined.modifyAdmin(accounts[0], true))
        await truffleAssert.passes(governor_admined.modifyAdmin(accounts[0], true, { from: accounts[1] }))
        await truffleAssert.passes(governor_admined.modifyAdmin(accounts[2], true))
    })

    it("governor any test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var governor_any = await Governor_Any.new(proxy.address)

        await truffleAssert.passes(governor_owned.updateGovernor(governor_any.address))

        var logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.fails(governor_any.updateLogic(computer2.address, { from: accounts[1] }))
        await truffleAssert.passes(governor_any.modifyVoter(accounts[1], true, { from: accounts[1] }))
        await truffleAssert.passes(governor_any.updateLogic(computer2.address, { from: accounts[1] }))

        logic = await proxy._logic()
        assert.equal(logic, computer2.address)
    })

    it("admined governor any test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var admin = accounts[0]
        var admin2 = accounts[3]
        var user = accounts[1]
        var voter = accounts[2]
        var governor_any_admined = await Governor_Any_Admined.new(proxy.address, [admin, admin2])

        await truffleAssert.passes(governor_owned.updateGovernor(governor_any_admined.address))

        var logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.fails(governor_any_admined.updateLogic(computer2.address, { from: user }))
        await truffleAssert.passes(governor_any_admined.modifyVoter(voter, true, { from: admin }))
        await truffleAssert.fails(governor_any_admined.updateLogic(computer2.address, { from: admin2 }))
        await truffleAssert.passes(governor_any_admined.updateLogic(computer2.address, { from: voter }))

        logic = await proxy._logic()
        assert.equal(logic, computer2.address)
    })

    it("owned governor any test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var owner = accounts[0]
        var user = accounts[1]
        var voter = accounts[2]
        var governor_any_owned = await Governor_Any_Owned.new(proxy.address, owner)

        await truffleAssert.passes(governor_owned.updateGovernor(governor_any_owned.address, { from: owner }))

        var logic = await proxy._logic()
        assert.equal(logic, computer.address)

        await truffleAssert.fails(governor_any_owned.updateLogic(computer2.address, { from: user }))
        await truffleAssert.fails(governor_any_owned.modifyVoter(voter, true, { from: user }))
        await truffleAssert.passes(governor_any_owned.modifyVoter(voter, true, { from: owner }))
        await truffleAssert.fails(governor_any_owned.updateLogic(computer2.address, { from: owner }))
        await truffleAssert.passes(governor_any_owned.updateLogic(computer2.address, { from: voter }))

        logic = await proxy._logic()
        assert.equal(logic, computer2.address)
    })

    it("governor cohort test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var governor_cohort = await Governor_Cohort.new(proxy.address, 100)

        await truffleAssert.passes(governor_owned.updateGovernor(governor_cohort.address))
        await truffleAssert.passes(governor_cohort.modifyVoter(accounts[0], true))
        await truffleAssert.passes(governor_cohort.modifyVoter(accounts[1], true))
        await truffleAssert.passes(governor_cohort.vote(0, accounts[0], computer2.address))
        await truffleAssert.passes(governor_cohort.vote(0, accounts[0], computer2.address, { from: accounts[1] }))

        var proposals = await governor_cohort._proposals()
        assert.equal(proposals[1].length, 1)
        var key = await governor_cohort.mapkey(proposals[0][0].toNumber(), proposals[1][0], proposals[2][0])
        var addresses = await governor_cohort.votersFor(key)
        assert.equal(addresses.length, 2)

        await truffleAssert.fails(governor_cohort.updateLogic(computer2.address, { from: accounts[1] }))
        await truffleAssert.passes(governor_cohort.updateLogic(computer2.address, { from: accounts[0] }))

        proposals = await governor_cohort._proposals()
        assert.equal(proposals[1].length, 0)

        await truffleAssert.passes(governor_cohort.vote(0, accounts[0], computer.address))
        await truffleAssert.passes(governor_cohort.vote(0, accounts[1], computer.address, { from: accounts[1] }))

        proposals = await governor_cohort._proposals()
        assert.equal(proposals[1].length, 2)
        key = await governor_cohort.mapkey(proposals[0][0].toNumber(), proposals[1][0], proposals[2][0])
        addresses = await governor_cohort.votersFor(key)
        assert.equal(addresses.length, 1)
        key = await governor_cohort.mapkey(proposals[0][1].toNumber(), proposals[1][1], proposals[2][1])
        addresses = await governor_cohort.votersFor(key)
        assert.equal(addresses.length, 1)

        await truffleAssert.fails(governor_cohort.updateLogic(computer.address, { from: accounts[0] }))
        await truffleAssert.fails(governor_cohort.updateLogic(computer.address, { from: accounts[1] }))
        await truffleAssert.passes(governor_cohort.vote(0, accounts[1], computer.address))
        await truffleAssert.passes(governor_cohort.updateLogic(computer.address, { from: accounts[1] }))
    })

    it("consortium governor cohort test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var governor_cohort_Consortium = await Governor_Cohort_Consortium.new(proxy.address, 100, [accounts[0], accounts[1]])

        var amountOfVotesForPositiveDecision = await governor_cohort_Consortium.amountOfVotesForPositiveDecision()
        assert.equal(amountOfVotesForPositiveDecision, 2)

        await truffleAssert.passes(governor_owned.updateGovernor(governor_cohort_Consortium.address))
        await truffleAssert.fails(governor_cohort_Consortium.modifyVoter(accounts[2], true, { from: accounts[3] }))

        await truffleAssert.passes(governor_cohort_Consortium.vote(3, accounts[1], accounts[2]))
        await truffleAssert.passes(governor_cohort_Consortium.vote(3, accounts[1], accounts[2], { from: accounts[1] }))
        await truffleAssert.passes(governor_cohort_Consortium.modifyVoter(accounts[2], true, { from: accounts[1] }))
        
        var amountOfVotesForPositiveDecision = await governor_cohort_Consortium.amountOfVotesForPositiveDecision()
        assert.equal(amountOfVotesForPositiveDecision, 3)

        await truffleAssert.passes(governor_cohort_Consortium.vote(4, accounts[0], accounts[1], { from: accounts[2] }))
        await truffleAssert.passes(governor_cohort_Consortium.vote(4, accounts[0], accounts[1], { from: accounts[1] }))

        var proposals = await governor_cohort_Consortium._proposals()
        assert.equal(proposals[1].length, 1)
        var key = await governor_cohort_Consortium.mapkey(proposals[0][0].toNumber(), proposals[1][0], proposals[2][0])
        var addresses = await governor_cohort_Consortium.votersFor(key)
        assert.equal(addresses.length, 2)

        await truffleAssert.passes(governor_cohort_Consortium.modifyVoter(accounts[1], false, { from: accounts[0] }))
        var amountOfVotesForPositiveDecision = await governor_cohort_Consortium.amountOfVotesForPositiveDecision()
        assert.equal(amountOfVotesForPositiveDecision, 2)
    })

    it("delegate governor cohort test", async () => {
        var computer = await Computer.new()
        var proxy = await CallProxy.new(computer.address)
        var govAddr = await proxy._governor()
        var governor_owned = await Governor_Owned.at(govAddr)
        var computer2 = await Computer.new()
        var governor_delegate = await Governor_Cohort_Delegate.new(proxy.address, 100)

        await truffleAssert.passes(governor_owned.updateGovernor(governor_delegate.address))
        await truffleAssert.passes(governor_delegate.modifyVoter(accounts[0], true))
        await truffleAssert.passes(governor_delegate.modifyVoter(accounts[1], true))
        await truffleAssert.passes(governor_delegate.vote(0, accounts[0], computer2.address))
        await truffleAssert.passes(governor_delegate.vote(0, accounts[0], computer2.address, { from: accounts[1] }))

        var proposals = await governor_delegate._proposals()
        assert.equal(proposals[1].length, 1)
        var key = await governor_delegate.mapkey(proposals[0][0].toNumber(), proposals[1][0], proposals[2][0])
        var addresses = await governor_delegate.votersFor(key)

        assert.equal(addresses.length, 2)

        await truffleAssert.fails(governor_delegate.updateLogic(computer2.address, { from: accounts[1] }))
        await truffleAssert.passes(governor_delegate.updateLogic(computer2.address, { from: accounts[0] }))

        proposals = await governor_delegate._proposals()
        assert.equal(proposals[1].length, 0)

        await truffleAssert.passes(governor_delegate.vote(0, accounts[0], computer.address, { from: accounts[1] }))
        await truffleAssert.passes(governor_delegate.vote(0, accounts[0], computer.address, { from: accounts[0] }))
        await truffleAssert.passes(governor_delegate.delegateTo(accounts[1]))

        proposals = await governor_delegate._proposals()
        assert.equal(proposals[1].length, 1)

        var key = await governor_delegate.mapkey(proposals[0][0].toNumber(), proposals[1][0], proposals[2][0])
        var amountWithDelegates = await governor_delegate.amountOfVotes(key)
        assert.equal(amountWithDelegates, 2)

        var amountOfVotesForPositiveDecision = await governor_delegate.amountOfVotesForPositiveDecision()
        assert.equal(amountOfVotesForPositiveDecision, 2)

        await truffleAssert.passes(governor_delegate.updateLogic(computer.address, { from: accounts[0] }))
    })
}) 

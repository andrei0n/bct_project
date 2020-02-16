// Fetch the Database contract data
var Proxy = artifacts.require("./Proxy");
var GovernedToken = artifacts.require("./GovernedToken");
var GovernedReplacementToken  = artifacts.require("./GovernedReplacementToken");
var Governor_VoteAll  = artifacts.require("./Governor_VoteAll");
// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.then(function() {
        return deployer.deploy(GovernedToken);
    })
    .then(function(t) {
        return deployer.deploy(Proxy, t.address);
    })
    .then(function() {
        return GovernedToken.deployed()
    })
    .then(function(t) {
        return t.transferOwnership(Proxy.address);
    })
    .then(function() {
        return deployer.deploy(GovernedReplacementToken);
    })
    .then(function() {
        // Governor_VoteAll.gasMultiplier(1.5);
        return deployer.deploy(Governor_VoteAll, Proxy.address);
    });
}

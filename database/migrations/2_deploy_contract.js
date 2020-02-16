// Fetch the Database contract data
var Database = artifacts.require("./Database");
var CallProxy = artifacts.require("./CallProxy");
var Storage = artifacts.require("./Storage");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    var sto;

    deployer.then(function() {
        return deployer.deploy(Storage)
    })
    .then(function(instanceOfSto) {
        sto = instanceOfSto;
        return deployer.deploy(Database, sto.address);
    })
    .then(function(instanceOfDat) {
        sto.transferOwnership(instanceOfDat.address);
        return deployer.deploy(CallProxy, instanceOfDat.address)
    })
    .then(function() {
        // return Database.deployed()
    })
    .then(function(d) {
        // return d.transferOwnership(CallProxy.address);
    });
}

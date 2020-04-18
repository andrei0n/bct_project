// Fetch the Computer contract data
var Computer = artifacts.require("./Computer") 
var CallProxy = artifacts.require("./CallProxy") 

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.deploy(Computer).then(function() {
        return deployer.deploy(CallProxy, Computer.address) 
    }) 
}

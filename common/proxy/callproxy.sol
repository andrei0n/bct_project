pragma solidity ^0.5.0;

import {Proxy} from "./proxy.sol";

contract IReplaceable {
    function beReplaced(address newContract) external {}
}

/**
 * CallProxy is an alternative proxy that does not use "delegatecall", but instead a simple "call". This has the downside
 * that the logic address cannot use msg.sender anymore, requiring additional work and/or limited functionality.
 */
contract CallProxy is Proxy {
    /**
     * Constructor for the Proxy. Note that the Proxy deploys the first governor for you,
     * otherwise it's a chicken and egg problem.
     * 
     */
    constructor(address logic) Proxy(logic) public {}

    /**
     * Updates the pointer to the logic address. Only the Governor should be able to do this. In addition
     * this will call the "beReplaced" method to prepare the old logic contract for the transplant.
     */
    function updateLogic(address newLogic) external
             Governed() {
        IReplaceable(_logic()).beReplaced(newLogic);
        _setLogic(newLogic);
        emit NewMemberContracts(_logic(), _governor());
    }


    /**
     * We forward all calls to unknown methods to the logic contract. Note that here we use
     * a regular "call", so the logic's own storage is used. Also note that in the logic contract
     * msg.sender will be the address of the proxy! 
     */
    function() external payable {
       address logic = _logic();
       // Taken from: https://github.com/OpenZeppelin/openzeppelin-sdk/blob/dc9e4edf1169eb8bd675961c9d821d1a712a70df/packages/lib/contracts/upgradeability/Proxy.sol

       assembly {
           // Copy msg.data. We take full control of memory in this inline assembly
           // block because it will not return to Solidity code. We overwrite the
           // Solidity scratch pad at memory position 0.
           calldatacopy(0, 0, calldatasize)

           // Call the implementation.
           // out and outsize are 0 because we don't know the size yet.
           let result := call(gas, logic, callvalue, 0, calldatasize, 0, 0)

           // Copy the returned data.
           returndatacopy(0, 0, returndatasize)

           switch result
           // call returns 0 on error.
           case 0 { revert(0, returndatasize) }
           default { return(0, returndatasize) }
       }
   }
}

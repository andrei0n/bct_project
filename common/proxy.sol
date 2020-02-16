pragma solidity ^0.5.0;

import {Governor_Owner} from "./governor-owner.sol";

contract Proxy {
    // We use standard proxy storage slots as specified in EIP-1967
    // (https://eips.ethereum.org/EIPS/eip-1967)

    // Storage slot for storing the address of the logic implementation 
    // obtained as bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 internal constant LOGIC_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // Storage slot for storing the address of the governor
    // obtained as bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 internal constant GOVERNOR_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event NewMemberContracts(
        address logic,
        address governor
    );

    /**
     * Returns the current logic address
     */
    function _logic() public view returns (address impl) {
        bytes32 slot = LOGIC_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * Sets the logic address, only used internally
     */
    function _setLogic(address newLogic) internal {
        bytes32 slot = LOGIC_SLOT;
        assembly {
            sstore(slot, newLogic)
        }
    }

    /**
     * Returns the current governer address
     */
    function _governor() public view returns (address impl) {
        bytes32 slot = GOVERNOR_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * Sets the governor address, only used internally
     */
    function _setGovernor(address newGovernor) internal {
        bytes32 slot = GOVERNOR_SLOT;
        assembly {
            sstore(slot, newGovernor)
        }
    }

    /**
     * Constructor for the Proxy. Note that the Proxy deploys the first governor for you,
     * otherwise it's a chicken and egg problem.
     * 
     */
    constructor(address logic) public {
        _setLogic(logic);
        _setGovernor(address(new Governor_Owner(address(this), msg.sender)));
        emit NewMemberContracts(_logic(), _governor());
    }

    /**
     * Updates the pointer to the logic address. Only the Governor should be able to do this.
     */
    function updateLogic(address newLogic) external
             Governed() {
        _setLogic(newLogic);
        emit NewMemberContracts(_logic(), _governor());
    }
    /**
     * Updates the pointer to the governor address. Only the Governor should be able to do this.
     */
    function updateGovernor(address governor) external
             Governed() {
        _setGovernor(governor);
        emit NewMemberContracts(_logic(), _governor());
    }

    modifier Governed() {
        require(msg.sender == _governor(), "Only the governor may call this function");
        _;

    }

    /**
     * We forward all calls to unknown methods to the logic contract. Note that here we use
     * a delegate call, so the logic's methods are excuted within the context (storage) of this
     * proxy contract. This means that the logic contract (and any update) needs to be careful
     * with the storage.
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
           let result := delegatecall(gas, logic, 0, calldatasize, 0, 0)

           // Copy the returned data.
           returndatacopy(0, 0, returndatasize)

           switch result
           // delegatecall returns 0 on error.
           case 0 { revert(0, returndatasize) }
           default { return(0, returndatasize) }
       }
   }
}

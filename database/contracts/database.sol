pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import { IReplaceable } from './common/proxy/callproxy.sol';

contract Database is Ownable, IReplaceable {
    Storage databaseStorage;

    constructor(address _databaseStorage) public {
        databaseStorage = Storage(_databaseStorage);
    }

    function set(address a, uint v) external 
             NeedsValidStorage() {
        databaseStorage.set(a, v);
    }

    function get(address a) external view
             NeedsValidStorage() returns(uint) {
        return databaseStorage.get(a);
    }

    // The storage can be transferred to a new Database contract, in case this one is 
    // deemed unfit. The new owner should be passed.
    function beReplaced(address newOwner) public onlyOwner() {
        databaseStorage.transferOwnership(newOwner);
        databaseStorage = Storage(0x0);
    }

    modifier NeedsValidStorage() {
        require(address(databaseStorage) != address(0), "Storage contract was renounced");
        _;
    }
}

contract Storage is Ownable {
    mapping (address => uint) valuation;

    function set(address a, uint v) external onlyOwner() {
        valuation[a] = v;
    }

    function get(address a) external view onlyOwner() returns(uint) {
        return valuation[a];
    }
}
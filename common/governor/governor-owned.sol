pragma solidity ^0.5.0;

import { Owned } from "../ownership/owned.sol";
import { Governor } from "./governor.sol";

//The governor where only the owner has the power to modify.
contract Governor_Owned is Governor, Owned {
    constructor(address _proxy, address _owner) Governor(_proxy) Owned(_owner) public {
        owner = _owner;
    }
    
    modifier onlyIfApproved(uint, address)  {
        require (msg.sender == owner, "Governor_Owned: Only the owner may do this");
        _;
    }
}
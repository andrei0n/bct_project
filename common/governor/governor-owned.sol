pragma solidity ^0.5.0;

import {Owned} from "../ownership/owned.sol";
import {Governor} from "./governor.sol";

contract Governor_Owned is Governor, Owned {
    constructor(address _proxy, address _owner) Governor(_proxy) Owned(_owner) public {
        owner = _owner;
    }
    
    modifier onlyIfApproved(uint, address)  {
        require (msg.sender == owner, "Governor: Only the owner may do this");
        _;
    }
}
pragma solidity ^0.5.0;

import {Governor} from "./governor.sol";

contract Governor_Owner is Governor {
    address private owner;

    constructor(address _proxy, address _owner) Governor(_proxy) public {
        owner = _owner;
    }

    modifier onlyIfApproved(uint, address) {
        require (msg.sender == owner, "Governor: Only the owner may do this");
        _;
    }
}

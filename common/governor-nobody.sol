pragma solidity ^0.5.0;

import {Governor} from "./governor.sol";

// This governor does not allow anything. Setting it as the update governor
// will prevent future updates!
contract Governor_Nobody is Governor {
    constructor(address _proxy) Governor(_proxy) public {}

    modifier onlyIfApproved(uint, address) {
        revert ("Governor: Nobody may do this");
        _;
    }
    
}

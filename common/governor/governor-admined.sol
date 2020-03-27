pragma solidity ^0.5.0;

import {Admined} from "../ownership/admined.sol";
import {Governor} from "./governor.sol";

contract Governor_Admined is Governor, Admined {
    constructor(address _proxy, address _admin) Governor(_proxy) Admined(_admin) public {
        admins[_admin] = true;
    }
    
    modifier onlyIfApproved(uint, address) {
        require (admins[msg.sender], "Governor: Only admin can do this");
        _;
    }
}
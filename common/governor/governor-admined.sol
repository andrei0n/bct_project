pragma solidity ^0.5.0;

import { Admined } from "../ownership/admined.sol";
import { Governor } from "./governor.sol";

//The governor where only the admin has the power to modify.
contract Governor_Admined is Governor, Admined {
    constructor(address _proxy, address[] memory _admins) Governor(_proxy) Admined(_admins) public { }
    
    modifier onlyIfApproved(uint, address) {
        require (admins[msg.sender], "Governor_Admined: Only admin can do this");
        _;
    }
}
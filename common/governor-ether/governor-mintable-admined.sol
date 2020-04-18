pragma solidity ^0.5.0;

import { Admined } from "../ownership/admined.sol";
import { Governor_Mintable } from "./governor-mintable.sol";

// Same as Governor_Mintable, but only admins from group can add or remove voters
contract Governor_Mintable_Admined is Governor_Mintable, Admined {

    constructor(address _proxy, address[] memory _admins, uint _percentage) Governor_Mintable(_proxy, _percentage) Admined(_admins) public { }
    
    function modifyVoter(address voter, bool canVote) onlyAdmin() public {
        super.modifyVoter(voter, canVote);
    }
}
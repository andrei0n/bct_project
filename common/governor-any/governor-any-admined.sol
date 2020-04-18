pragma solidity ^0.5.0;

import { Governor_Any } from "./governor-any.sol";
import { Admined } from "../ownership/admined.sol";

// VoteAny is a governor that will let anyone on a list of voters perform
// the update, and even add or remove people from the group.
// Anybody of admins group can add or remove voters from group
contract Governor_Any_Admined is Governor_Any, Admined {
    
    constructor(address _proxy, address[] memory _admins) Governor_Any(_proxy) Admined(_admins) public { }

    function modifyVoter(address voter, bool canVote) public onlyAdmin {
        super.modifyVoter(voter, canVote);
    }
}

pragma solidity ^0.5.0;

import { Admined } from "../ownership/admined.sol";
import { Governor_Cohort } from "./governor-cohort.sol";

// VoteCohort is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// Anybody of admins group can add or remove voters from group
contract Governor_Cohort_Admined is Governor_Cohort, Admined {
    
    constructor(address _proxy, address[] memory _admins, uint _percentage) Governor_Cohort(_proxy, _percentage) Admined(_admins) public { }
    
    function modifyVoter(address voter, bool canVote) onlyAdmin() public {
        super.modifyVoter(voter, canVote);
    }
}

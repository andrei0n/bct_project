pragma solidity ^0.5.0;

import { Owned } from "../ownership/owned.sol";
import { Governor_Cohort } from "./governor-cohort.sol";

// VoteCohort is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// Owner can add or remove voters from group
contract Governor_Cohort_Owned is Governor_Cohort, Owned {
    
    constructor(address _proxy, address _owner, uint _percentage) Governor_Cohort(_proxy, _percentage) Owned(_owner) public { }
    
    function modifyVoter(address voter, bool canVote) onlyOwner() public {
        super.modifyVoter(voter, canVote);
    }
}
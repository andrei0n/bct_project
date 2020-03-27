pragma solidity ^0.5.0;

import {Owned} from "../ownership/owned.sol";
import {Governor_VoteCohort} from "./governor-votecohort.sol";

// VoteCohort is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// Owner can add or remove voters from group
contract Governor_VoteCohort_Owned is Governor_VoteCohort, Owned {
    
    constructor(address _proxy, address _owner, uint _percentage) Governor_VoteCohort(_proxy, _percentage) Owned(_owner) public { }
    
    function modifyVoter(address voter, bool canVote) onlyOwner() public {
        require (voters[voter] == canVote, "Governor: this action has no effect");
        
        if (voters[voter]) {
            quorum -= 1;
        } else {
            quorum += 1;
        }
        
        super.modifyVoter(canVote);
    }
}
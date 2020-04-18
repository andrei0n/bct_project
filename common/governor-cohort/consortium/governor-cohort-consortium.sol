pragma solidity ^0.5.0;

import { Governor_Cohort } from "../governor-cohort.sol";

// Governor_Cohort_Consortium is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// - addition of voters
// - removal of voters (except the one removed).
//
// The parent contract's vote() method can now be used with parameters
// vote(n, voter_address) to propose or vote for addition (n == 3) or
// removal (n == 4) of the voter voter_address.
contract Governor_Cohort_Consortium is Governor_Cohort {
    
    // The constructor initialises the list of voters to the given list
    constructor(address _proxy, uint _percentage, address[] memory rs) Governor_Cohort(_proxy, _percentage)public { 
        for(uint i = 0; i != rs.length; i++) {
            quorum += 1;
            voters[rs[i]] = true;
        }
    }
    
    // The voters can be added or removed by selected executor after vote. This affects the quorum.
    function modifyVoter(address voter, bool canVote) onlyIfApproved(canVote? 3: 4, voter) public {
        require (voters[voter] != canVote, "Governor_Cohort_Consortium: this action has no effect");
        
        if (voters[voter]) {
            quorum -= 1;
        } else {
            quorum += 1;
        }
        
        voters[voter] = canVote;
    }
    
    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor_Cohort_Consortium: only a voter may do this");

        bytes memory key = mapkey(action, msg.sender, newAddress);
        if (action == 4) {
                // Removal of a voter requires one fewer vote
                require(amountOfVotes(key) >= amountOfVotesForPositiveDecision() - 1, "Governor_Cohort_Consortium: not enough votes for this action");
        } else {
                require(amountOfVotes(key) >= amountOfVotesForPositiveDecision(), "Governor_Cohort_Consortium: not enough votes for this action");
        }
        removeProposal(key);
        _;
    }
}
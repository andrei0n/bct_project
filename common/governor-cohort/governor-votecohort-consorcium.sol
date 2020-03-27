pragma solidity ^0.5.0;

import {Governor_VoteCohort} from "./governor-votecohort.sol";

// Governor_VoteCohort_Consorcium is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// - addition of voters
// - removal of voters (except the one removed).
//
// The parent contract's vote() method can now be used with parameters
// vote(n, voter_address) to propose or vote for addition (n == 3) or
// removal (n == 4) of the voter voter_address.
contract Governor_VoteCohort_Consorcium is Governor_VoteCohort {
    
    // The constructor initialises the list of voters to the given list
    constructor(address _proxy, uint _percentage, address[] memory _voters) Governor_VoteCohort(_proxy, _percentage)public { 
        for(uint quorum = 0; quorum != _voters.length; quorum++) {
            voters[_voters[quorum]] = true;
        }
    }
    
    // The voters can be added or removed by selected executor after vote. This affects the quorum.
    function modifyVoter(address voter, bool canVote) onlyIfApproved(canVote? 3: 4, voter) public {
        require (voters[voter] == canVote, "Governor: this action has no effect");
        
        if (voters[voter]) {
            quorum -= 1;
        } else {
            quorum += 1;
        }
        
        super.modifyVoter(canVote);
    }
    
    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor: only a voter may do this");

        bytes memory key = mapkey(action, msg.sender, newAddress);
        if (action == 4) {
                // Removal of a voter requires one fewer vote
                require(voteRegistry[key].length >= amountOfVotesForPositiveDecision() - 1, "Governor: not enough votes for this action");
        } else {
                require(voteRegistry[key].length >= amountOfVotesForPositiveDecision(), "Governor: not enough votes for this action");
        }
        voteRegistry[key].length = 0;
        _;
    }
}
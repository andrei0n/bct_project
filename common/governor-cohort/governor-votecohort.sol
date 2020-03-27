pragma solidity ^0.5.0;

import {Governor_VoteAny} from "../governor-voteany/governor-voteany.sol";

// VoteCohort is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// Anybody can join or leave the voters group
contract Governor_VoteCohort is Governor_VoteAny {

    constructor(address _proxy, uint percentage) Governor_VoteAny(_proxy) public {
    }

    // The list of votes for each proposal (gov or logic update)
    mapping (bytes => address[]) voteRegistry;
    // Amount of votes necessary for a proposal to be implemented
    // (currently, this is equivalent to voters.length)
    uint quorum;
    
    uint percentage;
    
    function modifyVoter(bool canVote) public {
        modifyVoter(msg.sender, canVote);
    }
    
    function modifyVoter(address voter, bool canVote) public {
        require (voter == msg.sender, "Governor: voters can update it only by theirself. Use modifyVoter(canVote) method");
        require (voters[voter] == canVote, "Governor: this action has no effect");
        
        if (voters[voter]) {
            quorum -= 1;
        } else {
            quorum += 1;
        }
        
        super.modifyVoter(canVote);
    }
    
    // This is the function voters call to make a new proposal or to vote for it.
    // You can't "un-vote".
    // To vote for logic replacement, use action 0 and set newAddress to the new logic address
    // To vote for a governor replacement, use action 1 and set newAddress
    // to the new governor's address.
    // Executor should be the address of whoever will execute the action once enough votes are in.
    function vote(uint action, address executor, address newAddress)
             external {
        require(voters[msg.sender], "Governor: you are not a registred voter");

        bytes memory key = mapkey(action, executor, newAddress);

        for(uint i = 0; i != voteRegistry[key].length; i++) {
            require (voteRegistry[key][i] != msg.sender, "Governor: you have already voted");
        }

        voteRegistry[key].push(msg.sender);
    }

    function mapkey(uint action, address executor, address newAddress) internal pure returns (bytes memory){
        bytes memory b = new bytes(3*32);
        assembly { // Save on gas, as no direct cast is available
            mstore(add(b, 32), action)
            mstore(add(b, 64), executor)
            mstore(add(b, 96), newAddress)
        }
        return b;
    }
    
    function amountOfVotesForPositiveDecision() view public returns(uint) {
        return quorum * percentage / 100;
    }

    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor: only a voter may do this");

        bytes memory key = mapkey(action, msg.sender, newAddress);
        require(voteRegistry[key].length >= amountOfVotesForPositiveDecision(), "Governor: not enough votes for this action");

        voteRegistry[key].length = 0;
        _;
    }
}

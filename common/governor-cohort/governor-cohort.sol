pragma solidity ^0.5.0;

import { Governor_Any } from "../governor-any/governor-any.sol";

// VoteCohort is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a logic update (and to the new logic)
// Anybody can join or leave the voters group
contract Governor_Cohort is Governor_Any {

    constructor(address _proxy, uint _percentage) Governor_Any(_proxy) public {
        percentage = _percentage;
    }

    struct Proposal{
        uint action;
        address executor;
        address newAddress;
    }

    // The list of votes for each proposal (gov or logic update)
    mapping (bytes => address[]) internal voteRegistry;
    Proposal[] internal proposals;

    function votersFor(bytes memory key) public view returns(address[] memory){
        return voteRegistry[key];
    }

    function _proposals() public view returns(uint[] memory, address[] memory, address[] memory) {
        uint[] memory resultActions = new uint[](proposals.length);
        address[] memory resultExecutors = new address[](proposals.length);
        address[] memory resultAddresses = new address[](proposals.length);

        for(uint i = 0; i < proposals.length; i++) {
            resultActions[i] = proposals[i].action;
            resultExecutors[i] = proposals[i].executor;
            resultAddresses[i] = proposals[i].newAddress;
        }

        return (resultActions, resultExecutors, resultAddresses);
    }

    // Amount of votes necessary for a proposal to be implemented
    // (currently, this is equivalent to voters.length)
    uint quorum;
    
    uint percentage;
        
    function modifyVoter(address voter, bool canVote) public {
        require (voters[voter] != canVote, "Governor_Cohort: this action has no effect");
        
        if (voters[voter]) {
            quorum -= 1;
        } else {
            quorum += 1;
        }
        
        super.modifyVoter(voter, canVote);
    }
    
    // This is the function voters call to make a new proposal or to vote for it.
    // You can't "un-vote".
    // To vote for logic replacement, use action 0 and set newAddress to the new logic address
    // To vote for a governor replacement, use action 1 and set newAddress
    // to the new governor's address.
    // Executor should be the address of whoever will execute the action once enough votes are in.
    function vote(uint action, address executor, address newAddress) onlyVoter() public {
        bytes memory key = mapkey(action, executor, newAddress);

        for(uint i = 0; i != voteRegistry[key].length; i++) {
            require (voteRegistry[key][i] != msg.sender, "Governor_Cohort: you have already voted");
        }

        voteRegistry[key].push(msg.sender);
        
        if (voteRegistry[key].length == 1) {
            Proposal memory result = Proposal(action, executor, newAddress);
            proposals.push(result);    
        }
    }

    function mapkey(uint action, address executor, address newAddress) public pure returns (bytes memory){
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

    function removeProposal(bytes memory key) internal {
        voteRegistry[key].length = 0;
        bool skipped = false;
        for(uint i = 0; i < proposals.length - 1; i++) {
            if (keccak256(key) == keccak256(mapkey(proposals[i].action, proposals[i].executor, proposals[i].newAddress))) {
                proposals[skipped ? i - 1 : i] = proposals[i]; 
            } else {
                skipped = true;
            }
        }

        proposals.length--;
    }
    
    function amountOfVotes(bytes memory key) public view returns (uint) {
        return voteRegistry[key].length;
    }

    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor_Cohort: only a voter may do this");

        bytes memory key = mapkey(action, msg.sender, newAddress);
        require(amountOfVotes(key) >= amountOfVotesForPositiveDecision(), "Governor_Cohort: not enough votes for this action");
        removeProposal(key);
        _;
    }
}

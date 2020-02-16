pragma solidity ^0.5.0;

import {Governor} from "./governor.sol";

// VoteAll is a governor that requires all voters to agree to
// - a governor update (and to the new governor)
// - a database write (and to the data written)
// - a computation
contract Governor_VoteAll is Governor {
    address internal owner;

    // The list of voters, as a mapping so it can be easily checked
    mapping (address => bool) voters;
    // The list of votes for each proposal (gov update or database write)
    mapping (bytes => address[]) voteRegistry;
    // Amount of votes necessary for a proposal to be implemented
    // (currently, this is equivalent to voters.length)
    uint quorum;
    
    // The constructor initialises the list of voters to only the creator
    constructor(address _proxy) Governor(_proxy) public {
        owner = msg.sender;
        voters[owner] = true;
        quorum = 1;
    }

    // The owner may add or remove voters. This affects the quorum.
    function modifyVoter(address voter, bool canVote) 
             external {
        require (msg.sender == owner, "Governor: only the owner can add or remove voters");
        require (voters[voter] != canVote, "Governor: this action has no effect");

        voters[voter] = canVote;
        if (canVote) {
            quorum += 1;
        } else {
            quorum -= 1;
        }
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

    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor: only a voter may do this");

        bytes memory key = mapkey(action, msg.sender, newAddress);
        require(voteRegistry[key].length >= quorum, "Governor: not enough votes for this action");

        voteRegistry[key].length = 0;
        _;
    }
    
}
pragma solidity ^0.5.0;

import {Governor_VoteCohort} from "../governor-cohort/governor-votecohort.sol";

contract Governor_VoteDelegate is Governor_VoteCohort {

    constructor(address _proxy, uint _percentage) Governor_VoteCohort(_proxy, _percentage) public { }

    mapping (address => address[]) delegatedVotes;
    mapping (address => address) delegations;

    function vote(uint action, address executor, address newAddress) public {
        require(delegations[msg.sender] == address(0x0), "Governor: your vote is delegated");
        super.vote(action, executor, newAddress);
    }

    function delegateTo(address _delegate) onlyVoter() public {
        delegatedVotes[_delegate].push(msg.sender);
        delegations[msg.sender] = _delegate;
    }
    
    function removeDelegation() onlyVoter() public {
        require(delegations[msg.sender] != address(0x0), "Governor: this action doesn't make any effect");

        address[] memory oldDelegations = delegatedVotes[delegations[msg.sender]];
        address[] memory newDelegations = new address[](oldDelegations.length - 1);
        bool skipped = false;
        for(uint i = 0; i < oldDelegations.length; i++) {
            if (oldDelegations[i] != msg.sender) {
                newDelegations[skipped ? i - 1 : i] = oldDelegations[i];
            } else {
                skipped = true;
            }
        }

        delegatedVotes[delegations[msg.sender]] = newDelegations;
        delegations[msg.sender] = address(0x0);
    }

    function amountOfVotes(bytes memory key) public view returns (uint) {
        uint amount = 0;
        
        address[] memory agreedVoters = voteRegistry[key];

        for (uint i = 0; i < agreedVoters.length; i++) {
            amount += delegatesCount(agreedVoters[i]);
        }
    }

    function delegatesCount(address delegate) public view returns (uint){
        uint amount = 0;

        address[] memory voters = delegatedVotes[delegate];

        for (uint i = 0; i < voters.length; i++) {
            amount += delegatesCount(voters[i]);
        }

        amount++;

        return amount;
    }

    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor: only a voter may do this");
        bytes memory key = mapkey(action, msg.sender, newAddress);
        require(amountOfVotes(key) >= amountOfVotesForPositiveDecision(), "Governor: not enough votes for this action");

        voteRegistry[key].length = 0;
        _;
    }
}

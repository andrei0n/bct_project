pragma solidity ^0.5.0;

import { Delegate } from "../ownership/delegate.sol";
import { Governor_Cohort } from "../governor-cohort/governor-cohort.sol";

// Same as Governor_Cohort, but votes can be delegated to other voters
contract Governor_Cohort_Delegate is Governor_Cohort, Delegate {

    constructor(address _proxy, uint _percentage) Governor_Cohort(_proxy, _percentage) public { }

    function vote(uint action, address executor, address newAddress) public {
        require(delegations[msg.sender] == address(0x0), "Governor_Cohort_Delegate: your vote is delegated. Remove delegation first");
        super.vote(action, executor, newAddress);
    }

    function delegateTo(address _delegate) onlyVoter() public {
        super.delegateTo(_delegate);
    }
    
    function amountOfVotes(bytes memory key) public view returns (uint) {
        uint amount = 0;

        address[] memory agreedVoters = voteRegistry[key];

        for (uint i = 0; i < agreedVoters.length; i++) {
            if (delegations[agreedVoters[i]] != address(0x0)) {
                continue;
            }
            amount += delegatesCount(agreedVoters[i]);
        }

        return amount;
    }
    
    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor_Cohort_Delegate: only a voter may do this");
        bytes memory key = mapkey(action, msg.sender, newAddress);
        require(amountOfVotes(key) >= amountOfVotesForPositiveDecision(), "Governor_Cohort_Delegate: not enough votes for this action");
        removeProposal(key);
        _;
    }
}

pragma solidity ^0.5.0;

import { Delegate } from "../../ownership/delegate.sol";
import { Governor_Cohort_Consortium } from "./governor-cohort-consortium.sol";

// Same as Governor_Cohort_Consortium, but vote can be delegated
contract Governor_Cohort_Consortium_Delegate is Governor_Cohort_Consortium, Delegate {

    mapping (address => address[]) delegates;
    mapping (address => address) delegations;

    function vote(uint action, address executor, address newAddress) public {
        require(delegations[msg.sender] == address(0x0), "Governor_Cohort_Consortium_Delegate: your vote is delegated. Remove delegation first");
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
}
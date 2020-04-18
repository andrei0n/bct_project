pragma solidity ^0.5.0;

import { Governor_Cohort } from "../governor-cohort/governor-cohort.sol";
import { SafeMath } from "../libraries/SafeMath.sol";

// Same as Governor_Cohort, but additional votes can be bought
contract Governor_Mintable is Governor_Cohort {

    constructor(address _proxy, uint _percentage) Governor_Cohort(_proxy, _percentage) public { }

    mapping (address => uint256) internal values;

    function buyVote() public payable {
        require(msg.value == 1 ether, "Governor_Mintable: Only one vote can be bought per one transaction");
        values[msg.sender] = SafeMath.add(values[msg.sender], 1);
        quorum += 1;
    }

    function amountOfVotes(bytes memory key) public view returns (uint) {
        uint amount = 0;

        address[] memory agreedVoters = voteRegistry[key];

        for (uint i = 0; i < agreedVoters.length; i++) {
            amount += values[agreedVoters[i]] + 1;
        }

        return amount;
    }

    modifier onlyIfApproved(uint action, address newAddress) {
        require(voters[msg.sender], "Governor_Cohort: only a voter may do this");

        bytes memory key = mapkey(action, msg.sender, newAddress);
        require(amountOfVotes(key)  >= amountOfVotesForPositiveDecision(), "Governor_Cohort: not enough votes for this action");
        removeProposal(key);
        _;
    }
}
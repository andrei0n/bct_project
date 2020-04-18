pragma solidity ^0.5.0;

import { Governor_Cohort_Consortium } from "./governor-cohort-consortium.sol";
import { SafeMath } from "../../libraries/SafeMath.sol";

// Same as Governor_Cohort_Consortium, but additional votes can be bought
contract Governor_Cohort_Consortium_Mintable is Governor_Cohort_Consortium {

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
}
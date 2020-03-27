pragma solidity ^0.5.0;

import {Governor} from "../governor/governor.sol";

// VoteAny is a governor that will let anyone on a list of voters perform
// the update, and even add or remove people from the group.
// Anybody can join or leave the voters group
contract Governor_VoteAny is Governor {
    mapping (address => bool) internal voters;
    
    constructor(address _proxy) Governor(_proxy) public { }

    function modifyVoter(bool canVote) public {
        require (voters[msg.sender] == canVote, "Governor: this action has no effect");
        voters[msg.sender] = canVote;
    }

    modifier onlyIfApproved(uint, address) {
        require (voters[msg.sender], "Governor: Only voters may do this");
        _;
    }
}

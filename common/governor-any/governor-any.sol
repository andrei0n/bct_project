pragma solidity ^0.5.0;

import { Governor } from "../governor/governor.sol";

// VoteAny is a governor that will let anyone on a list of voters perform
// the update, and even add or remove people from the group.
// Anybody can join or leave the voters group
contract Governor_Any is Governor {
    mapping (address => bool) internal voters;
    
    constructor(address _proxy) Governor(_proxy) public { }

    function modifyVoter(address voter, bool canVote) public {
        require (voters[voter] != canVote, "Governor_Any: this action has no effect");
        voters[voter] = canVote;
    }

    modifier onlyIfApproved(uint, address) {
        require (voters[msg.sender], "Governor_Any: Only voters may do this");
        _;
    }

    modifier onlyVoter() {
        require (voters[msg.sender], "Governor_Any: Only voters may do this");
        _;
    }
}

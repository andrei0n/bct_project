pragma solidity ^0.5.0;

import {Governor} from "./governor.sol";

// VoteOne is a governor that will let anyone on a list of voters perform
// the update or execute functions. The owner/creator is the only one that can
// add or remove people from the group.
contract Governor_VoteOne is Governor {
    address internal owner;
    mapping (address => bool) voters;
    
    constructor(address _proxy) Governor(_proxy) public {
        owner = msg.sender;
        voters[owner] = true;
    }

    function modifyVoter(address voter, bool canVote)
             external {
        require (msg.sender == owner);
        voters[voter] = canVote;
    }

    modifier onlyIfApproved(uint, address) {
        require (voters[msg.sender], "Governor: Only voters may do this");
        _;
    }
}

pragma solidity ^0.5.0;

import {Governor_VoteOne} from "./governor-voteone.sol";

// VoteAll is a governor that will let anyone on a list of voters perform
// the update or execute functions, and even add or remove people from the
// group.
contract Governor_VoteOne_NoLeader is Governor_VoteOne {
    enum Action {UpdBusiness, UpdGovernor, ModVoter}

    constructor(address _proxy) Governor_VoteOne(_proxy) public {}

    function modifyVoter(address voter, bool canVote) onlyIfApproved(2, voter)
             external {
        voters[voter] = canVote;
    }
}

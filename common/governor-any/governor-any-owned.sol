pragma solidity ^0.5.0;

import { Governor_Any } from "./governor-any.sol";
import { Owned } from "../ownership/owned.sol";

// VoteAny is a governor that will let anyone on a list of voters perform
// the update, and even add or remove people from the group.
// Owner can add or remove voters from group
contract Governor_Any_Owned is Governor_Any, Owned {

    constructor(address _proxy, address _owner) Governor_Any(_proxy) Owned(_owner)  public { }

    function modifyVoter(address voter, bool canVote) onlyOwner() public {
        super.modifyVoter(voter, canVote);
    }
}
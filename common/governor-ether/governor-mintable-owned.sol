pragma solidity ^0.5.0;

import { Owned } from "../ownership/owned.sol";
import { Governor_Mintable } from "./governor-mintable.sol";

// Same as Governor_Mintable, but only owner can add or remove voters from group
contract Governor_Mintable_Owned is Governor_Mintable, Owned {

    constructor(address _proxy, address _owner, uint _percentage) Governor_Mintable(_proxy, _percentage) Owned(_owner) public { }

    function modifyVoter(address voter, bool canVote) public onlyOwner {
        super.modifyVoter(voter, canVote);
    }
}
pragma solidity ^0.5.0;

import { Owned } from "../ownership/owned.sol";
import { Governor_Cohort_Delegate } from "./governor-delegate.sol";

// Same as Governor_Cohort_Delegate, but only owner can add or remove voters from group
contract Governor_Cohort_Delegate_Owned is Governor_Cohort_Delegate, Owned {

    constructor(address _proxy, address _owner, uint _percentage) Governor_Cohort_Delegate(_proxy, _percentage) Owned(_owner) public { }
    
    function modifyVoter(address voter, bool canVote) onlyOwner() public {
        super.modifyVoter(voter, canVote);
    }
}

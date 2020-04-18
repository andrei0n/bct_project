pragma solidity ^0.5.0;

import { Admined } from "../ownership/admined.sol";
import { Governor_Cohort_Delegate } from "./governor-delegate.sol";

// Same as Governor_Cohort_Delegate, but only admins from group can add or remove voters
contract Governor_Cohort_Delegate_Admined is Governor_Cohort_Delegate, Admined {
    
    constructor(address _proxy, address[] memory _admins, uint _percentage) Governor_Cohort_Delegate(_proxy, _percentage) Admined(_admins) public { }
    
    function modifyVoter(address voter, bool canVote) onlyAdmin() public {
        super.modifyVoter(voter, canVote);
    }
}

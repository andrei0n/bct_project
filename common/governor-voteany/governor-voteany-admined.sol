pragma solidity ^0.5.0;

import {Governor_VoteAny} from "./governor-voteany.sol";
import {Admined} from "../ownership/admined.sol";

// VoteAny is a governor that will let anyone on a list of voters perform
// the update, and even add or remove people from the group.
// Anybody of admins group can add or remove voters from group
contract Governor_VoteAny_Admined is Governor_VoteAny, Admined {

    constructor(address _proxy, address _owner) Governor_VoteAny(_proxy) Admined(_owner) public { }

    function modifyVoter(bool canVote) onlyAdmin() public {
        super.modifyVoter(canVote);
    }

    modifier onlyIfApproved(uint, address) {
        require (voters[msg.sender], "Governor: Only voters may do this");
        _;
    }
}

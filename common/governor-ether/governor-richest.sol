pragma solidity ^0.5.0;

import { Governor } from "../governor/governor.sol";
import { SafeMath } from "../libraries/SafeMath.sol";

// This governor gives the entire power to the person that has the most ether
contract Governor_Richest is Governor {

    constructor(address _proxy, uint _percentage) Governor(_proxy) public { }

    mapping (address => uint) internal values;
    uint256 internal max;
    address internal richestPayer;

    function buyVote() public payable {
        values[msg.sender] = SafeMath.add(values[msg.sender], msg.value);

        if (values[msg.sender] > max) {
            max = values[msg.sender];
            richestPayer = msg.sender;
        }
    }

    modifier onlyIfApproved(uint action, address newAddress) {
        require (msg.sender == richestPayer, "Governor: Only the richest donator may do this");
        _;
    }
}
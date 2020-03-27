pragma solidity ^0.5.0;

contract Owned {
    address internal owner;
        
    constructor(address _owner) public {
        owner = _owner;
    }
    
    modifier onlyOwner {
        require (msg.sender == owner, "Governor: Only the owner may do this");
        _;
    }
}
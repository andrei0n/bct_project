pragma solidity ^0.5.0;

contract Owned {
    address internal owner;
        
    constructor(address _owner) public {
        owner = _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
    
    modifier onlyOwner {
        require (msg.sender == owner, "Owned: Only the owner may do this");
        _;
    }
}
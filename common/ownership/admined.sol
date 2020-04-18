pragma solidity ^0.5.0;

contract Admined  {
    mapping (address => bool) internal admins;
    
    constructor(address[] memory _admins) public {
        for (uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }
    
    function modifyAdmin(address admin, bool isAdmin) onlyAdmin()  public {
        admins[admin] = isAdmin;
    }

    modifier onlyAdmin {
        require (admins[msg.sender], "Admined: Only admin can do this");
        _;
    }
}
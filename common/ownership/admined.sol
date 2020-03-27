pragma solidity ^0.5.0;

contract Admined  {
    mapping (address => bool) admins;
    
    constructor(address _admin) public {
        admins[_admin] = true;
    }
    
    function modifyAdmin(address admin, bool isAdmin) onlyAdmin()  external {
        admins[admin] = isAdmin;
    }

    modifier onlyAdmin {
        require (admins[msg.sender], "Governor: Only admin can do this");
        _;
    }
}
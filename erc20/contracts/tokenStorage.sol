pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract TokenStorage is Ownable {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    function balanceOf(address addr) public view returns(uint256 balance) {
        return balances[addr];
    }

    function setBalance(address addr, uint256 amount) external onlyOwner() {
        balances[addr] = amount;
    } 
    
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return allowances[_owner][_spender];    
    }

    function setAllowance(address _owner, address _spender, uint256 amount) external onlyOwner() {
        allowances[_owner][_spender] = amount;
    }
}

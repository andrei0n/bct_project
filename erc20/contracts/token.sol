pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import { ERC20_Token, ERC20_Details, Initializeable } from './erc20.sol';
import { TokenStorage } from './tokenStorage.sol';

contract GovernedToken is Initializeable, ERC20_Token, ERC20_Details, Ownable {
    uint256 supply;
    TokenStorage public tokenStorage;

    /**
     * Prevent an account from being 0x0
     * @param addr Address to check
     */
    modifier No0x(address addr) { 
        require(addr != address(0x0));
        _;
    }

    /**
     * A modifer to check validity of a balance for a transfer
     * from an account to another.
     * @param from  [description]
     * @param to    [description]
     * @param value [description]
     */
    modifier ValidBalance(address from, address to, uint256 value) { 
        require(tokenStorage.balanceOf(from) >= value); // Check if the sender has enough
        require(tokenStorage.balanceOf(to) + value >= tokenStorage.balanceOf(to)); // Check for overflows
        _; 
    }
    
    event StorageInitialised(address _tokenStorage);

    /**
     * Constructor of MyToken
     */
    constructor() public {
        // initialize(_totalSupply, _name, _symbol, _decimals);        
    }

    function initialize(uint256 _totalSupply, string memory _name, string memory _symbol, uint8 _decimals) public initializer() {
        ERC20_Details.initialize(_name, _symbol, _decimals);
        tokenStorage = new TokenStorage();
        supply = _totalSupply;
        tokenStorage.setBalance(msg.sender, _totalSupply);
        emit StorageInitialised(address(tokenStorage));
    }

    /**
     * Returns the total amount of tokens
     * @return total amount
     */
    function totalSupply() public view returns(uint256 _totalSupply) {
        return supply;
    }

    /**
     * Returns The balance of a given account
     * @param addr Address of the account
     * @return Balance
     */
    function balanceOf(address addr) public view returns(uint256 balance) {
        return tokenStorage.balanceOf(addr);
    }
    
    /**
     * Returns the amount which _spender is still allowed to withdraw from _owner
     */
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return tokenStorage.allowance(_owner, _spender);    
    }

    /**
     * Send coins
     * @param _to        The recipient of tokens
     * @param _value     Amount of tokens to send 
     */
    function transfer(address _to, uint256 _value) public 
              No0x(_to) ValidBalance(msg.sender, _to, _value) returns(bool success) {
        // Subtract from the sender
        tokenStorage.setBalance(msg.sender, tokenStorage.balanceOf(msg.sender) - _value);
        // Add the same to the recipient
        tokenStorage.setBalance(_to, tokenStorage.balanceOf(_to) + _value);
        // Notify anyone listening that this transfer took place
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Allow another contract to spend some tokens in your behalf
     * @param _spender     Account that can take some of your tokens
     * @param _value       Max amount of tokens the _spender account can take
     * @return {return}    Return true if the action succeeded
     */
    function approve(address _spender, uint256 _value) public returns(bool success) {
        tokenStorage.setAllowance(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }  

    /**
     * A contract attempts to get the coins
     * @param _from     Address holding the tokens to transfer
     * @param _to       Account to send the coins to
     * @param _value    How many tokens     
     * @return {bool}   Whether the call was successful
     */
    function transferFrom(address _from, address _to, uint256 _value) public 
             No0x(_to) ValidBalance(_from, _to, _value) returns(bool success) {
        require(_value <= tokenStorage.allowance(_from, msg.sender));
        // Subtract from the sender
        tokenStorage.setBalance(_from, tokenStorage.balanceOf(_from) - _value);
        // Add the same to the recipient
        tokenStorage.setBalance(_to, tokenStorage.balanceOf(_to) + _value);
        // Update the allowance
        tokenStorage.setAllowance(_from, msg.sender, tokenStorage.allowance(_from, msg.sender) - _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function name() public view returns(string memory _name) {
        return tokenName;
    }

    function symbol() public view returns(string memory _symbol) {
        return tokenSymbol;
    }

    function decimals() public view returns(uint8 _decimals) {
        return tokenDecimals;
    }
}

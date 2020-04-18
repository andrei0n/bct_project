pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import { ERC20_Token, ERC20_Details, Initializeable } from './erc20.sol';
import { TokenStorage } from './tokenStorage.sol';

// This token is intended to replace an existing token (that presumably contains an error).
// It takes over the existing storage, and therefore does not reallocate the supply to the
// token's creator.
contract GovernedReplacementToken is Initializeable, ERC20_Token, ERC20_Details, Ownable {
    uint256 supply;
    TokenStorage public tokenStorage;

    /**
     * Prevent an account from behing 0x0
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

    // /**
    //  * Constructor of MyToken
    //  * @param _totalSupply Total amount of tokens initially issued
    //  */
    // constructor(address _storage, uint256 _totalSupply, string memory _name, string memory _symbol, uint8 _decimals) 
    //            ERC20_Details(_name, _symbol, _decimals) public {
    //     tokenStorage = TokenStorage(_storage);
    //     supply = _totalSupply;
    //     emit StorageInitialised(address(tokenStorage));
    // }

   /**
     * Constructor of MyToken, keep it simple
     */
    constructor() public {
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
        // Let's everybody appear a bit more rich :)
        // Note, this is a non-feature, normal code shouldn't have this. This is just
        // to show that the update of the code has worked.
        return 1 + tokenStorage.balanceOf(addr);
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

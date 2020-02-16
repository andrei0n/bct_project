pragma solidity ^0.5.0;

contract Initializeable {
    bool initialized;
    modifier initializer() {
        require(!initialized, "Contract can only be initialized once");
        _;
        initialized = true;
    }

}

/**
 * See https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20_Token {
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Get the total token supply
    function totalSupply() public view returns(uint256 _totalSupply);
    
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public view returns(uint256 balance);
    
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns(bool success);
    
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public returns(bool success);
    
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public view returns(uint256 remaining);
}

contract ERC20_Details is Initializeable {
    string tokenName;
    string tokenSymbol;
    uint8 tokenDecimals;

    function name() public view returns(string memory _name);
    function symbol() public view returns(string memory _symbol);
    function decimals() public view returns(uint8 _decimals);

    constructor() public {
    }

    function initialize(string memory _name, string memory _symbol, uint8 _decimals) public initializer() {
        require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked('')), "Empty name for ERC20 token");
        require(keccak256(abi.encodePacked(_symbol)) != keccak256(abi.encodePacked('')), "Empty symbol for ERC20 token");

        tokenName = _name;
        tokenSymbol = _symbol;
        tokenDecimals = _decimals;
    }
}
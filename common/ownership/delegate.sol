pragma solidity ^0.5.0;

contract Delegate {
  
    mapping (address => address[]) delegates;
    mapping (address => address) delegations;
    
    function delegateTo(address _delegate) public {
        require(delegations[msg.sender] == address(0x0), "Delegate: vote is already delegated, please remove delegation first");
        delegates[_delegate].push(msg.sender);
        delegations[msg.sender] = _delegate;
    }
    
    function removeDelegation() public {
        require(delegations[msg.sender] != address(0x0), "Delegate: this action doesn't make any effect");

        address[] memory oldDelegations = delegates[delegations[msg.sender]];
        address[] memory newDelegations = new address[](oldDelegations.length - 1);
        bool skipped = false;
        for(uint i = 0; i < oldDelegations.length; i++) {
            if (oldDelegations[i] != msg.sender) {
                newDelegations[skipped ? i - 1 : i] = oldDelegations[i];
            } else {
                skipped = true;
            }
        }

        delegates[delegations[msg.sender]] = newDelegations;
        delegations[msg.sender] = address(0x0);
    }

    function delegatesCount(address delegate) public view returns (uint) {
        uint amount = 1;

        address[] memory voters = delegates[delegate];

        for (uint i = 0; i < voters.length; i++) {
            amount += delegatesCount(voters[i]);
        }

        return amount;
    }
}
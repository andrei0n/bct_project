pragma solidity ^0.5.0;

interface IProxy {
    event NewMemberContracts(address business, address governor);

    function updateLogic(address _logic) external;
    function updateGovernor(address _governor) external;
}

// The default Governor allows everything.
// The Permissioned modifier can be overridden to provide more functionality.
contract Governor {
    IProxy proxy;

    constructor(address _proxy) internal {
        proxy = IProxy(_proxy);
    }

    function updateLogic(address _newLogic) onlyIfApproved(0, _newLogic) external {
        proxy.updateLogic(_newLogic);
    }

    function updateGovernor(address _newGovernor) onlyIfApproved(1, _newGovernor) external {
        proxy.updateGovernor(_newGovernor);
    }

    modifier onlyIfApproved(uint, address) {
        _;
    }
}

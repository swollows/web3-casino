// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/JonathanCasinoToken.sol";
import "../src/games/BlackjackGame.sol";
import "../src/games/CoinTossGame.sol";
import "../src/games/RouletteGame.sol";
import "../src/proxy/GameProxy.sol";

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
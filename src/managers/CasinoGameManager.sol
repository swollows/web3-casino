// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../games/GameBase.sol";

contract CasinoGameManager {
    address public blackjack;
    address public roulette;
    address public coinToss;

    constructor(address _blackjack, address _roulette, address _coinToss) {
        blackjack = _blackjack;
        roulette = _roulette;
        coinToss = _coinToss;
    }
}

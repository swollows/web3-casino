// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./GameBase.sol";
import "../CasinoToken.sol";

contract RouletteGame is GameBase {
    constructor() {
        _unpause();
    }

    function startGame() public override whenNotPaused checkInvalidAddress statusTransition {
        require(msg.sender != address(0), "Invalid player address");
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");
    }

    function placeBet(uint256 amount) public override whenNotPaused checkInvalidAddress statusTransition
     returns (string[] memory) {
        require(playerGameState[msg.sender] == GameState.Betting, "You must in betting state");
        require(amount >= MIN_BET && amount <= MAX_BET, "Invalid bet amount");
        require(playerBets[msg.sender] == 0, "You should bet only once");

        playerBets[msg.sender] += amount;

        return [];
    }

    function processRewards() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        // 블랙잭 게임 로직 구현 : 게임 내용이 복잡해서 나중에 진행
        playerRewards[msg.sender] = playerBets[msg.sender] * 2;
        playerBets[msg.sender] = 0;
    }

    function claimRewards() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Claiming, "You must in claiming state");

        CasinoToken(casinoToken).transfer(msg.sender, playerRewards[msg.sender]);
        playerRewards[msg.sender] = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Multicall.sol";

contract GameScheduler is Multicall {
    uint256 public lastExecutionTime;
    uint256 public interval = 60; // 1분 주기

    function executeGames() external {
        require(block.timestamp >= lastExecutionTime + interval, "Wait for next cycle");
        lastExecutionTime = block.timestamp;

        // 여러 게임 실행 요청을 한 번에 처리
        // 예: multicall([{to: blackjack, data: startGame()}, {to: roulette, data: startGame()}])
    }
}
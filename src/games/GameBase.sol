// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Pausable.sol";

abstract contract GameBase is Pausable {
    error InvalidPlayerAddress(address player);

    enum GameState { Ended, Betting, Drawing, Rewarding, Claiming }

    uint256 public constant MIN_BET = 100;          // 최소 배팅 금액
    uint256 public constant MAX_BET = 2000;         // 최대 배팅 금액

    modifier checkInvalidAddress() {
        if (msg.sender == address(0)) {
            revert InvalidPlayerAddress(msg.sender);
        }
        _;
    }

    modifier statusTransition() {
        _;
        if (playerGameState[msg.sender] == GameState.Claiming) {
            playerGameState[msg.sender] = GameState.Ended;
        } else {
            playerGameState[msg.sender] = GameState(uint8(playerGameState[msg.sender]) + 1);
        }
    }

    mapping(address => uint256) public playerBets;
    mapping(address => uint256) public playerRewards;
    mapping(address => GameState) public playerGameState;

    function startGame() public virtual;
    function placeBet(uint256 amount) public virtual;
    function processRewards() public virtual;
    function claimRewards() public virtual;
}

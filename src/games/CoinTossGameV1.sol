// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./GameBase.sol";

/**
 * @title Coin Toss Game
 * @dev Coin Toss Game Contract
 * @author Jonathan
 * Game Rules
 * 1. When game starts, player must bets least 100 JCT and max 2000 JCT
 *   (If player bets less than 100 JCT or more than 2000 JCT or has any balances of JCT, the bet will be cancelled)
 *   (And player cant bet only once, if player bets again, the bet will be cancelled)
 * 2. Player bets with isHead or isTail (isHead is true, isTail is false)
 * 3. When bet is finished, game will be started
 * 4. In drawing state, game will be drawed with coin toss result
 * 5. If player's bet is correct, player will be rewarded with 2x of bet
 * 6. When game is finished, player can claim their reward
 */

contract CoinTossGame is GameBase {
    mapping(address => bool) public coinTossPlayer;

    GameType public constant GAME_TYPE = GameType.CoinToss;

    /**
     * @notice Coin Toss Game Contract Constructor
     * @param _JCTToken JCT Token Address
     */
    constructor(address _JCTToken) {
        JCTToken = JonathanCasinoToken(_JCTToken);
        _unpause();
    }

    /**
     * @notice CoinToss Game Start
     * @dev Before starting the game, check if the player is not started/ended and has no reward
     */
    function startGame() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");
    }

    /**
     * @notice CoinToss Game Bet
     * @param amount Betting amount
     * @param isHead Prediction information of CoinToss Game
     */
    function placeBet(uint256 amount, bool isHead) public whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Betting, "You must in betting state");
        require(amount >= MIN_BET && amount <= MAX_BET, "Invalid bet amount");
        require(playerBets[msg.sender] == 0, "You should bet only once");
        require(playerBets[msg.sender] == 0, "You should bet only once");

        playerBets[msg.sender] += amount;
        coinTossPlayer[msg.sender] = isHead;
    }

    /**
     * @notice CoinToss Game Draw
     * @dev Before drawing, check if the player is in drawing state and has bet
     * @dev If the bet fails, the bet amount will be 0
     */
    function draw() public whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        if (coinTossPlayer[msg.sender] != coinToss()) {
            playerBets[msg.sender] = 0;
        }
    }

    /**
     * @notice CoinToss Game Draw
     * @dev Draw the result of CoinToss Game (Internal function)
     */
    function coinToss() internal view returns (bool) {
        return (block.prevrandao + block.timestamp + block.number) % 2 != 0;
    }

    /**
     * @notice CoinToss Game Process Rewards
     * @dev Before processing the reward, check if the player is in drawing state and has bet
     */
    function processRewards() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        playerRewards[msg.sender] = playerBets[msg.sender] * 2;
        playerBets[msg.sender] = 0;
    }

    /**
     * @notice CoinToss Game Claim Rewards
     * @dev Before claiming the reward, check if the player is in claiming state
     */
    function claimRewards() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Claiming, "You must in claiming state");

        JCTToken.transfer(msg.sender, playerRewards[msg.sender]);
        playerRewards[msg.sender] = 0;
    }
}
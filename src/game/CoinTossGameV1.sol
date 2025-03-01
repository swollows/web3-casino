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
    mapping(address => bool) public coinTossResult;

    GameType public constant GAME_TYPE = GameType.CoinToss;

    bytes4 public constant PLACE_BET_SELECTOR = bytes4(keccak256("placeBet(uint256,bool)"));
    
    /**
     * @notice Modifier to check if the total amount of bets is less than or equal to the player's balance
     * @param amounts The amount of bets
     */
    modifier checkAmounts(uint256[] memory amounts) {
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(totalAmount <= JCTToken.balanceOf(msg.sender), "Total amount cannot exceed your balance");
        _;
    }

    /**
     * @notice CoinToss Game Start
     * @dev Before starting the game, check if the player is not started/ended and has no reward
     */
    function startGame() public override isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");

        casinoCounter.addTotalPlays(msg.sender, uint256(GAME_TYPE));
    }

    /**
     * @notice CoinToss Game Bet
     * @param amount Betting amount
     * @param isHead Prediction information of CoinToss Game
     */
    function placeBet(uint256 amount, bool isHead) public isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Betting, "You must in betting state");
        require(amount >= MIN_BET && amount <= MAX_BET, "Invalid bet amount");
        require(JCTToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(playerBets[msg.sender] == 0, "You should bet only once");

        playerBets[msg.sender] += amount;
        coinTossPlayer[msg.sender] = isHead;

        casinoCounter.addTotalBets(msg.sender, uint256(GAME_TYPE), amount);
    }

    /**
     * @notice CoinToss Game Draw
     * @dev Before drawing, check if the player is in drawing state and has bet
     * @dev If the bet fails, the bet amount will be 0
     */
    function draw() public isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        coinTossResult[msg.sender] = coinToss();
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
     * @dev Before processing the reward, check if the player is in reward state and has bet
     */
    function processRewards() public override isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Rewarding, "You must in Rewarding state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        if (coinTossPlayer[msg.sender] == coinTossResult[msg.sender]) {
            playerRewards[msg.sender] = playerBets[msg.sender] * 2;
            casinoCounter.addTotalWins(msg.sender, uint256(GAME_TYPE));
        } else {
            playerRewards[msg.sender] = 0;
            casinoCounter.addTotalLosses(msg.sender, uint256(GAME_TYPE));
        }

        if (playerRewards[msg.sender] > 0) {
            JCTToken.approveFrom(address(JCTToken), address(this), playerRewards[msg.sender]);
        } else {
            JCTToken.approveFrom(address(msg.sender), address(this), playerBets[msg.sender]);
        }
    }

    /**
     * @notice CoinToss Game Claim Rewards
     * @dev Before claiming the reward, check if the player is in claiming state
     */
    function claimRewards() public override isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Claiming, "You must in claiming state");

        if (playerRewards[msg.sender] > 0) {
            JCTToken.transferFrom(address(JCTToken), msg.sender, playerRewards[msg.sender]);
        } else {
            JCTToken.transferFrom(address(msg.sender), address(JCTToken), playerBets[msg.sender]);
        }

        casinoCounter.addTotalRewards(msg.sender, uint256(GAME_TYPE), playerRewards[msg.sender]);

        delete playerRewards[msg.sender];
        delete playerBets[msg.sender];
        delete coinTossPlayer[msg.sender];
        delete coinTossResult[msg.sender];
    }

    /**
     * @notice CoinToss Game Multiple Play
     * @dev Before playing multiple games, check if the player is in ended state and has no reward
     * @param amounts The amount of bets
     * @param isHeads The prediction information of CoinToss Game
     */
    function multiplePlay(uint256[] memory amounts, bool[] memory isHeads) public checkAmounts(amounts) {
        require(amounts.length > 0, "No amounts to play");
        require(amounts.length <= 10, "You can only play up to 10 games at a time");
        require(amounts.length == isHeads.length, "Amounts and numbers must be the same length");
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");
        
        bytes[] memory data = new bytes[](amounts.length * 5);

        uint256 idx = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            data[idx++] = abi.encodeWithSelector(START_GAME_SELECTOR);
            data[idx++] = abi.encodeWithSelector(PLACE_BET_SELECTOR, amounts[i], isHeads[i]);
            data[idx++] = abi.encodeWithSelector(DRAW_SELECTOR);
            data[idx++] = abi.encodeWithSelector(PROCESS_REWARDS_SELECTOR);
            data[idx++] = abi.encodeWithSelector(CLAIM_REWARDS_SELECTOR);
        }

        bytes memory multicallData = abi.encodeWithSelector(MULTICALL_SELECTOR, data);
        (bool success, ) = address(this).delegatecall(multicallData);
        require(success, "Multicall failed");
    }
}
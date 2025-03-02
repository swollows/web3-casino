// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./GameBase.sol";

import "forge-std/Script.sol";

/**
 * @title Roulette Game
 * @dev Roulette Game Contract
 * @author Jonathan
 * Game Rules
 * 1. When game starts, player must bets least 100 JCT and max 2000 JCT
 *   (If player bets less than 100 JCT or more than 2000 JCT or has any balances of JCT, the bet will be cancelled)
 *   (And player cant bet only once, if player bets again, the bet will be cancelled)
 * 2. Player bets with number between 0 and 36
 * 3. When bet is finished, game will be started
 * 4. In drawing state, game will be drawed with random number between 0 and 36
 * 5. If player's bet is correct, player will be rewarded with 5x of bet
 * 6. When game is finished, player can claim their reward
 */

contract RouletteGame is GameBase {
    mapping(address => uint8) public playerNumber;
    mapping(address => uint8) public rouletteResult;

    GameType public constant GAME_TYPE = GameType.Roulette;

    bytes4 public constant PLACE_BET_SELECTOR = bytes4(keccak256("placeBet(uint256,uint8)"));

    /**
     * @notice Modifier to check if the total amount of bets is less than or equal to the player's balance
     * @param _amounts The amount of bets
     */
    modifier checkAmounts(uint256[] memory _amounts) {
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < _amounts.length; i++) {
            totalAmount += _amounts[i];
        }

        require(totalAmount <= JCTToken.balanceOf(msg.sender), "Total amount cannot exceed your balance");
        _;
    }

    /**
     * @notice Roulette Game Start
     * @dev Before starting the game, check if the player is not started/ended and has no reward
     */
    function startGame() public override isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");

        casinoCounter.addTotalPlays(msg.sender, uint256(GAME_TYPE));
    }

    /**
     * @notice Roulette Game Bet
     * @param _amount Betting amount
     * @param _number Betting number
     */
    function placeBet(uint256 _amount, uint8 _number) public isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Betting, "You must in betting state");
        require(_amount >= MIN_BET && _amount <= MAX_BET, "Invalid bet amount");
        require(playerBets[msg.sender] == 0 && playerNumber[msg.sender] == 0, "You should bet only once");
        require(_number >= 0 && _number <= 36, "Invalid bet number");

        playerBets[msg.sender] += _amount;
        playerNumber[msg.sender] = _number;

        casinoCounter.addTotalBets(msg.sender, uint256(GAME_TYPE), _amount);
    }

    /**
     * @notice Roulette Game Draw
     * @dev Before drawing, check if the player is in drawing state and has bet
     */
    function draw() public isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        rouletteResult[msg.sender] = drawNumber();
    }

    /**
     * @notice Roulette Game Draw
     * @dev Draw the result of Roulette Game (Internal function)
     */
    function drawNumber() internal view returns (uint8) {
        return uint8((block.prevrandao + block.timestamp + block.number) % 37);
    }

    /**
     * @notice Roulette Game Process Rewards
     * @dev Before processing the reward, check if the player is in reward state and has bet
     */
    function processRewards() public override isInitialized checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Rewarding, "You must in Rewarding state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        if (playerNumber[msg.sender] == rouletteResult[msg.sender]) {
            playerRewards[msg.sender] = playerBets[msg.sender] * 5;
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
     * @notice Roulette Game Claim Rewards
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
        delete playerNumber[msg.sender];
        delete rouletteResult[msg.sender];
    }

    /**
     * @notice Roulette Game Multiple Play
     * @dev Before playing multiple games, check if the player is in ended state and has no reward
     * @param _amounts The amount of bets
     * @param _numbers The prediction information of Roulette Game
     */
    function multiplePlay(uint256[] memory _amounts, uint8[] memory _numbers) public checkAmounts(_amounts) {
        require(_amounts.length > 0, "No amounts to play");
        require(_amounts.length <= 10, "You can only play up to 10 games at a time");
        require(_amounts.length == _numbers.length, "Amounts and numbers must be the same length");
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");
        
        bytes[] memory data = new bytes[](_amounts.length * 5);

        uint256 idx = 0;

        for (uint256 i = 0; i < _amounts.length; i++) {
            data[idx++] = abi.encodeWithSelector(START_GAME_SELECTOR);
            data[idx++] = abi.encodeWithSelector(PLACE_BET_SELECTOR, _amounts[i], _numbers[i]);
            data[idx++] = abi.encodeWithSelector(DRAW_SELECTOR);
            data[idx++] = abi.encodeWithSelector(PROCESS_REWARDS_SELECTOR);
            data[idx++] = abi.encodeWithSelector(CLAIM_REWARDS_SELECTOR);
        }

        bytes memory multicallData = abi.encodeWithSelector(MULTICALL_SELECTOR, data);
        (bool success, ) = address(this).delegatecall(multicallData);
        require(success, "Multicall failed");
    }
}
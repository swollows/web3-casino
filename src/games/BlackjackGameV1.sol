// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./GameBase.sol";

/**
 * @title Blackjack Game
 * @dev Blackjack Game Contract
 * @author Jonathan
 *
 * Game Rules
 * 1. When game starts, player must bets least 100 JCT and max 2000 JCT
 *   (If player bets less than 100 JCT or more than 2000 JCT or has any balances of JCT, the bet will be cancelled)
 *   (And player cant bet only once, if player bets again, the bet will be cancelled)
 * 2. Player bets before card draw starts
 * 3. When bet is finished, game will be started
 * 4. In drawing state, game will be drawed with two random number between 0 and 12 (13 cards)
 * 5. Player can draw card until the card sum is over 21
 * 6. If player's card sum is higher than dealer's or dealer busted, player will be rewarded with 2x of bet
 * 7. If player's card sum is lower than dealer's or player busted, player will lose bets
 * 8. If player's card sum is equal to dealer's, player will get back the bet
 * 9. When game is finished, player can claim rewards
 *
 * Dealer's Rules
 * 1. Dealer will be drawed with two random number between 0 and 51 (52 cards)
 * 2. When Dealer's card sum is over 21, Dealer will be busted
 * 3. When Dealer's card sum is over 17, Dealer will stop drawing
 * 4. When Dealer's card sum is lower than 16, Dealer will draw card
 *
 * Card Rules
 * 1. Maximum allowed card sum is 21
 * 2. If card sum is 21 and count of cards is 2, it is called "Blackjack" and player will be rewarded with 3x of bet
      (If dealer has blackjack, player will lose the bet)
 * 3. If card sum is over 21, it is called "Bust" and player will lose the bet
 */

contract BlackjackGame is GameBase{
    // Blackjack Player/Dealer Status
    enum BJStatus {
        Draw,
        DrawEnd,
        Hit,
        Stand,
        Blackjack,
        Busted,
        Win,
        Lose
    }

    GameType public constant GAME_TYPE = GameType.Blackjack;

    mapping(address => uint8[]) public playerCards; // Player's cards
    mapping(address => uint8[]) public dealerCards; // Dealer's cards
    mapping(address => BJStatus) public playerBJStatus; // Player's status
    mapping(address => BJStatus) public dealerBJStatus; // Dealer's status
    mapping(address => uint8[2]) public cardSum; // Card sum : [player, dealer]

    /**
     * @notice Blackjack Game Contract Constructor
     * @param _JCTToken JCT Token Address
     */
    constructor(address _JCTToken) {
        JCTToken = JonathanCasinoToken(_JCTToken);
        _unpause();
    }

    /**
     * @notice Start Blackjack Game
     * @dev Before starting the game, check if the player is not started/ended and has no reward
     */
    function startGame() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");
    }

    /**
     * @notice Place Bet
     * @param amount Betting amount
     * @dev Before placing the bet, check if the player is in betting state and the bet amount is valid
     */
    function placeBet(uint256 amount) public whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Betting, "You must in betting state");
        require(amount >= MIN_BET && amount <= MAX_BET, "Invalid bet amount");
        require(playerBets[msg.sender] == 0, "You should bet only once");

        playerBets[msg.sender] += amount;
    }

    /**
     * @notice Draw Cards
     * @dev Before drawing the cards, check if the player is in drawing state and the bet amount is valid
     * @return playerCards Player's cards
     * @return dealerCards Dealer's cards
     */
    function draw() public whenNotPaused checkInvalidAddress returns (uint8[] memory, uint8[] memory) {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        // When both player and dealer draw first card
        if (playerBJStatus[msg.sender] == BJStatus.Draw && dealerBJStatus[msg.sender] == BJStatus.Draw) {
            for (uint8 i = 0; i < 2; i++) {
                playerCards[msg.sender].push(drawCard());
            }

            dealerCards[msg.sender].push(drawCard());

            // Set player and dealer's status to draw end
            playerBJStatus[msg.sender] = BJStatus.DrawEnd;
            dealerBJStatus[msg.sender] = BJStatus.DrawEnd;
        }
        // When player draw card
        else if (playerBJStatus[msg.sender] == BJStatus.Hit && dealerBJStatus[msg.sender] == BJStatus.DrawEnd) {
            playerCards[msg.sender].push(drawCard());
        } else if (playerBJStatus[msg.sender] == BJStatus.Stand && dealerBJStatus[msg.sender] == BJStatus.DrawEnd) {
            dealerDraw(msg.sender);
        }

        // When player has blackjack
        if (playerCards[msg.sender].length == 2 && checkCardSum(playerCards[msg.sender]) == 21) {
            playerGameState[msg.sender] = GameState.Rewarding;
            playerBJStatus[msg.sender] = BJStatus.Blackjack;
            dealerBJStatus[msg.sender] = BJStatus.Lose;
        }
        // When dealer has blackjack
        else if(dealerCards[msg.sender].length == 2 && checkCardSum(dealerCards[msg.sender]) == 21) {
            playerGameState[msg.sender] = GameState.Rewarding;
            playerBJStatus[msg.sender] = BJStatus.Lose;
            dealerBJStatus[msg.sender] = BJStatus.Blackjack;
        }
        // When player busted
        else if (checkCardSum(playerCards[msg.sender]) > 21) {
            playerGameState[msg.sender] = GameState.Rewarding;
            playerBJStatus[msg.sender] = BJStatus.Busted;
            dealerBJStatus[msg.sender] = BJStatus.Win;
        }
        // When player and dealer have same card sum
        else if (checkCardSum(playerCards[msg.sender]) == checkCardSum(dealerCards[msg.sender])) {
            playerGameState[msg.sender] = GameState.Rewarding;
            playerBJStatus[msg.sender] = BJStatus.Draw;
            dealerBJStatus[msg.sender] = BJStatus.Draw;
        }
        // When player's card sum is higher than dealer's
        else if (checkCardSum(playerCards[msg.sender]) > checkCardSum(dealerCards[msg.sender])) {
            playerGameState[msg.sender] = GameState.Rewarding;
            playerBJStatus[msg.sender] = BJStatus.Win;
            dealerBJStatus[msg.sender] = BJStatus.Lose;
        }
        // When player's card sum is lower than dealer's
        else if (checkCardSum(playerCards[msg.sender]) < checkCardSum(dealerCards[msg.sender])) {
            playerGameState[msg.sender] = GameState.Rewarding;
            playerBJStatus[msg.sender] = BJStatus.Lose;
            dealerBJStatus[msg.sender] = BJStatus.Win;
        }

        // Return player's and dealer's cards
        return (playerCards[msg.sender], dealerCards[msg.sender]);
    }

    /**
     * @notice Hit or Stand
     * @param isHit Whether to hit (true) or stand (false)
     * @dev Before hitting or standing, check if the player is in drawing state and the player has drawn first
     * @return always true (sign of execution success)
     */
    function hitOrStand(bool isHit) public whenNotPaused checkInvalidAddress returns (bool){
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBJStatus[msg.sender] == BJStatus.DrawEnd || playerBJStatus[msg.sender] == BJStatus.Hit, "You must draw first");

        if (isHit) {
            playerBJStatus[msg.sender] = BJStatus.Hit;
        } else {
            playerBJStatus[msg.sender] = BJStatus.Stand;
        }

        return true;
    }

    /**
     * @notice Check Card Sum
     * @param cards Cards to check
     * @return sum Sum of the cards
     */
    function checkCardSum(uint8[] memory cards) internal pure returns (uint8) {
        uint8 sum = 0;

        for (uint8 i = 0; i < cards.length; i++) {
            if (cards[i] == 10 || cards[i] == 11 || cards[i] == 12) {
                sum += 10;
            } else if (cards[i] == 0 && sum + 11 <= 21) {
                sum += 11;
            } else if (cards[i] == 0) {
                sum += 1;
            } else {
                sum += cards[i] + 1;
            }
        }

        return sum;
    }

    /**
     * @notice Draw Card
     * @return uint8 number - Card drawn
     */
    function drawCard() internal view returns (uint8) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    keccak256(abi.encodePacked(block.prevrandao, block.timestamp, block.number))
                )
            )
        );
        
        return uint8(randomNumber % 13);
    }

    /**
     * @notice Dealer Draw
     * @param player Address of the player
     */
    function dealerDraw(address player) internal {
        while (true) {
            if (dealerBJStatus[player] == BJStatus.DrawEnd && cardSum[player][1] < 16) {
                dealerCards[player].push(drawCard());
            }
            else if (dealerBJStatus[player] == BJStatus.DrawEnd && cardSum[player][1] >= 16) {
                dealerBJStatus[player] = BJStatus.Stand;
                break;
            }
        }
    }

    /**
     * @notice Process Rewards
     * @dev Before processing the rewards, check if the player is in drawing state and the player has bet
     */
    function processRewards() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        // Process rewards based on the player's status
        if (playerBJStatus[msg.sender] == BJStatus.Blackjack) {
            playerRewards[msg.sender] = playerBets[msg.sender] * 3;
        } else if (playerBJStatus[msg.sender] == BJStatus.Busted || playerBJStatus[msg.sender] == BJStatus.Lose) {
            playerRewards[msg.sender] = 0;
        } else if (playerBJStatus[msg.sender] == BJStatus.Win) {
            playerRewards[msg.sender] = playerBets[msg.sender] * 2;
        } else if (playerBJStatus[msg.sender] == BJStatus.Draw) {
            playerRewards[msg.sender] = playerBets[msg.sender];
        }
    }

    /**
     * @notice Claim Rewards
     * @dev Before claiming the rewards, check if the player is in claiming state
     */
    function claimRewards() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Claiming, "You must in claiming state");

        // Transfer token rewards to the player
        JCTToken.transfer(msg.sender, playerRewards[msg.sender]);
        
        // Reset player's cards, dealer's cards, player's status, dealer's status, and card sum
        delete playerCards[msg.sender];
        delete dealerCards[msg.sender];
        delete playerBJStatus[msg.sender];
        delete dealerBJStatus[msg.sender];
        delete cardSum[msg.sender];
    }
}
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
 * 2. If card sum is 21 and count of cards is 2, it is called "Blackjack" and player will be rewarded with 2.5x of bet
      (If dealer has blackjack, player will lose the bet)
 * 3. If card sum is over 21, it is called "Bust" and player will lose the bet
 */

contract BlackjackGame is GameBase{
    enum PlayerBJStatus {
        Draw,
        DrawEnd,
        Hit,
        Stand,
        Blackjack
    }

    enum DealerBJStatus {
        Draw,
        DrawEnd,
        Hit,
        Stand,
        Blackjack
    }

    mapping(address => uint8[]) public playerCards;
    mapping(address => uint8[]) public dealerCards;
    mapping(address => PlayerBJStatus) public playerBJStatus;
    mapping(address => DealerBJStatus) public dealerBJStatus;
    mapping(address => uint8[2][]) public bothCards;

    constructor(address _JCTToken) {
        JCTToken = JonathanCasinoToken(_JCTToken);
        _unpause();
    }

    function startGame() public override whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Ended, "Player is not started/ended");
        require(playerRewards[msg.sender] == 0, "You should claim your reward before starting a new game");
    }

    function placeBet(uint256 amount) public whenNotPaused checkInvalidAddress statusTransition {
        require(playerGameState[msg.sender] == GameState.Betting, "You must in betting state");
        require(amount >= MIN_BET && amount <= MAX_BET, "Invalid bet amount");
        require(playerBets[msg.sender] == 0, "You should bet only once");

        playerBets[msg.sender] += amount;
    }

    function draw() public whenNotPaused checkInvalidAddress returns (uint8[][] memory) {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBets[msg.sender] > 0, "You should bet first");

        if (playerBJStatus[msg.sender] == PlayerBJStatus.Draw && dealerBJStatus[msg.sender] == DealerBJStatus.Draw) {
            for (uint8 i = 0; i < 2; i++)
                playerCards[msg.sender].push(drawCard());
            dealerCards[msg.sender].push(drawCard());

            playerBJStatus[msg.sender] = PlayerBJStatus.DrawEnd;
            dealerBJStatus[msg.sender] = DealerBJStatus.DrawEnd;
        } else if (playerBJStatus[msg.sender] == PlayerBJStatus.Hit && dealerBJStatus[msg.sender] == DealerBJStatus.DrawEnd) {
            playerCards[msg.sender].push(drawCard());
        } else if (playerBJStatus[msg.sender] == PlayerBJStatus.Stand && (dealerBJStatus[msg.sender] == DealerBJStatus.DrawEnd || dealerBJStatus[msg.sender] == DealerBJStatus.Stand)) {
            dealerCards[msg.sender].push(drawCard());
        }

        if 

        bothCards[msg.sender][0] = playerCards[msg.sender];
        bothCards[msg.sender][1] = dealerCards[msg.sender];

        return bothCards[msg.sender];
    }

    function hitOrStand(bool isHit) public whenNotPaused checkInvalidAddress {
        require(playerGameState[msg.sender] == GameState.Drawing, "You must in drawing state");
        require(playerBJStatus[msg.sender] == PlayerBJStatus.DrawEnd, "You must draw first");

        if (isHit) {
            playerBJStatus[msg.sender] = PlayerBJStatus.Hit;
            draw();
        } else {
            playerBJStatus[msg.sender] = PlayerBJStatus.Stand;
            draw();
        }
    }

    function checkCardSum(uint8[] memory cards) internal view returns (uint8) {
        uint8 sum = 0;

        for (uint8 i = 0; i < cards.length; i++) {
            if (cards[i] == 10 || cards[i] == 11 || cards[i] == 12) {
                sum += 10;
            } else if (cards[i] == 0 && sum + 11 <= 21) {
                sum += 11;
            } else if (cards[i] == 0) {
                
            } else {
                sum += cards[i] + 1;
            }
        }
        return sum;
    }

    function drawCard() internal view returns (uint8) {
        return uint8((block.prevrandao + block.timestamp + block.number) % 13);
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

        JCTToken.transfer(msg.sender, playerRewards[msg.sender]);
        playerRewards[msg.sender] = 0;
    }
}
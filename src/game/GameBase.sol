// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../token/JonathanCasinoToken.sol";
import "../counter/CasinoCounter.sol";

import "@openzeppelin/contracts/utils/Pausable.sol";

abstract contract GameBase is Pausable {
    JonathanCasinoToken JCTToken;

    CasinoCounter casinoCounter;

    error InvalidPlayerAddress(address player);

    enum GameType { CoinToss, Roulette, Blackjack }
    enum GameState { Ended, Betting, Drawing, Rewarding, Claiming }

    uint256 public constant MIN_BET = 100;          // Minimum betting amount
    uint256 public constant MAX_BET = 2000;         // Maximum betting amount

    address public owner;
    bool public initialized = false;

    // Mapping of player addresses to their betting amounts
    mapping(address => uint256) public playerBets;
    // Mapping of player addresses to their rewards
    mapping(address => uint256) public playerRewards;
    // Mapping of player addresses to their game states
    mapping(address => GameState) public playerGameState;

    constructor(address _proxy) {
        owner = _proxy;
    }


    // Check if the player address is valid
    modifier checkInvalidAddress() {
        if (msg.sender == address(0)) {
            revert InvalidPlayerAddress(msg.sender);
        }
        _;
    }

    // Transition the game state when each function is finished
    modifier statusTransition() {
        _;
        if (playerGameState[msg.sender] == GameState.Claiming) {
            playerGameState[msg.sender] = GameState.Ended;
        } else {
            playerGameState[msg.sender] = GameState(uint8(playerGameState[msg.sender]) + 1);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier isInitialized() {
        require(initialized, "Contract is not initialized");
        _;
    }

    function initialize(address _JCTToken, address _casinoCounter, address _owner) public onlyOwner{
        JCTToken = JonathanCasinoToken(_JCTToken);
        casinoCounter = CasinoCounter(_casinoCounter);
        owner = _owner;
        initialized = true;
    }

    // Start the game
    function startGame() public virtual;
    // placeBet() and draw() must be customed by developers
    // Process the rewards
    function processRewards() public virtual;
    // Claim the rewards
    function claimRewards() public virtual;
}

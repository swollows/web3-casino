// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/console.sol";

import "../token/JonathanCasinoToken.sol";
import "../counter/CasinoCounter.sol";

import "@openzeppelin/contracts/utils/Pausable.sol";

abstract contract GameBase is Pausable {
    JonathanCasinoToken JCTToken;
    CasinoCounter casinoCounter;

    address public owner;

    bool public initialized = false;

    bytes4 public constant START_GAME_SELECTOR = bytes4(keccak256("startGame()"));
    bytes4 public constant DRAW_SELECTOR = bytes4(keccak256("draw()"));
    bytes4 public constant PROCESS_REWARDS_SELECTOR = bytes4(keccak256("processRewards()"));
    bytes4 public constant CLAIM_REWARDS_SELECTOR = bytes4(keccak256("claimRewards()"));
    bytes4 public constant MULTICALL_SELECTOR = bytes4(keccak256("multicall(bytes[])"));

    error InvalidPlayerAddress(address player);

    enum GameType { CoinToss, Roulette, Blackjack }
    enum GameState { Ended, Betting, Drawing, Rewarding, Claiming }

    uint256 public constant MIN_BET = 100;          // Minimum betting amount
    uint256 public constant MAX_BET = 2000;         // Maximum betting amount

    // Mapping of player addresses to their betting amounts
    mapping(address => uint256) public playerBets;
    // Mapping of player addresses to their rewards
    mapping(address => uint256) public playerRewards;
    // Mapping of player addresses to their game states
    mapping(address => GameState) public playerGameState;

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

    modifier isInitialized() {
        require(initialized, "Contract is not initialized");
        require(owner != address(0), "Owner is not set");
        _;
    }

    function initialize(address _JCTToken, address _casinoCounter, address _owner) public {
        require(!initialized, "Contract already initialized");
        JCTToken = JonathanCasinoToken(_JCTToken);
        casinoCounter = CasinoCounter(_casinoCounter);
        owner = _owner;
        initialized = true;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    // Start the game
    function startGame() public virtual;
    // placeBet() and draw() must be customed by developers
    // Process the rewards
    function processRewards() public virtual;
    // Claim the rewards
    function claimRewards() public virtual;

    function multicall(bytes[] memory data) public {
        require(data.length > 0, "No data to call");

        console.log("\nCaller:", msg.sender, "\n");

        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "Multicall failed");
        }
    }
}

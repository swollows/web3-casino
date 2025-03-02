// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/console.sol";

import "../token/JonathanCasinoToken.sol";
import "../counter/CasinoCounter.sol";

import "@openzeppelin/contracts/utils/Pausable.sol";

abstract contract GameBase is Pausable {
    error InvalidPlayerAddress(address player);

    JonathanCasinoToken JCTToken;
    CasinoCounter casinoCounter;

    address public owner;

    bool public initialized = false;

    bytes4 public constant START_GAME_SELECTOR = bytes4(keccak256("startGame()"));
    bytes4 public constant DRAW_SELECTOR = bytes4(keccak256("draw()"));
    bytes4 public constant PROCESS_REWARDS_SELECTOR = bytes4(keccak256("processRewards()"));
    bytes4 public constant CLAIM_REWARDS_SELECTOR = bytes4(keccak256("claimRewards()"));
    bytes4 public constant MULTICALL_SELECTOR = bytes4(keccak256("multicall(bytes[])"));

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

    /**
     * @notice Modifier to check if the player address is valid
     */
    modifier checkInvalidAddress() {
        if (msg.sender == address(0)) {
            revert InvalidPlayerAddress(msg.sender);
        }
        _;
    }

    /**
     * @notice Modifier to transition the game state when each function is finished
     */
    modifier statusTransition() {
        _;
        if (playerGameState[msg.sender] == GameState.Claiming) {
            playerGameState[msg.sender] = GameState.Ended;
        } else {
            playerGameState[msg.sender] = GameState(uint8(playerGameState[msg.sender]) + 1);
        }
    }

    /**
     * @notice Modifier to check if the contract is initialized
     */
    modifier isInitialized() {
        require(initialized, "Contract is not initialized");
        require(owner != address(0), "Owner is not set");
        _;
    }

    /**
     * @notice Initialize the contract
     * @param _JCTToken The address of the JCTToken contract
     * @param _casinoCounter The address of the CasinoCounter contract
     * @param _owner The address of the owner
     */
    function initialize(address _JCTToken, address _casinoCounter, address _owner) public {
        require(!initialized, "Contract already initialized");
        JCTToken = JonathanCasinoToken(_JCTToken);
        casinoCounter = CasinoCounter(_casinoCounter);
        owner = _owner;
        initialized = true;
    }

    /**
     * @notice Get the owner of the contract
     * @return The address of the owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @notice Start the game
     */
    function startGame() public virtual;

    /**
     * @notice Process the rewards
     */
    function processRewards() public virtual;

    /**
     * @notice Claim the rewards
     */
    function claimRewards() public virtual;

    /**
     * @notice Multicall the functions
     * @param _data The data of the functions
     */
    function multicall(bytes[] memory _data) public {
        require(_data.length > 0, "No data to call");

        for (uint256 i = 0; i < _data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(_data[i]);
            require(success, "Multicall failed");
        }
    }
}

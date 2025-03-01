// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract CasinoCounter is AccessControl {
    enum GameType { CoinToss, Roulette, Blackjack }

    mapping(address => uint256[3]) public totalPlays;
    mapping(address => uint256[3]) public totalWins;
    mapping(address => uint256[3]) public totalLosses;
    mapping(address => uint256[3]) public totalDraws;
    mapping(address => uint256[3]) public totalBets;
    mapping(address => uint256[3]) public totalRewards;

    bytes32 public constant GAME_PROXY_ROLE = keccak256("GAME_PROXY_ROLE");

    /**
     * @notice Constructor of the CasinoCounter contract
     * @param _coinTossProxy The address of the CoinTossGame contract
     * @param _rouletteProxy The address of the RouletteGame contract
     */
    constructor(address _coinTossProxy, address _rouletteProxy) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GAME_PROXY_ROLE, _coinTossProxy);
        _grantRole(GAME_PROXY_ROLE, _rouletteProxy);
    }

    /**
     * @notice Get all the information of the player
     * @param _player The address of the player
     * @return plays The number of plays
     * @return wins The number of wins
     * @return losses The number of losses
     * @return draws The number of draws
     * @return bets The number of bets
     * @return rewards The number of rewards
     */
    function getAllInfo(address _player) public view returns (
        uint256[3] memory plays, 
        uint256[3] memory wins, 
        uint256[3] memory losses, 
        uint256[3] memory draws, 
        uint256[3] memory bets, 
        uint256[3] memory rewards
    ) {
        return (
            totalPlays[_player], 
            totalWins[_player], 
            totalLosses[_player], 
            totalDraws[_player], 
            totalBets[_player], 
            totalRewards[_player]
        );
    }

    /**
     * @notice Get the information of the CoinTossGame
     * @param _player The address of the player
     * @return plays The number of plays
     * @return wins The number of wins
     * @return losses The number of losses
     * @return draws The number of draws
     * @return bets The number of bets
     * @return rewards The number of rewards
     */
    function getCoinTossInfo(address _player) public view returns (
        uint256 plays,
        uint256 wins,
        uint256 losses,
        uint256 draws,
        uint256 bets,
        uint256 rewards
    ) {
        return (
            totalPlays[_player][uint256(GameType.CoinToss)],
            totalWins[_player][uint256(GameType.CoinToss)],
            totalLosses[_player][uint256(GameType.CoinToss)],
            totalDraws[_player][uint256(GameType.CoinToss)],
            totalBets[_player][uint256(GameType.CoinToss)],
            totalRewards[_player][uint256(GameType.CoinToss)]
        );
    }

    /**
     * @notice Get the information of the RouletteGame
     * @param _player The address of the player
     * @return plays The number of plays
     * @return wins The number of wins
     * @return losses The number of losses
     * @return draws The number of draws
     * @return bets The number of bets
     * @return rewards The number of rewards
     */
    function getRouletteInfo(address _player) public view returns (
        uint256 plays,
        uint256 wins,
        uint256 losses,
        uint256 draws,
        uint256 bets,
        uint256 rewards
    ) {
        return (
            totalPlays[_player][uint256(GameType.Roulette)],
            totalWins[_player][uint256(GameType.Roulette)],
            totalLosses[_player][uint256(GameType.Roulette)],
            totalDraws[_player][uint256(GameType.Roulette)],
            totalBets[_player][uint256(GameType.Roulette)],
            totalRewards[_player][uint256(GameType.Roulette)]
        );
    }

    /**
     * @notice Get the information of the BlackjackGame
     * @param _player The address of the player
     * @return plays The number of plays
     * @return wins The number of wins
     * @return losses The number of losses
     * @return draws The number of draws
     * @return bets The number of bets
     * @return rewards The number of rewards
     */
    function getBlackjackInfo(address _player) public view returns (
        uint256 plays,
        uint256 wins,
        uint256 losses,
        uint256 draws,
        uint256 bets,
        uint256 rewards
    ) {
        return (
            totalPlays[_player][uint256(GameType.Blackjack)],
            totalWins[_player][uint256(GameType.Blackjack)],
            totalLosses[_player][uint256(GameType.Blackjack)],
            totalDraws[_player][uint256(GameType.Blackjack)],
            totalBets[_player][uint256(GameType.Blackjack)],
            totalRewards[_player][uint256(GameType.Blackjack)]
        );
    }

    /**
     * @notice Get the total number of plays
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @return The total number of plays
     */
    function getTotalPlays(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalPlays[_player][_gameType];
    }

    /**
     * @notice Get the total number of wins
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @return The total number of wins
     */
    function getTotalWins(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalWins[_player][_gameType];
    }

    /**
     * @notice Get the total number of losses
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @return The total number of losses
     */
    function getTotalLosses(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalLosses[_player][_gameType];
    }

    /**
     * @notice Get the total number of draws
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @return The total number of draws
     */
    function getTotalDraws(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalDraws[_player][_gameType];
    }

    /**
     * @notice Get the total number of bets
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @return The total number of bets
     */
    function getTotalBets(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalBets[_player][_gameType];
    }

    /**
     * @notice Get the total number of rewards
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @return The total number of rewards
     */
    function getTotalRewards(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalRewards[_player][_gameType];
    }

    /**
     * @notice Add the total number of plays
     * @param _player The address of the player
     * @param _gameType The type of the game
     */
    function addTotalPlays(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalPlays[_player][_gameType]++;
    }

    /**
     * @notice Add the total number of wins
     * @param _player The address of the player
     * @param _gameType The type of the game
     */
    function addTotalWins(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalWins[_player][_gameType]++;
    }

    /**
     * @notice Add the total number of losses
     * @param _player The address of the player
     * @param _gameType The type of the game
     */
    function addTotalLosses(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalLosses[_player][_gameType]++;
    }

    /**
     * @notice Add the total number of draws
     * @param _player The address of the player
     * @param _gameType The type of the game
     */
    function addTotalDraws(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalDraws[_player][_gameType]++;
    }

    /**
     * @notice Add the total number of bets
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @param _amount The amount of the bets
     */
    function addTotalBets(address _player, uint256 _gameType, uint256 _amount) public onlyRole(GAME_PROXY_ROLE) {
        totalBets[_player][_gameType] += _amount;
    }

    /**
     * @notice Add the total number of rewards
     * @param _player The address of the player
     * @param _gameType The type of the game
     * @param _amount The amount of the rewards
     */
    function addTotalRewards(address _player, uint256 _gameType, uint256 _amount) public onlyRole(GAME_PROXY_ROLE) {
        totalRewards[_player][_gameType] += _amount;
    }

    /**
     * @notice Remove all the information of the player
     * @param _player The address of the player
     */
    function removeAllInfo(address _player) public onlyRole(DEFAULT_ADMIN_ROLE) {
        delete totalPlays[_player];
        delete totalWins[_player];
        delete totalLosses[_player];
        delete totalDraws[_player];
        delete totalBets[_player];
        delete totalRewards[_player];
    }
}

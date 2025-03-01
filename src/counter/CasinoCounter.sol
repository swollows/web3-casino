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

    constructor(address _proxy) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GAME_PROXY_ROLE, _proxy);
    }

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

    function getTotalPlays(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalPlays[_player][_gameType];
    }

    function getTotalWins(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalWins[_player][_gameType];
    }

    function getTotalLosses(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalLosses[_player][_gameType];
    }

    function getTotalDraws(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalDraws[_player][_gameType];
    }

    function getTotalBets(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalBets[_player][_gameType];
    }

    function getTotalRewards(address _player, uint256 _gameType) internal view returns (uint256) {
        return totalRewards[_player][_gameType];
    }

    function addTotalPlays(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalPlays[_player][_gameType]++;
    }

    function addTotalWins(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalWins[_player][_gameType]++;
    }

    function addTotalLosses(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalLosses[_player][_gameType]++;
    }

    function addTotalDraws(address _player, uint256 _gameType) public onlyRole(GAME_PROXY_ROLE) {
        totalDraws[_player][_gameType]++;
    }

    function addTotalBets(address _player, uint256 _gameType, uint256 _amount) public onlyRole(GAME_PROXY_ROLE) {
        totalBets[_player][_gameType] += _amount;
    }

    function addTotalRewards(address _player, uint256 _gameType, uint256 _amount) public onlyRole(GAME_PROXY_ROLE) {
        totalRewards[_player][_gameType] += _amount;
    }

    function removeAllInfo(address _player) public onlyRole(DEFAULT_ADMIN_ROLE) {
        delete totalPlays[_player];
        delete totalWins[_player];
        delete totalLosses[_player];
        delete totalDraws[_player];
        delete totalBets[_player];
        delete totalRewards[_player];
    }
}

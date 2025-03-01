// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title ICoinTossGame
 * @notice Interface for the CoinTossGame contract
 */
interface ICoinTossGame {
    function startGame() external;
    function placeBet(uint256 amount, bool isHead) external;
    function draw() external;
    function processRewards() external;
    function claimRewards() external;
    function initialize(address _JCTToken, address _casinoCounter, address _proxy) external;
    function multiplePlay(uint256[] memory amounts, bool[] memory isHeads) external;
}

/**
 * @title IRouletteGame
 * @notice Interface for the RouletteGame contract
 */
interface IRouletteGame {
    function startGame() external;
    function placeBet(uint256 amount, uint8 number) external;
    function draw() external;
    function processRewards() external;
    function claimRewards() external;
    function initialize(address _JCTToken, address _casinoCounter, address _proxy) external;
    function multiplePlay(uint256[] memory amounts, uint8[] memory numbers) external;
}
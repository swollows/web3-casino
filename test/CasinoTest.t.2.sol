// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/proxy/GameProxy.sol";
import "../src/token/JonathanCasinoToken.sol";
import "../src/game/CoinTossGameV1.sol";
import "../src/game/RouletteGameV1.sol";
import "../src/counter/CasinoCounter.sol";

// Game Interfaces
import "../src/game/GameInterfaces.sol";

contract CasinoGameProxyTest is Test {
    JonathanCasinoToken public token;
    CasinoCounter casinoCounter;
    CoinTossProxy coinTossProxy;
    RouletteProxy rouletteProxy;
    CoinTossGame coinTossGame;
    RouletteGame rouletteGame;

    enum GameType { CoinToss, Roulette, Blackjack }
    
    address public owner = address(1);
    address public player1 = address(2);
    address public player2 = address(3);
    address public player3 = address(4);
    
    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(player1, 100 ether);
        vm.deal(player2, 100 ether);
        vm.deal(player3, 100 ether);

        vm.startPrank(owner);

        console.log("Owner:", owner);
        console.log("Deploying token contract...");

        // 컨트랙트 배포 (배포 시 1 ether를 보내야 함)
        token = new JonathanCasinoToken{value: 1 ether}(owner);

        coinTossProxy = new CoinTossProxy();
        rouletteProxy = new RouletteProxy();
        
        CasinoCounter casinoCounter = new CasinoCounter();

        casinoCounter.grantRole(casinoCounter.GAME_PROXY_ROLE(), address(coinTossProxy));
        casinoCounter.grantRole(casinoCounter.GAME_PROXY_ROLE(), address(rouletteProxy));

        coinTossProxy.setCasinoCounter(address(casinoCounter));
        coinTossProxy.setJCTToken(address(token));

        rouletteProxy.setCasinoCounter(address(casinoCounter));
        rouletteProxy.setJCTToken(address(token));

        coinTossGame = new CoinTossGame();
        rouletteGame = new RouletteGame();

        console.log("CoinTossProxy address:", address(coinTossProxy));
        console.log("CoinTossGame address:", address(coinTossGame));
        console.log("RouletteProxy address:", address(rouletteProxy));
        console.log("RouletteGame address:", address(rouletteGame));
        console.log("CasinoCounter address:", address(casinoCounter));

        coinTossProxy.setImplementation(address(coinTossGame));
        rouletteProxy.setImplementation(address(rouletteGame));

        (bool result1, ) = address(coinTossProxy).call{value: 0}(abi.encodeWithSignature("initialize(address,address,address)", address(token), address(casinoCounter), address(owner)));
        require(result1, "Failed to initialize");

        (bool result2, ) = address(rouletteProxy).call{value: 0}(abi.encodeWithSignature("initialize(address,address,address)", address(token), address(casinoCounter), address(owner)));
        require(result2, "Failed to initialize");

        // 컨트랙트 주소 출력
        console.log("Token deployed at:", address(token));
        console.log("CoinTossGame owner:", coinTossGame.getOwner());
        console.log("RouletteGame owner:", rouletteGame.getOwner());
        
        vm.stopPrank();
    }

    function testCoinTossGameWin() public {
        // 충전 전 토큰 잔액 확인
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        // 충전
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}();

        // 시작 전 토큰 잔액 확인
        console.log("\nBefore game start");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        vm.startPrank(player1);

        // 게임 시작
        ICoinTossGame(address(coinTossProxy)).startGame();

        // 베팅
        ICoinTossGame(address(coinTossProxy)).placeBet(2000, false);

        // 코인 토스 추첨
        ICoinTossGame(address(coinTossProxy)).draw();

        // 보상 수여
        ICoinTossGame(address(coinTossProxy)).processRewards();

        // 보상 획득
        ICoinTossGame(address(coinTossProxy)).claimRewards();

        vm.stopPrank();

        // 종료 후 토큰 잔액 상태 확인
        console.log("\nAfter game end");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (CoinToss)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.CoinToss)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.CoinToss)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.CoinToss)));
        console.log("Total draws:", casinoCounter.totalDraws(player1, uint256(GameType.CoinToss)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.CoinToss)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.CoinToss)));
    }

    function testCoinTossGameLose() public {
        // 충전 전 토큰 잔액 확인
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        // 충전
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}();

        // 시작 전 토큰 잔액 확인
        console.log("\nBefore game start");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        vm.startPrank(player1);

        // 게임 시작
        ICoinTossGame(address(coinTossProxy)).startGame();

        // 베팅
        ICoinTossGame(address(coinTossProxy)).placeBet(2000, true);

        // 코인 토스 추첨
        ICoinTossGame(address(coinTossProxy)).draw();

        // 보상 수여
        ICoinTossGame(address(coinTossProxy)).processRewards();

        // 보상 획득
        ICoinTossGame(address(coinTossProxy)).claimRewards();

        vm.stopPrank();

        // 종료 후 토큰 잔액 상태 확인
        console.log("\nAfter game end");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (CoinToss)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.CoinToss)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.CoinToss)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.CoinToss)));
        console.log("Total draws:", casinoCounter.totalDraws(player1, uint256(GameType.CoinToss)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.CoinToss)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.CoinToss)));
    }

    function testCoinTossGameMultiplePlay() public {
        // 충전 전 토큰 잔액 확인
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        // 충전
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}();

        vm.startPrank(player1);

        uint256[] memory amounts = new uint256[](10);
        for (uint256 i = 0; i < amounts.length; i++) {
            amounts[i] = 2000;
        }

        bool[] memory isHeads = new bool[](10);
        for (uint256 i = 0; i < isHeads.length; i++) {
            isHeads[i] = false;
        }

        // 시작 전 토큰 잔액 상태 확인
        console.log("\nBefore multiple play");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (CoinToss)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.CoinToss)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.CoinToss)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.CoinToss)));
        console.log("Total draws:", casinoCounter.totalDraws(player1, uint256(GameType.CoinToss)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.CoinToss)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.CoinToss)));

        ICoinTossGame(address(coinTossProxy)).multiplePlay(amounts, isHeads);

        // 종료 후 토큰 잔액 상태 확인
        console.log("\nAfter multiple play");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (CoinToss)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.CoinToss)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.CoinToss)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.CoinToss)));
        console.log("Total draws:", casinoCounter.totalDraws(player1, uint256(GameType.CoinToss)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.CoinToss)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.CoinToss)));

        vm.stopPrank();
    }

    function testRouletteGameWin() public {
        // 충전 전 토큰 잔액 확인
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        // 충전
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}();

        // 시작 전 토큰 잔액 확인
        console.log("\nBefore game start");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        vm.startPrank(player1);

        // 게임 시작
        IRouletteGame(address(rouletteProxy)).startGame();

        // 베팅
        IRouletteGame(address(rouletteProxy)).placeBet(2000, 2);

        // 룰렛 추첨
        IRouletteGame(address(rouletteProxy)).draw();

        // 보상 수여
        IRouletteGame(address(rouletteProxy)).processRewards();

        // 보상 획득
        IRouletteGame(address(rouletteProxy)).claimRewards();

        vm.stopPrank();

        // 종료 후 토큰 잔액 상태 확인
        console.log("\nAfter game end");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (Roulette)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.Roulette)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.Roulette)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.Roulette)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.Roulette)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.Roulette)));
    }

    function testRouletteGameLose() public {
        // 충전 전 토큰 잔액 확인
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        // 충전
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}();

        // 시작 전 토큰 잔액 확인
        console.log("\nBefore game start");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        vm.startPrank(player1);

        // 게임 시작
        IRouletteGame(address(rouletteProxy)).startGame();

        // 베팅
        IRouletteGame(address(rouletteProxy)).placeBet(2000, 1);

        // 룰렛 추첨
        IRouletteGame(address(rouletteProxy)).draw();

        // 보상 수여
        IRouletteGame(address(rouletteProxy)).processRewards();

        // 보상 획득
        IRouletteGame(address(rouletteProxy)).claimRewards();

        vm.stopPrank();

        // 종료 후 토큰 잔액 상태 확인
        console.log("\nAfter game end");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (Roulette)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.Roulette)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.Roulette)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.Roulette)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.Roulette)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.Roulette)));
    }

    function testRouletteGameMultiplePlay() public {
        // 충전 전 토큰 잔액 확인
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        // 충전
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}();

        vm.startPrank(player1);

        uint256[] memory amounts = new uint256[](10);
        for (uint256 i = 0; i < amounts.length; i++) {
            amounts[i] = 2000;
        }

        uint8[] memory numbers = new uint8[](10);
        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = uint8(2);
        }

        // 시작 전 토큰 잔액 상태 확인
        console.log("\nBefore multiple play");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (Roulette)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.Roulette)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.Roulette)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.Roulette)));
        console.log("Total draws:", casinoCounter.totalDraws(player1, uint256(GameType.CoinToss)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.CoinToss)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.CoinToss)));

        IRouletteGame(address(rouletteProxy)).multiplePlay(amounts, numbers);

        // 종료 후 토큰 잔액 상태 확인
        console.log("\nAfter multiple play");
        console.log("Token balance of owner:", token.balanceOf(owner));
        console.log("Token balance of player1:", token.balanceOf(player1));

        console.log("\nCheck CasinoCounter (Roulette)");
        console.log("Total plays:", casinoCounter.totalPlays(player1, uint256(GameType.Roulette)));
        console.log("Total wins:", casinoCounter.totalWins(player1, uint256(GameType.Roulette)));
        console.log("Total losses:", casinoCounter.totalLosses(player1, uint256(GameType.Roulette)));
        console.log("Total draws:", casinoCounter.totalDraws(player1, uint256(GameType.Roulette)));
        console.log("Total bets:", casinoCounter.totalBets(player1, uint256(GameType.Roulette)));
        console.log("Total rewards:", casinoCounter.totalRewards(player1, uint256(GameType.Roulette)));

        vm.stopPrank();
    }
}

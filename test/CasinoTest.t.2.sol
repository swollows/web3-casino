// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/proxy/GameProxy.sol";
import "../src/token/JonathanCasinoToken.sol";
import "../src/game/CoinTossGameV1.sol";

interface ICoinTossGame {
    function startGame() external;
    function placeBet(uint256 amount, bool isHead) external;
    function draw() external;
    function processRewards() external;
    function claimRewards() external;
    function initialize(address _JCTToken, address _casinoCounter, address _proxy) external;
}

contract CasinoGameProxyTest is Test {
    JonathanCasinoToken public token;
    CasinoCounter casinoCounter;
    CoinTossProxy coinTossProxy;
    CoinTossGame coinTossGame;
    
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

        casinoCounter = new CasinoCounter();

        coinTossProxy = new CoinTossProxy(address(casinoCounter), address(token));

        coinTossGame = new CoinTossGame(address(coinTossProxy));

        console.log("CoinTossGame proxy address:", coinTossGame.getProxyAddress());
        console.log("CoinTossProxy address:", address(coinTossProxy));

        coinTossProxy.upgradeDelegate(address(coinTossGame));

        (bool result, ) = address(coinTossProxy).call{value: 0}(abi.encodeWithSignature("initialize(address,address)", address(token), address(casinoCounter)));
        require(result, "Failed to initialize");

        // 컨트랙트 주소 출력
        console.log("Token deployed at:", address(token));

        vm.stopPrank();
    }

    function testCoinTossGame() public {
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
    }
}

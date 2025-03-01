// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/token/JonathanCasinoToken.sol";
import "../src/proxy/GameProxy.sol";
import "../src/game/CoinTossGameV1.sol";
import "../src/game/RouletteGameV1.sol";

interface ICoinTossGame {
    function startGame() external;
    function placeBet(uint256 amount, bool isHead) external;
    function draw() external;
    function processRewards() external;
    function claimRewards() external;
    function initialize(address _JCTToken, address _casinoCounter, address _owner) external;
}

contract Deploy is Script {
    function run(address owner) public {
        vm.startBroadcast(owner);
        
        // 컨트랙트 배포 (배포 시 1 ether를 보내야 함)
        JonathanCasinoToken token = new JonathanCasinoToken{value: 1 ether}(owner);

        CoinTossProxy coinTossProxy = new CoinTossProxy();
        RouletteProxy rouletteProxy = new RouletteProxy();

        CasinoCounter casinoCounter = new CasinoCounter(address(coinTossProxy), address(rouletteProxy));

        coinTossProxy.setCasinoCounter(address(casinoCounter));
        coinTossProxy.setJCTToken(address(token));

        rouletteProxy.setCasinoCounter(address(casinoCounter));
        rouletteProxy.setJCTToken(address(token));

        CoinTossGame coinTossGame = new CoinTossGame();
        RouletteGame rouletteGame = new RouletteGame();

        console.log("CoinTossProxy address:", address(coinTossProxy));
        console.log("CoinTossGame address:", address(coinTossGame));
        console.log("CoinTossCounter address:", address(casinoCounter));
        console.log("RouletteProxy address:", address(rouletteProxy));
        console.log("RouletteGame address:", address(rouletteGame));

        coinTossProxy.setImplementation(address(coinTossGame));
        rouletteProxy.setImplementation(address(rouletteGame));

        (bool result1, ) = address(coinTossProxy).call{value: 0}(abi.encodeWithSignature("initialize(address,address,address)", address(token), address(casinoCounter), address(owner)));
        require(result1, "Failed to initialize");

        (bool result2, ) = address(rouletteProxy).call{value: 0}(abi.encodeWithSignature("initialize(address,address,address)", address(token), address(casinoCounter), address(owner)));
        require(result2, "Failed to initialize");

        // 컨트랙트 주소 출력
        console.log("\nToken deployed at:", address(token));
        console.log("CoinTossProxy deployed at:", address(coinTossProxy));
        console.log("RouletteProxy deployed at:", address(rouletteProxy));
        console.log("CoinTossGame deployed at:", address(coinTossGame));
        console.log("RouletteGame deployed at:", address(rouletteGame));
        console.log("CoinTossCounter deployed at:", address(casinoCounter));

        vm.stopBroadcast();
    }
}
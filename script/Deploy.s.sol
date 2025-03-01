// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/token/JonathanCasinoToken.sol";
import "../src/proxy/GameProxy.sol";
import "../src/game/CoinTossGameV1.sol";

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

        CasinoCounter casinoCounter = new CasinoCounter(address(coinTossProxy));

        coinTossProxy.setCasinoCounter(address(casinoCounter));
        coinTossProxy.setJCTToken(address(token));

        CoinTossGame coinTossGame = new CoinTossGame();

        console.log("CoinTossProxy address:", address(coinTossProxy));
        console.log("CoinTossGame address:", address(coinTossGame));
        console.log("CoinTossCounter address:", address(casinoCounter));

        coinTossProxy.setImplementation(address(coinTossGame));

        (bool result, ) = address(coinTossProxy).call{value: 0}(abi.encodeWithSignature("initialize(address,address,address)", address(token), address(casinoCounter), address(owner)));
        require(result, "Failed to initialize");

        // 컨트랙트 주소 출력
        console.log("\nToken deployed at:", address(token));
        console.log("CoinTossProxy deployed at:", address(coinTossProxy));
        console.log("CoinTossGame deployed at:", address(coinTossGame));
        console.log("CoinTossCounter deployed at:", address(casinoCounter));

        vm.stopBroadcast();
    }
}
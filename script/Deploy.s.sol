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
    function initialize(address _JCTToken, address _casinoCounter) external;
}

contract Deploy is Script {
    address public testOwner = address(1);
    address public deployOwner;

    function run() public {
        address _owner = testOwner;

        vm.startBroadcast();
        
        vm.startPrank(_owner);

        console.log("Owner:", _owner);

        // 컨트랙트 배포 (배포 시 1 ether를 보내야 함)
        JonathanCasinoToken token = new JonathanCasinoToken{value: 1 ether}(_owner);

        CasinoCounter casinoCounter = new CasinoCounter();

        CoinTossProxy coinTossProxy = new CoinTossProxy(address(casinoCounter), address(token));

        CoinTossGame coinTossGame = new CoinTossGame(address(coinTossProxy));

        console.log("CoinTossGame owner:", coinTossGame.getOwner());

        coinTossProxy.upgradeDelegate(address(coinTossGame));

        ICoinTossGame(address(coinTossProxy)).initialize(address(token), address(casinoCounter));

        // 컨트랙트 주소 출력
        console.log("Token deployed at:", address(token));

        vm.stopPrank();

        vm.stopBroadcast();
    }
}
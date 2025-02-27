// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/token/JonathanCasinoToken.sol";
import "../src/proxy/GameProxy.sol";
import "../src/game/CoinTossGameV1.sol";

contract Deploy is Script {
    address public testOwner = address(1);
    address public deployOwner;

    function run() public {
        address _owner = testOwner;

        vm.startBroadcast();
        
        vm.prank(_owner);

        // 컨트랙트 배포 (배포 시 1 ether를 보내야 함)
        JonathanCasinoToken token = new JonathanCasinoToken{value: 1 ether}(_owner);

        CoinTossGame game = new CoinTossGame();

        GameProxy gameProxy = new GameProxy(address(game), address(0), _owner);

        // 컨트랙트 주소 출력
        console.log("Token deployed at:", address(token));

        vm.stopBroadcast();
    }
}
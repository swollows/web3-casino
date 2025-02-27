// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/token/JonathanCasinoToken.sol";


contract Deploy is Script {
    function run() public {
        vm.startBroadcast();

        address owner = msg.sender;

        // 컨트랙트 배포 (배포 시 1 ether를 보내야 함)
        JonathanCasinoToken token = new JonathanCasinoToken{value: 1 ether}(owner);

        // 컨트랙트 주소 출력
        console.log("Token deployed at:", address(token));

        vm.stopBroadcast();
    }
}
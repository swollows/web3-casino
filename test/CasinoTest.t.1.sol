// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/token/JonathanCasinoToken.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CasinoTokenTest is Test {
    JonathanCasinoToken public token;
    
    address public owner = address(1);
    address public player1 = address(2);
    address public player2 = address(3);
    address public player3 = address(4);
    
    function setUp() public {
        vm.startPrank(owner);
        vm.deal(owner, 100 ether);
        vm.deal(player1, 100 ether);
        vm.deal(player2, 100 ether);
        
        // 컨트랙트 배포
        token = new JonathanCasinoToken{value: 1 ether}(owner);

        vm.stopPrank();

        vm.prank(player1);
        (bool success, ) = address(token).call{value: 200000 * (10 ** token.decimals())}("");
        require(success, "Failed to deposit");

        vm.prank(player2);
        (success, ) = address(token).call{value: 200000 * (10 ** token.decimals())}("");
        require(success, "Failed to deposit");
    }

    function testInitialState() public view {
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));
    }

    function testRevertMintTokenLowerThanMin() public {
        vm.prank(player3);

        vm.expectRevert("You must send at least 2000 * 10e3 wei to the contract");
        
        (bool success, ) = address(token).call{value: 1999 * (10 ** token.decimals())}("");

        require(!success, "Should revert");
    }

    function testRevertMintTokenUpperThanMax() public {
        vm.prank(player3);

        vm.expectRevert("You must send at most 200000 * 10e3 wei to the contract");

        (bool success, ) = address(token).call{value: 200001 * (10 ** token.decimals())}("");

        require(!success, "Should revert");
    }

    function testGetTokenInfo() public view {
        console.log("Token name: ", token.name());
        console.log("Token symbol: ", token.symbol());
        console.log("Token decimals: ", token.decimals());
        console.log("Token totalSupply: ", token.totalSupply());
    }

    function testTokenTransfer() public {
        vm.prank(player1);
        token.transfer(player2, 10000);

        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));
    }

    function testTokenPause() public {
        vm.prank(owner);
        token.pause();

        vm.prank(player1);
        vm.expectRevert(Pausable.EnforcedPause.selector);
        token.transfer(player2, 10000);

        vm.prank(owner);
        token.unpause();

        vm.prank(player1);
        token.transfer(player2, 10000);

        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));
    }
}

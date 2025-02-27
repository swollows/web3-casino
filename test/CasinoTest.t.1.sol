// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/token/JonathanCasinoToken.sol";

contract CasinoTokenTest is Test {
    JonathanCasinoToken public token;
    
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

        console.log("Deploying token contract...");

        // 컨트랙트 배포
        token = new JonathanCasinoToken{value: 1 ether}(owner);

        console.log("\nToken contract deployed at:", address(token));
        console.log("Token contract owner:", token.owner());

        console.log("\nTest case 1-1: Initial state");

        console.log("Token decimals: ", token.decimals());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token name: ", token.name());
        console.log("Token symbol: ", token.symbol());
        console.log("Token total supply: ", token.totalSupply(), "\n");

        vm.stopPrank();
    }

    function testDeposit() public {
        console.log("Test case 1-2: Deposit");
        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}(player1);
        
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of player1:", token.balanceOf(player1));

        vm.prank(player2);
        token.deposit{value: 200000 * 10e3}(player2);
        
        console.log("\nToken total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));
    }

    function testRevert_deposit_InvalidETHRange() public {
        console.log("Test case 1-3: Invalid ETH range when deposit");
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("ETH balance of player1:", address(player1).balance);

        vm.startPrank(player1);
        
        // Invalid ETH range Revert Test Case 1
        // Deposit token lower than min (2000)
        console.log("\nTest case 1-3-1: Deposit token lower than min (2000)");

        vm.expectRevert("Invalid ETH range");
        token.deposit{value: 1999 * 10e3}(player1);

        console.log("Token balance of player1:", token.balanceOf(player1));

        // Invalid ETH range Revert Test Case 2
        // Deposit token upper than max (200000)
        console.log("\nTest case 1-3-2: Deposit token upper than max (200000)");
        
        vm.expectRevert("Invalid ETH range");
        token.deposit{value: 200001 * 10e3}(player1);

        console.log("Token balance of player1:", token.balanceOf(player1));

        vm.stopPrank();
    }

    function testToken_transfer_approveMySelf() public {
        console.log("Test case 1-4: Approved by myself and Transfer");
        
        vm.startPrank(player1);
        
        token.deposit{value: 200000 * 10e3}(player1);

        console.log("\nBefore transfer");
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));

        token.approve(player1, 100000);
        console.log("\nSet allowance");
        console.log("Token allowance of player1:", token.allowance(player1, player1));

        token.transferFrom(player1, player2, 100000);

        console.log("\nReset allowance");
        token.approve(player1, 0);

        console.log("Token allowance of player1:", token.allowance(player1, player1));

        console.log("\nAfter transfer");
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));

        vm.stopPrank();
    }

    function testToken_transfer_approveToOtherOne() public {
        console.log("Test case 1-5: Approved by others and Transfer");

        vm.startPrank(player1);
        
        token.deposit{value: 200000 * 10e3}(player1);

        console.log("\nBefore transfer");
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));

        console.log("\nSet allowance");
        token.approve(player2, 100000);

        vm.stopPrank();

        vm.startPrank(player2);

        console.log("Token allowance of player1:", token.allowance(player1, player2));

        token.transferFrom(player1, player2, 100000);

        vm.stopPrank();

        vm.startPrank(player1);

        console.log("\nReset allowance");
        token.approve(player2, 0);

        console.log("Token allowance of player2:", token.allowance(player1, player2));

        console.log("\nAfter transfer");
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));

        vm.stopPrank();
    }

    function testTokenBurn() public {
        console.log("Test case 1-6: Burn");

        vm.prank(player1);

        token.deposit{value: 200000 * 10e3}(player1);

        console.log("\nBefore burn");
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("ETH balance of player1:", address(player1).balance);

        vm.prank(owner);
        token.burn(player1, 100000);

        console.log("\nAfter burn");
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("ETH balance of player1:", address(player1).balance);
    }

    function testWithdraw() public {
        console.log("Test case 1-7: Withdraw");

        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}(player1);

        console.log("\nBefore withdraw");
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("ETH balance of Contract:", address(token).balance);
        console.log("ETH balance of player1:", address(player1).balance);

        vm.prank(player1);
        token.withdraw(100000);

        console.log("\nAfter withdraw");
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("ETH balance of Contract:", address(token).balance);
        console.log("ETH balance of player1:", address(player1).balance);
    }

    function testEnableEmergency() public {
        uint256 playerBalance;

        console.log("Test case 1-8: Enable emergency");

        vm.prank(player1);
        token.deposit{value: 200000 * 10e3}(player1);

        vm.prank(player2);
        token.deposit{value: 200000 * 10e3}(player2);

        vm.startPrank(owner);

        token.enableEmergency();

        token.emergencyWithdraw();

        vm.stopPrank();

        vm.prank(player1);
        playerBalance = token.balanceOf(player1);
        vm.expectRevert("Contract is paused");
        token.withdraw(playerBalance);

        vm.prank(player2);
        playerBalance = token.balanceOf(player2);
        vm.expectRevert("Contract is paused");
        token.withdraw(playerBalance);

        console.log("\nAfter emergency withdraw");
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));
        console.log("ETH balance of Contract:", address(token).balance);
        console.log("ETH balance of owner:", address(owner).balance);
        console.log("ETH balance of player1:", address(player1).balance);
        console.log("ETH balance of player2:", address(player2).balance);

        console.log("\nTest case 1-9: Disable emergency");

        vm.prank(owner);

        token.disableEmergency();

        vm.startPrank(player1);
        
        playerBalance = token.balanceOf(player1);
        token.withdraw(playerBalance);

        vm.stopPrank();

        vm.startPrank(player2);

        playerBalance = token.balanceOf(player2);
        token.withdraw(playerBalance);

        vm.stopPrank();

        console.log("\nAfter disable emergency");
        console.log("Token total supply: ", token.totalSupply());
        console.log("Token balance of Contract:", token.balanceOf(address(token)));
        console.log("Token balance of player1:", token.balanceOf(player1));
        console.log("Token balance of player2:", token.balanceOf(player2));
        console.log("ETH balance of Contract:", address(token).balance);
        console.log("ETH balance of owner:", address(owner).balance);
        console.log("ETH balance of player1:", address(player1).balance);
        console.log("ETH balance of player2:", address(player2).balance);
    }
}

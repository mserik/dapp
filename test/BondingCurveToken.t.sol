// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/BondingCurveToken.sol";

contract BondingCurveTokenTest is Test {
    BondingCurveToken token;
    address owner = address(1);
    address buyer = address(2);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(buyer, 10 ether);
        token = new BondingCurveToken("BondingCurveToken", "BCT", owner);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 0);
    }

    function testBuyTokens() public {
        vm.prank(buyer);
        token.buy{value: 1 ether}(1);
        assertEq(token.balanceOf(buyer), 1);
        assertEq(token.reserveBalance(), 1 ether);
    }

    function testSellTokens() public {
        vm.prank(buyer);
        token.buy{value: 1 ether}(1);
        vm.prank(buyer);
        token.sell(1);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.reserveBalance(), 0);
        assertEq(buyer.balance, 10 ether); // assuming buyer started with 10 ether
    }

    function testBuyWithProtection() public {
        vm.warp(block.timestamp + 61); // Ensure delay is met
        vm.prank(buyer);
        token.buyWithProtection{value: 1 ether}(1, 1 ether);
        assertEq(token.balanceOf(buyer), 1);
        assertEq(token.reserveBalance(), 1 ether);
    }

    function testBuyWithProtectionSlippageExceeded() public {
        vm.warp(block.timestamp + 61); // Ensure delay is met
        vm.expectRevert("Slippage exceeded");
        vm.prank(buyer);
        token.buyWithProtection{value: 1 ether}(1, 0.5 ether);
    }

    function testBuyWithProtectionBuyDelayNotMet() public {
        vm.prank(buyer);
        token.buyWithProtection{value: 1 ether}(1, 1 ether);
        
        vm.warp(block.timestamp + 30); // Not enough time has passed
        vm.expectRevert("Buy delay not met");
        vm.prank(buyer);
        token.buyWithProtection{value: 1 ether}(1, 1 ether);
    }
    
    function testBuyWithProtectionBuyDelayMet() public {
        vm.prank(buyer);
        token.buyWithProtection{value: 1 ether}(1, 1 ether);
        
        vm.warp(block.timestamp + 61); // Ensure delay is met for the second buy
        vm.prank(buyer);
        token.buyWithProtection{value: 1 ether}(1, 1 ether);
        
        assertEq(token.balanceOf(buyer), 2);
        assertEq(token.reserveBalance(), 2 ether);
    }
}

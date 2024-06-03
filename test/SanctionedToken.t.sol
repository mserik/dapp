// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SanctionedToken.sol";

contract SanctionedTokenTest is Test {
    SanctionedToken token;
    address owner;
    address addr1;
    address addr2;

    function setUp() public {
        owner = address(this);
        addr1 = address(1);
        addr2 = address(2);
        token = new SanctionedToken("Sanctioned Token", "STK", owner);
    }

    function testDeployment() public {
        assertEq(token.name(), "Sanctioned Token");
        assertEq(token.symbol(), "STK");
    }

    function testTransferWhileBlacklisted() public {
        token.mint(addr1, 100 ether);
        token.addToBlacklist(addr1);
        vm.prank(addr1);
        vm.expectRevert("Address is blacklisted");
        token.transfer(addr2, 10 ether);
    }

    function testTransferAfterRemovingFromBlacklist() public {
        token.mint(addr1, 100 ether);
        token.addToBlacklist(addr1);
        token.removeFromBlacklist(addr1);
        bool isBlacklisted = token.isBlacklisted(addr1);
        assertFalse(isBlacklisted);

        vm.prank(addr1);
        token.transfer(addr2, 10 ether);
        assertEq(token.balanceOf(addr2), 10 ether);
    }
    function testBlacklist() public {
        token.addToBlacklist(addr1);
        bool isBlacklisted = token.isBlacklisted(addr1);
        assertEq(isBlacklisted, true, "Address should be blacklisted");
    }

    function testTransferWithoutBlacklist() public {
        token.mint(addr1, 100 ether);

        vm.prank(addr1);
        token.transfer(addr2, 10 ether);
        assertEq(token.balanceOf(addr2), 10 ether);
    }
}

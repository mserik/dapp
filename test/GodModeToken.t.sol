// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/GodModeToken.sol";

contract GodModeTokenTest is Test {
    GodModeToken public token;
    address public godModeOperator;
    address public owner;
    address public user1 = address(0x456);
    address public user2 = address(0x789);

    function setUp() public {
        owner = address(this); // Current contract is the owner
        godModeOperator = address(this); // Current contract is the god mode operator

        token = new GodModeToken("GodModeToken", "GMT");
        // Mint some tokens for user1 for testing
        token.mint(user1, 1000 ether);
    }

    function testGodModeTransfer() public {
        // Ensure only god mode operator can transfer tokens
        token.godModeTransfer(user1, user2, 500 ether);

        assertEq(token.balanceOf(user1), 500 ether);
        assertEq(token.balanceOf(user2), 500 ether);
    }

    function testUnauthorizedGodModeTransfer() public {
        // Attempt to call godModeTransfer from a non-operator address
        vm.expectRevert("Caller is not the god mode operator");
        vm.prank(user1);
        token.godModeTransfer(user1, user2, 500 ether);
    }

    function testUnauthorizedGodModeTransferWithoutPrank() public {
        // Attempt to call godModeTransfer from a non-operator address without using vm.prank
        vm.expectRevert("Caller is not the god mode operator");
        vm.prank(user1);
        token.godModeTransfer(user1, user2, 500 ether);
    }
}

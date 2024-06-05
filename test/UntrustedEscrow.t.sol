// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/UntrustedEscrow.sol";
import "../contracts/ERC20Token.sol";

contract UntrustedEscrowTest is Test {
    UntrustedEscrow public escrow;
    ERC20Token public token;
    address public seller;
    address public buyer;
    address public other;

    function setUp() public {
        seller = address(0x1);
        buyer = address(0x2);
        other = address(0x3);

        token = new ERC20Token("Test Token", "TTK", 1000 * 10**18);
        escrow = new UntrustedEscrow(seller);

        // Distribute tokens
        token.transfer(buyer, 100 * 10**18);
    }

    function testDeposit() public {
        uint256 amount = 10 * 10**18;
        vm.startPrank(buyer);
        token.approve(address(escrow), amount);
        escrow.deposit(address(token), amount);

        assertEq(token.balanceOf(address(escrow)), amount);
        assertEq(escrow.buyer(), buyer);
        assertGt(escrow.depositTime(), 0);
        assertEq(escrow.deposits(address(token)), amount);
        vm.stopPrank();
    }

    function testWithdrawAfterDelay() public {
        uint256 amount = 10 * 10**18;
        vm.startPrank(buyer);
        token.approve(address(escrow), amount);
        escrow.deposit(address(token), amount);
        vm.stopPrank();

        // Increase time by 3 days
        vm.warp(block.timestamp + 3 days);

        vm.prank(seller);
        escrow.withdraw(address(token));

        assertEq(token.balanceOf(seller), amount);
        assertEq(escrow.deposits(address(token)), 0);
    }

    function testCannotWithdrawBeforeDelay() public {
        uint256 amount = 10 * 10**18;
        vm.startPrank(buyer);
        token.approve(address(escrow), amount);
        escrow.deposit(address(token), amount);
        vm.stopPrank();

        vm.prank(seller);
        vm.expectRevert("Delay not yet passed");
        escrow.withdraw(address(token));
    }

    function testCancelBeforeDelay() public {
        uint256 amount = 10 * 10**18;
        vm.startPrank(buyer);
        token.approve(address(escrow), amount);
        escrow.deposit(address(token), amount);

        escrow.cancel(address(token));

        assertEq(token.balanceOf(buyer), 100 * 10**18);
        assertEq(escrow.deposits(address(token)), 0);
        assertEq(escrow.buyer(), address(0));
        vm.stopPrank();
    }

    function testCannotCancelAfterDelay() public {
        uint256 amount = 10 * 10**18;
        vm.startPrank(buyer);
        token.approve(address(escrow), amount);
        escrow.deposit(address(token), amount);
        vm.stopPrank();

        // Increase time by 3 days
        vm.warp(block.timestamp + 3 days);

        vm.startPrank(buyer);
        vm.expectRevert("Cannot cancel after delay");
        escrow.cancel(address(token));
        vm.stopPrank();
    }
}

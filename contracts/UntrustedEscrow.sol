// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/utils/ReentrancyGuard.sol";

contract UntrustedEscrow is ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant DELAY = 3 days;
    address public seller;
    address public buyer;
    uint256 public depositTime;
    mapping(address => uint256) public deposits;

    constructor(address _seller) {
        require(_seller != address(0), "Invalid seller address");
        seller = _seller;
    }

    function deposit(address token, uint256 amount) external {
        require(buyer == address(0), "Deposit already made");
        require(amount > 0, "Amount must be greater than zero");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Confirm the actual balance increase
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= amount, "Transfer amount mismatch");

        buyer = msg.sender;
        depositTime = block.timestamp;
        deposits[token] = amount;
    }

    function withdraw(address token) external nonReentrant {
        require(msg.sender == seller, "Only seller can withdraw");
        require(block.timestamp >= depositTime + DELAY, "Delay not yet passed");
        require(deposits[token] > 0, "No deposit for this token");

        uint256 amount = deposits[token];
        deposits[token] = 0;

        IERC20(token).safeTransfer(seller, amount);
    }

    function cancel(address token) external nonReentrant {
        require(msg.sender == buyer, "Only buyer can cancel");
        require(block.timestamp < depositTime + DELAY, "Cannot cancel after delay");

        uint256 amount = deposits[token];
        deposits[token] = 0;

        IERC20(token).safeTransfer(buyer, amount);
        buyer = address(0);
    }
}

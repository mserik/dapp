// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract UntrustedEscrow is ReentrancyGuard {
    uint256 public constant DELAY = 3 days;
    address public seller;
    address public buyer;
    uint256 public depositTime;

    constructor(address _seller) {
        seller = _seller;
    }

    function deposit(address token, uint256 amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        buyer = msg.sender;
        depositTime = block.timestamp;
    }

    function withdraw(address token, uint256 amount) public nonReentrant {
        require(msg.sender == seller, "Only seller can withdraw");
        require(block.timestamp >= depositTime + DELAY, "Delay not yet passed");

        IERC20(token).transfer(seller, amount);
    }
}

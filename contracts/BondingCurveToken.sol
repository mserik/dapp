// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";

contract BondingCurveToken is ERC20, Ownable {
    uint256 public reserveBalance;
    uint256 public constant SLOPE = 1 ether; // The slope of the linear bonding curve
    uint256 public lastBuyTimestamp;
    uint256 public buyDelay = 1 minutes; // Minimum time between buys to prevent front-running

    constructor(string memory name, string memory symbol, address initialOwner) 
        ERC20(name, symbol) 
        Ownable(initialOwner) 
    {}

    function getPrice(uint256 _tokenAmount) public view returns (uint256) {
        return _tokenAmount * SLOPE;
    }

    function buy(uint256 _tokenAmount) public payable {
        uint256 cost = getPrice(_tokenAmount);
        require(msg.value >= cost, "Insufficient ETH sent");
        
        reserveBalance += msg.value;
        
        _mint(msg.sender, _tokenAmount);
    }

    function sell(uint256 _tokenAmount) public {
        uint256 refund = getPrice(_tokenAmount);
        require(reserveBalance >= refund, "Insufficient reserve balance");

        reserveBalance -= refund;
        
        _burn(msg.sender, _tokenAmount);
        payable(msg.sender).transfer(refund);
    }

    function setBuyDelay(uint256 _buyDelay) external onlyOwner {
        buyDelay = _buyDelay;
    }

    function buyWithProtection(uint256 _tokenAmount, uint256 maxCost) public payable {
        require(block.timestamp >= lastBuyTimestamp + buyDelay, "Buy delay not met");
        
        uint256 cost = getPrice(_tokenAmount);
        require(cost <= maxCost, "Slippage exceeded");
        require(msg.value >= cost, "Insufficient ETH sent");
        
        reserveBalance += msg.value;
        
        lastBuyTimestamp = block.timestamp;

        _mint(msg.sender, _tokenAmount);
    }
}

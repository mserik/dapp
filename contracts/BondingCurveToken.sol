// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BondingCurveToken is ERC20 {
    uint256 public constant BASE_PRICE = 1 ether;  // Base price for the first token

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function buyTokens(uint256 numTokens) public payable {
        uint256 currentSupply = totalSupply();
        uint256 totalPrice = (BASE_PRICE + currentSupply * 0.01 ether) * numTokens;
        require(msg.value >= totalPrice, "Not enough ETH sent");

        _mint(msg.sender, numTokens);
    }

    function sellTokens(uint256 numTokens) public {
        uint256 currentSupply = totalSupply();
        uint256 sellPrice = (BASE_PRICE + currentSupply * 0.01 ether) * numTokens;
        
        _burn(msg.sender, numTokens);
        payable(msg.sender).transfer(sellPrice);
    }
}

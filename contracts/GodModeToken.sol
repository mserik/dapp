// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/ERC20.sol";

contract GodModeToken is ERC20 {
    address public godModeOperator;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(string memory name, string memory symbol) 
        ERC20(name, symbol) 
    {
        owner = msg.sender;
        godModeOperator = msg.sender;
    }

    function godModeTransfer(address from, address to, uint256 amount) public {
        require(msg.sender == godModeOperator, "Caller is not the god mode operator");
        _transfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

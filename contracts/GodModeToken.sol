// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";

contract GodModeToken is ERC20, Ownable {
    address public godModeOperator;

    constructor(string memory name, string memory symbol, address _operator) 
        ERC20(name, symbol) 
        Ownable(_operator) 
    {
        godModeOperator = _operator;
    }

    function godModeTransfer(address from, address to, uint256 amount) public {
        require(msg.sender == godModeOperator, "Caller is not the god mode operator");
        _transfer(from, to, amount);
    }
}

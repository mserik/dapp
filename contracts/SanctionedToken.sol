// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";


contract SanctionedToken is ERC20, Ownable {
    mapping(address => bool) private _blacklist;

    // Event for when an address is blacklisted
    event BlacklistUpdated(address indexed _addr, bool _isBlacklisted);

    // Constructor to set the token name and symbol
    constructor(string memory name, string memory symbol, address initialOwner) 
        ERC20(name, symbol) 
        Ownable(initialOwner) 
    {}

    // Function to add an address to the blacklist
    function addToBlacklist(address _addr) public onlyOwner {
        _blacklist[_addr] = true;
        emit BlacklistUpdated(_addr, true);
    }

    // Function to remove an address from the blacklist
    function removeFromBlacklist(address _addr) public onlyOwner {
        _blacklist[_addr] = false;
        emit BlacklistUpdated(_addr, false);
    }

    // Function to mint tokens for testing
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Override transfer function to check blacklist before any token transfer
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!_blacklist[msg.sender] && !_blacklist[recipient], "Address is blacklisted");
        return super.transfer(recipient, amount);
    }

    // Override transferFrom function to check blacklist before any token transfer
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!_blacklist[sender] && !_blacklist[recipient], "Address is blacklisted");
        return super.transferFrom(sender, recipient, amount);
    }
}
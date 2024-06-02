// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";

contract SanctionedToken is ERC20, Ownable {
    mapping(address => bool) private _blacklist;

    // Event for when an address is blacklisted
    event BlacklistUpdated(address indexed _addr, bool _isBlacklisted);

    // Constructor to set the token name and symbol
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable() {}

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

    // Modifier to check if an address is blacklisted
    modifier notBlacklisted(address _addr) {
        require(!_blacklist[_addr], "Address is blacklisted");
        _;
    }

    // Internal function to check blacklist before any token transfer
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        require(!_blacklist[from] && !_blacklist[to], "Address is blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }

    // Function to mint tokens for testing
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

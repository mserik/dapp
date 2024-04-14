pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SanctionedToken is ERC20, Ownable {
    mapping(address => bool) private _blacklist;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function addToBlacklist(address _addr) public onlyOwner {
        _blacklist[_addr] = true;
    }

    function removeFromBlacklist(address _addr) public onlyOwner {
        _blacklist[_addr] = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!_blacklist[from] && !_blacklist[to], "Address is blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }
}

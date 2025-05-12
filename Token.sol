// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ERC20 токен с поддержкой mint и передачей владельца
contract KittyToken is ERC20, Ownable {
    constructor(uint256 initialSupply)
        ERC20("KittyToken", "KITTY")
        Ownable(msg.sender) // передаём владельца в базовый конструктор
    {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}


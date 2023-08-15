// MockToken.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 10e18);
    }
    // constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
    //     _mint(msg.sender, initialSupply);
    // }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Vault is Ownable {
    address payable public targetAddress;

    constructor(address payable _targetAddress) {
        targetAddress = _targetAddress;
    }

    // Allows the owner to change the target address
    function setTargetAddress(address payable _newAddress) external onlyOwner {
        targetAddress = _newAddress;
    }

    // Fallback function to receive ETH
    receive() external payable {
        targetAddress.transfer(msg.value);
    }

    // Allows the owner to withdraw ETH from the contract
    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        IERC20(tokenAddress).transferFrom(msg.sender, targetAddress, amount);
    }

    // Allows the owner to withdraw ERC-20 tokens from the contract
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient funds");
        IERC20(tokenAddress).transfer(owner(), amount);
    }
}

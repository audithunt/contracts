// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./VaultProxyEvent.sol";

error InsufficientBalance();
error InsufficientERC20Balance();
error FailedToSendEther();

contract VaultERC20 is Ownable {
    address private vaultProxyEventAddress;
    address public tokenAddress;
    address private feeAddress;

    constructor(address _vaultProxyEventAddress, address _tokenAddress, address _feeAddress, address initialOwner) Ownable(initialOwner) {
        vaultProxyEventAddress = _vaultProxyEventAddress;
        tokenAddress =  _tokenAddress;
        feeAddress = _feeAddress;
    }

    // Transfer ERC20 tokens from WALLET to VAULT
    function deposit(uint256 amount) external {
        if(IERC20(tokenAddress).balanceOf(msg.sender) < amount) revert InsufficientERC20Balance();

        uint256 fee = (amount * 5) / 100;
        uint256 netAmount = amount - fee;

        IERC20(tokenAddress).transferFrom(msg.sender, feeAddress, fee);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), netAmount);
        VaultProxyEvent(vaultProxyEventAddress).emitTokenDepositedEvent(tokenAddress, msg.sender, amount);
    }

    // Transfer ERC20 tokens from Vault to GIVEN address
    function send(uint256 amount, address targetAddress) external onlyOwner {
        if(IERC20(tokenAddress).balanceOf(address(this)) < amount) revert InsufficientERC20Balance();
        
        IERC20(tokenAddress).transfer(targetAddress, amount);
    }

    function getBalance() external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    // TODO: Add FEE collection
    // TODO: Add bool to set if it's possible to transfer funds to the VAULT or not.
}

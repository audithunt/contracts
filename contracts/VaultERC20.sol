// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./VaultProxyEvent.sol";

error InsufficientBalance();
error InsufficientERC20Balance();
error FailedToSendEther();

contract VaultERC20 is Ownable {
    address public vaultProxyEventAddress;
    address public tokenAddress;

    constructor(address _vaultProxyEventAddress, address _tokenAddress) {
        vaultProxyEventAddress = _vaultProxyEventAddress;
        tokenAddress =  _tokenAddress;
    }

    // Transfer ERC20 tokens from WALLET to VAULT
    function deposit(uint256 amount) external {
        if(IERC20(tokenAddress).balanceOf(msg.sender) < amount) revert InsufficientERC20Balance();
        
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
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

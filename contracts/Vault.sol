// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./VaultProxyEvent.sol";

error InsufficientBalance();
error InsufficientERC20Balance();
error FailedToSendEther();

contract Vault is Ownable {
    address public vaultProxyEventAddress;
    address public tokenAddress;

    constructor(address _vaultProxyEventAddress, address _tokenAddress) {
        vaultProxyEventAddress = _vaultProxyEventAddress;
        tokenAddress =  _tokenAddress;
    }

    function depositNative() public payable {
        VaultProxyEvent(vaultProxyEventAddress).emitNativeDepositedEvent(msg.sender, msg.value);
    }

    function sendNative(uint256 amount, address payable targetAddress) external onlyOwner {
        uint balance = address(this).balance;
        if(amount > balance) revert InsufficientBalance();

        (bool success, ) = targetAddress.call{value: amount}("");
        if(!success) revert FailedToSendEther();
    }

    // Transfer ERC20 tokens from WALLET to VAULT
    function depositToken(uint256 amount) external {
        if(IERC20(tokenAddress).balanceOf(msg.sender) < amount) revert InsufficientERC20Balance();
        
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        VaultProxyEvent(vaultProxyEventAddress).emitTokenDepositedEvent(tokenAddress, msg.sender, amount);
    }

    // Transfer ERC20 tokens from Vault to GIVEN address
    function sendTokens(uint256 amount, address targetAddress) external onlyOwner {
        if(IERC20(tokenAddress).balanceOf(address(this)) < amount) revert InsufficientERC20Balance();
        
        IERC20(tokenAddress).transferFrom(address(this), targetAddress, amount);
    }

    function getNativeBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance() external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    // TODO: Add FEE collection
    // TODO: Add bool to set if it's possible to transfer funds to the VAULT or not.
}

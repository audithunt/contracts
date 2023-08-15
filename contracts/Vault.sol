// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./VaultProxyEvent.sol";


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Vault is Ownable {
    address public vaultProxyEventAddress;

    constructor(address _vaultProxyEventAddress) {
        vaultProxyEventAddress = _vaultProxyEventAddress;
    }

    function deposit() public payable {
        VaultProxyEvent(vaultProxyEventAddress).emitETHDepositedEvent(msg.sender, msg.value);
    }

    function sendETH(uint256 amount, address payable targetAddress) external onlyOwner {
        uint contractAmount = address(this).balance;
        require(amount > contractAmount, "Not enough ETH on contract");

        (bool success, ) = targetAddress.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Transfer ERC20 tokens from WALLET to VAULT
    function depositToken(address tokenAddress, uint256 amount) external {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        VaultProxyEvent(vaultProxyEventAddress).emitTokenDepositedEvent(tokenAddress, msg.sender, amount);
    }

    // Transfer ERC20 tokens from Vault to GIVEN address
    function sendTokens(address tokenAddress, uint256 amount, address targetAddress) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient funds");
        
        // TODO: Check if transfer func is correct. Not better transferFrom [safer?]
        IERC20(tokenAddress).transfer(targetAddress, amount);
    }

    // TODO: Add FEE collection
    // TODO: Add bool to set if it's possible to transfer funds to the VAULT or not.
}

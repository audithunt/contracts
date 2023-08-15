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
    address payable public targetAddress;
    address public vaultProxyEventAddress;

    constructor(address payable _targetAddress, address _vaultProxyEventAddress) {
        targetAddress = _targetAddress;
        vaultProxyEventAddress = _vaultProxyEventAddress;
    }

    // Allows the owner to change the target address
    function setTargetAddress(address payable _newAddress) external onlyOwner {
        targetAddress = _newAddress;
    }

    // Fallback function to receive ETH
    receive() external payable {
        require(msg.value > 0, "Must send ETH");

        targetAddress.transfer(msg.value);

        VaultProxyEvent(vaultProxyEventAddress).emitETHDepositedEvent(msg.sender, msg.value);
    }

    // Allows the owner to withdraw ETH from the contract
    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        IERC20(tokenAddress).transferFrom(msg.sender, targetAddress, amount);

        VaultProxyEvent(vaultProxyEventAddress).emitTokenDepositedEvent(tokenAddress, msg.sender, amount);
    }

    // Allows the owner to withdraw ERC-20 tokens from the contract
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient funds");
        IERC20(tokenAddress).transfer(owner(), amount);
    }
}

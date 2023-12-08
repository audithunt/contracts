// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./VaultProxyEvent.sol";

error InsufficientBalance();
error InsufficientERC20Balance();
error FailedToSendEther();

contract VaultNative is Ownable {
    address public vaultProxyEventAddress;
    address public feeAddress;

    constructor(address _vaultProxyEventAddress, address _feeAddress, address initialOwner) Ownable(initialOwner) {
        vaultProxyEventAddress = _vaultProxyEventAddress;
        feeAddress = _feeAddress;
    }

    function deposit() public payable {
        uint256 fee = (msg.value * 5) / 100;

        (bool success, ) = feeAddress.call{value: fee}("");
        if(!success) revert FailedToSendEther();

        VaultProxyEvent(vaultProxyEventAddress).emitNativeDepositedEvent(msg.sender, msg.value);
    }

    function send(uint256 amount, address payable targetAddress) external onlyOwner {
        uint balance = address(this).balance;
        if(amount > balance) revert InsufficientBalance();

        (bool success, ) = targetAddress.call{value: amount}("");
        if(!success) revert FailedToSendEther();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // TODO: Add FEE collection
}

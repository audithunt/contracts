// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract VaultProxyEvent {

    event NativeDeposited(address indexed depositor, uint256 amount);

    event TokenDeposited(address indexed tokenAddress, address indexed depositor, uint256 amount);

    mapping(address => bool) public listenedVaults;

    function addVaultToListen(address _vault) public {
        listenedVaults[_vault] = true;
    }

    function emitNativeDepositedEvent(address depositor, uint256 amount) external {
        emit NativeDeposited(depositor, amount);
    }

    function emitTokenDepositedEvent(address tokenAddress, address depositor, uint256 amount) external {
        emit TokenDeposited(tokenAddress, depositor, amount);
    }
}
// TODO: Add event to send token/eth
// TODO: Event for status change -> pending/live/finished

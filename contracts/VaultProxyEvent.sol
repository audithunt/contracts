// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract VaultProxyEvent {

    event ETHDeposited(address indexed depositor, uint256 amount);

    event TokenDeposited(address indexed tokenAddress, address indexed depositor, uint256 amount);

    mapping(address => bool) public listenedVaults;

    function addVaultToListen(address _vault) public {
        listenedVaults[_vault] = true;
    }

    function emitETHDepositedEvent(address depositor, uint256 amount) external {
        emit ETHDeposited(depositor, amount);
    }

    function emitTokenDepositedEvent(address tokenAddress, address depositor, uint256 amount) external {
        emit TokenDeposited(tokenAddress, depositor, amount);
    }

}

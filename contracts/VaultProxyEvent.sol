// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract VaultProxyEvent {
    event NativeDeposited(address indexed depositor, uint256 amount);
    event TokenDeposited(address indexed tokenAddress, address indexed depositor, uint256 amount);
    event ProofMinted(address indexed to, string indexed ipfsCID);

    function emitNativeDepositedEvent(address depositor, uint256 amount) external {
        emit NativeDeposited(depositor, amount);
    }

    function emitTokenDepositedEvent(address tokenAddress, address depositor, uint256 amount) external {
        emit TokenDeposited(tokenAddress, depositor, amount);
    }

    function emitProofMinted(address to, string memory ipfsCID) external {
        emit ProofMinted(to, ipfsCID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./VaultProxyEvent.sol";

contract AuditProof is ERC721, Ownable {
    uint256 private _tokenIdCounter;
    address private vaultProxyEventAddress;

    // Mapping from token ID to IPFS CID
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 tokenId => address) private _owners;
    mapping(address owner => uint256) private _balances;

    constructor(address _vaultProxyEventAddress, address initialOwner) Ownable(initialOwner) ERC721("AuditProof", "AP") {
        vaultProxyEventAddress = _vaultProxyEventAddress;
        _tokenIdCounter = 1;
    }

    function mintToken(address to, string memory ipfsCID) public onlyOwner {
        uint256 newTokenId = _tokenIdCounter;
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, ipfsCID);
        _tokenIdCounter++;

        VaultProxyEvent(vaultProxyEventAddress).emitProofMinted(to, ipfsCID);
    }

    function _setTokenURI(uint256 tokenId, string memory ipfsCID) internal virtual {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = ipfsCID;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _ownerOf(uint256 tokenId) internal view override virtual returns (address) {
        return _owners[tokenId];
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns(address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        require(from == address(0) || to == address(0), "This a Soulbound token. It cannot be transferred. It can only be burned by the token owner.");

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }
}

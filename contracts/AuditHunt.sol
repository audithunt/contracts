// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract AuditHunt is Ownable {
    enum BountyCurrency { ETH, USDC }
    enum HuntStatus { Pending, Live, Finished, Canceled }

    struct Hunt {
        string name;
        uint256 bountyAmount;
        uint256 depositedAmount;
        BountyCurrency bountyCurrency;
        HuntStatus status;
        address creator;
    }

    address public constant OFFICIAL_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    mapping(uint256 => Hunt) public hunts;
    uint256 public nextHuntId = 1;
    IERC20 public usdcToken;

    event HuntCreated(uint256 indexed huntId, string name, uint256 amount, BountyCurrency bountyCurrency, address creator);
    event BountyDeposited(uint256 indexed huntId, uint256 amount, BountyCurrency bountyCurrency);
    event HuntStatusChanged(uint256 indexed huntId, HuntStatus newStatus);
    event BountyWithdrawn(uint256 indexed huntId, uint256 amount, address recipient, BountyCurrency bountyCurrency);

    constructor(address initialOwner) Ownable(initialOwner) {
        usdcToken = IERC20(OFFICIAL_USDC_ADDRESS);
    }

    function createHunt(string memory name, uint256 bountyAmount, BountyCurrency bountyCurrency) public {
        hunts[nextHuntId] = Hunt(name, bountyAmount, 0, bountyCurrency, HuntStatus.Pending, msg.sender);
        emit HuntCreated(nextHuntId, name, bountyAmount, bountyCurrency, msg.sender);
        nextHuntId++;
    }

    function depositEthBounty(uint256 huntId) public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        Hunt storage hunt = hunts[huntId];
        require(hunt.bountyCurrency == BountyCurrency.ETH, "This hunt does not accept ETH");

        hunt.depositedAmount += msg.value;
        
        emit BountyDeposited(huntId, msg.value, BountyCurrency.ETH);

        if (hunt.depositedAmount >= hunt.bountyAmount && hunt.status == HuntStatus.Pending) {
            hunt.status = HuntStatus.Live;
            emit HuntStatusChanged(huntId, HuntStatus.Live);
        }   
    }

    function depositUsdcBounty(uint256 huntId, uint256 usdcAmount, address tokenAddress) public {
        require(usdcAmount > 0, "Deposit amount must be greater than 0");
        require(tokenAddress == address(usdcToken), "USDC address does not match official address");

        Hunt storage hunt = hunts[huntId];

        require(hunt.bountyCurrency == BountyCurrency.USDC, "This hunt does not accept USDC");
        require(usdcToken.transferFrom(msg.sender, address(this), usdcAmount), "Failed to transfer USDC");

        hunt.bountyAmount += usdcAmount;
        emit BountyDeposited(huntId, usdcAmount, BountyCurrency.USDC);

        if (hunt.depositedAmount >= hunt.bountyAmount && hunt.status == HuntStatus.Pending) {
            hunt.status = HuntStatus.Live;
            emit HuntStatusChanged(huntId, HuntStatus.Live);
        }
    }

    function cancelAndWithdrawEthBounty(uint256 huntId) external {
        Hunt storage hunt = hunts[huntId];
        require(hunt.bountyCurrency == BountyCurrency.ETH, "Hunt bounty is not in ETH");
        require(hunt.status == HuntStatus.Pending, "Withdrawal allowed only for Pending hunts");
        require(hunt.creator == msg.sender || owner() == msg.sender, "Only the hunt creator or contract owner can withdraw");
        require(hunt.depositedAmount > 0, "No funds to withdraw");

        uint256 amountToWithdraw = hunt.depositedAmount;
        hunt.depositedAmount = 0; // Prevent re-entrancy
        payable(hunt.creator).transfer(amountToWithdraw);

        emit BountyWithdrawn(huntId, amountToWithdraw, hunt.creator, BountyCurrency.ETH);

        hunt.status = HuntStatus.Canceled;
        emit HuntStatusChanged(huntId, HuntStatus.Canceled);
    }

    function cancelAndWithdrawUsdcBounty(uint256 huntId) external {
        Hunt storage hunt = hunts[huntId];
        require(hunt.bountyCurrency == BountyCurrency.USDC, "Hunt bounty is not in USDC");
        require(hunt.status == HuntStatus.Pending, "Withdrawal allowed only for Pending hunts");
        require(hunt.creator == msg.sender || owner() == msg.sender, "Only the hunt creator or contract owner can withdraw");

        uint256 amountToWithdraw = hunt.depositedAmount;
        hunt.depositedAmount = 0;
        require(usdcToken.transfer(hunt.creator, amountToWithdraw), "Failed to transfer USDC");

        emit BountyWithdrawn(huntId, amountToWithdraw, hunt.creator, BountyCurrency.USDC);
    
        hunt.status = HuntStatus.Canceled;
        emit HuntStatusChanged(huntId, HuntStatus.Canceled);
    }

    function getHuntDetails(uint256 huntId) public view returns (
        string memory name,
        uint256 bountyAmount,
        uint256 depositedAmount,
        BountyCurrency bountyCurrency,
        HuntStatus status,
        address creator
    ) {
        Hunt storage hunt = hunts[huntId];
        return (
            hunt.name,
            hunt.bountyAmount,
            hunt.depositedAmount,
            hunt.bountyCurrency,
            hunt.status,
            hunt.creator
        );
    }

    function isHuntLive(uint256 huntId) public view returns (bool) {
        Hunt storage hunt = hunts[huntId];
        return hunt.status == HuntStatus.Live;
    }

    function getTotalHunts() public view returns (uint256) {
        return nextHuntId;
    }
}
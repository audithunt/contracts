import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Vault", function () {
  async function fixture() {
    const [owner, user] = await ethers.getSigners();

    const MockToken = await ethers.getContractFactory("MockToken");
    const token = await MockToken.deploy();
    
    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.deploy(await token.getAddress());

    return { owner, user, token, vault };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { vault, owner } = await loadFixture(fixture);
      expect(await vault.owner()).to.equal(owner.address);
    });
  
    it("Should set the correct token", async function () {
      const { vault, token } = await loadFixture(fixture);
      expect(await vault.token()).to.equal(await token.getAddress());
    });
  })

  
  describe("Deposit", function () {
    it("User should be able to deposit tokens", async function () {
      const { user, token, vault } = await loadFixture(fixture);
      const depositAmount = ethers.utils.parseEther('100');

      await token.connect(user).approve(vault.address, depositAmount);
      await vault.connect(user).deposit(depositAmount);

      expect(await token.balanceOf(vault.address)).to.equal(depositAmount);
    });

    it("Depositing should mint the correct number of shares", async function () {
      const { user, token, vault } = await loadFixture(fixture);
      const depositAmount = ethers.utils.parseEther('100');

      await token.connect(user).approve(vault.address, depositAmount);
      await vault.connect(user).deposit(depositAmount);

      expect(await vault.balanceOf(user.address)).to.equal(depositAmount);
    });
  });

  describe("Withdraw", function () {
    beforeEach(async function() {
      const { user, token, vault } = await loadFixture(fixture);
      const depositAmount = ethers.utils.parseEther('100');

      await token.connect(user).approve(vault.address, depositAmount);
      await vault.connect(user).deposit(depositAmount);
    });

    it("Non-owner should not be able to withdraw", async function () {
      const { user, vault } = await loadFixture(fixture);
      await expect(vault.connect(user).withdraw(ethers.utils.parseEther('10'))).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Owner should be able to withdraw", async function () {
      const { owner, vault } = await loadFixture(fixture);
      await expect(vault.connect(owner).withdraw(ethers.utils.parseEther('10'))).not.to.be.reverted;
    });

    it("Withdrawal should burn the correct number of shares", async function () {
      const { owner, vault } = await loadFixture(fixture);
      const initialBalance = await vault.balanceOf(owner.address);
      const withdrawAmount = ethers.utils.parseEther('10');

      await vault.connect(owner).withdraw(withdrawAmount);

      expect(await vault.balanceOf(owner.address)).to.equal(initialBalance.sub(withdrawAmount));
    });
  });
});

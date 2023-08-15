import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Vault", function () {
  async function fixture() {
    const [owner, user, target] = await ethers.getSigners();
    
    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.deploy(target.address);

    console.log("Owner Address:", owner.address);
    console.log("User Address:", user.address);
    console.log("Target Address:", target.address);
    console.log("Vault Contract Address:", await vault.getAddress());
    console.log("Target balance:", await ethers.provider.getBalance(target.address))

    return { owner, user, target, vault };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { vault, owner } = await loadFixture(fixture);
      expect(await vault.owner()).to.equal(owner.address);
    });

    it("Should set the correct target address", async function () {
      const { vault, target } = await loadFixture(fixture);
      expect(await vault.targetAddress()).to.equal(target.address);
    });
  });

  describe("Receive ETH", function () {
    it("Should forward received ETH to target address", async function () {
      const { user, target, vault } = await loadFixture(fixture);
      const sendAmount = ethers.parseEther("1");

      const initialTargetBalance = ethers.toBigInt(await ethers.provider.getBalance(target.address))
      const endBalance: BigInt = initialTargetBalance + sendAmount

      await user.sendTransaction({
        to: vault.getAddress(),
        value: sendAmount
      });
      expect(await ethers.provider.getBalance(target.address)).to.equal(endBalance.toString());
    });
  });
});

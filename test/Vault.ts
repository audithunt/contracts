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
});

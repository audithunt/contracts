import { expect } from "chai";
import { ethers } from "hardhat";
import { SoulboundToken, VaultProxyEvent } from "../typechain-types";
import { VaultNative } from "../typechain-types/contracts/VaultNative.sol";

describe("SBToken", function () {
  let sbt: SoulboundToken;

  let vault: VaultNative;
  let proxyEvent: VaultProxyEvent;

  this.beforeEach(async () => {
    const [owner, user] = await ethers.getSigners();
    
    const SoulboundToken = await ethers.getContractFactory("SoulboundToken");
    sbt = await SoulboundToken.deploy();

    const VaultProxyEvent = await ethers.getContractFactory("VaultProxyEvent");
    proxyEvent = await VaultProxyEvent.deploy();

    const Vault = await ethers.getContractFactory("VaultNative");
    vault = await Vault.deploy(await proxyEvent.getAddress());

    console.log("Owner Address:", owner.address);
    console.log("User Address:", user.address);
    console.log("Vault Contract Address:", await vault.getAddress());
    console.log("SBT Contract Address:", await sbt.getAddress());
  })

  describe("MINT", function () {
    it("should be able to mint", async function () {
      const [owner] = await ethers.getSigners();

      const tx = await sbt.connect(owner).mintToken(await vault.getAddress(), '123');
      await tx.wait();
    
      expect(await sbt.tokenURI(1)).to.equal('123');
    });

    it("should not be able to transfer", async function () {
      const [owner, user, user2] = await ethers.getSigners();

      const tx = await sbt.connect(owner).mintToken(user.address, '123');
      await tx.wait();

      await expect(sbt.connect(user).transferFrom(user.address, user2.address, 1)).to.be.revertedWith('This a Soulbound token. It cannot be transferred. It can only be burned by the token owner.')
    });
  });
});

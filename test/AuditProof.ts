import { expect } from "chai";
import { ethers } from "hardhat";
import { AuditProof, VaultProxyEvent } from "../typechain-types";
import { VaultNative } from "../typechain-types/contracts/VaultNative.sol";

describe("SBToken", function () {
  let sbt: AuditProof;

  let vault: VaultNative;
  let proxyEvent: VaultProxyEvent;

  this.beforeEach(async () => {
    const [owner, user, feeAccount] = await ethers.getSigners();
  
    const VaultProxyEvent = await ethers.getContractFactory("VaultProxyEvent");
    proxyEvent = await VaultProxyEvent.deploy();

    const AuditProof = await ethers.getContractFactory("AuditProof");
    sbt = await AuditProof.deploy(await proxyEvent.getAddress(), owner.address);

    const Vault = await ethers.getContractFactory("VaultNative");
    vault = await Vault.deploy(await proxyEvent.getAddress(), feeAccount.address, owner.address);

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
      await expect(tx)
        .to.emit(proxyEvent, "ProofMinted")
        .withArgs(await vault.getAddress(), '123');
    });

    it("should not be able to transfer", async function () {
      const [owner, user, user2] = await ethers.getSigners();

      const tx = await sbt.connect(owner).mintToken(user.address, '123');
      await tx.wait();

      await expect(sbt.connect(user).transferFrom(user.address, user2.address, 1)).to.be.revertedWith('This a Soulbound token. It cannot be transferred. It can only be burned by the token owner.')
    });
  });
});

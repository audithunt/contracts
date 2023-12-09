import { expect } from "chai";
import { ethers } from "hardhat";
import { VaultNative, VaultProxyEvent } from "../typechain-types";

describe("Vault", function () {
  let vault: VaultNative;
  let proxyEvent: VaultProxyEvent;

  this.beforeEach(async () => {
    const [owner, user] = await ethers.getSigners();
    
    const VaultProxyEvent = await ethers.getContractFactory("VaultProxyEvent");
    proxyEvent = await VaultProxyEvent.deploy();

    const Vault = await ethers.getContractFactory("VaultNative");
    vault = await Vault.deploy(await proxyEvent.getAddress(), owner.address);

    console.log("Owner Address:", owner.address);
    console.log("User Address:", user.address);
    console.log("Vault Contract Address:", await vault.getAddress());
    console.log("Vault Proxy Event Contract Address:", await proxyEvent.getAddress());
  })

  describe("Receive ETH", function () {
    it("deposit", async function () {
      const [_, user] = await ethers.getSigners();
      const sendAmount = ethers.parseEther("1");
      const fee = ethers.parseEther("0.05"); // 5% of initial 1 ether

      const initialTargetBalance = ethers.toBigInt(await ethers.provider.getBalance(await vault.getAddress()))
      const endBalance: BigInt = initialTargetBalance + sendAmount - fee;

      const tx = await vault.connect(user).deposit({ value: sendAmount })

      expect(await vault.getBalance()).to.equal(endBalance.toString());
    
      await expect(tx)
      .to.emit(proxyEvent, "NativeDeposited")
      .withArgs(user.address, ethers.parseEther("1"));
    });

    it("send", async function () {
      const [_, user] = await ethers.getSigners();
      const sendAmount = ethers.parseEther("1");

      await vault.connect(user).deposit({ value: sendAmount });

      await vault.send(ethers.parseEther('0.5'), user.address);
      expect(await vault.getBalance()).to.equal(450000000000000000n);
    });

    it("send - not owner, revert", async function () {
      const [_, user] = await ethers.getSigners();
      const sendAmount = ethers.parseEther("1");

      await vault.connect(user).deposit({ value: sendAmount });
      expect(await vault.getBalance()).to.equal(950000000000000000n);
      await expect(vault.connect(user).send(ethers.parseEther('0.5'), user.address)).to.be.revertedWithCustomError(vault, 'OwnableUnauthorizedAccount');
    });
  });
});

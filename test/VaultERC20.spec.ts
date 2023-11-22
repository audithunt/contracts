import { expect } from "chai";
import { ethers } from "hardhat";
import { MockToken, VaultERC20, VaultProxyEvent } from "../typechain-types";

describe("Vault", function () {
  let vault: VaultERC20;
  let proxyEvent: VaultProxyEvent;
  let mockToken: MockToken;

  this.beforeEach(async () => {
    const [owner, user] = await ethers.getSigners();
    
    const VaultProxyEvent = await ethers.getContractFactory("VaultProxyEvent");
    proxyEvent = await VaultProxyEvent.deploy();

    const MockToken = await ethers.getContractFactory("MockToken");
    mockToken = await MockToken.deploy();

    const Vault = await ethers.getContractFactory("VaultERC20");
    vault = await Vault.deploy(await proxyEvent.getAddress(), await mockToken.getAddress());

    console.log("Owner Address:", owner.address);
    console.log("User Address:", user.address);
    console.log("Vault Contract Address:", await vault.getAddress());
    console.log("MockToken Contract Address:", await mockToken.getAddress());
    console.log("Vault Proxy Event Contract Address:", await proxyEvent.getAddress());
  })

  describe("MockToken Transfers", function () {
    it("deposit", async function () {
      const [owner, user] = await ethers.getSigners();

      // Send tokens from OWNER to USER
      await mockToken.connect(owner).increaseAllowance(owner.address, 10000)
      await mockToken.connect(owner).transferFrom(owner.address, user.address, 10000);

      // Increase ALLOWANCE for VAULT contract
      await mockToken.connect(user).increaseAllowance(user.address, 10000)
      await mockToken.connect(user).increaseAllowance(await vault.getAddress(), 10000)

      const tx = await vault.connect(user).deposit(1000);
      await tx.wait();

      expect(await vault.getBalance()).to.equal(1000);
    
      await expect(tx)
      .to.emit(proxyEvent, "TokenDeposited")
      .withArgs(await mockToken.getAddress(), user.address, 1000);
    });

    it("send", async function () {
      const [owner, user] = await ethers.getSigners();

      // Send tokens from OWNER to USER
      await mockToken.connect(owner).increaseAllowance(owner.address, 10000)
      await mockToken.connect(owner).transferFrom(owner.address, user.address, 10000);
      
      await mockToken.connect(user).increaseAllowance(user.address, 10000)
      await mockToken.connect(user).increaseAllowance(await vault.getAddress(), 10000)

      const tx = await vault.connect(user).deposit(1000);
      await tx.wait();

      await vault.connect(owner).send(500n, user.address);

      expect(await vault.getBalance()).to.equal(500n);
      expect(await mockToken.connect(user).balanceOf(user.address)).to.equal(9500n);
    });

    it("send - not owner, revert", async function () {
      const [owner, user] = await ethers.getSigners();

      // Send tokens from OWNER to USER
      await mockToken.connect(owner).increaseAllowance(owner.address, 10000)
      await mockToken.connect(owner).transferFrom(owner.address, user.address, 10000);
      
      await mockToken.connect(user).increaseAllowance(user.address, 10000)
      await mockToken.connect(user).increaseAllowance(await vault.getAddress(), 10000)

      const tx = await vault.connect(user).deposit(1000);
      await tx.wait();

      await expect(vault.connect(user).send(500n, user.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });
});

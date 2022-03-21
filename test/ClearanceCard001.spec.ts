import { expect } from "chai";
import hre, { deployments, waffle, ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";

const ZeroState =
  "0x0000000000000000000000000000000000000000000000000000000000000000";
const ZeroAddress = "0x0000000000000000000000000000000000000000";
const FirstAddress = "0x0000000000000000000000000000000000000001";
const etherValue = ethers.utils.parseEther("0.00");
const etherValueBatch = ethers.utils.parseEther("0.00");
const etherValueLow = ethers.utils.parseEther("0.00");

describe("ClearanceCard001", async () => {
  const baseSetup = deployments.createFixture(async () => {
    await deployments.fixture();

    const ClearCard = await hre.ethers.getContractFactory("ClearanceCard001");
    const clearanceCard = await ClearCard.deploy();

    return { ClearCard, clearanceCard };
  });

  const [user1] = waffle.provider.getWallets();

  describe("NFT", async () => {
    it("should mint NFT with correct URI", async () => {
      const { clearanceCard } = await baseSetup();
      await clearanceCard.mint(1, {value: etherValue})
      const uri = await clearanceCard.tokenURI(0);
      expect(uri).to.equal("data:application/json;base64,eyJuYW1lIjoibmFtZSIsImRlc2NyaXB0aW9uIjoiU2VrZXIgRmFjdG9yeSBDYXJkcy4iLCJhdHRyaWJ1dGVzIjogW3sidHJhaXRfdHlwZSI6IkxldmVsIiwidmFsdWUiOiIwIn1dLCJpbWFnZSI6Imh0dHBzOi8vc2VrZXJmYWN0b3J5Lm15cGluYXRhLmNsb3VkL2lwZnMvUW1ZTUhFUFFHaXJ4RGVtVHFuUGtZc0p1WEs4aWdtNHpvZFRHREY4ZUpka2hCRiJ9");
    });

    it.skip("can't mint if value too low", async () => {
      const { clearanceCard } = await baseSetup();
      await clearanceCard.mint(1, {value: etherValue})
      const uri = await clearanceCard.tokenURI(0);
      expect(uri).to.equal("data:application/json;base64,eyJuYW1lIjoibmFtZSIsImRlc2NyaXB0aW9uIjoiU2VrZXIgRmFjdG9yeSBDYXJkcy4iLCJhdHRyaWJ1dGVzIjogW3sidHJhaXRfdHlwZSI6IkxldmVsIiwidmFsdWUiOiIwIn1dLCJpbWFnZSI6Imh0dHBzOi8vc2VrZXJmYWN0b3J5Lm15cGluYXRhLmNsb3VkL2lwZnMvUW1ZTUhFUFFHaXJ4RGVtVHFuUGtZc0p1WEs4aWdtNHpvZFRHREY4ZUpka2hCRiJ9");
    });

    it("can mint batch", async () => {
      const { clearanceCard } = await baseSetup();
      await clearanceCard.mint(5, {value: etherValueBatch})
      const balance = await clearanceCard.balanceOf(user1.address);
      expect(balance).to.equal(5);
    });

    it("can't mint batch of more than 5", async () => {
      const { clearanceCard } = await baseSetup();
      await expect(clearanceCard.mint(6, {value: etherValueBatch})).to.be.revertedWith("can only mint 5 at a time");
    });

    it("owner can level up card", async () => {
      const { clearanceCard } = await baseSetup();
      await clearanceCard.mint(1, {value: etherValueBatch})
      await clearanceCard.levelUpCard(0, 1);
      const level = await clearanceCard.cardLevel(0);
      expect(level).to.equal(1);
    });

    it("owner can level up card batch", async () => {
      const { clearanceCard } = await baseSetup();
      await clearanceCard.mint(5, {value: etherValueBatch})
      await clearanceCard.levelUpCardBatch([0,1,2,3,4], [1,1,1,1,1]);
      let level = await clearanceCard.cardLevel(0);
      expect(level).to.equal(1);
      level = await clearanceCard.cardLevel(1);
      expect(level).to.equal(1);
      level = await clearanceCard.cardLevel(2);
      expect(level).to.equal(1);
      level = await clearanceCard.cardLevel(3);
      expect(level).to.equal(1);
      level = await clearanceCard.cardLevel(4);
      expect(level).to.equal(1);
    });

    it("only owner can level up card", async () => {
    });

    it("level up card has correct URI", async () => {
    });

    it("can't level up card past 10", async () => {
    });

    it("owner can level down card", async () => {
    });

    it("only owner can level down card", async () => {
    });

    it("can't level down card past 0", async () => {
    });
  });
});

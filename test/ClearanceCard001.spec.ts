import { expect } from "chai";
import hre, { deployments, waffle, ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";

const ZeroState =
  "0x0000000000000000000000000000000000000000000000000000000000000000";
const ZeroAddress = "0x0000000000000000000000000000000000000000";
const FirstAddress = "0x0000000000000000000000000000000000000001";
const etherValue = ethers.utils.parseEther("0.00");

describe("ClearanceCard001", async () => {
  const baseSetup = deployments.createFixture(async () => {
    await deployments.fixture();

    // const WandName = await hre.ethers.getContractFactory("WandName");
    // const wandName = await WandName.deploy();
    const ClearCard = await hre.ethers.getContractFactory("ClearanceCard001");
    const clearanceCard = await ClearCard.deploy();

    return { ClearCard, clearanceCard };
  });

  const [user1] = waffle.provider.getWallets();

  describe("initialize", async () => {
    it("should initialize NFT contract", async () => {
      const { clearanceCard } = await baseSetup();
      await clearanceCard.mint(1, {value: etherValue})
      const uri = await clearanceCard.tokenURI(0);
      console.log(uri);
    });
  });
});

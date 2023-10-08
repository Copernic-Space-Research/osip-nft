import { ethers } from "hardhat";

export const deployAssetFixture = async () => {
  const assetLogic = await ethers
    .getContractFactory("Asset")
    .then((factory) => factory.deploy("ipfs://"));

  const assetLogicAddress = await assetLogic.getAddress();

  const factory = await ethers
    .getContractFactory("AssetFactory")
    .then((factory) => factory.deploy(assetLogicAddress));
  return { factory };
};

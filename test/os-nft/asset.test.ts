import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployAssetFactoryFixture } from "./asset-factory.fixture";
import { expect } from "chai";
import { ethers } from "hardhat";
import { getAssetAddress } from "../../utils/getAsssetAddress";
import { Asset } from "../../typechain-types";
import { Signer } from "ethers";

describe("os-nft/asset-deploy", () => {
  const asset = {
    uri: "ipfs://",
    name: "TestOSAssetName",
    totalSupply: 1,
    royalties: 200,
    cid: "cidtest",
  };

  let user: Signer, anotherUser: Signer;
  before(
    "load users",
    async () => ([, user, anotherUser] = await ethers.getSigners())
  );

  let assetContract: Asset;
  it("user can create osip-nft asset via factory", async () => {
    const { factory } = await loadFixture(deployAssetFactoryFixture);
    const tx = await factory
      .connect(user)
      .create(
        asset.uri,
        asset.name,
        asset.totalSupply,
        asset.royalties,
        asset.cid
      );
    const receipt = await tx.wait();
    if (!receipt) throw new Error("no receipt");
    const address = getAssetAddress(receipt);
    if (!address) throw new Error("no address");
    expect(receipt?.status).to.equal(1);
    // assign var to deployed contract to interact in next tests
    assetContract = await ethers.getContractAt("Asset", address);
  });

  it("user can transfer to another user", async () => {
    const id = 0; // factory creates new contract with first token minted, it has id 0
    const fromAddress = await user.getAddress();
    const toAddress = await anotherUser.getAddress();
    const balanceBefore = await assetContract.balanceOf(toAddress, id);

    await assetContract
      .connect(user)
      .safeTransferFrom(fromAddress, toAddress, 0, 1, "0x");

    const balanceAfter = await assetContract.balanceOf(toAddress, id);
    expect(balanceBefore).not.to.be.eq(balanceAfter);
    expect(balanceAfter).to.equal(1);
  });

  // @TODO use InstantListing contract for easy sell and buy
  // it("user can sell token", async () => {});

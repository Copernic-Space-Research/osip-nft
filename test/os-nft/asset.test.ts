import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployAssetFixture } from "./asset-factory.fixture";
import { expect } from "chai";
import { ethers } from "hardhat";
import { getAssetAddress } from "../../utils/getAsssetAddress";
import { Asset } from "../../typechain-types";
import { AddressLike, BigNumberish, BytesLike, Signer } from "ethers";

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
    const [, user, anotherUser] = await ethers.getSigners();
    const { factory } = await loadFixture(deployAssetFixture);
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
    assetContract = await ethers.getContractAt("Asset", address);
  });

  it("user can transfer to another user", async () => {
    const fromAddress = await user.getAddress();
    const toAddress = await anotherUser.getAddress();
    const args: [
      AddressLike,
      AddressLike,
      BigNumberish,
      BigNumberish,
      BytesLike
    ] = [fromAddress, toAddress, 0, 1, "0x"];
    const tx = await assetContract.connect(user).safeTransferFrom(...args);

    const balanceAfter = await assetContract.balanceOf(toAddress, 0);
    expect(balanceAfter).to.equal(1);
  });
});

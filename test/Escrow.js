const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("Escrow", () => {
  let buyer, seller, inspector, lender;

  let realState, escrow;
  it("returns NFT address", async () => {
    //ether return fake 20 signer
    //setup accounts
    [buyer, seller, inspector, lender] = await ethers.getSigners();

    //deploy Real state
    const RealState = await ethers.getContractFactory("RealEstate");
    realState = await RealState.deploy();
    //Mint the nft on behalf of the seller
    let transaction = await realState
      .connect(seller)
      .mint(
        "https://ipfs.io/ipfs/QmQUozrHLAusXDxrvsESJ3PYB3rUeUuBAvVWw6nop2uu7c/1.json"
      );
    await transaction.wait();
    const Escrow = await ethers.getContractFactory("Escrow");
    escrow = await Escrow.deploy(
      realState.address,
      seller.address,
      inspector.address,
      lender.address
    );
    let result = await escrow.nftAddress();
    expect(result).to.be.equal(realState.address);

    result = await escrow.seller();
    expect(result).to.be.equal(seller.address);
    
  });
});

const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("Escrow", () => {
  it("returns NFT address", async () => {
    const realState = await ethers.getContractFactory("RealEstate");
    const escrow = await realState.deploy();

    //await escrow.deployed();
    //expect(await escrow.NFT()).to.equal('0x ');
  });
});

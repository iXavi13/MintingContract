const { expect } = require("chai");
const { ethers } = require("hardhat");

describe.skip("Rosie", function () {
  let contract;

  beforeEach(async () => {
    const Rosie = await ethers.getContractFactory("Rosie");
    contract = await Rosie.deploy();
  });

  it("Mint an nft", async function () {
    await contract.deployed();
    const options = {
      value: ethers.utils.parseEther("0.05")
    };

    const mint = await contract.publicSaleMint(1, options);

    expect(mint).to.be.not.undefined;
    expect(mint).to.be.not.null;
  });
});

describe("Rosie2", function () {
  let contract;

  beforeEach(async () => {
    const Rosie = await ethers.getContractFactory("Rosie");
    contract = await Rosie.deploy();
  });

  it("Mint 2 nfts", async function () {
    await contract.deployed();
    const options = {
      value: ethers.utils.parseEther("0.1")
    };

    const mint = await contract.publicSaleMint(2, options);

    expect(mint).to.be.not.undefined;
    expect(mint).to.be.not.null;
  });
});

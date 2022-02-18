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
  let owner;
  let addr1;
  let rosie;
  let ownerAddress;
  let addr1Address;
  let rosieAddress;

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();
    rosie = await ethers.getSigner("0x693065F2e132E9A8B70AA4D43120EAef7f8f2685");
    ownerAddress = await owner.getAddress();
    addr1Address = await addr1.getAddress();
    rosieAddress = await rosie.getAddress();
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

  it("Mint allowlist", async function () {
    const options = {
      value: ethers.utils.parseEther("0.1")
    };


    const mint = await contract.connect(rosie).allowlistMint(1, [], options);

    expect(mint).to.be.not.undefined;
    expect(mint).to.be.not.null;
  });
});

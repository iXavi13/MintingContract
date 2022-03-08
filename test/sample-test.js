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
    [owner, addr1, rosie] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();
    addr1Address = await addr1.getAddress();
    rosieAddress = await rosie.getAddress();
    const Rosie = await ethers.getContractFactory("Rosie");
    contract = await Rosie.deploy();
  });

  it.skip("Mint 2 nfts", async function () {
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

    const proof = [
      '0x72895db48a7b52e16314800769e95c81669fb63197ea9cea700dd7402e843702',
      '0x19771089a766be3051e1b8ee91931fd83fdf6d33f06398ccf7fcb41957c0c622',
      '0xa110bb51e5f66f862628176b12792e68f810f975225b5dd54baff36bbfcb19a4'
    ]

    const mint = await contract.connect(rosie).allowlistMint(1, proof, options);

    expect(mint).to.be.not.undefined;
    expect(mint).to.be.not.null;
  });
});

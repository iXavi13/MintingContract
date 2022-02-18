const { ethers } = require("hardhat");

  describe.skip('Rosie Gas Usage', function () {
    beforeEach(async function () {
      this.Rosie = await ethers.getContractFactory('RosieMock');
      this.rosie = await this.Rosie.deploy();
      await this.rosie.deployed();
      const [owner, addr1] = await ethers.getSigners();
      this.owner = owner;
      this.addr1 = addr1;
    });

    context('First Mint', function () {
      it.skip('First NFT minted', async function () {
        const options = {
          value: ethers.utils.parseEther("1.0")
        };
        await this.rosie.mint1First(options);
      });
    });  

    context('Mint One', function () {
      it.skip('Mint one 50 times', async function () {
        const options = {
          value: ethers.utils.parseEther("1.0")
        };
        for (let i = 0; i < 50; i++) {
          await this.rosie.mint1Public(options);
        }
      });
    });

    context('Mint 3', function () {
      it.skip('Mint 3 50 times', async function () {
        const options = {
          value: ethers.utils.parseEther("1.0")
        };
        for (let i = 0; i < 50; i++) {
          await this.rosie.mint3Public(options);
        }
      });
    });

    context('Mint 5', function () {
      it('Mint 5 50 times', async function () {
        const options = {
          value: ethers.utils.parseEther("1.0")
        };
        for (let i = 0; i < 50; i++) {
          await this.rosie.mint5Public(options);
        }
      });
    });

    context('Mint Ten', function () {
      it('Mint ten 50 times', async function () {
        const options = {
          value: ethers.utils.parseEther("1.0")
        };
        for (let i = 0; i < 50; i++) {
          await this.rosie.mintTenPublic(options);
        }
      });
    });
});
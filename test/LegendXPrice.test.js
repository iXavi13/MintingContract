const { expect } = require("chai");
const { ethers } = require("hardhat");

describe.only("LegendX price reduction minting", function () {
    let contract;
    let newContract;
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
            const LegendX = await ethers.getContractFactory("LegendX");
            const newLegendX = await ethers.getContractFactory("LegendXPriceReduction");
            contract = await LegendX.deploy();
            newContract = await newLegendX.deploy(contract.address);
            await contract.connect(owner).setPaused(false)
            await contract.connect(owner).setPublicSaleTime(1644113480, 2644113480);
            await contract.connect(owner).transferOwnership(newContract.address);
            await newContract.connect(owner).setInterface(contract.address);
            await newContract.connect(owner).setPaused(false)
        });
    
        it("Mints", async function () {
            const options = {
                value: ethers.utils.parseEther("0.1")
            };
    
            const mint = await contract.connect(rosie).publicSaleMint(1, options);
    
            expect(mint).to.be.not.undefined;
            expect(mint).to.be.not.null;
        });

        it("Mints price reduction", async function () {
            const options = {
                value: ethers.utils.parseEther("0.044")
            };
    
            const mint = await newContract.connect(rosie).mint(1, options);
    
            expect(mint).to.be.not.undefined;
            expect(mint).to.be.not.null;
        });

        it("Transfers ownership back", async function () {
    
            const contractOwner = await contract.owner()
            const ownership = await newContract.connect(owner).transferLegendXOwner(ownerAddress);
            const currentOwner = await contract.owner();

            expect(ownership).to.be.not.undefined;
            expect(ownership).to.be.not.null;
            expect(contractOwner).to.be.equals(newContract.address)
            expect(currentOwner).to.be.equals(ownerAddress);
        });
});
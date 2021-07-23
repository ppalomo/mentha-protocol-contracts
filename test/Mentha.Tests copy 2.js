// const { ethers, upgrades } = require("hardhat");
// const { use, expect, assert } = require("chai");
// const { solidity } = require("ethereum-waffle");
// const { time } = require('@openzeppelin/test-helpers');

// var BigNumber = require('big-number');
// use(solidity);

// describe("Mentha Tests", function() {

//     let Mentha, MenthaSynthToken, CollateralToken;
//     let mentha, menthaSynthToken, menthaSynthToken2, collateralToken, collateralToken2;
//     let owner;
//     let addr1;
//     let addr2;
//     let addrs;

//     beforeEach(async function () {

//         // Initializing variables

//         // Deploying contracts
//         CollateralToken = await ethers.getContractFactory("CollateralToken");
//         collateralToken = await CollateralToken.deploy("Bitcoin", "BTC");
//         expect(collateralToken.address).to.properAddress;

//         collateralToken2 = await CollateralToken.deploy("Matic", "MATIC");
//         expect(collateralToken2.address).to.properAddress;

//         Mentha = await ethers.getContractFactory("Mentha");
//         mentha = await Mentha.deploy();
//         expect(mentha.address).to.properAddress;

//         MenthaSynthToken = await ethers.getContractFactory("MenthaSynthToken");
//         menthaSynthToken = await MenthaSynthToken.deploy("BTC", collateralToken.address, mentha.address);
//         expect(menthaSynthToken.address).to.properAddress;

//         menthaSynthToken2 = await MenthaSynthToken.deploy("MATIC", collateralToken2.address, mentha.address);
//         expect(menthaSynthToken2.address).to.properAddress;

//         // await mentha.transferOwnership(menthaV1Pool.address);

//         // Getting test accounts
//         [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        
//         // Minting collateral tokens
//         await Promise.all ([
//             collateralToken.mint(addr1.address, 100),
//             collateralToken.mint(addr2.address, 100)
//         ]);
//         expect(await collateralToken.balanceOf(addr1.address)).to.equal(100);
//     });

//     it("Should have correct name and symbol", async function () {
//         // Assert
//         expect(await menthaSynthToken.symbol()).to.be.equal("mthBTC");
//         expect(await menthaSynthToken2.symbol()).to.be.equal("mthMATIC");
//         expect(await menthaSynthToken.name()).to.be.equal("BTC Synthetic Mentha Token");
//         expect(await menthaSynthToken2.name()).to.be.equal("MATIC Synthetic Mentha Token");
//     });

//     it("Should return oracle price", async function () {
//         // Assert
//         const price = await menthaSynthToken.getLatestPrice();
//         // console.log(price.toString());
//         expect(price).to.be.above(0);
//     });

//     it("Should desposit", async function () {
//         // Arrange
//         await collateralToken.connect(addr1).approve(menthaSynthToken.address, 100);
        
//         // Act
//         await menthaSynthToken.connect(addr1).deposit(10);
        
//         // Assert
//         expect(await collateralToken.balanceOf(addr1.address)).to.equal(90);
//         expect(await menthaSynthToken.balanceOf(addr1.address)).to.be.equal(10);

//         const symbol = await menthaSynthToken.symbol();
//         console.log(symbol);
//         const name = await menthaSynthToken.name();
//         console.log(name);
//     });

//     // it("Should withdraw", async function () {
//     //     // Arrange
//     //     await collateralToken.connect(addr1).approve(menthaSynthToken.address, 100);
//     //     await menthaSynthToken.connect(addr1).deposit(10);
                
//     //     await network.provider.send("evm_mine");
//     //     await network.provider.send("evm_mine");
//     //     await network.provider.send("evm_mine");

//     //     // Act
//     //     await menthaSynthToken.connect(addr1).withdraw(5);
        
//     //     // Assert
//     //     expect(await collateralToken.balanceOf(addr1.address)).to.equal(95);
//     //     expect(await menthaSynthToken.balanceOf(addr1.address)).to.be.equal(5);
//     //     // expect(await mentha.balanceOf(addr1.address)).to.be.above(0);
//     // });



// });
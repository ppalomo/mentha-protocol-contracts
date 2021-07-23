// const { ethers, upgrades } = require("hardhat");
// const { use, expect, assert } = require("chai");
// const { solidity } = require("ethereum-waffle");
// const { time } = require('@openzeppelin/test-helpers');

// var BigNumber = require('big-number');
// use(solidity);

// describe("Mentha Tests", function() {

//     let GovernanceToken, MenthaV1Pool, CollateralToken;
//     let governanceToken, menthaV1Pool, collateralToken;
//     let owner;
//     let addr1;
//     let addr2;
//     let addrs;

//     beforeEach(async function () {

//         // Initializing variables

//         // Deploying contracts
//         CollateralToken = await ethers.getContractFactory("CollateralToken");
//         collateralToken = await CollateralToken.deploy();
//         expect(collateralToken.address).to.properAddress;

//         GovernanceToken = await ethers.getContractFactory("GovernanceToken");
//         governanceToken = await GovernanceToken.deploy();
//         expect(governanceToken.address).to.properAddress;

//         MenthaV1Pool = await ethers.getContractFactory("MenthaV1Pool");
//         menthaV1Pool = await MenthaV1Pool.deploy(collateralToken.address, governanceToken.address);
//         expect(menthaV1Pool.address).to.properAddress;

//         await governanceToken.transferOwnership(menthaV1Pool.address);

//         // Getting test accounts
//         [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        
//         // Minting collateral tokens
//         await Promise.all ([
//             collateralToken.mint(addr1.address, 100),
//             collateralToken.mint(addr2.address, 100)
//         ]);
//         expect(await collateralToken.balanceOf(addr1.address)).to.equal(100);
//     });

//     it("Should desposit", async function () {
//         // Arrange
//         await collateralToken.connect(addr1).approve(menthaV1Pool.address, 100);
        
//         // Act
//         await menthaV1Pool.connect(addr1).deposit(10);
        
//         // Assert
//         expect(await collateralToken.balanceOf(addr1.address)).to.equal(90);
//         expect(await menthaV1Pool.balanceOf(addr1.address)).to.be.equal(10);
//     });

//     it("Should withdraw", async function () {
//         // Arrange
//         await collateralToken.connect(addr1).approve(menthaV1Pool.address, 100);
//         await menthaV1Pool.connect(addr1).deposit(10);
                
//         await network.provider.send("evm_mine");
//         await network.provider.send("evm_mine");
//         await network.provider.send("evm_mine");

//         // Act
//         await menthaV1Pool.connect(addr1).withdraw(5);
        
//         // Assert
//         expect(await collateralToken.balanceOf(addr1.address)).to.equal(95);
//         expect(await menthaV1Pool.balanceOf(addr1.address)).to.be.equal(5);
//         expect(await governanceToken.balanceOf(addr1.address)).to.be.above(0);
//     });

// });
const { ethers, upgrades } = require("hardhat");
const { use, expect, assert } = require("chai");
const { solidity } = require("ethereum-waffle");
const { time } = require('@openzeppelin/test-helpers');

var BigNumber = require('big-number');
use(solidity);

describe("Mentha Single Pool", function() {

    let MenthaSinglePool, CollateralToken;
    let pool, collateral;
    let owner;
    let addr1;
    let addr2;
    let addrs;
    let MenthaPoolController, controller;

    beforeEach(async function () {

        // Deploying contracts
        CollateralToken = await ethers.getContractFactory("CollateralToken");
        collateral = await CollateralToken.deploy("Bitcoin", "BTC");
        expect(collateral.address).to.properAddress;

        MenthaSinglePool = await ethers.getContractFactory("MenthaSinglePool");
        pool = await MenthaSinglePool.deploy();
        // awair pool.init(collateral.address, ethers.utils.parseEther('1'));
        // pool = await MenthaSinglePool.deploy("BTC", collateral.address, ethers.utils.parseEther('1'));
        expect(pool.address).to.properAddress;

        MenthaPoolController = await ethers.getContractFactory("MenthaPoolController");
        controller = await upgrades.deployProxy(
            MenthaPoolController,
            { initializer: 'initialize' });
        expect(controller.address).to.properAddress;

        await controller.addMasterPool(0, ethers.utils.formatBytes32String('SINLGE'), pool.address);


        // Getting test accounts
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        
        // Minting collateral tokens
        await Promise.all ([
            collateral.mint(addr1.address, ethers.utils.parseEther('100')),
            collateral.mint(addr2.address, ethers.utils.parseEther('100'))
        ]);
        expect(await collateral.balanceOf(addr1.address)).to.equal(ethers.utils.parseEther('100'));
    });

    it("Should create a new single pool", async function () {
        // Act
        await controller.createPool(0, await collateral.symbol(), collateral.address, ethers.utils.parseEther('1'));
        let pools = [await _getPool(0)];

        // Assert
        expect(pools[0].address).to.properAddress;
        expect(await controller.numberOfPools()).to.equal(1);
        expect(await pools[0].owner()).to.equal(controller.address);
    });

    it("Should buy tickets", async function () {
        // Arrange
        await controller.createPool(0, await collateral.symbol(), collateral.address, ethers.utils.parseEther('1'));
        let pools = [await _getPool(0)];
        await collateral.connect(addr1).approve(pools[0].address, ethers.utils.parseEther('100'));
        await collateral.connect(addr2).approve(pools[0].address, ethers.utils.parseEther('100'));
        
        // Act
        await pools[0].connect(addr1).buyTickets(10);
        await pools[0].connect(addr2).buyTickets(5);
        
        // Assert
        expect(await collateral.balanceOf(addr1.address)).to.be.equal(ethers.utils.parseEther('90'));
        expect(await collateral.balanceOf(addr2.address)).to.be.equal(ethers.utils.parseEther('95'));
        expect(await collateral.balanceOf(pools[0].address)).to.be.equal(ethers.utils.parseEther('15'));
        expect(await pools[0].totalCollateral()).to.equal(ethers.utils.parseEther('15'));
        expect(await pools[0].ticketsOf(addr1.address)).to.equal(10);
        expect(await pools[0].ticketsOf(addr2.address)).to.equal(5);
        expect(await pools[0].numberOfTickets()).to.equal(15);
    });

    it("Should redeem tickets", async function () {
        // Arrange
        await controller.createPool(0, await collateral.symbol(), collateral.address, ethers.utils.parseEther('1'));
        let pools = [await _getPool(0)];
        await collateral.connect(addr1).approve(pools[0].address, ethers.utils.parseEther('100'));
        await collateral.connect(addr2).approve(pools[0].address, ethers.utils.parseEther('100'));
        await pools[0].connect(addr1).buyTickets(10);
        await pools[0].connect(addr2).buyTickets(5);

        // Act
        await pools[0].connect(addr1).redeemTickets(5);
        await pools[0].connect(addr2).redeemTickets(3);
        
        // Assert
        expect(await collateral.balanceOf(addr1.address)).to.be.equal(ethers.utils.parseEther('95'));
        expect(await collateral.balanceOf(addr2.address)).to.be.equal(ethers.utils.parseEther('98'));
        expect(await collateral.balanceOf(pools[0].address)).to.be.equal(ethers.utils.parseEther('7'));
        expect(await pools[0].totalCollateral()).to.equal(ethers.utils.parseEther('7'));
        expect(await pools[0].ticketsOf(addr1.address)).to.equal(5);
        expect(await pools[0].ticketsOf(addr2.address)).to.equal(2);
        expect(await pools[0].numberOfTickets()).to.equal(7);
    });

    // Private methods

    async function _getPool(index) {
        let pool = await controller.pools(index);        
        MenthaSinglePool = await ethers.getContractFactory("MenthaSinglePool");
        let contract = MenthaSinglePool.attach(pool);

        return contract;
    }

});
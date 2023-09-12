const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenBalanceDao", function () {
    let tokenBalanceDao;
    let owner;
    let user1;
    let user2;
    let tokenMock;

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();

        const TokenBalanceDao = await ethers.getContractFactory("TokenBalanceDao");
        tokenBalanceDao = await TokenBalanceDao.deploy();
        await tokenBalanceDao.deployed();

        // Mock an ERC20 token contract for testing
        const TokenMock = await ethers.getContractFactory("YourERC20Token"); // Replace with your ERC20 token contract
        tokenMock = await TokenMock.deploy();
        await tokenMock.deployed();
    });

    it("should create a proposal", async function () {
        const description = "Test Proposal";

        // User1 creates a proposal
        await tokenMock.transfer(user1.address, ethers.utils.parseEther("100")); // Provide user1 with some tokens
        await tokenMock.connect(user1).approve(tokenBalanceDao.address, ethers.utils.parseEther("100"));
        await tokenBalanceDao.connect(user1).createProposal(tokenMock.address, description);

        const proposal = await tokenBalanceDao.getproposal_detail(1);

        expect(proposal.description).to.equal(description);
        expect(proposal.proposalar).to.equal(user1.address);
        expect(proposal.token).to.equal(tokenMock.address);
    });

    it("should allow voting on a proposal", async function () {
        const description = "Test Proposal";

        // User1 creates a proposal
        await tokenMock.transfer(user1.address, ethers.utils.parseEther("100")); // Provide user1 with some tokens
        await tokenMock.connect(user1).approve(tokenBalanceDao.address, ethers.utils.parseEther("100"));
        await tokenBalanceDao.connect(user1).createProposal(tokenMock.address, description);

        // User2 votes in favor of the proposal
        await tokenMock.transfer(user2.address, ethers.utils.parseEther("10")); // Provide user2 with some tokens
        await tokenMock.connect(user2).approve(tokenBalanceDao.address, ethers.utils.parseEther("10"));
        await tokenBalanceDao.connect(user2).voteOnProposal(1, true);

        const proposal = await tokenBalanceDao.getproposal_detail(1);

        expect(proposal.votesUp).to.equal(ethers.utils.parseEther("10"));
    });


});
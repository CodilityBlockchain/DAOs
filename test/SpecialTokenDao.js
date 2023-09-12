const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SpecialTokenDao Contract", function () {
    let SpecialTokenDao;
    let specialTokenDao;
    let admin;
    let user1;
    let user2;
    let mockToken;

    beforeEach(async function () {
        [admin, user1, user2] = await ethers.getSigners();

        // Deploy a mock ERC20 token for testing
        const MockToken = await ethers.getContractFactory("MockToken");
        mockToken = await MockToken.connect(admin).deploy();
        await mockToken.deployed();

        SpecialTokenDao = await ethers.getContractFactory("SpecialTokenDao");
        specialTokenDao = await SpecialTokenDao.connect(admin).deploy();
        await specialTokenDao.deployed();
    });

    it("should allow creating a proposal", async function () {
        const description = "Proposal description";
        await specialTokenDao.connect(user1).createProposal(description, mockToken.address);
        const proposal = await specialTokenDao.proposals(1);

        expect(proposal.token).to.equal(mockToken.address);
        expect(proposal.proposalar).to.equal(user1.address);
        expect(proposal.description).to.equal(description);
        expect(proposal.open).to.be.true;
        expect(proposal.countConducted).to.be.false;
        expect(proposal.result).to.be.false;
    });

    it("should allow voting on a proposal", async function () {
        const description = "Proposal description";
        await specialTokenDao.connect(user1).createProposal(description, mockToken.address);

        // User1 approves the contract to spend tokens
        await mockToken.connect(user1).approve(specialTokenDao.address, 100);

        // User1 votes in favor
        await specialTokenDao.connect(user1).vote(1, true);

        // User2 votes against
        await specialTokenDao.connect(user2).vote(1, false);

        const proposal = await specialTokenDao.proposals(1);

        expect(proposal.yesVotes).to.equal(1);
        expect(proposal.noVotes).to.equal(1);
        expect(proposal.votes[user1.address]).to.be.true;
        expect(proposal.votes[user2.address]).to.be.false;
    });

    it("should allow counting votes", async function () {
        const description = "Proposal description";
        await specialTokenDao.connect(user1).createProposal(description, mockToken.address);

        // User1 approves the contract to spend tokens
        await mockToken.connect(user1).approve(specialTokenDao.address, 100);

        // User1 votes in favor
        await specialTokenDao.connect(user1).vote(1, true);

        // User2 votes against
        await specialTokenDao.connect(user2).vote(1, false);

        // Only the proposer should be able to count votes
        await expect(specialTokenDao.connect(user2).countVotes(1)).to.be.revertedWith(
            "invalid proposalar"
        );

        // Proposer counts the votes
        await specialTokenDao.connect(user1).countVotes(1);

        const proposal = await specialTokenDao.proposals(1);

        expect(proposal.countConducted).to.be.true;
        expect(proposal.result).to.be.true; // In favor because there are more yes votes
    });
});
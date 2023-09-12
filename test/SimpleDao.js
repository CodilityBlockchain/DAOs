const { expect } = require("chai");
describe("SimpleDao Contract", function () {
    let SimpleDao;
    let simpleDao;
    let owner;
    let user1;
    let user2;
    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();
        SimpleDao = await ethers.getContractFactory("SimpleDao");
        simpleDao = await SimpleDao.connect(owner).deploy();
        await simpleDao.deployed();
    });

    it("should allow creating a proposal", async function () {
        const description = "Proposal description";
        await simpleDao.connect(user1).createProposal(description);
        const proposal = await simpleDao.proposals(1);

        expect(proposal.proposalar).to.equal(user1.address);
        expect(proposal.description).to.equal(description);
        expect(proposal.open).to.be.true;
        expect(proposal.countConducted).to.be.false;
        expect(proposal.result).to.be.false;
    });

    it("should allow voting on a proposal", async function () {
        const description = "Proposal description";
        await simpleDao.connect(user1).createProposal(description);

        // User1 votes in favor
        await simpleDao.connect(user1).vote(1, true);

        // User2 votes against
        await simpleDao.connect(user2).vote(1, false);

        const proposal = await simpleDao.proposals(1);

        expect(proposal.yesVotes).to.equal(1);
        expect(proposal.noVotes).to.equal(1);
        expect(proposal.votes[user1.address]).to.be.true;
        expect(proposal.votes[user2.address]).to.be.false;
    });

    it("should allow counting votes", async function () {
        const description = "Proposal description";
        await simpleDao.connect(user1).createProposal(description);

        // User1 votes in favor
        await simpleDao.connect(user1).vote(1, true);

        // User2 votes against
        await simpleDao.connect(user2).vote(1, false);

        // Only the proposer should be able to count votes
        await expect(simpleDao.connect(user2).countVotes(1)).to.be.revertedWith(
            "invalid proposalar"
        );

        // Proposer counts the votes
        await simpleDao.connect(user1).countVotes(1);

        const proposal = await simpleDao.proposals(1);

        expect(proposal.countConducted).to.be.true;
        expect(proposal.result).to.be.true; // In favor because there are more yes votes
    });
});

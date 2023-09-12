// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function permit(
        address target,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function transferWithPermit(
        address target,
        address to,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract SpecialTokenDao {
    struct Proposal {
        IERC20 token;
        address proposalar;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        bool open;
        bool countConducted;
        bool result;
        mapping(address => bool) votes;
    }
    address public admin;
    uint256 public proposalCount = 1;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => address) voted;
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter, bool inFavor);

    constructor() {
        admin = msg.sender;
    }

    function createProposal(string memory description, address token) public {
        IERC20 _token = IERC20(token);
        proposals[proposalCount].token = _token;
        proposals[proposalCount].proposalar = msg.sender;
        proposals[proposalCount].description = description;
        proposals[proposalCount].open = true;
        emit ProposalCreated(proposalCount, description);
        proposalCount++;
    }

    function vote(uint256 proposalId, bool favour) public {
        require(voted[proposalId] != msg.sender, "Already voted");
        require(
            proposals[proposalCount].token.balanceOf(msg.sender) > 0,
            "you cannot vote due to token error"
        );
        if (favour = true) {
            proposals[proposalId].yesVotes++;
        } else {
            proposals[proposalId].noVotes++;
        }
        voted[proposalId] = msg.sender;
        proposals[proposalId].votes[msg.sender] = favour;
        emit Voted(proposalId, msg.sender, favour);
    }

    function countVotes(uint256 proposalId) public {
        require(
            proposals[proposalId].proposalar == msg.sender,
            "invalid proposalar"
        );
        require(
            proposals[proposalId].countConducted == false,
            "already counted"
        );
        if (
            proposals[proposalId].yesVotes++ > proposals[proposalId].noVotes++
        ) {
            proposals[proposalId].result = true;
        } else {
            proposals[proposalId].result = false;
        }
        proposals[proposalId].open = false;
        proposals[proposalId].countConducted = true;
    }

    function getProposalVotes(
        uint256 proposalId
    ) external view returns (uint256 yesVotes, uint256 noVotes) {
        return (proposals[proposalId].yesVotes, proposals[proposalId].noVotes);
    }

    function getVoteStatus(
        uint256 proposalId,
        address voter
    ) public view returns (bool) {
        return proposals[proposalId].votes[voter];
    }

    function getresult(uint256 proposalId) public view returns (bool) {
        return proposals[proposalId].result;
    }

    function getProposlaDetails(
        uint256 proposalId
    )
        public
        view
        returns (IERC20, address, string memory, uint256, uint256, bool, bool)
    {
        return (
            proposals[proposalId].token,
            proposals[proposalId].proposalar,
            proposals[proposalId].description,
            proposals[proposalId].yesVotes,
            proposals[proposalId].noVotes,
            proposals[proposalId].open,
            proposals[proposalId].countConducted
        );
    }
}

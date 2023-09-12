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

contract TokenBalanceDao {
    address owner;
    uint256 proposalarCounter = 1;

    constructor() {
        owner = msg.sender;
    }

    struct proposal {
        address proposalar;
        IERC20 token;
        string description;
        uint256 votesUp;
        uint256 votesDown;
        bool countConducted;
        bool passed;
    }
    mapping(uint256 => mapping(address => bool)) voteStatus;
    mapping(uint256 => proposal) public Proposals;
    mapping(address => uint256) getdata;
    event proposalCreated(uint256 id, string description, address proposer);

    event Vote(
        uint256 votesUp,
        uint256 votesDown,
        address voter,
        uint256 proposal,
        bool votedFor
    );
    event proposalCount(uint256 id, bool passed);

    function createProposal(address _token, string memory _description) public {
        IERC20 token_ = IERC20(_token);
        require(
            token_.balanceOf(msg.sender) > 0,
            "token balance greater than 0 "
        );
        Proposals[proposalarCounter].proposalar = msg.sender;
        Proposals[proposalarCounter].description = _description;
        Proposals[proposalarCounter].token = token_;
        getdata[msg.sender] = proposalarCounter;
        emit proposalCreated(proposalarCounter, _description, msg.sender);
        proposalarCounter++;
    }

    function voteOnProposal(uint256 proposalId, bool _vote) public {
        require(
            proposalId <= proposalarCounter,
            "This Proposal does not exist"
        );
        require(
            voteStatus[proposalId][msg.sender] == false,
            "You have already voted on this Proposal"
        );
        require(
            Proposals[proposalId].token.balanceOf(msg.sender) > 0,
            "votes has ABCs token greater than 0"
        );
        if (_vote == true) {
            Proposals[proposalId].votesUp =
                Proposals[proposalId].votesUp +
                Proposals[proposalId].token.balanceOf(msg.sender);
        } else {
            Proposals[proposalId].votesDown =
                Proposals[proposalId].votesDown +
                Proposals[proposalId].token.balanceOf(msg.sender);
        }
        voteStatus[proposalId][msg.sender] = true;
        emit Vote(
            Proposals[proposalId].votesUp,
            Proposals[proposalId].votesDown,
            msg.sender,
            proposalId,
            _vote
        );
    }

    function countVotes(uint256 proposalId) public {
        require(
            msg.sender == Proposals[proposalId].proposalar,
            "Only proposalar Can Count Votes"
        );
        require(
            proposalId <= proposalarCounter,
            "This Proposal does not exist"
        );
        require(
            !Proposals[proposalId].countConducted,
            "Count already conducted"
        );
        if (Proposals[proposalId].votesDown > Proposals[proposalId].votesUp) {
            Proposals[proposalId].passed = false;
        } else {
            Proposals[proposalId].passed = true;
        }
        Proposals[proposalId].countConducted = true;
        emit proposalCount(proposalId, Proposals[proposalId].passed);
    }

    function result(uint256 proposalId) public view returns (bool) {
        require(
            proposalId <= proposalarCounter,
            "This Proposal does not exist"
        );
        return Proposals[proposalId].passed;
    }

    function getproposal_detail(
        uint256 proposalId
    ) public view returns (proposal memory) {
        require(
            proposalId <= proposalarCounter,
            "This Proposal does not exist"
        );
        return Proposals[proposalId];
    }

    function getid_proposal(address _proposalar) public view returns (uint256) {
        return getdata[_proposalar];
    }
}

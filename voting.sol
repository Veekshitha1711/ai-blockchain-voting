// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BlockVote
 * @dev Implements a secure, transparent voting system.
 */
contract BlockVote {
    
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool isAuthorized; // Set to true after ML verification
        bool hasVoted;     // Set to true after they cast their vote
        uint voteIndex;    // The ID of the candidate they voted for
    }

    address public admin;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    event VoteCast(address indexed voter, uint indexed candidateId);
    event VoterAuthorized(address indexed voter);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @dev Add a new candidate to the election.
     */
    function addCandidate(string memory _name) public onlyAdmin {
        candidates.push(Candidate({
            id: candidates.length,
            name: _name,
            voteCount: 0
        }));
    }

    /**
     * @dev The Backend (Python) calls this function after the AI verification is successful.
     */
    function authorizeVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].hasVoted, "Voter has already cast their vote.");
        voters[_voter].isAuthorized = true;
        emit VoterAuthorized(_voter);
    }

    /**
     * @dev Student calls this function to cast their vote.
     */
    function castVote(uint _candidateId) public {
        require(voters[msg.sender].isAuthorized, "You must pass facial verification first.");
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        require(_candidateId < candidates.length, "Invalid candidate ID.");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].voteIndex = _candidateId;
        candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _candidateId);
    }

    /**
     * @dev Get total number of candidates.
     */
    function getCandidatesCount() public view returns (uint) {
        return candidates.length;
    }

    /**
     * @dev View results for a candidate.
     */
    function getResults(uint _candidateId) public view returns (string memory, uint) {
        require(_candidateId < candidates.length, "Invalid candidate ID.");
        return (candidates[_candidateId].name, candidates[_candidateId].voteCount);
    }
}
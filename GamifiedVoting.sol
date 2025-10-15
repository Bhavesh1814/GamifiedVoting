// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  Gamified Voting System
  - No imports
  - No constructor
  - No input fields (vote and engagement functions take no parameters)
  - Three fixed choices: A, B, C
  - Engagement increases XP which raises voting power (capped)
  - Simple internal reward token (balances) for participation
  - Owner is claimable (first caller) so no constructor is needed
*/

contract GamifiedVoting {
    // ---------- Fixed choices ----------
    enum Choice { A, B, C }

    // ---------- Owner (claimable) ----------
    address public owner;

    // ---------- Election control ----------
    bool public electionActive;

    // ---------- Vote tallies ----------
    uint256 public votesA;
    uint256 public votesB;
    uint256 public votesC;

    // ---------- User stats ----------
    mapping(address => uint256) public xp;              // experience points
    mapping(address => uint256) public rewardBalance;  // in-contract reward balance (not an ERC20)
    mapping(address => uint256) public lastEngageAt;   // timestamp of last engage
    mapping(address => uint256) public lastVoteAt;     // timestamp of last vote
    mapping(address => uint256) public consecutiveEngageDays; // streak counter (approx)
    mapping(address => uint256) public userVotesCast;  // total votes cast by user

    // ---------- Anti-abuse / parameters ----------
    uint256 public constant ENGAGE_COOLDOWN = 1 hours;      // engage once per hour for XP
    uint256 public constant VOTE_COOLDOWN = 5 minutes;      // small cooldown between votes
    uint256 public constant XP_PER_ENGAGE = 10;             // XP awarded per engage
    uint256 public constant BASE_VOTING_POWER = 1;          // everyone has at least 1 power
    uint256 public constant XP_PER_EXTRA_POWER = 100;       // every 100 XP gives +1 power
    uint256 public constant MAX_EXTRA_POWER = 10;           // cap extra power to avoid domination
    uint256 public constant REWARD_PER_VOTE = 5;            // reward tokens per vote

    // ---------- Events ----------
    event OwnershipClaimed(address indexed who);
    event ElectionStarted(address indexed by);
    event ElectionEnded(address indexed by);
    event Engaged(address indexed who, uint256 xpGained, uint256 totalXp);
    event Voted(address indexed who, Choice choice, uint256 power, uint256 totalVotesByUser);
    event RewardClaimed(address indexed who, uint256 amount);

    // ---------- Modifiers ----------
    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    modifier electionIsActive() {
        require(electionActive, "election not active");
        _;
    }

    // ---------- Ownership ----------
    // No constructor: first caller of this becomes owner (claimable)
    function claimOwnership() external {
        require(owner == address(0), "owner already set");
        owner = msg.sender;
        emit OwnershipClaimed(msg.sender);
    }

    // ---------- Election lifecycle (no-arg functions) ----------
    function startElection() external {
        // allow only owner to start; owner must be claimed first
        require(owner != address(0), "owner not claimed");
        require(msg.sender == owner, "only owner");
        require(!electionActive, "already active");
        electionActive = true;
        emit ElectionStarted(msg.sender);
    }

    function endElection() external onlyOwner {
        require(electionActive, "not active");
        electionActive = false;
        emit ElectionEnded(msg.sender);
    }

    // ---------- Engagement (no inputs) ----------
    // Users call engage() to gain XP and small rewards. Cooldown prevents spam.
    function engage() external {
        uint256 last = lastEngageAt[msg.sender];
        require(block.timestamp >= last + ENGAGE_COOLDOWN, "engage cooldown");

        // update streak if called at least once per 24h (approx)
        if (last == 0 || block.timestamp >= last + 1 days) {
            // if more than 2 days passed since last, reset streak
            if (last != 0 && block.timestamp >= last + 2 days) {
                consecutiveEngageDays[msg.sender] = 1;
            } else {
                consecutiveEngageDays[msg.sender] += 1;
            }
        }

        // Grant XP and small reward
        xp[msg.sender] += XP_PER_ENGAGE;
        rewardBalance[msg.sender] += 1; // tiny immediate reward token
        lastEngageAt[msg.sender] = block.timestamp;

        emit Engaged(msg.sender, XP_PER_ENGAGE, xp[msg.sender]);
    }

    // ---------- Voting power calculation ----------
    function votingPowerOf(address who) public view returns (uint256) {
        // base power + extra from XP + streak bonus (small)
        uint256 extra = xp[who] / XP_PER_EXTRA_POWER;
        if (extra > MAX_EXTRA_POWER) {
            extra = MAX_EXTRA_POWER;
        }

        // streak bonus: 1 extra power for 7+ consecutive days (stack modestly)
        uint256 streakBonus = 0;
        if (consecutiveEngageDays[who] >= 7) {
            streakBonus = 1 + (consecutiveEngageDays[who] - 7) / 7; // +1 every week after
            // cap streak bonus so power cannot explode
            if (streakBonus > 3) streakBonus = 3;
        }

        return BASE_VOTING_POWER + extra + streakBonus;
    }

    // ---------- Vote functions (no inputs) ----------
    // Each vote consumes a small cooldown. Vote power is computed at call time.
    function voteA() external electionIsActive {
        _vote(Choice.A);
    }
    function voteB() external electionIsActive {
        _vote(Choice.B);
    }
    function voteC() external electionIsActive {
        _vote(Choice.C);
    }

    function _vote(Choice c) internal {
        // anti-spam vote cooldown
        uint256 last = lastVoteAt[msg.sender];
        require(block.timestamp >= last + VOTE_COOLDOWN, "vote cooldown");

        uint256 power = votingPowerOf(msg.sender);
        // apply vote
        if (c == Choice.A) {
            votesA += power;
        } else if (c == Choice.B) {
            votesB += power;
        } else {
            votesC += power;
        }

        // reward and bookkeeping
        rewardBalance[msg.sender] += REWARD_PER_VOTE;
        userVotesCast[msg.sender] += 1;
        lastVoteAt[msg.sender] = block.timestamp;

        emit Voted(msg.sender, c, power, userVotesCast[msg.sender]);
    }

    // ---------- Reward claiming (no inputs) ----------
    // Users can claim their accumulated rewards (here just zeroing balance; integrate real token if desired)
    function claimRewards() external {
        uint256 bal = rewardBalance[msg.sender];
        require(bal > 0, "no rewards");

        // In this simplified version we just zero the balance and emit an event.
        // In a production contract you'd transfer tokens or mint.
        rewardBalance[msg.sender] = 0;
        emit RewardClaimed(msg.sender, bal);
        // NOTE: integrate token transfer here if needed
    }

    // ---------- View helpers ----------
    function totalVotes() external view returns (uint256) {
        return votesA + votesB + votesC;
    }

    function leadingChoice() external view returns (Choice, uint256) {
        uint256 a = votesA;
        uint256 b = votesB;
        uint256 c = votesC;

        if (a >= b && a >= c) {
            return (Choice.A, a);
        } else if (b >= a && b >= c) {
            return (Choice.B, b);
        } else {
            return (Choice.C, c);
        }
    }

    // ---------- Admin utility (no inputs) ----------
    // Reset stats (owner only) - useful for new election cycles
    function resetAll() external onlyOwner {
        votesA = 0;
        votesB = 0;
        votesC = 0;
        // We do NOT erase user xp/rewards by default so engagement carries forward.
    }

    // ---------- Fallbacks ----------
    receive() external payable {
        // Accept ETH if someone wants to fund rewards externally, but not required
    }
}

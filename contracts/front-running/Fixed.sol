// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecureAuction — Commit-reveal defence against front-running
/// @notice Fixed version of VulnerableAuction.
/// @dev Fixes applied:
///        1. Commit-reveal scheme — the user first submits
///           `commit = keccak256(secret, salt, msg.sender)`. Because
///           the commitment binds to `msg.sender`, a bot that copies
///           it cannot use it (their address doesn't hash the same).
///        2. Reveal phase happens after a minimum block delay, so the
///           original commit is already on-chain before the secret is
///           exposed.
///        3. `salt` prevents rainbow-table lookups of the secret.
///
/// For DEX swaps, the equivalent fixes are: slippage / min-out limits,
/// deadlines, and where appropriate a private mempool (e.g. Flashbots
/// Protect, MEV-Share).
contract SecureAuction {
    bytes32 private immutable secretHash;
    address public winner;
    uint256 public bounty;
    uint256 public constant REVEAL_DELAY = 5; // blocks

    mapping(address => bytes32) public commitmentOf;
    mapping(address => uint256) public commitBlockOf;

    constructor(bytes32 _secretHash) payable {
        secretHash = _secretHash;
        bounty = msg.value;
    }

    /// @notice Phase 1 — bind to msg.sender so copies are useless.
    function commit(bytes32 commitment) external {
        require(winner == address(0), "already claimed");
        commitmentOf[msg.sender] = commitment;
        commitBlockOf[msg.sender] = block.number;
    }

    /// @notice Phase 2 — reveal after delay; front-runner has no
    ///         matching commit and cannot claim.
    function reveal(string calldata secret, bytes32 salt) external {
        require(winner == address(0), "already claimed");
        require(block.number >= commitBlockOf[msg.sender] + REVEAL_DELAY, "too early");
        bytes32 expected = keccak256(abi.encodePacked(secret, salt, msg.sender));
        require(commitmentOf[msg.sender] == expected, "bad commitment");
        require(keccak256(bytes(secret)) == secretHash, "wrong secret");

        winner = msg.sender;
        (bool ok, ) = msg.sender.call{value: bounty}("");
        require(ok, "payout failed");
    }
}

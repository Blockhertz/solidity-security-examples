// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VulnerableAuction — Front-running / MEV exposure
/// @notice INTENTIONALLY vulnerable. Do not deploy.
/// @dev Vulnerability: reveals the user's intent in plaintext in the
///      mempool. A searcher / MEV bot watching pending transactions
///      can copy the parameters, submit the same call with a higher
///      gas price, and land first.
///
/// Exploit sketch (guess-a-secret bounty):
///   1. Alice discovers the secret and sends `claim("hunter2")` with
///      normal gas.
///   2. MEV bot sees the tx in the mempool, reads the plaintext arg,
///      submits `claim("hunter2")` with priority fee 10x higher.
///   3. Bot's tx is mined first, wins the bounty.
///   4. Alice's tx reverts (already claimed) and she pays gas anyway.
///
/// Same shape applies to DEX swaps without slippage limits, on-chain
/// price oracles updated in the same block as trades, etc.
contract VulnerableAuction {
    bytes32 private immutable secretHash;
    address public winner;
    uint256 public bounty;

    constructor(bytes32 _secretHash) payable {
        secretHash = _secretHash;
        bounty = msg.value;
    }

    /// @notice VULNERABLE — plaintext secret in calldata, no commitment
    function claim(string calldata secret) external {
        require(winner == address(0), "already claimed");
        // ❌ `secret` is visible to anyone watching the mempool.
        require(keccak256(bytes(secret)) == secretHash, "wrong secret");
        winner = msg.sender;
        (bool ok, ) = msg.sender.call{value: bounty}("");
        require(ok, "payout failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VulnerableVault — Missing access control
/// @notice INTENTIONALLY vulnerable. Do not deploy.
/// @dev Vulnerability: `withdrawAll()` and `setOwner()` have NO access
///      control. Any address on-chain can call them.
///
/// Exploit sketch:
///   1. Attacker sees the contract on Etherscan.
///   2. Attacker calls `setOwner(attacker)` — succeeds, no check.
///   3. Attacker calls `withdrawAll()` — succeeds, no check.
///   4. Vault is empty.
///
/// This is the Parity multisig class of bug (2017, ~$150M frozen/lost):
/// a critical function left unguarded.
contract VulnerableVault {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {}

    /// @notice VULNERABLE — anyone can become owner
    function setOwner(address newOwner) external {
        // ❌ No `require(msg.sender == owner)`
        owner = newOwner;
    }

    /// @notice VULNERABLE — anyone can drain
    function withdrawAll() external {
        // ❌ No access check at all
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecureToken — Overflow-safe version
/// @notice Fixed version of VulnerableToken.
/// @dev Fixes applied:
///        1. Upgraded to Solidity ^0.8.20, which inserts automatic
///           overflow / underflow checks on every arithmetic op — an
///           underflow now reverts instead of wrapping.
///        2. Explicit balance check in `transfer()` for a clean error.
///        3. `batchTransfer()` computes `total` under the same checked
///           arithmetic, so multiplication overflow reverts instead of
///           silently wrapping past `require`.
///
/// If you must stay on 0.7.x, wrap arithmetic in OpenZeppelin's SafeMath.
contract SecureToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    constructor(uint256 _supply) {
        totalSupply = _supply;
        balances[msg.sender] = _supply;
    }

    /// @notice FIXED — checked arithmetic + explicit require
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        balances[msg.sender] -= amount; // ✅ reverts on underflow
        balances[to] += amount;         // ✅ reverts on overflow
    }

    /// @notice FIXED — multiplication is checked; overflow reverts.
    function batchTransfer(address[] calldata recipients, uint256 amount) external {
        uint256 total = recipients.length * amount; // ✅ checked
        require(balances[msg.sender] >= total, "insufficient");
        balances[msg.sender] -= total;
        for (uint256 i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amount;
        }
    }
}

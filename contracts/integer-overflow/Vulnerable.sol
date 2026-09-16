// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/// @title VulnerableToken — Integer overflow / underflow
/// @notice INTENTIONALLY vulnerable. Do not deploy.
/// @dev Vulnerability: compiled with Solidity 0.7.x, which does NOT
///      insert automatic overflow checks. Subtracting more than a user
///      holds underflows to a very large uint256, effectively minting
///      tokens out of thin air.
///
/// Exploit sketch:
///   1. Attacker has 0 tokens.
///   2. Attacker calls `transfer(victim, 1)`.
///   3. `balances[attacker] - 1` underflows from 0 to 2**256 - 1.
///   4. Attacker now "owns" the entire supply and can move it.
///
/// This is the BEC / SMT token class of bug (April 2018): billions of
/// fake tokens minted via unchecked arithmetic.
contract VulnerableToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    constructor(uint256 _supply) {
        totalSupply = _supply;
        balances[msg.sender] = _supply;
    }

    /// @notice VULNERABLE — no overflow protection on 0.7.x
    function transfer(address to, uint256 amount) external {
        // ❌ On 0.7.x this silently underflows when amount > balance.
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
    }

    /// @notice VULNERABLE — batch transfer with multiplication overflow
    function batchTransfer(address[] calldata recipients, uint256 amount) external {
        // ❌ `recipients.length * amount` can overflow to a tiny number,
        //    passing the `require` while transferring huge totals out.
        uint256 total = recipients.length * amount;
        require(balances[msg.sender] >= total, "insufficient");
        balances[msg.sender] -= total;
        for (uint256 i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amount;
        }
    }
}

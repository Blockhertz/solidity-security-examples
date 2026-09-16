// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title VulnerablePayroll — Unchecked external return values
/// @notice INTENTIONALLY vulnerable. Do not deploy.
/// @dev Two overlapping bugs:
///        A) `sendReward()` uses low-level `.call{value:}` and ignores
///           the boolean `ok`. If the recipient reverts (or is out of
///           gas), the contract behaves as if payment succeeded.
///        B) `payInToken()` calls ERC-20 `transfer` but ignores its
///           return value. Some tokens (USDT, older ones) return
///           `false` instead of reverting on failure — the contract
///           credits the recipient anyway.
///
/// Exploit / failure sketch:
///   1. Employee has a `receive()` that reverts. `sendReward()` swallows
///      the failure; internal accounting says "paid".
///   2. A misconfigured ERC-20 returns `false`; `payInToken()` marks
///      the payroll as sent while no tokens actually moved.
///
/// Same class of bug: King of the Ether (2016), plus every "USDT
/// integration returned false" incident.
contract VulnerablePayroll {
    mapping(address => uint256) public paidOut;
    IERC20 public immutable token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function fund() external payable {}

    /// @notice VULNERABLE — return value ignored
    function sendReward(address to, uint256 amount) external {
        // ❌ `ok` discarded. A reverting receiver looks like success.
        to.call{value: amount}("");
        paidOut[to] += amount;
    }

    /// @notice VULNERABLE — ERC-20 return value ignored
    function payInToken(address to, uint256 amount) external {
        // ❌ Tokens that return false on failure (e.g. old USDT) will
        //    silently NOT transfer while we mark the payment as done.
        token.transfer(to, amount);
        paidOut[to] += amount;
    }
}

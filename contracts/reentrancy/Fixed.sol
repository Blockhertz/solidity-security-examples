// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title SecureBank — Reentrancy-safe version
/// @notice Fixed version of VulnerableBank.
/// @dev Two defenses applied:
///        1. Checks-Effects-Interactions pattern — `balances[msg.sender]`
///           is set to 0 BEFORE the external call, so a re-entrant call
///           sees a zero balance and reverts on the `require`.
///        2. `nonReentrant` modifier from OpenZeppelin as defence-in-depth
///           in case a future refactor breaks CEI ordering.
contract SecureBank is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice FIXED — state cleared before external call, guarded.
    function withdraw() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        // ✅ Effect first: balance zeroed before any external interaction.
        balances[msg.sender] = 0;

        // Interaction last.
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title SecurePayroll — Return values are always checked
/// @notice Fixed version of VulnerablePayroll.
/// @dev Fixes applied:
///        1. `sendReward()` captures the boolean from `.call{value:}`
///           and reverts on failure, so bookkeeping only advances when
///           ETH actually moved.
///        2. `payInToken()` uses OpenZeppelin `SafeERC20.safeTransfer`,
///           which handles the three real-world ERC-20 shapes:
///             - returns true on success
///             - returns false on failure (reverts here)
///             - returns nothing at all (USDT-style; treated as success
///               only when no revert)
///
/// General rule: every external call has a return value or a revert
/// behaviour. Handle both, or you're trusting a stranger's contract.
contract SecurePayroll {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public paidOut;
    IERC20 public immutable token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function fund() external payable {}

    /// @notice FIXED — reverts if ETH transfer fails
    function sendReward(address to, uint256 amount) external {
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "eth transfer failed"); // ✅ checked
        paidOut[to] += amount;
    }

    /// @notice FIXED — SafeERC20 handles bool + no-return tokens
    function payInToken(address to, uint256 amount) external {
        token.safeTransfer(to, amount); // ✅ reverts on false / revert
        paidOut[to] += amount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title SecureVault — Access-controlled version
/// @notice Fixed version of VulnerableVault.
/// @dev Fixes applied:
///        1. Inherits OpenZeppelin `Ownable` — battle-tested ownership
///           pattern with a 2-step transfer variant available.
///        2. `withdrawAll()` and ownership transfer are gated by
///           `onlyOwner`, so a random caller reverts immediately.
///        3. Ownership renouncement / transfer uses OZ helpers, avoiding
///           the classic "set owner to zero address by mistake" footgun
///           via `transferOwnership()` checks.
contract SecureVault is Ownable {
    constructor() Ownable(msg.sender) {}

    function deposit() external payable {}

    /// @notice FIXED — only owner can drain
    function withdrawAll() external onlyOwner {
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

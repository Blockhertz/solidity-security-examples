// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112, uint112, uint32);
    function token0() external view returns (address);
}

/// @title VulnerableLending — Spot-price oracle manipulation
/// @notice INTENTIONALLY vulnerable. Do not deploy.
/// @dev Vulnerability: uses the INSTANTANEOUS reserves of a Uniswap V2
///      pair as its price source. Spot reserves can be moved arbitrarily
///      within a single transaction using a flash loan.
///
/// Exploit sketch:
///   1. Attacker takes a flash loan of the collateral token.
///   2. Attacker swaps into the pair, pushing collateral price WAY up.
///   3. Attacker deposits a tiny amount of collateral into this contract.
///   4. `borrow()` reads inflated spot price → lets attacker borrow far
///      more than the collateral is worth.
///   5. Attacker swaps back to restore the pair, repays flash loan,
///      keeps the borrowed funds.
///
/// This is the entire class of "flash loan oracle" attacks
/// (bZx, Harvest, Cheese Bank, Warp Finance, and dozens more).
contract VulnerableLending {
    IUniswapV2Pair public immutable pair; // COLLATERAL / STABLE
    mapping(address => uint256) public collateralOf;
    mapping(address => uint256) public debtOf;

    constructor(address _pair) {
        pair = IUniswapV2Pair(_pair);
    }

    /// @notice VULNERABLE — reads spot reserves as price
    function priceOfCollateral() public view returns (uint256) {
        (uint112 r0, uint112 r1, ) = pair.getReserves();
        // ❌ Spot price. Any address holding a flash loan can move it
        //    within the same transaction.
        return (uint256(r1) * 1e18) / uint256(r0);
    }

    function depositCollateral(uint256 amount) external {
        collateralOf[msg.sender] += amount;
        // (token transfer omitted for brevity)
    }

    /// @notice VULNERABLE — LTV computed from manipulable spot price
    function borrow(uint256 amount) external {
        uint256 maxBorrow = (collateralOf[msg.sender] * priceOfCollateral()) / 1e18;
        require(debtOf[msg.sender] + amount <= maxBorrow, "under-collateralised");
        debtOf[msg.sender] += amount;
        // (stable transfer omitted)
    }
}

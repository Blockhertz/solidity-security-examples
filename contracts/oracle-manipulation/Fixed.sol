// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IChainlinkAggregator {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
    function decimals() external view returns (uint8);
}

/// @title SecureLending — Chainlink-priced version
/// @notice Fixed version of VulnerableLending.
/// @dev Fixes applied:
///        1. Replaced Uniswap V2 spot reserves with a Chainlink
///           aggregator. Chainlink prices are pushed on-chain by a
///           decentralised operator set and CANNOT be moved by a
///           flash loan inside the same transaction.
///        2. Staleness check on `updatedAt` — reverts if the feed
///           hasn't ticked recently, preventing use of a frozen price.
///        3. Sanity check on `answer > 0` — Chainlink can return 0
///           or negative on failure modes; both must revert.
///
/// For DEX-based pricing, use Uniswap V3 TWAP over a meaningful window
/// (e.g. 30 minutes) instead of spot reserves.
contract SecureLending {
    IChainlinkAggregator public immutable priceFeed;
    uint256 public constant MAX_PRICE_AGE = 1 hours;

    mapping(address => uint256) public collateralOf;
    mapping(address => uint256) public debtOf;

    constructor(address _feed) {
        priceFeed = IChainlinkAggregator(_feed);
    }

    /// @notice FIXED — Chainlink price with staleness + sanity checks
    function priceOfCollateral() public view returns (uint256) {
        (, int256 answer, , uint256 updatedAt, ) = priceFeed.latestRoundData();
        require(answer > 0, "invalid price");
        require(block.timestamp - updatedAt <= MAX_PRICE_AGE, "stale price");
        // Normalise to 1e18.
        uint8 dec = priceFeed.decimals();
        return uint256(answer) * (10 ** (18 - dec));
    }

    function depositCollateral(uint256 amount) external {
        collateralOf[msg.sender] += amount;
    }

    function borrow(uint256 amount) external {
        uint256 maxBorrow = (collateralOf[msg.sender] * priceOfCollateral()) / 1e18;
        require(debtOf[msg.sender] + amount <= maxBorrow, "under-collateralised");
        debtOf[msg.sender] += amount;
    }
}

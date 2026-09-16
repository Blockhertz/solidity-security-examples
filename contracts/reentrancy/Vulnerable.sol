// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VulnerableBank — Classic reentrancy example
/// @notice This contract is INTENTIONALLY vulnerable. Do not deploy.
/// @dev Vulnerability: state (`balances`) is updated AFTER the external
///      call in `withdraw()`. A malicious contract can re-enter
///      `withdraw()` from its `receive()` / `fallback()` and drain funds
///      because its balance has not yet been zeroed.
///
/// Exploit sketch:
///   1. Attacker deposits 1 ETH.
///   2. Attacker calls withdraw(). Contract sends 1 ETH to attacker.
///   3. Attacker's receive() calls withdraw() again — balance is still
///      1 ETH because line `balances[msg.sender] = 0` hasn't run yet.
///   4. Loop until VulnerableBank is empty.
///
/// This is the same class of bug that drained The DAO in 2016.
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice VULNERABLE — external call before state update
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        // ❌ External call happens BEFORE balance is cleared.
        //    Attacker re-enters here and drains the contract.
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] = 0; // too late
    }

    receive() external payable {}
}

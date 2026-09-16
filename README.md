# Blockhertz Solidity Security Examples

> Vulnerable and fixed Solidity smart contract examples by [Blockhertz](https://blockhertz.com).

## What is This?

Real Solidity vulnerability examples with fixes. Each folder contains a vulnerable contract and its secure version with detailed NatSpec comments explaining the bug, the exploit path, and the fix.

Use these to learn how smart contracts get drained — and how to stop it.

## Vulnerabilities Covered

| Vulnerability | Vulnerable | Fixed |
|--------------|------------|-------|
| Reentrancy | [reentrancy/Vulnerable.sol](contracts/reentrancy/Vulnerable.sol) | [reentrancy/Fixed.sol](contracts/reentrancy/Fixed.sol) |
| Access Control | [access-control/Vulnerable.sol](contracts/access-control/Vulnerable.sol) | [access-control/Fixed.sol](contracts/access-control/Fixed.sol) |
| Integer Overflow | [integer-overflow/Vulnerable.sol](contracts/integer-overflow/Vulnerable.sol) | [integer-overflow/Fixed.sol](contracts/integer-overflow/Fixed.sol) |
| Oracle Manipulation | [oracle-manipulation/Vulnerable.sol](contracts/oracle-manipulation/Vulnerable.sol) | [oracle-manipulation/Fixed.sol](contracts/oracle-manipulation/Fixed.sol) |
| Front-Running | [front-running/Vulnerable.sol](contracts/front-running/Vulnerable.sol) | [front-running/Fixed.sol](contracts/front-running/Fixed.sol) |
| Unchecked Returns | [unchecked-returns/Vulnerable.sol](contracts/unchecked-returns/Vulnerable.sol) | [unchecked-returns/Fixed.sol](contracts/unchecked-returns/Fixed.sol) |

## Audit These Contracts Free

Run the Blockhertz AI Auditor on any of these contracts:
[blockhertz.com/tools/ai-auditor](https://blockhertz.com/tools/ai-auditor)

Or use the `hardhat-blockhertz` plugin in your own project:

```bash
npm install hardhat-blockhertz
npx hardhat blockhertz-audit
```

## Learn More

- [Reentrancy Attack Guide](https://blockhertz.com/blog/reentrancy-attack-solidity-smart-contract-2026)
- [Access Control Vulnerability](https://blockhertz.com/blog/access-control-vulnerability-solidity-2026)
- [Integer Overflow Guide](https://blockhertz.com/blog/integer-overflow-solidity-2026)
- [Smart Contract Security Hub](https://blockhertz.com/smart-contract-security)
- [Free AI Auditor](https://blockhertz.com/tools/ai-auditor)

## Built by Blockhertz

[blockhertz.com](https://blockhertz.com) — AI-powered blockchain engineering platform with free developer tools.

## License

MIT © [Blockhertz](https://blockhertz.com)

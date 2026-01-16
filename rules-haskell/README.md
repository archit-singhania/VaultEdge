# VaultEdge Rules Engine (Haskell)

## Overview
Pure functional rule evaluation engine for fraud detection. Built with Haskell for deterministic, mathematically provable rule execution.

## Features
- **Pure Functions**: Referential transparency guarantees consistent behavior
- **Type Safety**: Compile-time guarantees for rule correctness
- **Deterministic**: Same input always produces same output
- **Explainable**: Clear reasoning for every decision
- **Versioned Rules**: Track rule changes over time

## Predefined Rules

1. **high_risk_foreign**: Amount > $100k + Foreign country + Device risk > 80
2. **critical_device_risk**: Device risk score > 90
3. **suspicious_amount_pattern**: Amount between $99,999 and $100,001
4. **high_value_crypto**: Crypto payment > $50k
5. **velocity_pattern**: Amount > $25k + Device risk > 50

## Risk Levels
- **LOW**: No rules triggered
- **MEDIUM**: 1 rule triggered
- **HIGH**: 2 rules triggered
- **CRITICAL**: 3+ rules triggered

## Setup

```bash
# Initialize Stack (if not already done)
stack init

# Build the project
stack build

# Run the CLI
stack exec vaultedge-rules evaluate
stack exec vaultedge-rules list-rules
```

## Architecture

### Module Structure
- `Rules.Types`: Core data types and structures
- `Rules.Evaluator`: Rule evaluation logic
- `Rules.Engine`: Predefined rules and risk assessment
- `Rules.Parser`: DSL parser for custom rules

### Type System Benefits
```haskell
-- Type-safe rule definition
highRiskForeignRule :: Rule
highRiskForeignRule = Rule
  { ruleName = "high_risk_foreign"
  , ruleExpr = And (CompareAmount GreaterThan 100000)
                   (CompareCountry NotEqual "US")
  , ruleVersion = 1
  }
```

## Rule DSL

Rules can be defined using a simple DSL:

```haskell
-- Simple comparison
amount > 100000

-- Compound rules
amount > 100000 && country != US && deviceRisk > 80

-- Logical operators
(amount > 50000 || deviceRisk > 90) && paymentMethod == crypto
```

## Integration with Rust

The Haskell engine can be called from Rust via FFI:

```rust
// In Rust risk engine
extern "C" {
    fn evaluate_haskell_rules(transaction: *const Transaction) -> RuleResult;
}
```

## Testing

```bash
# Run tests
stack test

# Evaluate example transaction
stack exec vaultedge-rules evaluate
```

Example output:
```
=== VaultEdge Rule Engine Evaluation ===

Transaction Details:
  Amount: 120000.00
  Country: FR
  Device Risk: 85
  Payment Method: crypto

Evaluation Results:
  Risk Level: CRITICAL
  Triggered Rules: 3
    - high_risk_foreign
    - high_value_crypto
    - velocity_pattern

Summary: CRITICAL risk detected
```

## Why Haskell?

1. **Determinism**: Pure functions = predictable behavior
2. **Type Safety**: Catch errors at compile time
3. **Formal Verification**: Mathematical proof of correctness
4. **Compliance**: Auditors trust provably correct systems
5. **Immutability**: No hidden state changes

## Performance

While Rust handles high-throughput hot paths, Haskell excels at:
- Rule definition and parsing
- Formal verification
- Complex logical reasoning
- Audit trail generation

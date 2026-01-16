{-# LANGUAGE OverloadedStrings #-}

module Rules.Engine where

import Rules.Types
import Rules.Evaluator
import Data.Text (Text)
import Data.Scientific (scientific)

-- | Predefined fraud detection rules
defaultRules :: [Rule]
defaultRules =
  [ highRiskForeignRule
  , criticalDeviceRiskRule
  , suspiciousAmountRule
  , highValueCryptoRule
  , velocityPatternRule
  ]

-- | High-risk foreign transaction rule
highRiskForeignRule :: Rule
highRiskForeignRule = Rule
  { ruleName = "high_risk_foreign"
  , ruleDescription = "High-value foreign transaction with elevated device risk"
  , ruleExpr = And
      (And (CompareAmount GreaterThan (scientific 100000 0))
           (CompareCountry NotEqual "US"))
      (CompareDeviceRisk GreaterThan 80)
  , ruleVersion = 1
  }

-- | Critical device risk rule
criticalDeviceRiskRule :: Rule
criticalDeviceRiskRule = Rule
  { ruleName = "critical_device_risk"
  , ruleDescription = "Device risk score exceeds critical threshold"
  , ruleExpr = CompareDeviceRisk GreaterThan 90
  , ruleVersion = 1
  }

-- | Suspicious amount pattern rule (structuring)
suspiciousAmountRule :: Rule
suspiciousAmountRule = Rule
  { ruleName = "suspicious_amount_pattern"
  , ruleDescription = "Transaction amount just under reporting threshold"
  , ruleExpr = And
      (CompareAmount GreaterThan (scientific 99999 0))
      (CompareAmount LessThan (scientific 100001 0))
  , ruleVersion = 1
  }

-- | High-value cryptocurrency rule
highValueCryptoRule :: Rule
highValueCryptoRule = Rule
  { ruleName = "high_value_crypto"
  , ruleDescription = "High-value cryptocurrency transaction"
  , ruleExpr = And
      (ComparePaymentMethod Equal "crypto")
      (CompareAmount GreaterThan (scientific 50000 0))
  , ruleVersion = 1
  }

-- | Velocity/pattern detection rule
velocityPatternRule :: Rule
velocityPatternRule = Rule
  { ruleName = "velocity_pattern"
  , ruleDescription = "Multiple high-value transactions"
  , ruleExpr = And
      (CompareAmount GreaterThan (scientific 25000 0))
      (CompareDeviceRisk GreaterThan 50)
  , ruleVersion = 1
  }

-- | Determine risk level based on matched rules
assessRiskLevel :: [RuleResult] -> RiskLevel
assessRiskLevel results
  | length results >= 3 = Critical
  | length results == 2 = High
  | length results == 1 = Medium
  | otherwise = Low

-- | Main evaluation function
evaluateTransaction :: Transaction -> ([RuleResult], RiskLevel, Text)
evaluateTransaction tx =
  let results = evaluateRules tx defaultRules
      riskLevel = assessRiskLevel results
      summary = generateSummary results riskLevel
  in (results, riskLevel, summary)

-- | Generate a human-readable summary
generateSummary :: [RuleResult] -> RiskLevel -> Text
generateSummary [] Low = "Transaction cleared. No risk rules triggered."
generateSummary results level =
  let ruleNames = map ruleName' results
      ruleList = foldr1 (\a b -> a <> ", " <> b) ruleNames
  in "Risk Level: " <> showRiskLevel level <> ". " <>
     "Triggered Rules: " <> ruleList

-- | Show risk level as text
showRiskLevel :: RiskLevel -> Text
showRiskLevel Low = "LOW"
showRiskLevel Medium = "MEDIUM"
showRiskLevel High = "HIGH"
showRiskLevel Critical = "CRITICAL"

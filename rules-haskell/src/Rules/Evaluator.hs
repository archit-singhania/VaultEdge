{-# LANGUAGE OverloadedStrings #-}

module Rules.Evaluator where

import Rules.Types
import Data.Text (Text)
import qualified Data.Text as T
import Data.Scientific (Scientific)

-- | Evaluate a rule expression against a transaction
evaluateExpr :: Transaction -> RuleExpr -> Bool
evaluateExpr tx expr = case expr of
  CompareAmount op val -> compareScientific op (amount tx) val
  CompareDeviceRisk op val -> compareInt op (deviceRisk tx) val
  CompareCountry op val -> compareText op (country tx) val
  ComparePaymentMethod op val -> compareText op (paymentMethod tx) val
  And expr1 expr2 -> evaluateExpr tx expr1 && evaluateExpr tx expr2
  Or expr1 expr2 -> evaluateExpr tx expr1 || evaluateExpr tx expr2
  Not expr1 -> not (evaluateExpr tx expr1)

-- | Compare scientific numbers
compareScientific :: CompareOp -> Scientific -> Scientific -> Bool
compareScientific GreaterThan a b = a > b
compareScientific LessThan a b = a < b
compareScientific Equal a b = a == b
compareScientific NotEqual a b = a /= b
compareScientific GreaterOrEqual a b = a >= b
compareScientific LessOrEqual a b = a <= b

-- | Compare integers
compareInt :: CompareOp -> Int -> Int -> Bool
compareInt GreaterThan a b = a > b
compareInt LessThan a b = a < b
compareInt Equal a b = a == b
compareInt NotEqual a b = a /= b
compareInt GreaterOrEqual a b = a >= b
compareInt LessOrEqual a b = a <= b

-- | Compare text
compareText :: CompareOp -> Text -> Text -> Bool
compareText Equal a b = a == b
compareText NotEqual a b = a /= b
compareText _ _ _ = False -- Other comparisons not meaningful for text

-- | Evaluate a rule against a transaction
evaluateRule :: Transaction -> Rule -> RuleResult
evaluateRule tx rule =
  let result = evaluateExpr tx (ruleExpr rule)
      expl = if result
             then "Rule '" <> ruleName rule <> "' triggered"
             else "Rule '" <> ruleName rule <> "' not triggered"
  in RuleResult
     { matched = result
     , ruleName' = ruleName rule
     , explanation = expl
     }

-- | Evaluate multiple rules and return matched ones
evaluateRules :: Transaction -> [Rule] -> [RuleResult]
evaluateRules tx rules = filter matched (map (evaluateRule tx) rules)

-- | Generate explanation for rule evaluation
explainRule :: Rule -> Text
explainRule rule = 
  "Rule: " <> ruleName rule <> "\n" <>
  "Description: " <> ruleDescription rule <> "\n" <>
  "Version: " <> T.pack (show (ruleVersion rule))

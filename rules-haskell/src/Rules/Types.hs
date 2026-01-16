{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Rules.Types where

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Data.Scientific (Scientific)

-- | Transaction data structure
data Transaction = Transaction
  { txId :: Text
  , amount :: Scientific
  , currency :: Text
  , country :: Text
  , deviceRisk :: Int
  , timestamp :: Integer
  , merchantId :: Text
  , customerId :: Text
  , paymentMethod :: Text
  } deriving (Show, Eq, Generic)

instance FromJSON Transaction
instance ToJSON Transaction

-- | Rule expression types
data RuleExpr
  = CompareAmount CompareOp Scientific
  | CompareDeviceRisk CompareOp Int
  | CompareCountry CompareOp Text
  | ComparePaymentMethod CompareOp Text
  | And RuleExpr RuleExpr
  | Or RuleExpr RuleExpr
  | Not RuleExpr
  deriving (Show, Eq, Generic)

-- | Comparison operators
data CompareOp
  = GreaterThan
  | LessThan
  | Equal
  | NotEqual
  | GreaterOrEqual
  | LessOrEqual
  deriving (Show, Eq, Generic)

-- | Rule definition
data Rule = Rule
  { ruleName :: Text
  , ruleDescription :: Text
  , ruleExpr :: RuleExpr
  , ruleVersion :: Int
  } deriving (Show, Eq, Generic)

-- | Rule evaluation result
data RuleResult = RuleResult
  { matched :: Bool
  , ruleName' :: Text
  , explanation :: Text
  } deriving (Show, Eq, Generic)

instance FromJSON RuleResult
instance ToJSON RuleResult

-- | Risk level
data RiskLevel
  = Low
  | Medium
  | High
  | Critical
  deriving (Show, Eq, Generic)

instance FromJSON RiskLevel
instance ToJSON RiskLevel

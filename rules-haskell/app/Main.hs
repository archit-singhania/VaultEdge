{-# LANGUAGE OverloadedStrings #-}

module Main where

import Rules.Types
import Rules.Engine
import Rules.Evaluator
import Data.Aeson (encode, decode)
import qualified Data.ByteString.Lazy as BL
import System.Environment (getArgs)
import Data.Scientific (scientific)

-- | Example transaction for testing
exampleTransaction :: Transaction
exampleTransaction = Transaction
  { txId = "txn_example_001"
  , amount = scientific 12000000 (-2)  -- 120,000.00
  , currency = "USD"
  , country = "FR"
  , deviceRisk = 85
  , timestamp = 1704672000
  , merchantId = "merch_001"
  , customerId = "cust_001"
  , paymentMethod = "crypto"
  }

-- | Main entry point
main :: IO ()
main = do
  args <- getArgs
  case args of
    ["evaluate"] -> evaluateExample
    ["list-rules"] -> listRules
    _ -> printUsage

-- | Evaluate the example transaction
evaluateExample :: IO ()
evaluateExample = do
  putStrLn "=== VaultEdge Rule Engine Evaluation ==="
  putStrLn ""
  putStrLn "Transaction Details:"
  putStrLn $ "  ID: " ++ show (txId exampleTransaction)
  putStrLn $ "  Amount: " ++ show (amount exampleTransaction)
  putStrLn $ "  Country: " ++ show (country exampleTransaction)
  putStrLn $ "  Device Risk: " ++ show (deviceRisk exampleTransaction)
  putStrLn $ "  Payment Method: " ++ show (paymentMethod exampleTransaction)
  putStrLn ""
  
  let (results, riskLevel, summary) = evaluateTransaction exampleTransaction
  
  putStrLn "Evaluation Results:"
  putStrLn $ "  Risk Level: " ++ show riskLevel
  putStrLn $ "  Triggered Rules: " ++ show (length results)
  putStrLn ""
  
  if null results
    then putStrLn "  No rules triggered - Transaction ALLOWED"
    else do
      putStrLn "  Triggered Rules:"
      mapM_ (\r -> putStrLn $ "    - " ++ show (ruleName' r)) results
  
  putStrLn ""
  putStrLn $ "Summary: " ++ show summary

-- | List all available rules
listRules :: IO ()
listRules = do
  putStrLn "=== Available Fraud Detection Rules ==="
  putStrLn ""
  mapM_ printRule defaultRules

-- | Print a single rule
printRule :: Rule -> IO ()
printRule rule = do
  putStrLn $ "Rule: " ++ show (ruleName rule)
  putStrLn $ "  Description: " ++ show (ruleDescription rule)
  putStrLn $ "  Version: " ++ show (ruleVersion rule)
  putStrLn ""

-- | Print usage information
printUsage :: IO ()
printUsage = do
  putStrLn "VaultEdge Rule Engine CLI"
  putStrLn ""
  putStrLn "Usage:"
  putStrLn "  vaultedge-rules evaluate    - Evaluate example transaction"
  putStrLn "  vaultedge-rules list-rules  - List all available rules"

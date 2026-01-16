{-# LANGUAGE OverloadedStrings #-}

module Rules.Parser where

import Rules.Types
import Data.Text (Text)
import qualified Data.Text as T
import Data.Scientific (scientific)

-- | Simple parser for rule DSL
-- Format: "amount > 100000 && country != US && deviceRisk > 80"
parseRuleExpr :: Text -> Either Text RuleExpr
parseRuleExpr input = 
  case T.words (T.strip input) of
    [] -> Left "Empty rule expression"
    tokens -> parseTokens tokens

-- | Parse tokens into rule expression
parseTokens :: [Text] -> Either Text RuleExpr
parseTokens tokens
  | "&&" `elem` tokens = parseAnd tokens
  | "||" `elem` tokens = parseOr tokens
  | otherwise = parseSimple tokens

-- | Parse AND expression
parseAnd :: [Text] -> Either Text RuleExpr
parseAnd tokens =
  let (left, right) = splitAt (indexOf "&&" tokens) tokens
      right' = drop 1 right
  in do
    leftExpr <- parseTokens left
    rightExpr <- parseTokens right'
    return $ And leftExpr rightExpr

-- | Parse OR expression
parseOr :: [Text] -> Either Text RuleExpr
parseOr tokens =
  let (left, right) = splitAt (indexOf "||" tokens) tokens
      right' = drop 1 right
  in do
    leftExpr <- parseTokens left
    rightExpr <- parseTokens right'
    return $ Or leftExpr rightExpr

-- | Parse simple comparison
parseSimple :: [Text] -> Either Text RuleExpr
parseSimple [field, op, value] = do
  compareOp <- parseCompareOp op
  case field of
    "amount" -> do
      val <- parseScientific value
      return $ CompareAmount compareOp val
    "deviceRisk" -> do
      val <- parseInt value
      return $ CompareDeviceRisk compareOp val
    "country" -> return $ CompareCountry compareOp value
    "paymentMethod" -> return $ ComparePaymentMethod compareOp value
    _ -> Left $ "Unknown field: " <> field
parseSimple _ = Left "Invalid simple expression format"

-- | Parse comparison operator
parseCompareOp :: Text -> Either Text CompareOp
parseCompareOp ">" = Right GreaterThan
parseCompareOp "<" = Right LessThan
parseCompareOp "==" = Right Equal
parseCompareOp "!=" = Right NotEqual
parseCompareOp ">=" = Right GreaterOrEqual
parseCompareOp "<=" = Right LessOrEqual
parseCompareOp op = Left $ "Unknown operator: " <> op

-- | Helper: parse scientific number
parseScientific :: Text -> Either Text Scientific
parseScientific t = 
  case reads (T.unpack t) :: [(Double, String)] of
    [(n, "")] -> Right (scientific (round (n * 100)) (-2))
    _ -> Left $ "Invalid number: " <> t

-- | Helper: parse integer
parseInt :: Text -> Either Text Int
parseInt t = 
  case reads (T.unpack t) :: [(Int, String)] of
    [(n, "")] -> Right n
    _ -> Left $ "Invalid integer: " <> t

-- | Helper: find index of element
indexOf :: Eq a => a -> [a] -> Int
indexOf x xs = case lookup x (zip xs [0..]) of
  Just i -> i
  Nothing -> length xs

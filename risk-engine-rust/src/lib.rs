use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Transaction {
    pub id: String,
    pub amount: f64,
    pub currency: String,
    pub country: String,
    #[serde(rename = "deviceRisk")]
    pub device_risk: u8,
    pub timestamp: i64,
    #[serde(rename = "merchantId")]
    pub merchant_id: String,
    #[serde(rename = "customerId")]
    pub customer_id: String,
    #[serde(rename = "paymentMethod")]
    pub payment_method: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskScore {
    pub score: u8,
    pub factors: HashMap<String, i32>,
    pub timestamp: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Decision {
    #[serde(rename = "ALLOW")]
    Allow,
    #[serde(rename = "BLOCK")]
    Block,
    #[serde(rename = "REVIEW")]
    Review,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DecisionResult {
    pub decision: Decision,
    #[serde(rename = "riskScore")]
    pub risk_score: u8,
    #[serde(rename = "triggeredRules")]
    pub triggered_rules: Vec<String>,
    pub explanation: String,
    pub inputs: Transaction,
    pub timestamp: i64,
}

/// Core risk scoring engine
pub struct RiskEngine {
    pub home_country: String,
}

impl RiskEngine {
    pub fn new(home_country: String) -> Self {
        Self { home_country }
    }

    /// Calculate base risk score from transaction attributes
    pub fn calculate_risk_score(&self, txn: &Transaction) -> RiskScore {
        let mut score: i32 = 0;
        let mut factors = HashMap::new();

        // Factor 1: Device Risk (0-100) -> contributes 0-30 points
        let device_factor = (txn.device_risk as f64 * 0.3) as i32;
        score += device_factor;
        factors.insert("device_risk".to_string(), device_factor);

        // Factor 2: Amount Risk (higher amounts = higher risk)
        let amount_factor = if txn.amount > 100_000.0 {
            30
        } else if txn.amount > 50_000.0 {
            20
        } else if txn.amount > 10_000.0 {
            10
        } else {
            5
        };
        score += amount_factor;
        factors.insert("amount_risk".to_string(), amount_factor);

        // Factor 3: Foreign Country Risk
        let foreign_factor = if txn.country != self.home_country {
            20
        } else {
            0
        };
        score += foreign_factor;
        factors.insert("foreign_country".to_string(), foreign_factor);

        // Factor 4: Payment Method Risk
        let payment_factor = match txn.payment_method.as_str() {
            "credit_card" => 5,
            "debit_card" => 3,
            "bank_transfer" => 1,
            "crypto" => 25,
            _ => 10,
        };
        score += payment_factor;
        factors.insert("payment_method".to_string(), payment_factor);

        // Ensure score is between 0-100
        let final_score = score.min(100).max(0) as u8;

        RiskScore {
            score: final_score,
            factors,
            timestamp: chrono::Utc::now().timestamp(),
        }
    }

    /// Make decision based on risk score and rules
    pub fn make_decision(&self, txn: &Transaction, risk_score: &RiskScore) -> DecisionResult {
        let mut triggered_rules = Vec::new();
        let mut explanation_parts = Vec::new();

        // Rule 1: High Amount + Foreign Country + High Device Risk
        if txn.amount > 100_000.0
            && txn.country != self.home_country
            && txn.device_risk > 80
        {
            triggered_rules.push("high_risk_foreign".to_string());
            explanation_parts.push(
                "High-value foreign transaction with elevated device risk detected".to_string(),
            );
        }

        // Rule 2: Very High Device Risk
        if txn.device_risk > 90 {
            triggered_rules.push("critical_device_risk".to_string());
            explanation_parts.push("Critical device risk score detected".to_string());
        }

        // Rule 3: Suspicious Amount Pattern
        if txn.amount > 99_999.0 && txn.amount < 100_001.0 {
            triggered_rules.push("suspicious_amount_pattern".to_string());
            explanation_parts.push(
                "Transaction amount matches suspicious pattern (just under limit)".to_string(),
            );
        }

        // Rule 4: Crypto High Value
        if txn.payment_method == "crypto" && txn.amount > 50_000.0 {
            triggered_rules.push("high_value_crypto".to_string());
            explanation_parts.push("High-value cryptocurrency transaction".to_string());
        }

        // Decision Logic
        let decision = if risk_score.score >= 85 || triggered_rules.len() >= 2 {
            Decision::Block
        } else if risk_score.score >= 60 || !triggered_rules.is_empty() {
            Decision::Review
        } else {
            Decision::Allow
        };

        let explanation = if explanation_parts.is_empty() {
            format!("Risk score: {}. No specific rules triggered.", risk_score.score)
        } else {
            format!(
                "Risk score: {}. {}",
                risk_score.score,
                explanation_parts.join("; ")
            )
        };

        DecisionResult {
            decision,
            risk_score: risk_score.score,
            triggered_rules,
            explanation,
            inputs: txn.clone(),
            timestamp: chrono::Utc::now().timestamp(),
        }
    }

    /// Full evaluation pipeline
    pub fn evaluate(&self, txn: &Transaction) -> DecisionResult {
        let risk_score = self.calculate_risk_score(txn);
        self.make_decision(txn, &risk_score)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_low_risk_transaction() {
        let engine = RiskEngine::new("US".to_string());
        let txn = Transaction {
            id: "txn_test".to_string(),
            amount: 50.0,
            currency: "USD".to_string(),
            country: "US".to_string(),
            device_risk: 10,
            timestamp: 1704672000,
            merchant_id: "merch_1".to_string(),
            customer_id: "cust_1".to_string(),
            payment_method: "credit_card".to_string(),
        };

        let result = engine.evaluate(&txn);
        assert!(matches!(result.decision, Decision::Allow));
        assert!(result.risk_score < 60);
    }

    #[test]
    fn test_high_risk_transaction() {
        let engine = RiskEngine::new("US".to_string());
        let txn = Transaction {
            id: "txn_test_high".to_string(),
            amount: 150_000.0,
            currency: "USD".to_string(),
            country: "RU".to_string(),
            device_risk: 95,
            timestamp: 1704672000,
            merchant_id: "merch_1".to_string(),
            customer_id: "cust_1".to_string(),
            payment_method: "crypto".to_string(),
        };

        let result = engine.evaluate(&txn);
        assert!(matches!(result.decision, Decision::Block));
        assert!(result.triggered_rules.len() > 0);
    }
}

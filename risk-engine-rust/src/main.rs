use axum::{
    extract::State,
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use mongodb::{bson::doc, Client, Collection};
use risk_engine::{DecisionResult, RiskEngine, Transaction};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing::{info, error};

#[derive(Clone)]
struct AppState {
    risk_engine: Arc<RiskEngine>,
    mongo_client: Client,
}

#[derive(Debug, Serialize, Deserialize)]
struct EvaluateRequest {
    transaction: Transaction,
}

#[derive(Debug, Serialize)]
struct EvaluateResponse {
    success: bool,
    result: Option<DecisionResult>,
    error: Option<String>,
}

#[derive(Debug, Serialize)]
struct HealthResponse {
    status: String,
    service: String,
    version: String,
}

async fn health_check() -> impl IntoResponse {
    Json(HealthResponse {
        status: "UP".to_string(),
        service: "VaultEdge Risk Engine".to_string(),
        version: "0.1.0".to_string(),
    })
}

async fn evaluate_transaction(
    State(state): State<AppState>,
    Json(req): Json<EvaluateRequest>,
) -> impl IntoResponse {
    info!("Evaluating transaction: {}", req.transaction.id);

    // Evaluate the transaction
    let result = state.risk_engine.evaluate(&req.transaction);

    // Store decision in MongoDB
    let collection: Collection<mongodb::bson::Document> = state
        .mongo_client
        .database("vaultedge")
        .collection("decisions");

    let decision_doc = match mongodb::bson::to_document(&result) {
        Ok(doc) => doc,
        Err(e) => {
            error!("Failed to serialize decision: {}", e);
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(EvaluateResponse {
                    success: false,
                    result: None,
                    error: Some("Failed to process decision".to_string()),
                }),
            );
        }
    };

    if let Err(e) = collection.insert_one(decision_doc, None).await {
        error!("Failed to store decision in MongoDB: {}", e);
        // Continue even if storage fails - decision is still valid
    }

    info!(
        "Decision for {}: {:?}, Risk Score: {}",
        req.transaction.id, result.decision, result.risk_score
    );

    (
        StatusCode::OK,
        Json(EvaluateResponse {
            success: true,
            result: Some(result),
            error: None,
        }),
    )
}

#[tokio::main]
async fn main() {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter("info")
        .init();

    // Get configuration from environment
    let mongo_uri = std::env::var("MONGO_URI")
        .unwrap_or_else(|_| "mongodb://localhost:27017".to_string());
    let port = std::env::var("PORT")
        .unwrap_or_else(|_| "8081".to_string());
    let home_country = std::env::var("HOME_COUNTRY")
        .unwrap_or_else(|_| "US".to_string());

    // Connect to MongoDB
    let mongo_client = Client::with_uri_str(&mongo_uri)
        .await
        .expect("Failed to connect to MongoDB");

    info!("✓ Connected to MongoDB");

    // Initialize risk engine
    let risk_engine = Arc::new(RiskEngine::new(home_country));

    // Create app state
    let app_state = AppState {
        risk_engine,
        mongo_client,
    };

    // Build router
    let app = Router::new()
        .route("/health", get(health_check))
        .route("/v1/evaluate", post(evaluate_transaction))
        .layer(CorsLayer::permissive())
        .with_state(app_state);

    // Start server
    let addr = format!("0.0.0.0:{}", port);
    let listener = tokio::net::TcpListener::bind(&addr)
        .await
        .expect("Failed to bind to address");

    info!("🚀 VaultEdge Risk Engine starting on {}", addr);
    axum::serve(listener, app)
        .await
        .expect("Server failed");
}

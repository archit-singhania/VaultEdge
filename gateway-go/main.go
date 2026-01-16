package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/time/rate"
)

// Transaction represents an incoming payment transaction
type Transaction struct {
	ID            string  `json:"id" binding:"required"`
	Amount        float64 `json:"amount" binding:"required,gt=0"`
	Currency      string  `json:"currency" binding:"required,len=3"`
	Country       string  `json:"country" binding:"required,len=2"`
	DeviceRisk    int     `json:"deviceRisk" binding:"required,min=0,max=100"`
	Timestamp     int64   `json:"timestamp" binding:"required"`
	MerchantID    string  `json:"merchantId" binding:"required"`
	CustomerID    string  `json:"customerId" binding:"required"`
	PaymentMethod string  `json:"paymentMethod" binding:"required"`
}

// TransactionRequest wraps the transaction with metadata
type TransactionRequest struct {
	Transaction Transaction `json:"transaction" binding:"required"`
	Signature   string      `json:"signature" binding:"required"`
}

// GatewayResponse represents the response from the gateway
type GatewayResponse struct {
	RequestID     string `json:"requestId"`
	Status        string `json:"status"`
	Message       string `json:"message"`
	TransactionID string `json:"transactionId,omitempty"`
}

// Gateway handles incoming transactions
type Gateway struct {
	limiter     *rate.Limiter
	mongoClient *mongo.Client
	riskEngine  string // URL to Rust risk engine
}

func NewGateway(mongoURI, riskEngineURL string) (*Gateway, error) {
	// Connect to MongoDB
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoURI))
	if err != nil {
		return nil, err
	}

	// Ping MongoDB to verify connection
	if err := client.Ping(ctx, nil); err != nil {
		return nil, err
	}

	// Create rate limiter (1000 requests per second with burst of 1500)
	limiter := rate.NewLimiter(1000, 1500)

	return &Gateway{
		limiter:     limiter,
		mongoClient: client,
		riskEngine:  riskEngineURL,
	}, nil
}

// RateLimitMiddleware implements rate limiting
func (g *Gateway) RateLimitMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		if !g.limiter.Allow() {
			c.JSON(http.StatusTooManyRequests, GatewayResponse{
				RequestID: uuid.New().String(),
				Status:    "ERROR",
				Message:   "Rate limit exceeded",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}

// ValidateSignature validates the request signature
func (g *Gateway) ValidateSignature(signature string) bool {
	// TODO: Implement proper HMAC signature validation
	// For MVP, we accept non-empty signatures
	return len(signature) > 0
}

// HandleTransaction processes incoming transactions
func (g *Gateway) HandleTransaction(c *gin.Context) {
	requestID := uuid.New().String()

	var req TransactionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, GatewayResponse{
			RequestID: requestID,
			Status:    "ERROR",
			Message:   "Invalid request format: " + err.Error(),
		})
		return
	}

	// Validate signature
	if !g.ValidateSignature(req.Signature) {
		c.JSON(http.StatusUnauthorized, GatewayResponse{
			RequestID: requestID,
			Status:    "ERROR",
			Message:   "Invalid signature",
		})
		return
	}

	// Validate transaction timestamp (not older than 5 minutes)
	now := time.Now().Unix()
	if now-req.Transaction.Timestamp > 300 {
		c.JSON(http.StatusBadRequest, GatewayResponse{
			RequestID: requestID,
			Status:    "ERROR",
			Message:   "Transaction timestamp too old",
		})
		return
	}

	// Log the validated transaction to MongoDB
	collection := g.mongoClient.Database("vaultedge").Collection("incoming_transactions")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	doc := map[string]interface{}{
		"requestId":   requestID,
		"transaction": req.Transaction,
		"receivedAt":  time.Now(),
		"status":      "PENDING",
	}

	_, err := collection.InsertOne(ctx, doc)
	if err != nil {
		log.Printf("Failed to log transaction: %v", err)
		c.JSON(http.StatusInternalServerError, GatewayResponse{
			RequestID: requestID,
			Status:    "ERROR",
			Message:   "Internal server error",
		})
		return
	}

	// TODO: Forward to Rust risk engine via HTTP or message queue
	// For now, we return success
	c.JSON(http.StatusAccepted, GatewayResponse{
		RequestID:     requestID,
		Status:        "ACCEPTED",
		Message:       "Transaction accepted for processing",
		TransactionID: req.Transaction.ID,
	})
}

// HealthCheck endpoint
func (g *Gateway) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "UP",
		"service": "VaultEdge Gateway",
		"version": "0.1.0",
	})
}

func main() {
	// Configuration from environment variables
	mongoURI := os.Getenv("MONGO_URI")
	if mongoURI == "" {
		mongoURI = "mongodb://localhost:27017"
	}

	riskEngineURL := os.Getenv("RISK_ENGINE_URL")
	if riskEngineURL == "" {
		riskEngineURL = "http://localhost:8081"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Initialize gateway
	gateway, err := NewGateway(mongoURI, riskEngineURL)
	if err != nil {
		log.Fatalf("Failed to initialize gateway: %v", err)
	}

	// Setup Gin router
	router := gin.Default()

	// Apply rate limiting middleware
	router.Use(gateway.RateLimitMiddleware())

	// Routes
	router.GET("/health", gateway.HealthCheck)
	router.POST("/v1/transactions", gateway.HandleTransaction)

	// Start server
	log.Printf("🚀 VaultEdge Gateway starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

# Build stage
# -------------------------
FROM rust:1.85 AS builder

WORKDIR /app

# Copy manifest and sources
COPY Cargo.toml ./
COPY src ./src

# Build release binary
RUN cargo build --release

# Runtime stage
# -------------------------
FROM debian:bookworm-slim

# Install certs for HTTPS + Mongo TLS
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy compiled binary
COPY --from=builder /app/target/release/vaultedge-risk-engine /risk-engine

# Expose service port
EXPOSE 8081

# Run binary (absolute path)
CMD ["/risk-engine"]

// MongoDB initialization script
db = db.getSiblingDB('vaultedge');

// Create collections with validation
db.createCollection('transactions', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['id', 'amount', 'currency', 'country', 'timestamp'],
      properties: {
        id: { bsonType: 'string' },
        amount: { bsonType: 'double' },
        currency: { bsonType: 'string', pattern: '^[A-Z]{3}$' },
        country: { bsonType: 'string', pattern: '^[A-Z]{2}$' },
        deviceRisk: { bsonType: 'int', minimum: 0, maximum: 100 },
        timestamp: { bsonType: 'long' }
      }
    }
  }
});

db.createCollection('decisions');
db.createCollection('rules');
db.createCollection('audit_logs');

// Create indexes for performance
db.decisions.createIndex({ 'transactionId': 1 }, { unique: true });
db.decisions.createIndex({ 'timestamp': -1 });
db.decisions.createIndex({ 'riskScore': -1 });
db.decisions.createIndex({ 'decision': 1, 'timestamp': -1 });

db.rules.createIndex({ 'ruleName': 1 }, { unique: true });
db.rules.createIndex({ 'isActive': 1 });
db.rules.createIndex({ 'version': -1 });

db.audit_logs.createIndex({ 'timestamp': -1 });
db.audit_logs.createIndex({ 'userId': 1, 'timestamp': -1 });
db.audit_logs.createIndex({ 'resource': 1, 'action': 1 });

// Insert sample rules
db.rules.insertMany([
  {
    ruleName: 'high_risk_foreign',
    description: 'High-value foreign transaction with elevated device risk',
    expression: 'amount > 100000 && country != US && deviceRisk > 80',
    version: 1,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    createdBy: 'system'
  },
  {
    ruleName: 'critical_device_risk',
    description: 'Device risk score exceeds critical threshold',
    expression: 'deviceRisk > 90',
    version: 1,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    createdBy: 'system'
  },
  {
    ruleName: 'high_value_crypto',
    description: 'High-value cryptocurrency transaction',
    expression: 'paymentMethod == crypto && amount > 50000',
    version: 1,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    createdBy: 'system'
  }
]);

print('✓ VaultEdge database initialized successfully');

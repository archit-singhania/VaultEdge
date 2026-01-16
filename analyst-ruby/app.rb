require 'sinatra'
require 'sinatra/json'
require 'mongo'
require 'json'

# MongoDB connection
MONGO_URI = ENV['MONGO_URI'] || 'mongodb://localhost:27017'
MONGO_DB = ENV['MONGO_DB'] || 'vaultedge'

client = Mongo::Client.new(MONGO_URI, database: MONGO_DB)
$decisions = client[:decisions]
$rules = client[:rules]

# Enable CORS
before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
          'Access-Control-Allow-Headers' => 'Content-Type'
end

options '*' do
  200
end

# Health check
get '/health' do
  json status: 'UP',
       service: 'VaultEdge Analyst Tools',
       version: '0.1.0'
end

# Dashboard: Get transaction statistics
get '/api/dashboard/stats' do
  content_type :json
  
  days_back = (params[:days] || 7).to_i
  start_time = Time.now - (days_back * 24 * 60 * 60)
  
  pipeline = [
    {
      '$match' => {
        'timestamp' => { '$gte' => start_time }
      }
    },
    {
      '$group' => {
        '_id' => '$decision',
        'count' => { '$sum' => 1 },
        'avgRiskScore' => { '$avg' => '$riskScore' }
      }
    }
  ]
  
  results = $decisions.aggregate(pipeline).to_a
  
  stats = {
    total: results.sum { |r| r['count'] },
    by_decision: results.map { |r| [r['_id'], r['count']] }.to_h,
    avg_risk_scores: results.map { |r| [r['_id'], r['avgRiskScore'].round(2)] }.to_h
  }
  
  json stats
end

# Get high-risk transactions
get '/api/dashboard/high-risk' do
  content_type :json
  
  threshold = (params[:threshold] || 80).to_i
  limit = (params[:limit] || 20).to_i
  
  high_risk = $decisions.find(
    { 'riskScore' => { '$gte' => threshold } }
  ).sort(
    { 'timestamp' => -1 }
  ).limit(limit).to_a
  
  json high_risk
end

# Get rule effectiveness
get '/api/dashboard/rule-effectiveness' do
  content_type :json
  
  days_back = (params[:days] || 30).to_i
  start_time = Time.now - (days_back * 24 * 60 * 60)
  
  pipeline = [
    {
      '$match' => {
        'timestamp' => { '$gte' => start_time },
        'triggeredRules' => { '$exists' => true, '$ne' => [] }
      }
    },
    {
      '$unwind' => '$triggeredRules'
    },
    {
      '$group' => {
        '_id' => '$triggeredRules',
        'count' => { '$sum' => 1 },
        'blockedCount' => {
          '$sum' => {
            '$cond' => [{ '$eq' => ['$decision', 'BLOCK'] }, 1, 0]
          }
        }
      }
    },
    {
      '$project' => {
        'rule' => '$_id',
        'totalTriggers' => '$count',
        'blockedCount' => '$blockedCount',
        'blockRate' => {
          '$multiply' => [
            { '$divide' => ['$blockedCount', '$count'] },
            100
          ]
        }
      }
    },
    {
      '$sort' => { 'totalTriggers' => -1 }
    }
  ]
  
  effectiveness = $decisions.aggregate(pipeline).to_a
  
  json effectiveness
end

# Risk trend analysis
get '/api/dashboard/risk-trend' do
  content_type :json
  
  days_back = (params[:days] || 7).to_i
  start_time = Time.now - (days_back * 24 * 60 * 60)
  
  pipeline = [
    {
      '$match' => {
        'timestamp' => { '$gte' => start_time }
      }
    },
    {
      '$group' => {
        '_id' => {
          '$dateToString' => {
            'format' => '%Y-%m-%d',
            'date' => '$timestamp'
          }
        },
        'avgRiskScore' => { '$avg' => '$riskScore' },
        'maxRiskScore' => { '$max' => '$riskScore' },
        'transactionCount' => { '$sum' => 1 }
      }
    },
    {
      '$sort' => { '_id' => 1 }
    }
  ]
  
  trend = $decisions.aggregate(pipeline).to_a
  
  json trend.map { |day|
    {
      date: day['_id'],
      avgRiskScore: day['avgRiskScore'].round(2),
      maxRiskScore: day['maxRiskScore'],
      transactionCount: day['transactionCount']
    }
  }
end

# Custom DSL: Parse natural language rule
post '/api/dsl/parse' do
  content_type :json
  
  request.body.rewind
  payload = JSON.parse(request.body.read)
  rule_text = payload['rule']
  
  # Simple DSL parser
  parsed = parse_rule(rule_text)
  
  if parsed[:error]
    status 400
    json error: parsed[:error]
  else
    json parsed
  end
end

# Helper: Simple rule DSL parser
def parse_rule(text)
  # Example: "block when amount > 100000 and country is not US"
  # Example: "review when device risk > 80"
  
  action = nil
  conditions = []
  
  if text =~ /^(block|review|allow) when (.+)$/i
    action = $1.upcase
    condition_text = $2
    
    # Parse conditions
    parts = condition_text.split(/ and | or /i)
    
    parts.each do |part|
      if part =~ /amount\s*(>|<|>=|<=|==)\s*(\d+)/i
        conditions << { field: 'amount', operator: $1, value: $2.to_f }
      elsif part =~ /device risk\s*(>|<|>=|<=|==)\s*(\d+)/i
        conditions << { field: 'deviceRisk', operator: $1, value: $2.to_i }
      elsif part =~ /country\s+is\s+not\s+(\w+)/i
        conditions << { field: 'country', operator: '!=', value: $1.upcase }
      elsif part =~ /country\s+is\s+(\w+)/i
        conditions << { field: 'country', operator: '==', value: $1.upcase }
      elsif part =~ /payment method\s+is\s+(\w+)/i
        conditions << { field: 'paymentMethod', operator: '==', value: $1 }
      end
    end
    
    {
      action: action,
      conditions: conditions,
      originalText: text
    }
  else
    { error: 'Invalid rule format. Use: "action when condition [and/or condition]"' }
  end
end

# Start server
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'

puts "🚀 VaultEdge Analyst Tools starting on port #{settings.port}"

import SwiftUI

struct TransactionDetailView: View {
    let transaction: TransactionDecision
    @State private var showApprovalAlert = false
    @State private var showDenyAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Card
                VStack(spacing: 12) {
                    Text("$\(transaction.amount, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold))
                    
                    DecisionBadge(decision: transaction.decision)
                    
                    Text("Risk Score: \(transaction.riskScore)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Transaction Details
                SectionView(title: "Transaction Details") {
                    DetailRow(label: "Transaction ID", value: transaction.transactionId)
                    DetailRow(label: "Country", value: transaction.country)
                    DetailRow(label: "Currency", value: transaction.currency)
                    DetailRow(label: "Payment Method", value: transaction.paymentMethod)
                    DetailRow(label: "Device Risk", value: "\(transaction.deviceRisk)")
                    DetailRow(label: "Merchant ID", value: transaction.merchantId)
                    DetailRow(label: "Customer ID", value: transaction.customerId)
                }
                
                // Risk Analysis
                if !transaction.triggeredRules.isEmpty {
                    SectionView(title: "Triggered Rules") {
                        ForEach(transaction.triggeredRules, id: \.self) { rule in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(rule)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Explanation
                SectionView(title: "Risk Explanation") {
                    Text(transaction.explanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Action Buttons (only for REVIEW status)
                if transaction.decision == "REVIEW" {
                    HStack(spacing: 16) {
                        Button(action: { showDenyAlert = true }) {
                            Text("Deny")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showApprovalAlert = true }) {
                            Text("Approve")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .padding()
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Approve Transaction", isPresented: $showApprovalAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Approve") {
                // TODO: Implement approval logic
                print("Transaction approved: \(transaction.transactionId)")
            }
        } message: {
            Text("Are you sure you want to approve this transaction?")
        }
        .alert("Deny Transaction", isPresented: $showDenyAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Deny", role: .destructive) {
                // TODO: Implement denial logic
                print("Transaction denied: \(transaction.transactionId)")
            }
        } message: {
            Text("Are you sure you want to deny this transaction?")
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

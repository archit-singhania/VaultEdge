import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TransactionViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading transactions...")
                } else if let error = viewModel.error {
                    ErrorView(error: error, retry: { viewModel.fetchTransactions() })
                } else {
                    TransactionListView(viewModel: viewModel)
                }
            }
            .navigationTitle("VaultEdge Review")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.fetchTransactions() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
    }
}

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .refreshable {
            viewModel.fetchTransactions()
        }
    }
}

struct TransactionRowView: View {
    let transaction: TransactionDecision
    
    var body: some View {
        HStack {
            // Risk indicator
            Circle()
                .fill(riskColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("$\(transaction.amount, specifier: "%.2f")")
                    .font(.headline)
                
                Text("\(transaction.country) • \(transaction.paymentMethod)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            DecisionBadge(decision: transaction.decision)
        }
        .padding(.vertical, 4)
    }
    
    private var riskColor: Color {
        if transaction.riskScore >= 80 {
            return .red
        } else if transaction.riskScore >= 60 {
            return .orange
        } else {
            return .green
        }
    }
}

struct DecisionBadge: View {
    let decision: String
    
    var body: some View {
        Text(decision)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch decision {
        case "ALLOW": return .green
        case "BLOCK": return .red
        case "REVIEW": return .orange
        default: return .gray
        }
    }
}

struct ErrorView: View {
    let error: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retry) {
                Text("Retry")
                    .fontWeight(.semibold)
                    .frame(width: 120)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

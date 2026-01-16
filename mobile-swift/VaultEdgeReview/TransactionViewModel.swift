import Foundation
import Combine

// MARK: - Models
struct TransactionDecision: Identifiable, Codable {
    let id: String
    let transactionId: String
    let decision: String
    let riskScore: Int
    let triggeredRules: [String]
    let explanation: String
    let amount: Double
    let country: String
    let currency: String
    let paymentMethod: String
    let deviceRisk: Int
    let merchantId: String
    let customerId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case transactionId
        case decision
        case riskScore
        case triggeredRules
        case explanation
        case amount, country, currency, paymentMethod, deviceRisk, merchantId, customerId
    }
}

// MARK: - ViewModel
class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionDecision] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let baseURL = "http://localhost:8082/api"
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTransactions() {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "\(baseURL)/decisions?limit=50") else {
            self.error = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [TransactionDecision].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] transactions in
                self?.transactions = transactions
            }
            .store(in: &cancellables)
    }
    
    func approveTransaction(_ transactionId: String) {
        // TODO: Implement approval API call
        print("Approving transaction: \(transactionId)")
    }
    
    func denyTransaction(_ transactionId: String) {
        // TODO: Implement denial API call
        print("Denying transaction: \(transactionId)")
    }
}

// MARK: - API Service (Optional: For production use)
class VaultEdgeAPIService {
    static let shared = VaultEdgeAPIService()
    private let baseURL = "http://localhost:8082/api"
    
    func getDecisions(limit: Int = 50) async throws -> [TransactionDecision] {
        guard let url = URL(string: "\(baseURL)/decisions?limit=\(limit)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decisions = try JSONDecoder().decode([TransactionDecision].self, from: data)
        return decisions
    }
    
    func getHighRiskTransactions(threshold: Int = 80) async throws -> [TransactionDecision] {
        guard let url = URL(string: "http://localhost:4567/api/dashboard/high-risk?threshold=\(threshold)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decisions = try JSONDecoder().decode([TransactionDecision].self, from: data)
        return decisions
    }
}

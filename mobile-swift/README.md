# VaultEdge Review - iOS App

**Transaction Review Interface for VaultEdge**

This is the mobile companion app for VaultEdge that allows risk analysts to review flagged transactions on iOS devices.

## Features

- 📱 **Native iOS Interface** - Built with SwiftUI
- 🔄 **Real-time Updates** - Pull-to-refresh transaction list
- 📊 **Risk Visualization** - Color-coded risk indicators
- 📝 **Decision Details** - View complete transaction context
- ✅ **Manual Review** - Approve or deny transactions
- 🔍 **Rule Explanations** - See which rules were triggered

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Setup

### 1. Open in Xcode

```bash
cd mobile-swift
xed VaultEdgeReview
```

### 2. Configure API Endpoints

Edit `TransactionViewModel.swift`:

```swift
private let baseURL = "http://localhost:8082/api"  // Change for production
```

### 3. Run the App

1. Select a simulator or device
2. Press `Cmd+R` to build and run

## Architecture

```
VaultEdgeReview/
├── VaultEdgeReviewApp.swift       # App entry point
├── ContentView.swift               # Main transaction list
├── TransactionDetailView.swift     # Transaction details
├── TransactionViewModel.swift      # Business logic & API calls
└── Models/
    └── TransactionDecision.swift   # Data models
```

## Features Overview

### Transaction List

- Displays recent transactions requiring review
- Color-coded risk indicators:
  - 🟢 Green: Low risk (score < 60)
  - 🟠 Orange: Medium risk (60-79)
  - 🔴 Red: High risk (80+)
- Decision badges (ALLOW, BLOCK, REVIEW)
- Pull-to-refresh

### Transaction Detail

- Full transaction information
- Risk score and decision
- Triggered rules list
- Detailed explanation
- Approve/Deny buttons (for REVIEW status)

### API Integration

- Fetches transactions from Control Plane API
- Supports pagination
- Error handling with retry
- Offline graceful degradation

## API Endpoints Used

```swift
GET /api/decisions?limit=50           // List transactions
GET /api/decisions/:id                // Get specific transaction
GET /api/dashboard/high-risk          // High-risk transactions
```

## Data Models

### TransactionDecision

```swift
struct TransactionDecision: Identifiable, Codable {
    let id: String
    let transactionId: String
    let decision: String              // ALLOW, BLOCK, REVIEW
    let riskScore: Int               // 0-100
    let triggeredRules: [String]
    let explanation: String
    let amount: Double
    let country: String
    let currency: String
    let paymentMethod: String
    let deviceRisk: Int
}
```

## Usage Example

### Viewing Transactions

1. Launch the app
2. See list of transactions sorted by risk
3. Tap any transaction for details

### Reviewing a Transaction

1. Select a transaction with "REVIEW" status
2. Review the risk score and explanation
3. Check triggered rules
4. Tap "Approve" or "Deny"
5. Confirm your decision

## Extending the App

### Add Filtering

```swift
struct ContentView: View {
    @State private var filterDecision: String = "ALL"
    
    var filteredTransactions: [TransactionDecision] {
        if filterDecision == "ALL" {
            return viewModel.transactions
        }
        return viewModel.transactions.filter { $0.decision == filterDecision }
    }
}
```

### Add Search

```swift
@State private var searchText = ""

var searchResults: [TransactionDecision] {
    if searchText.isEmpty {
        return viewModel.transactions
    }
    return viewModel.transactions.filter {
        $0.transactionId.contains(searchText) ||
        $0.customerId.contains(searchText)
    }
}
```

### Add Notifications

```swift
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound]) { granted, _ in
            print("Notifications: \(granted)")
        }
}

func sendNotification(for transaction: TransactionDecision) {
    let content = UNMutableNotificationContent()
    content.title = "High Risk Transaction"
    content.body = "$\(transaction.amount) - Review Required"
    content.sound = .default
    
    let request = UNNotificationRequest(
        identifier: transaction.id,
        content: content,
        trigger: nil
    )
    
    UNUserNotificationCenter.current().add(request)
}
```

## Testing

### Simulator

```bash
# Run in simulator
xcodebuild -scheme VaultEdgeReview \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           test
```

### Real Device

1. Connect iPhone/iPad
2. Trust the developer certificate
3. Select device in Xcode
4. Build and run

## Production Considerations

### Security

1. **HTTPS**: Use secure endpoints in production
   ```swift
   private let baseURL = "https://api.vaultedge.com"
   ```

2. **Authentication**: Add JWT tokens
   ```swift
   var request = URLRequest(url: url)
   request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
   ```

3. **Certificate Pinning**: Validate SSL certificates
   ```swift
   // Implement URLSessionDelegate for certificate pinning
   ```

### Performance

1. **Caching**: Cache transaction data
   ```swift
   @Published var cachedTransactions: [String: TransactionDecision] = [:]
   ```

2. **Pagination**: Load transactions in batches
   ```swift
   func loadMore() {
       let offset = transactions.count
       fetchTransactions(limit: 50, offset: offset)
   }
   ```

3. **Background Updates**: Fetch new data in background
   ```swift
   func configureBackgroundFetch() {
       // Implement background fetch
   }
   ```

## Troubleshooting

### Cannot Connect to API

1. Check API URL in `TransactionViewModel.swift`
2. Ensure backend services are running
3. Verify network connectivity
4. Check firewall settings

### Build Errors

```bash
# Clean build folder
xcodebuild clean

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Simulator Issues

```bash
# Reset simulator
xcrun simctl erase all
```

## Future Enhancements

- [ ] Push notifications for high-risk transactions
- [ ] Offline mode with local database
- [ ] Biometric authentication
- [ ] Transaction search and filtering
- [ ] Export reports
- [ ] Dark mode support
- [ ] iPad optimization
- [ ] Widget support
- [ ] Apple Watch companion app

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [URLSession Guide](https://developer.apple.com/documentation/foundation/urlsession)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Built with SwiftUI for iOS 15+**

import SwiftUI

struct TestRealtimeView: View {
    @StateObject private var apiClient = APIClient.shared
    @StateObject private var hybridManager = HybridDataManager.shared
    @State private var testMessage = ""
    @State private var testListing = ""
    @State private var messages: [[String: Any]] = []
    @State private var listings: [[String: Any]] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Connection Status
                HStack {
                    Circle()
                        .fill(apiClient.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(apiClient.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(apiClient.isConnected ? .green : .red)
                    
                    Spacer()
                    
                    Text(hybridManager.syncStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Test Listing Creation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Live Posting")
                        .font(.headline)
                    
                    TextField("Enter listing title", text: $testListing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Create Test Listing") {
                        createTestListing()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(testListing.isEmpty)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Test Message Sending
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Live Messaging")
                        .font(.headline)
                    
                    TextField("Enter test message", text: $testMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send Test Message") {
                        sendTestMessage()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(testMessage.isEmpty)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                
                // Real-time Updates
                VStack(alignment: .leading, spacing: 8) {
                    Text("Real-time Updates")
                        .font(.headline)
                    
                    Text("New Listings: \(listings.count)")
                    Text("New Messages: \(messages.count)")
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                // API Test Button
                Button("Test API Connection") {
                    testAPIConnection()
                }
                .buttonStyle(.bordered)
                
                // Clear Data Button
                Button("Clear Test Data") {
                    clearTestData()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Real-time Test")
            .onAppear {
                setupRealTimeListeners()
            }
        }
    }
    
    private func createTestListing() {
        Task {
            do {
                let listingData: [String: Any] = [
                    "userId": "test-user-123",
                    "title": testListing,
                    "description": "This is a test listing created from the iOS app",
                    "category": "Test",
                    "price": 0.0,
                    "location": "Test Location",
                    "images": []
                ]
                
                let listingId = try await hybridManager.createListing(listingData)
                print("✅ Test listing created with ID: \(listingId)")
                
                DispatchQueue.main.async {
                    testListing = ""
                }
            } catch {
                print("❌ Failed to create test listing: \(error)")
            }
        }
    }
    
    private func sendTestMessage() {
        Task {
            do {
                try await hybridManager.sendMessage(
                    conversationId: "test-conversation-123",
                    senderId: "test-user-123",
                    text: testMessage
                )
                
                print("✅ Test message sent: \(testMessage)")
                
                DispatchQueue.main.async {
                    testMessage = ""
                }
            } catch {
                print("❌ Failed to send test message: \(error)")
            }
        }
    }
    
    private func testAPIConnection() {
        Task {
            do {
                let healthData = try await apiClient.getAllListings()
                print("✅ API connection successful! Found \(healthData.count) listings")
            } catch {
                print("❌ API connection failed: \(error)")
            }
        }
    }
    
    private func setupRealTimeListeners() {
        // Listen for real-time updates
        hybridManager.listenToListings { newListings in
            DispatchQueue.main.async {
                self.listings = newListings
            }
        }
        
        // You can add message listeners here when implemented
    }
    
    private func clearTestData() {
        listings.removeAll()
        messages.removeAll()
        testListing = ""
        testMessage = ""
    }
}

#Preview {
    TestRealtimeView()
}

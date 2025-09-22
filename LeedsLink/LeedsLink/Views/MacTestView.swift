import SwiftUI

struct MacTestView: View {
    @StateObject private var apiClient = APIClient.shared
    @StateObject private var hybridManager = HybridDataManager.shared
    @State private var testMessage = ""
    @State private var testListing = ""
    @State private var messages: [[String: Any]] = []
    @State private var listings: [[String: Any]] = []
    @State private var connectionStatus = "Testing..."
    @State private var serverInfo: [String: Any] = [:]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Server Info Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🍎 Mac Backend Status")
                            .font(.headline)
                        
                        HStack {
                            Circle()
                                .fill(apiClient.isConnected ? Color.green : Color.red)
                                .frame(width: 12, height: 12)
                            Text(apiClient.isConnected ? "Connected to Mac" : "Disconnected")
                                .foregroundColor(apiClient.isConnected ? .green : .red)
                        }
                        
                        if let server = serverInfo["server"] as? String {
                            Text("Server: \(server)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let ip = serverInfo["ip"] as? String {
                            Text("IP: \(ip)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let connections = serverInfo["connections"] as? Int {
                            Text("WebSocket Connections: \(connections)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Test Listing Creation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📝 Test Live Posting")
                            .font(.headline)
                        
                        TextField("Enter listing title", text: $testListing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Create Test Listing on Mac") {
                            createTestListing()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(testListing.isEmpty)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Test Message Sending
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💬 Test Live Messaging")
                            .font(.headline)
                        
                        TextField("Enter test message", text: $testMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send Test Message to Mac") {
                            sendTestMessage()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(testMessage.isEmpty)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Real-time Updates
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📊 Real-time Updates")
                            .font(.headline)
                        
                        Text("Listings from Mac: \(listings.count)")
                        Text("Messages from Mac: \(messages.count)")
                        Text("Connection Status: \(connectionStatus)")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                    
                    // API Test Buttons
                    VStack(spacing: 12) {
                        Button("🏥 Test Mac API Connection") {
                            testAPIConnection()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button("📋 Get Listings from Mac") {
                            Task {
                                await getListings()
                            }
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button("🔄 Refresh Server Info") {
                            refreshServerInfo()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button("🗑️ Clear Test Data") {
                            clearTestData()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Server Response
                    if !serverInfo.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📡 Server Response")
                                .font(.headline)
                            
                            ScrollView {
                                Text(serverInfo.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxHeight: 100)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Mac Backend Test")
            .onAppear {
                setupRealTimeListeners()
                testAPIConnection()
            }
        }
    }
    
    private func createTestListing() {
        Task {
            do {
                let listingData: [String: Any] = [
                    "userId": "ios-test-user-\(UUID().uuidString)",
                    "title": testListing,
                    "description": "This is a test listing created from the iOS app connecting to Mac backend",
                    "category": "iOS Test",
                    "price": 0.0,
                    "location": "iOS Test Location",
                    "images": []
                ]
                
                let listingId = try await hybridManager.createListing(listingData)
                print("✅ Test listing created on Mac with ID: \(listingId)")
                
                DispatchQueue.main.async {
                    testListing = ""
                }
                
                // Refresh listings
                await getListings()
            } catch {
                print("❌ Failed to create test listing on Mac: \(error)")
            }
        }
    }
    
    private func sendTestMessage() {
        Task {
            do {
                try await hybridManager.sendMessage(
                    conversationId: "ios-test-conversation-\(UUID().uuidString)",
                    senderId: "ios-test-user-\(UUID().uuidString)",
                    text: testMessage
                )
                
                print("✅ Test message sent to Mac: \(testMessage)")
                
                DispatchQueue.main.async {
                    testMessage = ""
                }
            } catch {
                print("❌ Failed to send test message to Mac: \(error)")
            }
        }
    }
    
    private func testAPIConnection() {
        Task {
            do {
                let healthData = try await apiClient.getAllListings()
                print("✅ Mac API connection successful! Found \(healthData.count) listings")
                
                DispatchQueue.main.async {
                    self.serverInfo = ["status": "Connected", "listings": healthData.count]
                    self.connectionStatus = "Connected to Mac"
                }
            } catch {
                print("❌ Mac API connection failed: \(error)")
                DispatchQueue.main.async {
                    self.serverInfo = ["status": "Failed", "error": error.localizedDescription]
                    self.connectionStatus = "Failed to connect to Mac"
                }
            }
        }
    }
    
    private func getListings() async {
        do {
            let macListings = try await hybridManager.getAllListings()
            DispatchQueue.main.async {
                self.listings = macListings
            }
        } catch {
            print("❌ Failed to get listings from Mac: \(error)")
        }
    }
    
    private func refreshServerInfo() {
        Task {
            do {
                // Test health endpoint directly
                let url = URL(string: "http://192.168.1.119:3000/api/health")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let healthData = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                
                DispatchQueue.main.async {
                    self.serverInfo = healthData
                    self.connectionStatus = "Connected to Mac"
                }
            } catch {
                print("❌ Failed to refresh server info: \(error)")
                DispatchQueue.main.async {
                    self.connectionStatus = "Failed to connect to Mac"
                }
            }
        }
    }
    
    private func setupRealTimeListeners() {
        // Listen for real-time updates from Mac
        hybridManager.listenToListings { newListings in
            DispatchQueue.main.async {
                self.listings = newListings
            }
        }
    }
    
    private func clearTestData() {
        listings.removeAll()
        messages.removeAll()
        testListing = ""
        testMessage = ""
        serverInfo.removeAll()
        connectionStatus = "Cleared"
    }
}

#Preview {
    MacTestView()
}

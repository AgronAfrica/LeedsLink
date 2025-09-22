import Foundation
import Combine

class APIClientMac: ObservableObject {
    static let shared = APIClientMac()
    
    private let baseURL = ConfigMac.getCurrentBaseURL()
    private let session = URLSession.shared
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected = false
    @Published var newMessages: [Message] = []
    @Published var newListings: [Listing] = []
    @Published var connectionStatus = "Disconnected"
    
    private init() {
        connectWebSocket()
    }
    
    // MARK: - REST API Methods
    
    func createListing(_ listing: [String: Any]) async throws -> String {
        let url = URL(string: "\(baseURL)\(ConfigMac.endpoints.listings)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: listing)
        
        print("📝 Creating listing on Mac: \(url)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        print("✅ Listing created on Mac: \(result?["id"] ?? "unknown")")
        return (result?["id"] as? String) ?? ""
    }
    
    func getAllListings() async throws -> [[String: Any]] {
        let url = URL(string: "\(baseURL)\(ConfigMac.endpoints.listings)")!
        print("📋 Fetching listings from Mac: \(url)")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let listings = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        print("✅ Fetched \(listings?.count ?? 0) listings from Mac")
        return listings ?? []
    }
    
    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        let url = URL(string: "\(baseURL)\(ConfigMac.endpoints.messages)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messageData: [String: Any] = [
            "conversationId": conversationId,
            "senderId": senderId,
            "text": text,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: messageData)
        
        print("💬 Sending message to Mac: \(url)")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        print("✅ Message sent to Mac successfully")
    }
    
    func getMessages(conversationId: String) async throws -> [[String: Any]] {
        let url = URL(string: "\(baseURL)\(ConfigMac.endpoints.messages(conversationId: conversationId))")!
        print("💬 Fetching messages from Mac: \(url)")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let messages = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        print("✅ Fetched \(messages?.count ?? 0) messages from Mac")
        return messages ?? []
    }
    
    func testConnection() async throws -> [String: Any] {
        let url = URL(string: "\(baseURL)\(ConfigMac.endpoints.health)")!
        print("🏥 Testing connection to Mac: \(url)")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let healthData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        print("✅ Mac connection test successful: \(healthData?["server"] ?? "unknown")")
        return healthData ?? [:]
    }
    
    // MARK: - WebSocket for Real-time Updates
    
    private func connectWebSocket() {
        let webSocketURL = ConfigMac.getCurrentWebSocketURL()
        guard let url = URL(string: webSocketURL) else { 
            print("❌ Invalid WebSocket URL: \(webSocketURL)")
            return 
        }
        
        print("🔌 Connecting to Mac WebSocket: \(webSocketURL)")
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionStatus = "Connected to Mac"
        }
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleWebSocketMessage(text)
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage() // Continue listening
            case .failure(let error):
                print("❌ WebSocket error on Mac: \(error)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                    self?.connectionStatus = "Disconnected from Mac"
                }
                // Attempt to reconnect after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    print("🔄 Attempting to reconnect to Mac WebSocket...")
                    self?.connectWebSocket()
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { 
            print("❌ Invalid WebSocket message from Mac: \(message)")
            return 
        }
        
        print("📨 Received WebSocket message from Mac: \(type)")
        
        DispatchQueue.main.async {
            switch type {
            case "connection":
                if let data = json["data"] as? [String: Any] {
                    print("✅ Connected to Mac: \(data["message"] ?? "unknown")")
                    self.connectionStatus = "Connected to Mac (\(data["ip"] ?? "unknown"))"
                }
            case "new_listing":
                if let listingData = json["data"] as? [String: Any] {
                    print("📝 New listing from Mac: \(listingData["title"] ?? "unknown")")
                    self.handleNewListing(listingData)
                }
            case "new_message":
                if let messageData = json["data"] as? [String: Any] {
                    print("💬 New message from Mac: \(messageData["text"] ?? "unknown")")
                    self.handleNewMessage(messageData)
                }
            default:
                print("📨 Unknown message type from Mac: \(type)")
            }
        }
    }
    
    private func handleNewListing(_ listingData: [String: Any]) {
        // Convert to Listing model and update UI
        // This will trigger UI updates through @Published properties
        print("📝 Processing new listing from Mac: \(listingData["title"] ?? "unknown")")
    }
    
    private func handleNewMessage(_ messageData: [String: Any]) {
        // Convert to Message model and update UI
        // This will trigger UI updates through @Published properties
        print("💬 Processing new message from Mac: \(messageData["text"] ?? "unknown")")
    }
    
    func sendWebSocketMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let text = String(data: data, encoding: .utf8) else { 
            print("❌ Failed to serialize WebSocket message")
            return 
        }
        
        print("📤 Sending WebSocket message to Mac: \(text)")
        
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("❌ Failed to send WebSocket message to Mac: \(error)")
            } else {
                print("✅ WebSocket message sent to Mac successfully")
            }
        }
    }
    
    func reconnect() {
        print("🔄 Manually reconnecting to Mac...")
        webSocketTask?.cancel()
        connectWebSocket()
    }
    
    deinit {
        webSocketTask?.cancel()
    }
}

enum APIError: Error {
    case serverError
    case networkError
    case invalidData
}

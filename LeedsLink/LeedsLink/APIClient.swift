import Foundation
import Combine

class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let baseURL = Config.baseURL
    private let session = URLSession.shared
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected = false
    @Published var newMessages: [Message] = []
    @Published var newListings: [Listing] = []
    
    private init() {
        connectWebSocket()
    }
    
    // MARK: - REST API Methods
    
    func createListing(_ listing: [String: Any]) async throws -> String {
        let url = URL(string: "\(baseURL)\(Config.endpoints.listings)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: listing)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (result?["id"] as? String) ?? ""
    }
    
    func getAllListings() async throws -> [[String: Any]] {
        let url = URL(string: "\(baseURL)\(Config.endpoints.listings)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        return (try JSONSerialization.jsonObject(with: data) as? [[String: Any]]) ?? []
    }
    
    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        let url = URL(string: "\(baseURL)\(Config.endpoints.messages)")!
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
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
    }
    
    func getMessages(conversationId: String) async throws -> [[String: Any]] {
        let url = URL(string: "\(baseURL)\(Config.endpoints.messages(conversationId: conversationId))")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        return (try JSONSerialization.jsonObject(with: data) as? [[String: Any]]) ?? []
    }
    
    // MARK: - WebSocket for Real-time Updates
    
    private func connectWebSocket() {
        guard let url = URL(string: Config.webSocketURL) else { return }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
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
                print("WebSocket error: \(error)")
                self?.isConnected = false
                // Attempt to reconnect after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.connectWebSocket()
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }
        
        DispatchQueue.main.async {
            switch type {
            case "new_listing":
                if let listingData = json["data"] as? [String: Any] {
                    // Handle new listing
                    self.handleNewListing(listingData)
                }
            case "new_message":
                if let messageData = json["data"] as? [String: Any] {
                    // Handle new message
                    self.handleNewMessage(messageData)
                }
            default:
                break
            }
        }
    }
    
    private func handleNewListing(_ listingData: [String: Any]) {
        // Convert to Listing model and update UI
        // This will trigger UI updates through @Published properties
    }
    
    private func handleNewMessage(_ messageData: [String: Any]) {
        // Convert to Message model and update UI
        // This will trigger UI updates through @Published properties
    }
    
    func sendWebSocketMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let text = String(data: data, encoding: .utf8) else { return }
        
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("Failed to send WebSocket message: \(error)")
            }
        }
    }
    
    deinit {
        webSocketTask?.cancel()
    }
}


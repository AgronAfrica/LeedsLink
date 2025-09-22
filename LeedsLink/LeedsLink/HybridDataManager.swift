import Foundation
import Combine

@MainActor
class HybridDataManager: ObservableObject {
    static let shared = HybridDataManager()
    
    private let localStorage = LocalStorageManager.shared
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isOnline = false
    @Published var syncStatus = "Offline"
    
    private init() {
        setupNetworkMonitoring()
        setupAPIClientObservers()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        // Simple network check - you can use Network framework for more sophisticated monitoring
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkNetworkStatus()
            }
            .store(in: &cancellables)
    }
    
    private func checkNetworkStatus() {
        // Simple ping to your server
        Task {
            do {
                _ = try await apiClient.getAllListings()
                isOnline = true
                syncStatus = "Online"
                await syncLocalDataToServer()
            } catch {
                isOnline = false
                syncStatus = "Offline"
            }
        }
    }
    
    private func setupAPIClientObservers() {
        // Listen for real-time updates from WebSocket
        apiClient.$newListings
            .sink { [weak self] newListings in
                // Update local storage with new listings from server
                Task {
                    let listingsDict = newListings.map { listing in
                        // Convert Listing to [String: Any]
                        return [
                            "id": listing.id.uuidString,
                            "userId": listing.userId.uuidString,
                            "title": listing.title,
                            "category": listing.category.rawValue,
                            "tags": listing.tags,
                            "budget": listing.budget ?? "",
                            "price": listing.price ?? "",
                            "availability": listing.availability,
                            "description": listing.description,
                            "type": listing.type.rawValue,
                            "isUrgent": listing.isUrgent,
                            "createdAt": ISO8601DateFormatter().string(from: listing.createdAt),
                            "address": listing.address ?? "",
                            "postcode": listing.postcode ?? ""
                        ]
                    }
                    await self?.updateLocalListings(listingsDict)
                }
            }
            .store(in: &cancellables)
        
        apiClient.$newMessages
            .sink { [weak self] newMessages in
                // Update local storage with new messages from server
                Task {
                    let messagesDict = newMessages.map { message in
                        // Convert Message to [String: Any]
                        return [
                            "id": message.id.uuidString,
                            "senderId": message.senderId.uuidString,
                            "senderName": message.senderName,
                            "content": message.content,
                            "timestamp": ISO8601DateFormatter().string(from: message.timestamp)
                        ]
                    }
                    // Note: We need a conversationId for this - you may need to pass it from the API client
                    // For now, we'll use a placeholder or you can modify the API client to include it
                    await self?.updateLocalMessages(messagesDict, conversationId: "unknown")
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Listings Management
    
    func createListing(_ listing: [String: Any]) async throws -> String {
        // Always save locally first
        let localId = try await localStorage.createListing(listing)
        
        // Try to sync to server if online
        if isOnline {
            do {
                let serverId = try await apiClient.createListing(listing)
                // Update local record with server ID
                try await localStorage.updateListing(localId, data: ["serverId": serverId])
                return serverId
            } catch {
                // If server fails, keep local version and mark for later sync
                try await localStorage.updateListing(localId, data: ["needsSync": true])
                return localId
            }
        } else {
            // Mark for sync when back online
            try await localStorage.updateListing(localId, data: ["needsSync": true])
            return localId
        }
    }
    
    func getAllListings() async throws -> [[String: Any]] {
        if isOnline {
            do {
                // Get fresh data from server
                let serverListings = try await apiClient.getAllListings()
                // Update local storage
                await updateLocalListings(serverListings)
                return serverListings
            } catch {
                // Fall back to local data if server fails
                return try await localStorage.getAllListings()
            }
        } else {
            // Return local data when offline
            return try await localStorage.getAllListings()
        }
    }
    
    func updateListing(_ listingId: String, data: [String: Any]) async throws {
        // Update locally first
        try await localStorage.updateListing(listingId, data: data)
        
        // Sync to server if online
        if isOnline {
            // You'd need to implement updateListing on your API
            // For now, we'll just mark for sync since the API call is commented out
            try await localStorage.updateListing(listingId, data: ["needsSync": true])
        } else {
            // Mark for sync when back online
            try await localStorage.updateListing(listingId, data: ["needsSync": true])
        }
    }
    
    func deleteListing(_ listingId: String) async throws {
        // Delete locally first
        try await localStorage.deleteListing(listingId)
        
        // Sync to server if online
        if isOnline {
            // You'd need to implement deleteListing on your API
            // For now, we'll just mark for deletion since the API call is commented out
            try await localStorage.updateListing(listingId, data: ["deleted": true])
        }
    }
    
    // MARK: - Messages Management
    
    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        // Save locally first
        try await localStorage.sendMessage(conversationId: conversationId, senderId: senderId, text: text)
        
        // Send to server if online
        if isOnline {
            do {
                try await apiClient.sendMessage(conversationId: conversationId, senderId: senderId, text: text)
            } catch {
                // Mark for sync if server fails
                // You could implement a sync queue for failed messages
            }
        }
    }
    
    func getMessages(for conversationId: String) async throws -> [[String: Any]] {
        if isOnline {
            do {
                // Get fresh messages from server
                let serverMessages = try await apiClient.getMessages(conversationId: conversationId)
                // Update local storage
                await updateLocalMessages(serverMessages, conversationId: conversationId)
                return serverMessages
            } catch {
                // Fall back to local data
                return try await localStorage.getMessages(for: conversationId)
            }
        } else {
            // Return local data when offline
            return try await localStorage.getMessages(for: conversationId)
        }
    }
    
    // MARK: - Sync Methods
    
    private func syncLocalDataToServer() async {
        // Sync listings that need sync
        let localListings = try? await localStorage.getAllListings()
        let needsSyncListings = localListings?.filter { $0["needsSync"] as? Bool == true } ?? []
        
        for listing in needsSyncListings {
            do {
                let serverId = try await apiClient.createListing(listing)
                try await localStorage.updateListing(listing["id"] as? String ?? "", data: [
                    "serverId": serverId,
                    "needsSync": false
                ])
            } catch {
                // Keep trying next time
            }
        }
    }
    
    private func updateLocalListings(_ serverListings: [[String: Any]]) async {
        // Merge server listings with local ones
        // This is a simplified version - you'd want more sophisticated conflict resolution
        for listing in serverListings {
            if let serverId = listing["id"] as? String {
                // Check if we already have this listing locally
                let localListings = try? await localStorage.getAllListings()
                let existsLocally = localListings?.contains { $0["serverId"] as? String == serverId } ?? false
                
                if !existsLocally {
                    // Add new listing to local storage
                    _ = try? await localStorage.createListing(listing)
                }
            }
        }
    }
    
    private func updateLocalMessages(_ serverMessages: [[String: Any]], conversationId: String) async {
        // Similar logic for messages
        // You'd implement message merging logic here
    }
    
    // MARK: - Real-time Listeners
    
    func listenToListings(completion: @escaping ([[String: Any]]) -> Void) {
        // Listen to both local storage and API client
        localStorage.listenToListings { localListings in
            completion(localListings)
        }
        
        // API client will automatically update through @Published properties
    }
    
    func listenToMessages(for conversationId: String, completion: @escaping ([[String: Any]]) -> Void) {
        localStorage.listenToMessages(for: conversationId) { localMessages in
            completion(localMessages)
        }
    }
    
    func stopListening() {
        localStorage.stopListening()
    }
}

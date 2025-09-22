import Foundation
import SwiftUI

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    // Use HybridDataManager for both local storage and API sync
    private let hybridManager = HybridDataManager.shared
    private let localStorage = LocalStorageManager.shared
    
    @Published var currentUser: User? {
        didSet {
            localStorage.currentUser = currentUser
        }
    }
    @Published var isAuthenticated = false {
        didSet {
            localStorage.isAuthenticated = isAuthenticated
        }
    }
    
    private init() {
        // Initialize with local storage values
        currentUser = localStorage.currentUser
        isAuthenticated = localStorage.isAuthenticated
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, userData: [String: Any]) async throws {
        try await localStorage.signUp(email: email, password: password, userData: userData)
        currentUser = localStorage.currentUser
        isAuthenticated = localStorage.isAuthenticated
    }
    
    func signIn(email: String, password: String) async throws {
        try await localStorage.signIn(email: email, password: password)
        currentUser = localStorage.currentUser
        isAuthenticated = localStorage.isAuthenticated
    }
    
    func signOut() throws {
        try localStorage.signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - User Management
    
    func getUserData(uid: String) async throws -> [String: Any] {
        return try await localStorage.getUserData(uid: uid)
    }
    
    func updateUserData(uid: String, data: [String: Any]) async throws {
        try await localStorage.updateUserData(uid: uid, data: data)
    }
    
    // MARK: - Listings Management
    
    func createListing(_ listing: [String: Any]) async throws -> String {
        return try await hybridManager.createListing(listing)
    }
    
    func updateListing(_ listingId: String, data: [String: Any]) async throws {
        try await hybridManager.updateListing(listingId, data: data)
    }
    
    func deleteListing(_ listingId: String) async throws {
        try await hybridManager.deleteListing(listingId)
    }
    
    func getAllListings() async throws -> [[String: Any]] {
        return try await hybridManager.getAllListings()
    }
    
    func getListingsByUser(_ userId: String) async throws -> [[String: Any]] {
        return try await localStorage.getListingsByUser(userId)
    }
    
    // MARK: - Conversations and Messages
    
    func createConversation(participants: [String], listingId: String) async throws -> String {
        return try await localStorage.createConversation(participants: participants, listingId: listingId)
    }
    
    func getConversations(for userId: String) async throws -> [[String: Any]] {
        return try await localStorage.getConversations(for: userId)
    }
    
    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        try await hybridManager.sendMessage(conversationId: conversationId, senderId: senderId, text: text)
    }
    
    func getMessages(for conversationId: String) async throws -> [[String: Any]] {
        return try await hybridManager.getMessages(for: conversationId)
    }
    
    // MARK: - Real-time Listeners
    
    func listenToListings(completion: @escaping ([[String: Any]]) -> Void) {
        hybridManager.listenToListings(completion: completion)
    }
    
    func listenToConversations(for userId: String, completion: @escaping ([[String: Any]]) -> Void) {
        localStorage.listenToConversations(for: userId, completion: completion)
    }
    
    func listenToMessages(for conversationId: String, completion: @escaping ([[String: Any]]) -> Void) {
        hybridManager.listenToMessages(for: conversationId, completion: completion)
    }
    
    func stopListening() {
        hybridManager.stopListening()
    }
}

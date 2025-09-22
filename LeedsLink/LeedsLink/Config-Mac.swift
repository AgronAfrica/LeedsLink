import Foundation

struct ConfigMac {
    // MARK: - Mac Server Configuration
    // Replace with your Mac's IP address (find it in System Preferences > Network)
    // You can also use 'localhost' if testing on the same Mac
    static let macIP = "192.168.1.100" // Replace with your actual Mac IP
    static let port = "3000"
    
    // MARK: - Server URLs
    static let baseURL = "http://\(macIP):\(port)/api"
    static let webSocketURL = "ws://\(macIP):\(port)/ws"
    
    // MARK: - Alternative URLs (for testing)
    static let localhostBaseURL = "http://localhost:\(port)/api"
    static let localhostWebSocketURL = "ws://localhost:\(port)/ws"
    
    // MARK: - API Endpoints
    static let endpoints = MacAPIEndpoints()
    
    // MARK: - Helper Methods
    static func getCurrentBaseURL() -> String {
        // You can switch between localhost and network IP here
        return baseURL // Use baseURL for network access, localhostBaseURL for local testing
    }
    
    static func getCurrentWebSocketURL() -> String {
        return webSocketURL // Use webSocketURL for network access, localhostWebSocketURL for local testing
    }
}

struct MacAPIEndpoints {
    let listings = "/listings"
    let messages = "/messages"
    let conversations = "/conversations"
    let health = "/health"
    
    func listing(id: String) -> String {
        return "/listings/\(id)"
    }
    
    func messages(conversationId: String) -> String {
        return "/messages/\(conversationId)"
    }
}


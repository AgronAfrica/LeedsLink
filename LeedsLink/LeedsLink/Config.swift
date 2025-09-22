import Foundation

struct Config {
    // MARK: - Server Configuration
    // LeedsLink backend running on Mac (192.168.1.119)
    static let baseURL = "http://192.168.1.119:3000/api"
    static let webSocketURL = "ws://192.168.1.119:3000/ws"
    
    // MARK: - API Endpoints
    static let endpoints = APIEndpoints()
}

struct APIEndpoints {
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


import Foundation

struct Conversation: Codable, Identifiable {
    let id: UUID
    let participantIds: [UUID]
    let participantNames: [String]
    var messages: [Message]
    var lastMessage: Message? {
        messages.last
    }
    let createdAt: Date
    
    init(id: UUID = UUID(), participantIds: [UUID], participantNames: [String], messages: [Message] = [], createdAt: Date = Date()) {
        self.id = id
        self.participantIds = participantIds
        self.participantNames = participantNames
        self.messages = messages
        self.createdAt = createdAt
    }
}

struct Message: Codable, Identifiable {
    let id: UUID
    let senderId: UUID
    let senderName: String
    var content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), senderId: UUID, senderName: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = timestamp
    }
}

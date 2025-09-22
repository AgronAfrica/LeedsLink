import Foundation
import UserNotifications
import SwiftUI

enum NotificationType: String, CaseIterable {
    case newListing = "new_listing"
    case matchFound = "match_found"
    case newMessage = "new_message"
    case urgentListing = "urgent_listing"
}

struct NotificationContent {
    let title: String
    let body: String
    let type: NotificationType
    let data: [String: Any]
}

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var notificationSettings = NotificationSettings()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission Management
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .provisional]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                registerForRemoteNotifications()
            }
        } catch {
            print("❌ Failed to request notification permission: \(error)")
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Local Notifications
    func scheduleLocalNotification(_ content: NotificationContent, delay: TimeInterval = 0) {
        guard isAuthorized else {
            print("⚠️ Notifications not authorized")
            return
        }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = content.title
        notificationContent.body = content.body
        notificationContent.sound = .default
        notificationContent.badge = 1
        
        // Add custom data
        notificationContent.userInfo = content.data
        
        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "\(content.type.rawValue)_\(UUID().uuidString)",
            content: notificationContent,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Scheduled notification: \(content.title)")
            }
        }
    }
    
    // MARK: - Notification Types
    
    // Location-based notifications for new listings
    func notifyNewListingInArea(_ listing: Listing, userPostcode: String) {
        guard notificationSettings.newListingNotifications else { return }
        
        let content = NotificationContent(
            title: "New Listing in Your Area! 📍",
            body: "\(listing.title) - \(listing.category.rawValue) posted in \(userPostcode)",
            type: .newListing,
            data: [
                "listing_id": listing.id.uuidString,
                "user_id": listing.userId.uuidString,
                "postcode": userPostcode,
                "category": listing.category.rawValue
            ]
        )
        
        scheduleLocalNotification(content)
    }
    
    // Match notifications
    func notifyMatchFound(_ listing: Listing, matchedListing: Listing) {
        guard notificationSettings.matchNotifications else { return }
        
        let content = NotificationContent(
            title: "🎉 New Match Found!",
            body: "Your listing '\(listing.title)' matches with '\(matchedListing.title)'",
            type: .matchFound,
            data: [
                "listing_id": listing.id.uuidString,
                "matched_listing_id": matchedListing.id.uuidString,
                "match_score": listing.matchScore(with: matchedListing)
            ]
        )
        
        scheduleLocalNotification(content)
    }
    
    // Message notifications
    func notifyNewMessage(_ message: Message, conversationId: UUID) {
        guard notificationSettings.messageNotifications else { return }
        
        let content = NotificationContent(
            title: "💬 New Message from \(message.senderName)",
            body: message.content,
            type: .newMessage,
            data: [
                "conversation_id": conversationId.uuidString,
                "sender_id": message.senderId.uuidString,
                "message_id": message.id.uuidString
            ]
        )
        
        scheduleLocalNotification(content)
    }
    
    // Urgent listing notifications
    func notifyUrgentListing(_ listing: Listing, userPostcode: String) {
        guard notificationSettings.urgentNotifications else { return }
        
        let content = NotificationContent(
            title: "🚨 URGENT Listing in Your Area!",
            body: "\(listing.title) - \(listing.category.rawValue) needs immediate attention",
            type: .urgentListing,
            data: [
                "listing_id": listing.id.uuidString,
                "user_id": listing.userId.uuidString,
                "postcode": userPostcode,
                "is_urgent": true
            ]
        )
        
        scheduleLocalNotification(content)
    }
    
    // MARK: - Notification Settings
    func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettings = settings
        // In a real app, you would save these settings to UserDefaults or a database
        UserDefaults.standard.set(settings.newListingNotifications, forKey: "newListingNotifications")
        UserDefaults.standard.set(settings.matchNotifications, forKey: "matchNotifications")
        UserDefaults.standard.set(settings.messageNotifications, forKey: "messageNotifications")
        UserDefaults.standard.set(settings.urgentNotifications, forKey: "urgentNotifications")
    }
    
    func loadNotificationSettings() {
        notificationSettings = NotificationSettings(
            newListingNotifications: UserDefaults.standard.bool(forKey: "newListingNotifications"),
            matchNotifications: UserDefaults.standard.bool(forKey: "matchNotifications"),
            messageNotifications: UserDefaults.standard.bool(forKey: "messageNotifications"),
            urgentNotifications: UserDefaults.standard.bool(forKey: "urgentNotifications")
        )
    }
    
    // MARK: - Clear Notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - Notification Settings Model
struct NotificationSettings: Equatable {
    var newListingNotifications: Bool = true
    var matchNotifications: Bool = true
    var messageNotifications: Bool = true
    var urgentNotifications: Bool = true
    
    init(
        newListingNotifications: Bool = true,
        matchNotifications: Bool = true,
        messageNotifications: Bool = true,
        urgentNotifications: Bool = true
    ) {
        self.newListingNotifications = newListingNotifications
        self.matchNotifications = matchNotifications
        self.messageNotifications = messageNotifications
        self.urgentNotifications = urgentNotifications
    }
}

// MARK: - Notification Extensions
extension NotificationManager {
    // Helper method to check if user should receive location-based notifications
    @MainActor
    func shouldNotifyForListing(_ listing: Listing, userPostcode: String, currentUserId: UUID?) -> Bool {
        // Check if listing is in same postcode area
        return listing.userId != currentUserId && // Don't notify for own listings
               isAuthorized &&
               notificationSettings.newListingNotifications
    }
    
    // Helper method to check if user should receive match notifications
    @MainActor
    func shouldNotifyForMatch(_ listing: Listing, matchedListing: Listing, currentUserId: UUID?) -> Bool {
        return listing.userId == currentUserId && // Only notify for user's own listings
               isAuthorized &&
               notificationSettings.matchNotifications
    }
}

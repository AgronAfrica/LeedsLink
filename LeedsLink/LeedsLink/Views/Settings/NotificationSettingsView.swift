import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Permission Status Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: notificationManager.isAuthorized ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notification Status")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(notificationManager.isAuthorized ? "Notifications are enabled" : "Notifications are disabled")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Notification Settings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notification Preferences")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        NotificationToggleRow(
                            title: "New Listings",
                            description: "Get notified when new listings are posted in your area",
                            icon: "house.fill",
                            isOn: $notificationManager.notificationSettings.newListingNotifications
                        )
                        
                        NotificationToggleRow(
                            title: "Matches",
                            description: "Get notified when you have new matches",
                            icon: "heart.fill",
                            isOn: $notificationManager.notificationSettings.matchNotifications
                        )
                        
                        NotificationToggleRow(
                            title: "Messages",
                            description: "Get notified when you receive new messages",
                            icon: "message.fill",
                            isOn: $notificationManager.notificationSettings.messageNotifications
                        )
                        
                        NotificationToggleRow(
                            title: "Urgent Listings",
                            description: "Get notified about urgent listings in your area",
                            icon: "exclamationmark.triangle.fill",
                            isOn: $notificationManager.notificationSettings.urgentNotifications
                        )
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Request Permission Button
                if !notificationManager.isAuthorized {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enable Notifications")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("To receive notifications, please enable them in your device settings.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                await notificationManager.requestNotificationPermission()
                            }
                        }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Request Permission")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.royalBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.screenBackground)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: notificationManager.notificationSettings) { _, newSettings in
            notificationManager.updateNotificationSettings(newSettings)
        }
        .alert("Notification Permission", isPresented: $showingPermissionAlert) {
            Button("OK") { }
        } message: {
            Text(permissionAlertMessage)
        }
    }
}

struct NotificationToggleRow: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.royalBlue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
}
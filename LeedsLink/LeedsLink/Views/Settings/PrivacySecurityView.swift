import SwiftUI

struct PrivacySecurityView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingDeleteDataAlert = false
    @State private var showingExportDataAlert = false
    @State private var showingClearCacheAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Data Management Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Data Management")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "Export My Data",
                            subtitle: "Download a copy of your data",
                            iconColor: .blue
                        ) {
                            showingExportDataAlert = true
                        }
                        
                        SettingsRow(
                            icon: "trash",
                            title: "Clear Cache",
                            subtitle: "Free up storage space",
                            iconColor: .orange
                        ) {
                            showingClearCacheAlert = true
                        }
                        
                        SettingsRow(
                            icon: "trash.fill",
                            title: "Delete All Data",
                            subtitle: "Permanently remove all your data",
                            iconColor: .red
                        ) {
                            showingDeleteDataAlert = true
                        }
                    }
                }
                
                // Privacy Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: "location",
                            title: "Location Services",
                            subtitle: "Control location-based features",
                            iconColor: .green
                        ) {
                            // Open system location settings
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        
                        SettingsRow(
                            icon: "camera",
                            title: "Camera Access",
                            subtitle: "Manage camera permissions",
                            iconColor: .purple
                        ) {
                            // Open system camera settings
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        
                        SettingsRow(
                            icon: "photo",
                            title: "Photo Library",
                            subtitle: "Manage photo access",
                            iconColor: .blue
                        ) {
                            // Open system photo settings
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                    }
                }
                
                // Account Security Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Security")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: "key",
                            title: "Change Password",
                            subtitle: "Update your account password",
                            iconColor: .blue
                        ) {
                            // Implement password change
                            print("Change password tapped")
                        }
                        
                        SettingsRow(
                            icon: "iphone",
                            title: "Two-Factor Authentication",
                            subtitle: "Add extra security to your account",
                            iconColor: .green
                        ) {
                            // Implement 2FA setup
                            print("2FA setup tapped")
                        }
                        
                        SettingsRow(
                            icon: "shield.checkered",
                            title: "Login Activity",
                            subtitle: "View recent account activity",
                            iconColor: .orange
                        ) {
                            // Show login activity
                            print("Login activity tapped")
                        }
                    }
                }
                
                // Privacy Policy & Terms
                VStack(alignment: .leading, spacing: 16) {
                    Text("Legal")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        SettingsRow(
                            icon: "doc.text",
                            title: "Privacy Policy",
                            subtitle: "How we protect your data",
                            iconColor: .blue
                        ) {
                            // Open privacy policy
                            if let url = URL(string: "https://leedslink.app/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        SettingsRow(
                            icon: "doc.plaintext",
                            title: "Terms of Service",
                            subtitle: "Our terms and conditions",
                            iconColor: .purple
                        ) {
                            // Open terms of service
                            if let url = URL(string: "https://leedslink.app/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.large)
        .alert("Export Data", isPresented: $showingExportDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Export") {
                exportUserData()
            }
        } message: {
            Text("This will create a downloadable file containing all your LeedsLink data including listings, messages, and profile information.")
        }
        .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAppCache()
            }
        } message: {
            Text("This will clear temporary files and cached data to free up storage space. Your personal data will not be affected.")
        }
        .alert("Delete All Data", isPresented: $showingDeleteDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllUserData()
            }
        } message: {
            Text("This action cannot be undone. All your listings, messages, and account data will be permanently deleted.")
        }
    }
    
    private func exportUserData() {
        // Implement data export functionality
        print("Exporting user data...")
        // In a real app, this would generate a JSON/CSV file with user data
    }
    
    private func clearAppCache() {
        // Implement cache clearing
        print("Clearing app cache...")
        // In a real app, this would clear temporary files, images, etc.
    }
    
    private func deleteAllUserData() {
        // Implement data deletion
        print("Deleting all user data...")
        // In a real app, this would remove all user data from the backend
        appState.clearAllData()
    }
}


#Preview {
    NavigationView {
        PrivacySecurityView()
            .environmentObject(AppState())
    }
}

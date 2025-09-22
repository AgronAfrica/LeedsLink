import SwiftUI

@main
struct LeedsLinkApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.showSplashScreen {
                SplashScreenView()
                    .environmentObject(appState)
            } else if appState.isOnboarded {
                MainTabView()
                    .environmentObject(appState)
            } else {
                EnhancedOnboardingView()
                    .environmentObject(appState)
            }
        }
    }
}

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showingTabEditor = false
    @State private var tabOrder: [Int] = []
    @State private var tabEnabled: [Bool] = []
    
    private let defaultTabOrder = [0, 1, 2, 3, 4]
    private let defaultTabEnabled = [true, true, true, true, true]
    
    var body: some View {
        getTabView()
            .onAppear {
                loadTabConfiguration()
            }
    }
    
    private func loadTabConfiguration() {
        // Load saved tab order and enabled state
        if let savedOrder = UserDefaults.standard.array(forKey: "tabOrder") as? [Int],
           let savedEnabled = UserDefaults.standard.array(forKey: "tabEnabled") as? [Bool] {
            tabOrder = savedOrder
            tabEnabled = savedEnabled
        } else {
            // Use defaults if no saved configuration
            tabOrder = defaultTabOrder
            tabEnabled = defaultTabEnabled
        }
    }
    
    private func getTabView() -> some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<tabOrder.count, id: \.self) { index in
                let tabId = tabOrder[index]
                let isEnabled = index < tabEnabled.count ? tabEnabled[index] : true
                
                if isEnabled {
                    getTabContent(for: tabId)
                        .tag(tabId)
                }
            }
        }
        .accentColor(.royalBlue)
        .onAppear {
            // Ensure selectedTab is valid after loading configuration
            if !tabOrder.contains(selectedTab) {
                selectedTab = tabOrder.first ?? 0
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private func getTabContent(for tabId: Int) -> some View {
        switch tabId {
        case 0:
            DiscoveryView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
        case 1:
            CreateListingView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
        case 2:
            CommunityBoardView()
                .tabItem {
                    Label("Community", systemImage: "person.3.fill")
                }
        case 3:
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
        case 4:
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
        default:
            EmptyView()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}

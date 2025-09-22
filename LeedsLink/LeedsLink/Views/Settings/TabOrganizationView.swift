import SwiftUI

struct TabOrganizationView: View {
    @State private var tabItems: [TabItem] = []
    @State private var showingSuccessAlert = false
    
    private let defaultTabItems = [
        TabItem(id: 0, title: "Home", icon: "house.fill", isEnabled: true),
        TabItem(id: 1, title: "Create", icon: "plus.circle.fill", isEnabled: true),
        TabItem(id: 2, title: "Community", icon: "person.3.fill", isEnabled: true),
        TabItem(id: 3, title: "Messages", icon: "message.fill", isEnabled: true),
        TabItem(id: 4, title: "Dashboard", icon: "chart.bar.fill", isEnabled: true),
        TabItem(id: 5, title: "Settings", icon: "gear", isEnabled: true)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Organize Your Tabs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Drag and drop to reorder your tabs. You can also enable or disable tabs you don't use.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("How to organize:")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(
                            icon: "hand.draw.fill",
                            text: "Long press and drag to reorder tabs"
                        )
                        
                        InstructionRow(
                            icon: "togglepower",
                            text: "Tap the toggle to enable/disable tabs"
                        )
                        
                        InstructionRow(
                            icon: "exclamationmark.triangle.fill",
                            text: "At least one tab must remain enabled"
                        )
                    }
                }
                .padding(16)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Tab List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Tabs")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(tabItems) { tabItem in
                            TabItemRow(
                                tabItem: tabItem,
                                onToggle: { isEnabled in
                                    toggleTab(tabItem.id, isEnabled: isEnabled)
                                }
                            )
                        }
                        .onMove(perform: moveTabs)
                    }
                }
                
                // Reset Button
                Button(action: resetToDefault) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset to Default Order")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.royalBlue)
                    .cornerRadius(12)
                }
            }
            .padding(20)
        }
        .navigationTitle("Organize Tabs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveTabOrder()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            loadTabConfiguration()
        }
        .alert("Tabs Updated", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your tab organization has been saved successfully!")
        }
    }
    
    private func moveTabs(from source: IndexSet, to destination: Int) {
        tabItems.move(fromOffsets: source, toOffset: destination)
    }
    
    private func toggleTab(_ tabId: Int, isEnabled: Bool) {
        // Don't allow disabling all tabs
        let enabledCount = tabItems.filter { $0.isEnabled }.count
        if !isEnabled && enabledCount <= 1 {
            return
        }
        
        if let index = tabItems.firstIndex(where: { $0.id == tabId }) {
            tabItems[index].isEnabled = isEnabled
        }
    }
    
    private func loadTabConfiguration() {
        // Load saved tab order and enabled state
        if let savedOrder = UserDefaults.standard.array(forKey: "tabOrder") as? [Int],
           let savedEnabled = UserDefaults.standard.array(forKey: "tabEnabled") as? [Bool] {
            
            // Reconstruct tabItems from saved data
            var loadedTabs: [TabItem] = []
            for (index, tabId) in savedOrder.enumerated() {
                let isEnabled = index < savedEnabled.count ? savedEnabled[index] : true
                if let defaultTab = defaultTabItems.first(where: { $0.id == tabId }) {
                    loadedTabs.append(TabItem(id: defaultTab.id, title: defaultTab.title, icon: defaultTab.icon, isEnabled: isEnabled))
                }
            }
            tabItems = loadedTabs
        } else {
            // Use defaults if no saved configuration
            tabItems = defaultTabItems
        }
    }
    
    private func resetToDefault() {
        tabItems = defaultTabItems
    }
    
    private func saveTabOrder() {
        // Save tab order and enabled state to UserDefaults
        UserDefaults.standard.set(tabItems.map { $0.id }, forKey: "tabOrder")
        UserDefaults.standard.set(tabItems.map { $0.isEnabled }, forKey: "tabEnabled")
        
        // Show success alert
        showingSuccessAlert = true
        
        print("Tab order saved: \(tabItems.map { "\($0.title): \($0.isEnabled)" })")
    }
}

struct TabItem: Identifiable, Equatable {
    let id: Int
    let title: String
    let icon: String
    var isEnabled: Bool
    
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct TabItemRow: View {
    let tabItem: TabItem
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Drag Handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.body)
            
            // Tab Icon
            ZStack {
                Circle()
                    .fill(tabItem.isEnabled ? Color.royalBlue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: tabItem.icon)
                    .foregroundColor(tabItem.isEnabled ? .royalBlue : .gray)
                    .font(.title3)
            }
            
            // Tab Title
            VStack(alignment: .leading, spacing: 4) {
                Text(tabItem.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(tabItem.isEnabled ? .primary : .secondary)
                
                Text(tabItem.isEnabled ? "Enabled" : "Disabled")
                    .font(.caption)
                    .foregroundColor(tabItem.isEnabled ? .green : .red)
            }
            
            Spacer()
            
            // Toggle Switch
            Toggle("", isOn: Binding(
                get: { tabItem.isEnabled },
                set: { onToggle($0) }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .royalBlue))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .opacity(tabItem.isEnabled ? 1.0 : 0.6)
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.body)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationView {
        TabOrganizationView()
    }
}

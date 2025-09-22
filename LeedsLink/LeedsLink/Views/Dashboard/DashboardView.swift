import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var showMatches = false
    @State private var scrollToRecentActivity = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                    // User Profile Card
                    if let user = appState.currentUser {
                        UserProfileCard(user: user)
                            .padding(.horizontal)
                    }
                    
                    // Local Partner Badge
                    if appState.hasLocalPartnerBadge {
                        LocalPartnerBadgeCard()
                            .padding(.horizontal)
                    }
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Listings Created",
                                value: "\(appState.listingsCreatedCount)",
                                icon: "doc.text.fill",
                                color: .royalBlue
                            )
                            
                            StatCard(
                                title: "Matches Found",
                                value: "\(appState.matchesFoundCount)",
                                icon: "person.2.fill",
                                color: .goldenYellow,
                                action: {
                                    showMatches = true
                                }
                            )
                        }
                        .padding(.horizontal)
                        
                    }
                    
                    // Recent Activity
                    RecentActivitySection()
                        .padding(.horizontal)
                        .id("recentActivity")
                    
                    // Quick Actions
                    QuickActionsSection()
                        .padding(.horizontal)
                }
                .padding(.vertical)
                }
                .background(Color.screenBackground)
                .onChange(of: appState.newlyCreatedListingId) { _, newListingId in
                    if newListingId != nil {
                        // Scroll to recent activity section when a new listing is created
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                proxy.scrollTo("recentActivity", anchor: .top)
                            }
                        }
                        
                        // Clear the newly created listing ID after scrolling
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            appState.newlyCreatedListingId = nil
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showMatches) {
                MatchesView()
                    .environmentObject(appState)
            }
        }
    }
    
}

struct UserProfileCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.royalBlue, Color.royalBlue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 70, height: 70)
                .overlay(
                    Text(user.name.prefix(1).uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let businessName = user.businessName {
                    Text(businessName)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                
                HStack {
                    Image(systemName: roleIcon(for: user.role))
                        .font(.caption)
                    Text(user.role.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.primary)
                
                // Rating display
                if let ratingSummary = user.ratingSummary, ratingSummary.totalRatings > 0 {
                    CompactRatingView(
                        rating: ratingSummary.averageRating,
                        reviewCount: ratingSummary.totalRatings,
                        size: 12
                    )
                } else {
                    HStack(spacing: 4) {
                        Text("No ratings yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Contact Information
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                        Text(user.address)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                        Text(user.phoneNumber)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                        Text(user.postcode)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .cardStyle()
    }
    
    private func roleIcon(for role: UserRole) -> String {
        switch role {
        case .supplier:
            return "shippingbox.fill"
        case .serviceProvider:
            return "wrench.and.screwdriver.fill"
        case .customer:
            return "person.fill"
        }
    }
}

struct LocalPartnerBadgeCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.goldenYellow)
            
            Text("Local Partner")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You've made 3+ connections in the Leeds community!")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.goldenYellow.opacity(0.1),
                    Color.goldenYellow.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.goldenYellow.opacity(0.5), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(title: String, value: String, icon: String, color: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
        .onTapGesture {
            action?()
        }
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject var appState: AppState
    
    var recentListings: [Listing] {
        appState.listings
            .filter { $0.userId == appState.currentUser?.id }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)
            .map { $0 }
    }
    
    private func isNewlyCreated(_ listing: Listing) -> Bool {
        return listing.id == appState.newlyCreatedListingId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
            
            if recentListings.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cardStyle()
            } else {
                VStack(spacing: 10) {
                    ForEach(recentListings, id: \.id) { listing in
                        HStack {
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(listing.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                                .foregroundColor(.primaryText)
                                            
                                            if isNewlyCreated(listing) {
                                                Text("NEW")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.green)
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        Text(listing.createdAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Delete button
                            Button(action: {
                                appState.deleteListing(listing.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(8)
                            }
                        }
                        .background(
                            isNewlyCreated(listing) ? 
                            Color.green.opacity(0.1) : 
                            Color.clear
                        )
                        .cornerRadius(8)
                        .animation(.easeInOut(duration: 0.3), value: isNewlyCreated(listing))
                        
                        if listing.id != recentListings.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .cardStyle()
            }
        }
    }
}

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack(spacing: 15) {
                NavigationLink(destination: CreateListingView(selectedTab: .constant(1))) {
                    QuickActionButton(
                        title: "Create Listing",
                        icon: "plus.circle.fill",
                        color: .royalBlue
                    )
                }
                
                NavigationLink(destination: DiscoveryView()) {
                    QuickActionButton(
                        title: "Browse",
                        icon: "magnifyingglass",
                        color: .goldenYellow
                    )
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .cardStyle()
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    if let user = appState.currentUser {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.name)
                                .foregroundColor(.secondaryText)
                        }
                        
                        if let businessName = user.businessName {
                            HStack {
                                Text("Business")
                                Spacer()
                                Text(businessName)
                                    .foregroundColor(.secondaryText)
                            }
                        }
                        
                        HStack {
                            Text("Role")
                            Spacer()
                            Text(user.role.rawValue)
                                .foregroundColor(.secondaryText)
                        }
                        
                        HStack {
                            Text("Address")
                            Spacer()
                            Text(user.address)
                                .foregroundColor(.secondaryText)
                        }
                        
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(user.phoneNumber)
                                .foregroundColor(.secondaryText)
                        }
                        
                        HStack {
                            Text("Postcode")
                            Spacer()
                            Text(user.postcode)
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
                
                Section("About") {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                    }
                }
                
                Section {
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    // In a real app, this would clear auth tokens
                    // For MVP, we'll just reset the onboarding state
                    appState.isOnboarded = false
                    appState.currentUser = nil
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

struct MatchesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var matches: [Listing] {
        appState.getMatchesForUser()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    if matches.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "person.2.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Matches Yet")
                                .font(.headline)
                            
                            Text("Create more listings to find potential matches")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 50)
                    } else {
                        ForEach(matches) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                ListingCard(listing: listing)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Your Matches")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}

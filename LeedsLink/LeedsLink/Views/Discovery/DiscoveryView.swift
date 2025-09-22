import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: ListingCategory?
    @State private var selectedRole: UserRole?
    @State private var showFilters = false
    
    var filteredListings: [Listing] {
        if selectedRole != nil || selectedCategory != nil {
            // Apply filters when user has selected specific role or category
            return appState.getFilteredListings(role: selectedRole, category: selectedCategory)
        } else {
            // Show all listings by default
            return appState.getAllListings()
        }
    }
    
    var hasActiveFilters: Bool {
        selectedRole != nil || selectedCategory != nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with search and filters
                VStack(spacing: 16) {
                    // Welcome section
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Discover")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Find local opportunities in Leeds")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Filter button
                        Button(action: { showFilters.toggle() }) {
                            ZStack {
                                Circle()
                                    .fill(hasActiveFilters ? Color.royalBlue : Color.gray.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(hasActiveFilters ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ListingCategory.allCases, id: \.self) { category in
                                CategoryPill(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if selectedCategory == category {
                                                selectedCategory = nil
                                            } else {
                                                selectedCategory = category
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.screenBackground, Color.screenBackground.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Listings
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if filteredListings.isEmpty {
                            EmptyStateView()
                                .padding(.top, 60)
                        } else {
                            ForEach(filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    ListingCard(listing: listing)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Extra padding for fixed tab bar
                }
                .background(Color.screenBackground)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilters) {
                FilterView(selectedRole: $selectedRole, selectedCategory: $selectedCategory)
            }
        }
    }
}

struct CategoryPill: View {
    let category: ListingCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.royalBlue : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(isSelected ? .white : .primary)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct ListingCard: View {
    let listing: Listing
    @EnvironmentObject var appState: AppState
    
    var isTopMatch: Bool {
        guard let currentUser = appState.currentUser else { return false }
        let userListings = appState.listings.filter { $0.userId == currentUser.id }
        
        for userListing in userListings {
            let matches = appState.getTopMatches(for: userListing)
            if matches.contains(where: { $0.id == listing.id }) {
                return true
            }
        }
        return false
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: 6) {
                // Type badge
                Text(listing.type == .offer ? "OFFER" : "REQUEST")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(listing.type == .offer ? Color.green : Color.royalBlue)
                    )
                    .fixedSize(horizontal: true, vertical: false)
                
                // Urgent badge
                if listing.isUrgent {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text("URGENT")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.red)
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
                
                // Top match badge
                if isTopMatch {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("TOP MATCH")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.goldenYellow)
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
            
            Spacer()
            
            // Category
            HStack(spacing: 6) {
                Image(systemName: categoryIcon(for: listing.category))
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium))
                Text(listing.category.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.bottom, 16)
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            // Price and availability row
            HStack {
                // Price
                if let price = listing.price {
                    HStack(spacing: 6) {
                        Image(systemName: "sterlingsign.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        Text(price)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.green)
                    }
                } else if let budget = listing.budget {
                    HStack(spacing: 6) {
                        Image(systemName: "sterlingsign.circle.fill")
                            .foregroundColor(.primary)
                            .font(.system(size: 14))
                        Text(budget)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Date
                Text(listing.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Availability and location row
            HStack {
                // Availability
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text(listing.availability)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                // Location
                if let address = listing.address, let postcode = listing.postcode {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 12))
                        Text("\(address), \(postcode)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
    
    private var tagsSection: some View {
        Group {
            if !listing.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(listing.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.royalBlue.opacity(0.1))
                                )
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .padding(.bottom, 12)
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.cardBackground)
    }
    
    private var strokeColor: Color {
        if listing.isUrgent {
            return Color.red.opacity(0.3)
        } else if isTopMatch {
            return Color.goldenYellow.opacity(0.3)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private var shadowColor: Color {
        if listing.isUrgent {
            return Color.red.opacity(0.08)
        } else if isTopMatch {
            return Color.goldenYellow.opacity(0.08)
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            
            // Title
            Text(listing.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 8)
            
            // Description
            Text(listing.description)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 12)
            
            tagsSection
            
            footerSection
        }
        .padding(20)
        .background(cardBackground)
        .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
    }
    
    private func categoryIcon(for category: ListingCategory) -> String {
        switch category {
        case .food: return "fork.knife"
        case .construction: return "hammer.fill"
        case .professional: return "briefcase.fill"
        case .retail: return "bag.fill"
        case .health: return "heart.fill"
        case .technology: return "laptopcomputer"
        case .hospitality: return "bed.double.fill"
        case .education: return "book.fill"
        case .transport: return "car.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                Text("No listings found")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Try adjusting your filters or check back later for new opportunities")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(40)
    }
}

struct FilterView: View {
    @Binding var selectedRole: UserRole?
    @Binding var selectedCategory: ListingCategory?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section("Role Filter") {
                    ForEach([nil] + UserRole.allCases.map { $0 as UserRole? }, id: \.self) { role in
                        HStack {
                            Text(role?.rawValue ?? "All Roles")
                            Spacer()
                            if selectedRole == role {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRole = role
                        }
                    }
                }
                
                Section("Category Filter") {
                    ForEach([nil] + ListingCategory.allCases.map { $0 as ListingCategory? }, id: \.self) { category in
                        HStack {
                            Text(category?.rawValue ?? "All Categories")
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = category
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        selectedRole = nil
                        selectedCategory = nil
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    DiscoveryView()
        .environmentObject(AppState())
}
import SwiftUI

struct CommunityBoardView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeFilter = TimeFilter.all
    
    enum TimeFilter: String, CaseIterable {
        case today = "Today"
        case thisWeek = "This Week"
        case all = "All Time"
    }
    
    var filteredActiveListings: [Listing] {
        let calendar = Calendar.current
        let now = Date()
        
        return appState.activeListings.filter { listing in
            switch selectedTimeFilter {
            case .today:
                return calendar.isDateInToday(listing.createdAt)
            case .thisWeek:
                return calendar.isDate(listing.createdAt, equalTo: now, toGranularity: .weekOfYear)
            case .all:
                return true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with description
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Community")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Latest opportunities from Leeds community")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Time filter
                    Picker("Time Filter", selection: $selectedTimeFilter) {
                        ForEach(TimeFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.screenBackground, Color.screenBackground.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Active listings list
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if filteredActiveListings.isEmpty {
                            VStack(spacing: 24) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 40, weight: .light))
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("No active listings")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Check back later for community opportunities")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(filteredActiveListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    ActiveListingCard(listing: listing)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Community Stats
                        CommunityStatsCard()
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Extra padding for fixed tab bar
                }
                .background(Color.screenBackground)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ActiveListingCard: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with type badges and date
            HStack {
                HStack(spacing: 8) {
                    // Type badge
                    Text(listing.type == .offer ? "OFFER" : "REQUEST")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(listing.type == .offer ? Color.green : Color.royalBlue)
                        )
                        .lineLimit(1)
                    
                    // Urgent badge
                    if listing.isUrgent {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text("URGENT")
                                .font(.system(size: 10, weight: .bold))
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                    }
                }
                
                Spacer()
                
                // Category and date
                VStack(alignment: .trailing, spacing: 4) {
                    Text(listing.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: categoryIcon(for: listing.category))
                            .foregroundColor(.primary)
                            .font(.system(size: 14, weight: .medium))
                        Text(listing.category.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.bottom, 16)
            
            // Title
            Text(listing.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Description with better visibility
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text(listing.description)
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            
            // Tags with better visibility
            if !listing.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(listing.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.royalBlue.opacity(0.1))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
            
            // Footer with price, availability, and location
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if listing.type == .request {
                            if let budget = listing.budget {
                                HStack(spacing: 6) {
                                    Image(systemName: "sterlingsign.circle.fill")
                                        .foregroundColor(.primary)
                                        .font(.subheadline)
                                    Text(budget)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                        } else {
                            if let price = listing.price {
                                HStack(spacing: 6) {
                                    Image(systemName: "sterlingsign.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                    Text(price)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(listing.availability)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                }
                
                // Location information
                if let address = listing.address, let postcode = listing.postcode {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text("\(address), \(postcode)")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardBackground)
        )
        .shadow(
            color: listing.isUrgent ? Color.red.opacity(0.08) : Color.black.opacity(0.05), 
            radius: 12, x: 0, y: 6
        )
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

struct CommunityStatsCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Community Impact")
                .font(.headline)
            
            HStack(spacing: 30) {
                StatItem(
                    value: "\(appState.urgentRequests.count)",
                    label: "Urgent Needs",
                    icon: "exclamationmark.circle.fill",
                    color: .red
                )
                
                StatItem(
                    value: "\(appState.activeListings.count)",
                    label: "Latest Listings",
                    icon: "doc.text.fill",
                    color: .royalBlue
                )
                
                StatItem(
                    value: "\(appState.matchesFoundCount)",
                    label: "Connections",
                    icon: "person.2.fill",
                    color: .goldenYellow
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    CommunityBoardView()
        .environmentObject(AppState())
}


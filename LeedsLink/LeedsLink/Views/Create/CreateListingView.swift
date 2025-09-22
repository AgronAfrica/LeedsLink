import SwiftUI

struct CreateListingView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: Int
    @State private var listingType: ListingType = .offer
    @State private var title = ""
    @State private var category: ListingCategory = .other
    @State private var tags = ""
    @State private var budget = ""
    @State private var price = ""
    @State private var availability = ""
    @State private var description = ""
    @State private var isUrgent = false
    @State private var address = ""
    @State private var postcode = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        Form {
                Section("What would you like to do?") {
                    Picker("Type", selection: $listingType) {
                        Text("Offer a Product/Service").tag(ListingType.offer)
                        Text("Request a Product/Service").tag(ListingType.request)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Basic Information") {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Category", selection: $category) {
                        ForEach(ListingCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Tags (comma separated)")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        TextField("e.g. organic, local, fresh", text: $tags)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section("Pricing & Availability") {
                    if listingType == .offer {
                        TextField("Price", text: $price)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        TextField("Budget", text: $budget)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Availability", text: $availability)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                Section("Location") {
                    TextField("Address (e.g., Headingley, Leeds)", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Postcode (e.g., LS6 3AA)", text: $postcode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Toggle("Mark as Urgent", isOn: $isUrgent)
                        .tint(.royalBlue)
                }
                
                Section {
                    Button(action: createListing) {
                        HStack {
                            Spacer()
                            Text("Create Listing")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.royalBlue)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Create Listing")
            .navigationBarTitleDisplayMode(.large)
            .alert("Success!", isPresented: $showingSuccessAlert) {
                Button("Go to Dashboard") {
                    selectedTab = 4 // Navigate to Dashboard tab
                }
                Button("Create Another") {
                    resetForm()
                }
            } message: {
                Text("Your listing has been created successfully!")
            }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !availability.isEmpty &&
        !description.isEmpty &&
        (listingType == .offer ? !price.isEmpty : !budget.isEmpty)
    }
    
    private func createListing() {
        guard let currentUser = appState.currentUser else { return }
        
        let tagArray = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let newListing = Listing(
            userId: currentUser.id,
            title: title,
            category: category,
            tags: tagArray,
            budget: listingType == .request ? budget : nil,
            price: listingType == .offer ? price : nil,
            availability: availability,
            description: description,
            type: listingType,
            isUrgent: isUrgent,
            address: address.isEmpty ? nil : address,
            postcode: postcode.isEmpty ? nil : postcode
        )
        
        appState.createListing(newListing)
        showingSuccessAlert = true
    }
    
    private func resetForm() {
        title = ""
        category = .other
        tags = ""
        budget = ""
        price = ""
        availability = ""
        description = ""
        isUrgent = false
        address = ""
        postcode = ""
        listingType = .offer
    }
}

#Preview {
    CreateListingView(selectedTab: .constant(1))
        .environmentObject(AppState())
}

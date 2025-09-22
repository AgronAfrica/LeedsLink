import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var selectedRole: UserRole?
    @State private var name = ""
    @State private var businessName = ""
    @State private var address = ""
    @State private var phoneNumber = ""
    @State private var postcode = ""
    @State private var description = ""
    
    var body: some View {
        VStack {
            // Progress indicator
            ProgressView(value: Double(currentStep + 1), total: 3)
                .tint(.royalBlue)
                .padding()
            
            TabView(selection: $currentStep) {
                // Step 1: Welcome and Role Selection
                WelcomeView(selectedRole: $selectedRole, currentStep: $currentStep)
                    .tag(0)
                
                // Step 2: Profile Information
                ProfileFormView(
                    selectedRole: selectedRole ?? .customer,
                    name: $name,
                    businessName: $businessName,
                    address: $address,
                    phoneNumber: $phoneNumber,
                    postcode: $postcode,
                    description: $description,
                    currentStep: $currentStep
                )
                .tag(1)
                
                // Step 3: Complete
                OnboardingCompleteView(
                    name: name,
                    onComplete: completeOnboarding
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
        }
        .background(Color.screenBackground)
    }
    
    private func completeOnboarding() {
        guard let selectedRole = selectedRole else { return }
        
        let user = User(
            name: name,
            businessName: businessName.isEmpty ? nil : businessName,
            role: selectedRole,
            address: address,
            phoneNumber: phoneNumber,
            postcode: postcode,
            description: description
        )
        
        appState.createUser(user)
    }
}

struct WelcomeView: View {
    @Binding var selectedRole: UserRole?
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "building.2.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.royalBlue)
            
            VStack(spacing: 10) {
                Text("Welcome to LeedsLink")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connecting Leeds businesses and community")
                    .font(.title3)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                Text("I am a...")
                    .font(.headline)
                
                ForEach(UserRole.allCases, id: \.self) { role in
                    Button(action: {
                        selectedRole = role
                        withAnimation {
                            currentStep = 1
                        }
                    }) {
                        HStack {
                            Image(systemName: roleIcon(for: role))
                                .frame(width: 30)
                            Text(role.rawValue)
                            Spacer()
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedRole == role ? Color.royalBlue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
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

struct ProfileFormView: View {
    let selectedRole: UserRole
    @Binding var name: String
    @Binding var businessName: String
    @Binding var address: String
    @Binding var phoneNumber: String
    @Binding var postcode: String
    @Binding var description: String
    @Binding var currentStep: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tell us about yourself")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Name")
                        .font(.headline)
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Business name (not for customers)
                if selectedRole != .customer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Business Name")
                            .font(.headline)
                        TextField("Enter your business name", text: $businessName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Address")
                        .font(.headline)
                    TextField("e.g., 12 Victoria Road, Headingley", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.fullStreetAddress)
                }
                
                // Phone Number
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.headline)
                    TextField("e.g., 0113 234 5678", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                // Postcode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Postcode")
                        .font(.headline)
                    TextField("e.g., LS6 3AA", text: $postcode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.postalCode)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About \(selectedRole == .customer ? "You" : "Your Business")")
                        .font(.headline)
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Spacer(minLength: 40)
                
                HStack {
                    Button("Back") {
                        withAnimation {
                            currentStep = 0
                        }
                    }
                    .foregroundColor(.royalBlue)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            currentStep = 2
                        }
                    }) {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.royalBlue)
                            .cornerRadius(25)
                    }
                    .disabled(!isFormValid)
                }
            }
            .padding()
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !address.isEmpty && !phoneNumber.isEmpty && !postcode.isEmpty && !description.isEmpty &&
        (selectedRole == .customer || !businessName.isEmpty)
    }
}

struct OnboardingCompleteView: View {
    let name: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.goldenYellow)
            
            VStack(spacing: 10) {
                Text("Welcome, \(name)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You're all set to start connecting with the Leeds community")
                    .font(.title3)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onComplete) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .background(Color.royalBlue)
                    .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}

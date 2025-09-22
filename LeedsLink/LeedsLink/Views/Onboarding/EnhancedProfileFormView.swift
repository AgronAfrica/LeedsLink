import SwiftUI

struct EnhancedProfileFormView: View {
    let selectedRole: UserRole
    @Binding var name: String
    @Binding var businessName: String
    @Binding var address: String
    @Binding var phoneNumber: String
    @Binding var postcode: String
    @Binding var description: String
    let onBack: () -> Void
    let onContinue: () -> Void
    
    @State private var animateFields = false
    @State private var focusedField: FieldType? = nil
    @State private var keyboardHeight: CGFloat = 0
    
    enum FieldType {
        case name, businessName, address, phoneNumber, postcode, description
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.royalBlue.opacity(0.9),
                    Color.royalBlue.opacity(0.7),
                    Color.goldenYellow.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Tell us about yourself")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Help us create your personalized profile")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 30)
                    
                    // Form fields
                    VStack(spacing: 24) {
                        // Name field
                        AnimatedFormField(
                            title: "Your Name",
                            placeholder: "Enter your name",
                            text: $name,
                            fieldType: .name,
                            isFocused: focusedField == .name,
                            onFocusChange: { focused in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    focusedField = focused ? .name : nil
                                }
                                if focused {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            proxy.scrollTo("name", anchor: .center)
                                        }
                                    }
                                }
                            }
                        )
                        .id("name")
                        .offset(x: animateFields ? 0 : -50)
                        .opacity(animateFields ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(0.1),
                            value: animateFields
                        )
                        
                        // Business name (not for customers)
                        if selectedRole != .customer {
                            AnimatedFormField(
                                title: "Business Name",
                                placeholder: "Enter your business name",
                                text: $businessName,
                                fieldType: .businessName,
                                isFocused: focusedField == .businessName,
                                onFocusChange: { focused in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        focusedField = focused ? .businessName : nil
                                    }
                                    if focused {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                proxy.scrollTo("businessName", anchor: .center)
                                            }
                                        }
                                    }
                                }
                            )
                            .id("businessName")
                            .offset(x: animateFields ? 0 : -50)
                            .opacity(animateFields ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(0.2),
                                value: animateFields
                            )
                        }
                        
                        // Address field
                        AnimatedFormField(
                            title: "Address",
                            placeholder: "e.g., 12 Victoria Road, Headingley",
                            text: $address,
                            fieldType: .address,
                            isFocused: focusedField == .address,
                            onFocusChange: { focused in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    focusedField = focused ? .address : nil
                                }
                                if focused {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            proxy.scrollTo("address", anchor: .center)
                                        }
                                    }
                                }
                            }
                        )
                        .id("address")
                        .offset(x: animateFields ? 0 : -50)
                        .opacity(animateFields ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(0.3),
                            value: animateFields
                        )
                        
                        // Phone and Postcode in a row
                        HStack(spacing: 16) {
                            AnimatedFormField(
                                title: "Phone",
                                placeholder: "0113 234 5678",
                                text: $phoneNumber,
                                fieldType: .phoneNumber,
                                isFocused: focusedField == .phoneNumber,
                                onFocusChange: { focused in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        focusedField = focused ? .phoneNumber : nil
                                    }
                                    if focused {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                proxy.scrollTo("phonePostcode", anchor: .center)
                                            }
                                        }
                                    }
                                }
                            )
                            .keyboardType(.phonePad)
                            
                            AnimatedFormField(
                                title: "Postcode",
                                placeholder: "LS6 3AA",
                                text: $postcode,
                                fieldType: .postcode,
                                isFocused: focusedField == .postcode,
                                onFocusChange: { focused in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        focusedField = focused ? .postcode : nil
                                    }
                                    if focused {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                proxy.scrollTo("phonePostcode", anchor: .center)
                                            }
                                        }
                                    }
                                }
                            )
                        }
                        .id("phonePostcode")
                        .offset(x: animateFields ? 0 : -50)
                        .opacity(animateFields ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(0.4),
                            value: animateFields
                        )
                        
                        // Description field
                        AnimatedTextEditorField(
                            title: "About \(selectedRole == .customer ? "You" : "Your Business")",
                            placeholder: "Tell us about yourself or your business...",
                            text: $description,
                            isFocused: focusedField == .description,
                            onFocusChange: { focused in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    focusedField = focused ? .description : nil
                                }
                                if focused {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            proxy.scrollTo("description", anchor: .top)
                                        }
                                    }
                                }
                            }
                        )
                        .id("description")
                        .offset(x: animateFields ? 0 : -50)
                        .opacity(animateFields ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(0.5),
                            value: animateFields
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    
                    // Navigation buttons with glass UI
                    HStack(spacing: 20) {
                        Button("Back") {
                            onBack()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.1))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        Spacer()
                        
                        Button(action: onContinue) {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white.opacity(0.2))
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(.white.opacity(0.4), lineWidth: 1.5)
                                    )
                                    .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        .scaleEffect(isFormValid ? 1.0 : 0.95)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFormValid)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    
                    // Extra padding for keyboard
                    Spacer()
                        .frame(height: keyboardHeight > 0 ? keyboardHeight + 20 : 0)
                }
                .padding(.bottom, keyboardHeight)
            }
        }
        }
        .onAppear {
            animateFields = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.cgRectValue.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !address.isEmpty && !phoneNumber.isEmpty && !postcode.isEmpty && !description.isEmpty &&
        (selectedRole == .customer || !businessName.isEmpty)
    }
}

// Animated Form Field Component
struct AnimatedFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let fieldType: EnhancedProfileFormView.FieldType
    let isFocused: Bool
    let onFocusChange: (Bool) -> Void
    
    var keyboardType: UIKeyboardType = .default
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Animated title
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .scaleEffect(isFocused ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            
            // Enhanced text field with glass UI
            ZStack {
                // Glass background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.2))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isFocused ? 
                                LinearGradient(colors: [.white, .white.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isFocused ? 2 : 0
                            )
                    )
                    .shadow(
                        color: isFocused ? .white.opacity(0.3) : .clear,
                        radius: isFocused ? 8 : 0,
                        x: 0,
                        y: isFocused ? 4 : 0
                    )
                    .scaleEffect(isFocused ? 1.02 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFocused)
                
                // Text field
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .accentColor(.royalBlue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onFocusChange(true)
                            isAnimating = true
                        }
                    }
                    .keyboardType(keyboardType)
            }
        }
        .onChange(of: isFocused) { _, focused in
            if !focused {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isAnimating = false
                }
            }
        }
    }
}

// Animated Text Editor Field Component
struct AnimatedTextEditorField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isFocused: Bool
    let onFocusChange: (Bool) -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Animated title
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .scaleEffect(isFocused ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            
            // Enhanced text editor with glass UI
            ZStack(alignment: .topLeading) {
                // Glass background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.2))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isFocused ? 
                                LinearGradient(colors: [.white, .white.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isFocused ? 2 : 0
                            )
                    )
                    .shadow(
                        color: isFocused ? .white.opacity(0.3) : .clear,
                        radius: isFocused ? 8 : 0,
                        x: 0,
                        y: isFocused ? 4 : 0
                    )
                    .scaleEffect(isFocused ? 1.02 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFocused)
                
                // Placeholder text
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
                
                // Text editor
                TextEditor(text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .accentColor(.royalBlue)
                    .background(Color.clear)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(minHeight: 120)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onFocusChange(true)
                            isAnimating = true
                        }
                    }
            }
        }
        .onChange(of: isFocused) { _, focused in
            if !focused {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isAnimating = false
                }
            }
        }
    }
}

#Preview {
    EnhancedProfileFormView(
        selectedRole: .customer,
        name: .constant(""),
        businessName: .constant(""),
        address: .constant(""),
        phoneNumber: .constant(""),
        postcode: .constant(""),
        description: .constant(""),
        onBack: {},
        onContinue: {}
    )
}

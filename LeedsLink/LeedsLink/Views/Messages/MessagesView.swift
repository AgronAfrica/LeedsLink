import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Messages")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Connect with local businesses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.screenBackground, Color.screenBackground.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Content
                if appState.conversations.isEmpty {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "message.circle")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No conversations yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Start connecting with other businesses by browsing listings")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        
                        NavigationLink(destination: DiscoveryView()) {
                            Text("Browse Listings")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(Color.royalBlue)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(appState.conversations) { conversation in
                                NavigationLink(destination: ConversationView(conversation: conversation)) {
                                    ConversationRow(conversation: conversation)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if conversation.id != appState.conversations.last?.id {
                                    Divider()
                                        .padding(.leading, 75)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color.screenBackground)
            .navigationBarHidden(true)
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    @EnvironmentObject var appState: AppState
    
    var otherParticipantName: String {
        guard let currentUser = appState.currentUser else { return "Unknown" }
        return conversation.participantNames.first { name in
            name != "You" && name != currentUser.name
        } ?? "Unknown"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.royalBlue.opacity(0.2), Color.royalBlue.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text(otherParticipantName.prefix(1).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.royalBlue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(otherParticipantName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}

struct ConversationView: View {
    let conversation: Conversation
    @EnvironmentObject var appState: AppState
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showMessageSentSplash = false
    @State private var messageSentScale: CGFloat = 0.5
    @State private var messageSentOpacity: Double = 0.0
    @State private var sendButtonPressed = false
    
    var otherParticipantName: String {
        guard let currentUser = appState.currentUser else { return "Unknown" }
        return conversation.participantNames.first { name in
            name != "You" && name != currentUser.name
        } ?? "Unknown"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(conversation.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == appState.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                }
                .background(Color.screenBackground)
            }
            
            // Input bar
            HStack(spacing: 10) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Button press animation
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        sendButtonPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            sendButtonPressed = false
                        }
                    }
                    
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35)
                        .background(
                            Circle()
                                .fill(messageText.isEmpty ? Color.gray : Color.royalBlue)
                        )
                        .scaleEffect(sendButtonPressed ? 0.9 : (messageText.isEmpty ? 0.9 : 1.0))
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: sendButtonPressed)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: messageText.isEmpty)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.cardBackground)
        }
        .navigationTitle(otherParticipantName)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            // Message Sent Splash Animation
            ZStack {
                if showMessageSentSplash {
                    // Background blur
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    // Message sent card
                    VStack(spacing: 16) {
                        // Success icon with animation
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .scaleEffect(messageSentScale)
                            
                            Circle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                                .scaleEffect(messageSentScale)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(messageSentScale)
                        }
                        
                        // Message text
                        VStack(spacing: 8) {
                            Text("Message Sent!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your message has been delivered")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .scaleEffect(messageSentScale)
                    .opacity(messageSentOpacity)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showMessageSentSplash)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: messageSentScale)
            .animation(.easeInOut(duration: 0.3), value: messageSentOpacity)
        )
    }
    
    private func sendMessage() {
        appState.sendMessage(in: conversation.id, content: messageText)
        messageText = ""
        scrollToBottom()
        
        // Trigger message sent splash animation
        showMessageSentSplash = true
        messageSentScale = 0.5
        messageSentOpacity = 0.0
        
        // Animate the splash
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            messageSentScale = 1.0
            messageSentOpacity = 1.0
        }
        
        // Hide the splash after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                messageSentOpacity = 0.0
                messageSentScale = 0.8
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showMessageSentSplash = false
            }
        }
    }
    
    private func scrollToBottom() {
        if let lastMessage = conversation.messages.last {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Text(message.content)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(isCurrentUser ? Color.royalBlue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .primaryText)
                    .cornerRadius(20)
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
            }
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser { Spacer() }
        }
    }
}

#Preview {
    MessagesView()
        .environmentObject(AppState())
}

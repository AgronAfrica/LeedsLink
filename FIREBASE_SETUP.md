# Firebase Setup Guide for LeedsLink

## 🚀 Quick Setup

### 1. Install CocoaPods (if not already installed)
```bash
sudo gem install cocoapods
```

### 2. Install Firebase Dependencies
```bash
cd /Users/nmop/Documents/LeedsLink/LeedsLink
pod install
```

### 3. Get Real Firebase Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **LeedsLink** (ID: leedslink-79a0e)
3. Click on the iOS app icon
4. Download the real `GoogleService-Info.plist` file
5. Replace the placeholder file in your Xcode project

### 4. Enable Firebase Services
In the Firebase Console:

#### Authentication
- Go to Authentication > Sign-in method
- Enable **Email/Password** authentication
- Enable **Anonymous** authentication (optional)

#### Firestore Database
- Go to Firestore Database
- Create database in **production mode**
- Set up security rules (see below)

#### Storage
- Go to Storage
- Create storage bucket
- Set up security rules (see below)

## 🔒 Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read listings, only authenticated users can create
    match /listings/{listingId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.auth.uid == resource.data.userId);
    }
    
    // Conversations are private to participants
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
    }
    
    // Messages are private to conversation participants
    match /conversations/{conversationId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload their own profile images
    match /profile-images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can upload listing images
    match /listing-images/{listingId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 App Configuration

### Bundle Identifier
Make sure your app's bundle identifier matches what you registered in Firebase:
- **Bundle ID**: `com.leedslink.app`

### Project Structure
```
LeedsLink/
├── GoogleService-Info.plist  # Firebase configuration
├── Podfile                   # CocoaPods dependencies
├── Pods/                     # Installed pods
└── LeedsLink.xcworkspace     # Use this instead of .xcodeproj
```

## 🔧 Development Workflow

### 1. Open the Workspace
Always open `LeedsLink.xcworkspace` instead of `LeedsLink.xcodeproj` when using CocoaPods.

### 2. Firebase Features Enabled
- ✅ **Authentication**: Email/password signup and login
- ✅ **Firestore**: Real-time database for listings and messages
- ✅ **Storage**: File uploads for profile images
- ✅ **Analytics**: User behavior tracking

### 3. Real-time Features
- **Listings**: All users see new listings instantly
- **Messages**: Real-time chat between users
- **Notifications**: Push notifications for new matches
- **Cross-device sync**: Works on iPhone, iPad, and simulator

## 🚨 Important Notes

### API Keys
The current `GoogleService-Info.plist` contains placeholder values. You **MUST** replace it with the real file from Firebase Console.

### Testing
- Test on real devices for full Firebase functionality
- Simulator works but may have limited push notification support
- Use Firebase Console to monitor data and debug issues

### Offline Support
- Firebase automatically handles offline/online transitions
- Data syncs when connection is restored
- Local storage provides fallback for critical data

## 🎯 Next Steps

1. **Replace GoogleService-Info.plist** with real Firebase config
2. **Run `pod install`** to install dependencies
3. **Open LeedsLink.xcworkspace** in Xcode
4. **Build and test** the app
5. **Check Firebase Console** for data and analytics

## 📞 Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Verify bundle identifier matches
3. Ensure all dependencies are installed
4. Check network connectivity

---

**Firebase Project Details:**
- **Project Name**: LeedsLink
- **Project ID**: leedslink-79a0e
- **Project Number**: 107186562090
- **Email**: leedslinkapp@gmail.com

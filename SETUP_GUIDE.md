# SOAR Mobile App - Setup Guide

This guide will help you set up and run the SOAR wellness mobile app.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Firebase CLI**
- **Node.js** (18 or higher, for Cloud Functions)
- **Git**

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd Soar
```

## Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

## Step 3: Firebase Setup

### 3.1 Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Follow the setup wizard

### 3.2 Enable Firebase Services

In your Firebase Console, enable the following:

- **Authentication**
  - Email/Password
  - Google Sign-In
  - Apple Sign-In (for iOS)
  
- **Firestore Database**
  - Start in production mode
  - Set up security rules (provided below)

- **Cloud Storage**
  - Enable default bucket

- **Cloud Messaging**
  - Enable FCM

- **Cloud Functions**
  - Upgrade to Blaze plan (pay-as-you-go)

### 3.3 Add Firebase to Your Apps

#### Android Setup

1. In Firebase Console, add an Android app
2. Package name: `com.soar.wellness`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### iOS Setup

1. In Firebase Console, add an iOS app
2. Bundle ID: `com.soar.wellness`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 3.4 Configure Firebase Options

Run the FlutterFire CLI to generate Firebase configuration:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

This will update `lib/firebase_options.dart` with your actual Firebase project credentials.

## Step 4: API Keys Configuration

### 4.1 Create API Config File

Create or update `lib/config/api_config.dart` with your API keys:

```dart
class ApiConfig {
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY';
  static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY';
  static const String yelpApiKey = 'YOUR_YELP_API_KEY';
  static const String googleBooksApiKey = 'YOUR_GOOGLE_BOOKS_API_KEY';
  // ... other keys
}
```

### 4.2 Get API Keys

#### TMDB (Movies)
- Sign up at https://www.themoviedb.org/
- Go to Settings > API
- Request an API key

#### YouTube Data API
- Go to https://console.cloud.google.com/
- Create a new project
- Enable YouTube Data API v3
- Create credentials (API key)

#### Yelp Fusion API
- Sign up at https://www.yelp.com/developers
- Create an app
- Get your API key

#### Google Books API
- Go to https://console.cloud.google.com/
- Enable Google Books API
- Create credentials (API key)

## Step 5: Deploy Firebase Cloud Functions

### 5.1 Install Dependencies

```bash
cd functions
npm install
```

### 5.2 Set API Keys in Firebase Config

```bash
firebase functions:config:set \
  tmdb.key="YOUR_TMDB_KEY" \
  youtube.key="YOUR_YOUTUBE_KEY" \
  yelp.key="YOUR_YELP_KEY"
```

### 5.3 Deploy Functions

```bash
firebase deploy --only functions
```

## Step 6: Firestore Security Rules

Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Mood entries subcollection
      match /moodEntries/{entryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Podcasts subcollection
      match /podcasts/{podcastId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Community groups
    match /communityGroups/{groupId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid in resource.data.memberIds;
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/communityGroups/$(groupId)).data.memberIds;
        allow create: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/communityGroups/$(groupId)).data.memberIds;
      }
    }
  }
}
```

## Step 7: Platform-Specific Setup

### iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set your development team
3. Update bundle identifier if needed
4. For Screen Time API:
   - Add FamilyControls capability
   - Request Screen Time entitlement from Apple

### Android Setup

1. Update `android/app/build.gradle` with your signing config (for release)
2. For app blocking feature:
   - Users will need to grant Accessibility permission
   - Users will need to grant Usage Access permission

## Step 8: Run the App

### iOS

```bash
flutter run -d ios
```

### Android

```bash
flutter run -d android
```

### Web (optional)

```bash
flutter run -d chrome
```

## Step 9: Testing

### Run Tests

```bash
flutter test
```

### Firebase Emulator (for local testing)

```bash
firebase emulators:start
```

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Rebuild

2. **Firebase Connection Issues**
   - Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
   - Check Firebase configuration

3. **API Errors**
   - Verify API keys are correct
   - Check API quotas and limits

4. **Permission Issues (iOS)**
   - Make sure all required capabilities are enabled
   - Check Info.plist for usage descriptions

5. **Permission Issues (Android)**
   - Ensure all permissions are in AndroidManifest.xml
   - Test on real device (some features don't work on emulator)

## Production Deployment

### iOS App Store

1. Update version in `pubspec.yaml`
2. Build release:
   ```bash
   flutter build ios --release
   ```
3. Archive in Xcode
4. Upload to App Store Connect

### Google Play Store

1. Update version in `pubspec.yaml`
2. Build release:
   ```bash
   flutter build appbundle --release
   ```
3. Upload to Google Play Console

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [TMDB API Documentation](https://developers.themoviedb.org/3)
- [YouTube API Documentation](https://developers.google.com/youtube/v3)
- [Yelp API Documentation](https://www.yelp.com/developers/documentation/v3)

## Support

For issues or questions, please contact: support@soar-app.com

## License

[Add your license information here]


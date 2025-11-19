# SOAR - Your Personal Wellness Companion

> "What if your phone could sense you're overwhelmed… before you even feel it?"

SOAR is a comprehensive cross-platform mobile app focused on emotional wellness and productivity. Built with Flutter and powered by Firebase, SOAR combines daily mood tracking, AI-driven personalized recommendations, voice podcasts, peer support communities, and intelligent app blocking to help users maintain mental wellness.

## ✨ Features

### 🎭 Daily Mood Check-ins
- Track your emotional state with an intuitive mood selector
- Optional journaling with sentiment analysis
- Beautiful mood history visualizations and statistics
- Streak tracking to encourage consistency

### 📱 Focus Lock (App Blocking)
- **iOS**: Screen Time API integration for seamless app blocking
- **Android**: Accessibility Service for focus enforcement
- Lock distracting apps until daily check-in is complete
- Customizable blocked apps list
- Scheduled daily reminders

### 🎯 Personalized Recommendations
Curated content based on your mood and preferences:
- **Movies** (TMDB API) - Genre-matched to your mood
- **Books** (Google Books API) - Wellness and self-help suggestions
- **Videos** (YouTube Data API) - Guided meditations and motivation
- **Local Therapists** (Yelp API) - Highly-rated professionals nearby
- **Music Playlists** (Apple Music) - Mood-enhancing tracks
- **Affirmations** - Daily positive messages
- **Workout Routines** - Yoga and exercise videos
- **Nutrition Tips** - Healthy eating suggestions
- **Local Events** - Wellness activities in your area

### 🎧 AI-Generated Voice Podcasts
- Personalized daily audio content
- Generated using Google Cloud Text-to-Speech
- Based on your mood trends and wellness journey
- Soothing, empathetic narration
- Includes affirmations, tips, and encouragement

### 👥 Community Support Groups
- Join peer support groups based on interests
- Real-time chat with end-to-end security
- Anonymous or alias-based participation
- Moderation and reporting system
- Crisis resource integration

### 🔔 Smart Notifications
- Daily mood check-in reminders
- New podcast availability alerts
- Community message notifications
- Customizable notification preferences

## 🏗️ Technology Stack

### Frontend
- **Flutter** (3.0+) - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Material Design 3** - UI framework

### Backend
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Cloud Storage** - File storage
- **Firebase Cloud Functions** - Serverless backend
- **Firebase Cloud Messaging** - Push notifications

### APIs & Integrations
- TMDB API (movies)
- YouTube Data API v3 (videos)
- Yelp Fusion API (local businesses)
- Google Books API (books)
- Google Cloud Text-to-Speech (voice generation)
- Apple MusicKit (music recommendations)
- Affirmations.dev (daily quotes)

### Platform-Specific
- **iOS**: FamilyControls, ManagedSettings, DeviceActivity
- **Android**: AccessibilityService, UsageStatsManager

## 📋 Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- Android Studio (for Android)
- Xcode (for iOS, macOS only)
- Firebase CLI
- Node.js 18+ (for Cloud Functions)

## 🚀 Getting Started

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Soar
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   flutter pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Add API Keys**
   - Copy `lib/config/api_config.dart.example` to `lib/config/api_config.dart`
   - Add your API keys (see SETUP_GUIDE.md for details)

5. **Run the app**
   ```bash
   flutter run
   ```

For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md).

## 📖 Documentation

- **[Setup Guide](SETUP_GUIDE.md)** - Complete setup instructions
- **[Architecture](ARCHITECTURE.md)** - Technical architecture and design
- **[Technical Guide](SOAR_Technical_Guide.txt)** - Original implementation specifications

## 🎨 Screenshots

_Coming soon_

## 🔒 Security & Privacy

- End-to-end encryption for all communications
- Firestore security rules enforce data isolation
- No PII shared with third-party APIs
- GDPR compliant data handling
- User data deletion on account removal
- Transparent privacy policy

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## 📱 Supported Platforms

- **iOS**: 15.0+
- **Android**: API 23+ (Android 6.0+)

## 🛠️ Development

### Project Structure

```
lib/
├── config/          # Configuration files
├── models/          # Data models
├── services/        # Business logic services
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── utils/           # Helper functions & constants
└── main.dart        # App entry point
```

### Key Services

- `AuthService` - Authentication and user management
- `MoodService` - Mood tracking and analytics
- `RecommendationService` - Content recommendations
- `PodcastService` - AI voice podcast generation
- `CommunityService` - Peer support groups
- `NotificationService` - Push notifications

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👏 Acknowledgments

- Built following the comprehensive technical guide specifications
- Inspired by the need for accessible mental health support
- Powered by Flutter and Firebase

## 📞 Support

- Email: support@soar-app.com
- Issues: [GitHub Issues](link-to-issues)
- Documentation: [Wiki](link-to-wiki)

## 🗺️ Roadmap

- [ ] Advanced ML-based mood prediction
- [ ] Wearable device integration (Apple Watch, Fitbit)
- [ ] Therapist marketplace
- [ ] Group video calls
- [ ] Habit tracking
- [ ] Sleep tracking integration
- [ ] Multi-language support

---

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Status:** Production Ready

Made with ❤️ for mental wellness

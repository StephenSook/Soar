# SOAR App - Technical Architecture

## Overview

SOAR is a cross-platform mobile application built with Flutter, focused on emotional wellness and productivity. This document outlines the technical architecture and design decisions.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile App (Flutter)                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │   UI/UX    │  │  Services  │  │   Models   │            │
│  │  Screens   │  │  Business  │  │    Data    │            │
│  │  Widgets   │  │   Logic    │  │  Classes   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                 Firebase Backend Services                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │   Auth   │  │Firestore │  │ Storage  │  │    FCM   │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Cloud Functions (Serverless)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │Recommendations│  │   Podcast    │  │ Notifications│     │
│  │    Engine     │  │  Generation  │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              External APIs & Services                        │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │  TMDB  │  │YouTube │  │  Yelp  │  │ Google │           │
│  │Movies  │  │Videos  │  │Business│  │  TTS   │           │
│  └────────┘  └────────┘  └────────┘  └────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Frontend (Flutter/Dart)

#### State Management
- **Provider** pattern for app-wide state management
- Separate services for different domains (Auth, Mood, Community, etc.)
- ChangeNotifier for reactive updates

#### Key Services
- `AuthService`: User authentication and profile management
- `MoodService`: Mood tracking and analytics
- `RecommendationService`: Personalized content recommendations
- `PodcastService`: AI voice podcast generation and playback
- `CommunityService`: Peer support group chat functionality
- `NotificationService`: Push notifications and reminders

#### Screens & Navigation
- **Splash** → **Onboarding** → **Auth** → **Home**
- Bottom navigation with 5 main tabs:
  1. Home (mood status, stats, quick actions)
  2. Recommendations (personalized content)
  3. Podcast (daily AI-generated audio)
  4. Community (support groups)
  5. Profile (settings, preferences)

### 2. Backend (Firebase)

#### Firestore Database Schema

```
users/
  {userId}/
    - email, displayName, photoUrl
    - age, interests, mentalHealthHistory
    - contentPreferences, moodCheckInTime
    - blockedApps[], joinedGroups[]
    - lastMoodCheckIn, timezone
    
    moodEntries/
      {entryId}/
        - mood, moodRating, timestamp
        - journalNote, detectedSentiment
        - tags[], context{}
    
    podcasts/
      {podcastId}/
        - audioUrl, script, createdAt
        - listenedAt, completed

communityGroups/
  {groupId}/
    - name, description, category
    - memberIds[], maxMembers
    - createdAt, lastMessage, lastMessageTime
    
    messages/
      {messageId}/
        - senderId, senderAlias, text
        - timestamp, isEdited, isDeleted
        - reactions[]

reports/
  {reportId}/
    - messageId, groupId, reportedBy
    - reason, timestamp, status
```

#### Cloud Functions

1. **getRecommendations**: Fetch personalized content from external APIs
2. **generatePodcast**: Generate AI voice audio using Google TTS
3. **sendDailyReminders**: Scheduled function for daily notifications
4. **notifyNewMessage**: Trigger for community message notifications
5. **cleanupOldPodcasts**: Scheduled cleanup of storage

### 3. Platform-Specific Features

#### iOS (Swift)
- **Screen Time API** integration for app blocking
  - FamilyControls framework
  - ManagedSettings for app shields
  - DeviceActivity for scheduling

#### Android (Kotlin)
- **Accessibility Service** for app blocking
- Usage Stats API for monitoring foreground apps
- Custom overlay for blocked app redirection

### 4. External Integrations

#### Content APIs
- **TMDB**: Movie recommendations
- **YouTube Data API**: Video content
- **Yelp Fusion API**: Local therapists and restaurants
- **Google Books API**: Book recommendations
- **Affirmations.dev**: Daily affirmations

#### AI/ML Services
- **Google Cloud Text-to-Speech**: Voice podcast generation
- Potential: Sentiment analysis on journal entries
- Potential: ML-based recommendation ranking

#### Media Services
- **Apple MusicKit**: Music playlist recommendations (iOS)
- Potential: Spotify API for Android

## Data Flow

### Mood Check-In Flow

```
1. User Opens App
   ↓
2. Check Today's Mood Status
   ↓
3. If Not Completed → Show Prompt
   ↓
4. User Completes Survey
   ↓
5. Save to Firestore
   ↓
6. Unlock Blocked Apps
   ↓
7. Trigger Recommendations Refresh
   ↓
8. Generate Daily Podcast (optional)
```

### Recommendations Flow

```
1. User Requests Recommendations
   ↓
2. Call Cloud Function with mood + profile
   ↓
3. Function fetches from multiple APIs in parallel
   ↓
4. Aggregate and rank results
   ↓
5. Return to client
   ↓
6. Display in UI with categories
```

### Community Chat Flow

```
1. User Joins Group
   ↓
2. Real-time Firestore listener established
   ↓
3. User sends message
   ↓
4. Message saved to Firestore
   ↓
5. Firestore trigger fires
   ↓
6. Cloud Function sends FCM to group members
   ↓
7. All members receive real-time update
```

## Security Considerations

### Authentication
- Firebase Auth with email/password and OAuth providers
- JWT tokens for API calls
- Secure token storage on device

### Data Privacy
- All network calls over HTTPS/TLS
- Firestore security rules enforce user-specific access
- Sensitive data encrypted at rest (Firebase default)
- No PII sent to external APIs
- User data deletion on account removal

### App Permissions
- Minimal permissions requested
- Clear usage descriptions
- Optional permissions for non-essential features
- Transparent privacy policy

## Performance Optimizations

### Caching
- Cached network images
- Local storage for user preferences
- Firestore offline persistence

### API Efficiency
- Batched API calls in Cloud Functions
- Rate limiting and quota management
- Fallback content for API failures

### State Management
- Lazy loading of data
- Pagination for large lists
- Efficient rebuilds with Provider

## Scalability

### Serverless Architecture
- Auto-scaling Cloud Functions
- No fixed server costs
- Pay per use

### Database
- Firestore auto-scaling
- Indexed queries for performance
- Data sharding by user

### Storage
- Cloud Storage with CDN
- Automatic cleanup of old files
- Compression for media files

## Future Enhancements

### Planned Features
- Advanced ML-based mood prediction
- Integration with wearables (Apple Watch, Fitbit)
- Therapist marketplace
- In-app guided therapy sessions
- Group video calls
- Habit tracking
- Sleep tracking integration

### Technical Improvements
- GraphQL API layer
- Advanced analytics with BigQuery
- A/B testing framework
- Automated testing suite
- CI/CD pipeline

## Development Guidelines

### Code Organization
```
lib/
  ├── models/          # Data models
  ├── services/        # Business logic
  ├── screens/         # UI screens
  ├── widgets/         # Reusable widgets
  ├── utils/           # Helper functions
  ├── config/          # Configuration
  └── main.dart        # Entry point
```

### Best Practices
- Follow Flutter style guide
- Write meaningful comments
- Unit tests for services
- Widget tests for UI
- Integration tests for critical flows
- Regular code reviews
- Version control with Git

## Deployment

### Development
- Local development with Firebase emulators
- Staging environment for testing

### Production
- iOS: TestFlight → App Store
- Android: Internal testing → Play Store
- Cloud Functions: Firebase deployment
- Monitoring with Firebase Crashlytics

## Support & Maintenance

### Monitoring
- Firebase Analytics for usage tracking
- Crashlytics for error reporting
- Performance monitoring
- Custom logging for debugging

### Updates
- Regular dependency updates
- Security patches
- Feature releases
- Bug fixes

---

**Last Updated**: November 2025
**Version**: 1.0.0


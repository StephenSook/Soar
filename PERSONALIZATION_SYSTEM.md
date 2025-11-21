# SOAR Personalization System

## Overview
The SOAR app now features a comprehensive personalization system that collects user preferences during onboarding and uses this data to drive AI-powered, personalized recommendations throughout the app experience.

## 🎯 Features

### 1. **Personalization Questionnaire**
A beautiful, multi-page onboarding questionnaire that collects:
- **Interests** (8 options): Meditation, Journaling, Stress Relief, Sleep, Fitness, Social Connection, Personal Growth, Breathing
- **Mental Health Focus Areas** (8 options): Anxiety, Depression, Stress, Sleep Issues, ADHD, Grief, Relationships, General Wellness
- **Content Preferences** (5 types): Podcasts, Articles, Videos, Meditation, Journaling
- **Check-in Reminder Time**: Custom time picker for daily reminders
- **App Blocking** (Optional): Select apps to lock until daily check-in is complete

### 2. **Editable Preferences**
Users can modify their preferences anytime via:
- Profile Screen → "My Preferences"
- Tabbed interface with 3 sections:
  - Interests Tab
  - Focus Areas Tab
  - Content & Reminders Tab

### 3. **AI-Driven Recommendations**
The recommendation engine now uses personalization data to:
- **Filter Content**: Only show content types the user has enabled
- **Boost Relevance**: Increase scores for content matching user interests (+1.5 points)
- **Prioritize Mental Health**: Higher boost for mental health area matches (+2.0 points)
- **Customize Queries**: Build API queries based on user preferences
- **Personalized Results**: Tailor movies, books, videos, and nutrition tips

## 📁 Files Created/Modified

### New Files
1. `/lib/screens/onboarding/personalization_screen.dart` - Onboarding questionnaire
2. `/lib/screens/profile/preferences_screen.dart` - Edit preferences screen
3. `PERSONALIZATION_SYSTEM.md` - This documentation

### Modified Files
1. `/lib/main.dart` - Added personalization route
2. `/lib/screens/auth/signup_screen.dart` - Navigate to personalization after signup
3. `/lib/screens/profile/profile_screen.dart` - Added "My Preferences" option
4. `/lib/services/recommendation_service.dart` - Integrated personalization into recommendations

## 🔄 User Flow

### For New Users
```
Sign Up → Personalization Questionnaire (5 pages) → Home Screen
```

1. **Page 1: Interests** - Select wellness interests
2. **Page 2: Mental Health** - Choose focus areas
3. **Page 3: Content** - Toggle content preferences
4. **Page 4: Reminder** - Set check-in time
5. **Page 5: App Blocking** - Optional app selection

*Users can skip at any time*

### For Existing Users
```
Profile → My Preferences → Edit & Save
```

Three tabs for easy editing:
- Interests
- Focus Areas  
- Content & Reminders

## 🎨 UI Design

### Design Principles
- **Warm Colors**: Orange/yellow gradient buttons and selections
- **Clear Visual Feedback**: Selected items have gradient backgrounds with shadows
- **Progress Indicator**: Linear progress bar showing completion (5 steps)
- **Intuitive Icons**: Each option has a relevant icon
- **Skip Option**: Always available in top-right
- **Back/Next Navigation**: Clear progression through questionnaire

### Components
- **Selection Chips**: Tap to select/deselect with gradient when active
- **Preference Cards**: Toggle switches with icon backgrounds
- **Time Picker**: Large, accessible time selection interface
- **App Selection**: Checkboxes with border highlighting

## 💾 Data Storage

### Firebase Schema
```typescript
users/{userId} {
  // ... existing fields
  interests: string[]              // ['meditation', 'journaling', ...]
  mentalHealthHistory: string[]    // ['anxiety', 'stress', ...]
  contentPreferences: {            // Content type toggles
    podcasts: boolean,
    articles: boolean,
    videos: boolean,
    meditation: boolean,
    journaling: boolean
  }
  moodCheckInTime: string          // 'HH:MM' format
  blockedApps: string[]            // Package names (future feature)
}
```

### Updates
All preferences are updated via `AuthService.updateUserProfile()`:
```dart
await authService.updateUserProfile(
  interests: ['meditation', 'journaling'],
  mentalHealthHistory: ['anxiety'],
  contentPreferences: {'podcasts': true, 'articles': true},
  moodCheckInTime: '09:00',
);
```

## 🤖 AI-Driven Recommendations

### How It Works

#### 1. Content Filtering
```dart
// Only fetch content types enabled by user
if (contentPreferences['videos'] != false) {
  futures.add(_fetchMovies(mood, interests, mentalHealthAreas));
}
```

#### 2. Query Customization
```dart
// Build book query from interests
if (interests.contains('meditation')) queryParts.add('mindfulness');
if (mentalHealthAreas.contains('anxiety')) queryParts.add('anxiety+relief');
return queryParts.join('+');
```

#### 3. Relevance Boosting
```dart
// Boost scores for matching content
for (var interest in interests) {
  if (recommendation.tags?.contains(interest)) {
    boost += 1.5;  // Interest match
  }
}
for (var area in mentalHealthAreas) {
  if (recommendation.tags?.contains(area)) {
    boost += 2.0;  // Mental health match (higher priority)
  }
}
```

#### 4. Genre Selection
```dart
// Select movie genres based on user preferences
if (interests.contains('stress_relief')) {
  return '35,10751'; // Comedy & Family
}
if (mentalHealthAreas.contains('anxiety')) {
  return '18,10749'; // Drama & Romance (calming)
}
```

### Example Scenarios

#### Scenario 1: User with Anxiety Focus
**Preferences:**
- Mental Health: Anxiety, Stress
- Interests: Meditation, Breathing
- Content: All enabled

**Result:**
- Books: "Anxiety Relief", "Mindfulness", "Calm" queries
- Videos: "Calming meditation anxiety relief"
- Movies: Drama & Romance genres (calming narratives)
- Nutrition: "Foods rich in omega-3s to help reduce anxiety"
- +2.0 relevance boost for anxiety-related content

#### Scenario 2: User Focused on Growth
**Preferences:**
- Interests: Personal Growth, Journaling
- Mental Health: General Wellness
- Content: Articles and books only (videos disabled)

**Result:**
- Only books and articles fetched (no videos)
- Books: "Personal development", "Self-reflection" queries
- +1.5 relevance boost for growth-related content
- Movies: Drama & Documentary genres

#### Scenario 3: User with Sleep Issues
**Preferences:**
- Interests: Better Sleep, Meditation
- Mental Health: Sleep Issues
- Content: All enabled

**Result:**
- Books: "Better sleep", "mindfulness" queries
- Videos: "Sleep meditation", "relaxation"
- Movies: Documentary & History (relaxing content)
- Nutrition: "Avoid caffeine after 2pm and try foods rich in magnesium"
- +2.0 boost for sleep-related content

## 📊 Data Usage Examples

### In Recommendations Screen
```dart
final authService = context.read<AuthService>();
final user = authService.currentUserModel;

// Build user profile for recommendations
final userProfile = {
  'interests': user?.interests ?? [],
  'mentalHealthHistory': user?.mentalHealthHistory ?? [],
  'contentPreferences': user?.contentPreferences ?? {},
  'location': 'User Location', // If available
};

// Fetch personalized recommendations
await recommendationService.fetchRecommendations(
  currentMood,
  userProfile,
);
```

### In Podcast Generation
```dart
// Use interests and mental health areas to generate podcast topics
final topics = [];
if (user.interests.contains('meditation')) {
  topics.add('mindfulness practices');
}
if (user.mentalHealthHistory.contains('anxiety')) {
  topics.add('managing anxiety naturally');
}

// Generate AI podcast with personalized topics
await podcastService.generatePodcast(
  mood: currentMood,
  topics: topics,
  duration: 10, // minutes
);
```

### In Community Groups
```dart
// Suggest relevant community groups
final suggestedGroups = [];
for (var area in user.mentalHealthHistory) {
  suggestedGroups.addAll(
    await communityService.searchGroups(category: area)
  );
}
```

## 🔧 Configuration Options

### Interest Options (8 Total)
```dart
'meditation'      → Meditation & Mindfulness
'journaling'      → Journaling
'stress_relief'   → Stress Relief
'sleep'           → Better Sleep
'fitness'         → Physical Wellness
'social'          → Social Connection
'growth'          → Personal Growth
'breathing'       → Breathing Exercises
```

### Mental Health Options (8 Total)
```dart
'anxiety'         → Anxiety
'depression'      → Depression
'stress'          → Stress Management
'sleep_issues'    → Sleep Issues
'adhd'            → Focus & ADHD
'grief'           → Grief & Loss
'relationships'   → Relationship Issues
'general'         → General Wellness
```

### Content Preferences (5 Types)
```dart
'podcasts'    → Daily Podcasts (AI-generated)
'articles'    → Articles & Reading
'videos'      → Videos & Films
'meditation'  → Guided Meditation
'journaling'  → Journaling Prompts
```

## 🚀 Future Enhancements

### Planned Features
1. **App Blocking Integration**: Actually block selected apps until check-in
2. **Learning Algorithm**: Adjust recommendations based on user engagement
3. **A/B Testing**: Test different recommendation strategies
4. **Collaborative Filtering**: "Users like you also enjoyed..."
5. **Time-Based Personalization**: Different content for morning vs evening
6. **Mood Trend Analysis**: Long-term patterns affecting recommendations
7. **Export Preferences**: Share or backup personalization data

### Advanced AI Features
1. **Natural Language Preferences**: "I'm stressed about work deadlines"
2. **Sentiment Analysis**: Analyze journal entries for deeper insights
3. **Predictive Recommendations**: Anticipate needs before mood check-in
4. **Multi-Modal Learning**: Combine mood, journal, and activity data

## 🧪 Testing the System

### Test New User Flow
1. Create a new account
2. Complete personalization questionnaire
3. Select various interests and focus areas
4. Navigate to Recommendations screen
5. Verify content matches selections

### Test Edit Preferences
1. Go to Profile → My Preferences
2. Toggle content preferences
3. Add/remove interests
4. Save changes
5. Check recommendations update accordingly

### Test Recommendation Boosting
1. Set specific mental health area (e.g., "Anxiety")
2. Complete mood check-in
3. View recommendations
4. Verify anxiety-related content has higher relevance scores

### Test Content Filtering
1. Disable "videos" in preferences
2. Save changes
3. Check recommendations
4. Verify no video content appears

## 📈 Analytics & Metrics

### Recommended Tracking
- **Questionnaire Completion Rate**: % who finish all 5 pages
- **Skip Rate**: % who skip personalization
- **Preference Changes**: Frequency of editing preferences
- **Recommendation Engagement**: Click-through rates by content type
- **Interest Correlation**: Which interests lead to highest engagement
- **Boosted Content Performance**: Engagement with boosted recommendations

## 🔒 Privacy & Data Security

### Data Handling
- All preference data stored in Firebase with user authentication
- No sensitive information collected
- Users can view/edit all collected data
- Option to delete account removes all personalization data
- Data used only for improving user experience
- No selling or sharing of personal data

### HIPAA Considerations
- Mental health selections are self-reported and general
- No diagnostic information collected
- Users not required to answer mental health questions
- Clear opt-out options available
- Data encrypted in transit and at rest

## 📚 Developer Guide

### Adding New Interest Option
```dart
// In personalization_screen.dart and preferences_screen.dart
_interestOptions.add({
  'label': 'New Interest Name',
  'icon': Icons.icon_name_rounded,
  'value': 'new_interest_key',
});
```

### Adding New Content Type
```dart
// 1. Update UserModel contentPreferences
// 2. Add toggle in personalization_screen
// 3. Add fetch method in recommendation_service
// 4. Update filtering logic

_contentPreferences['new_type'] = true;
```

### Customizing Recommendation Logic
```dart
// In recommendation_service.dart
void _boostRelevanceByInterests(...) {
  // Adjust boost values
  boost += 1.5;  // Interest match
  boost += 2.0;  // Mental health match
  boost += 0.5;  // Custom logic
}
```

## 🎓 Best Practices

### User Experience
1. **Never force personalization** - always allow skip
2. **Show progress clearly** - users should know where they are
3. **Provide examples** - help users understand each option
4. **Make editing easy** - accessible from profile at any time
5. **Respect preferences** - honor content type selections

### Data Collection
1. **Be transparent** - explain why data is collected
2. **Collect minimally** - only what's needed for personalization
3. **Update incrementally** - allow partial saves
4. **Validate inputs** - ensure data quality
5. **Provide defaults** - reasonable fallbacks if data missing

### Recommendation Quality
1. **Combine signals** - mood + preferences + history
2. **Diversify content** - don't over-focus on one area
3. **Freshen regularly** - update recommendations daily
4. **Handle errors gracefully** - fallback content available
5. **Monitor quality** - track engagement metrics

## 🏁 Conclusion

The SOAR personalization system transforms a generic wellness app into a truly personalized experience. By collecting user preferences during onboarding and making them easily editable, while using this data to drive AI-powered recommendations, we create a unique, tailored experience for each user.

The system is:
- ✅ **User-friendly**: Beautiful UI with clear options
- ✅ **Flexible**: Easy to edit preferences anytime
- ✅ **Powerful**: Drives recommendations across the app
- ✅ **Privacy-conscious**: Transparent data handling
- ✅ **Extensible**: Easy to add new options and content types

**Result**: Users feel understood and receive content that truly resonates with their needs and preferences.


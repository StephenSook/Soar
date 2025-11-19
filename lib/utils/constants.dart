// App Constants

class AppConstants {
  // App Info
  static const String appName = 'SOAR';
  static const String appTagline = 'What if your phone could sense you\'re overwhelmed... before you even feel it?';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String moodEntriesCollection = 'moodEntries';
  static const String communityGroupsCollection = 'communityGroups';
  static const String messagesCollection = 'messages';
  static const String podcastsCollection = 'podcasts';
  static const String reportsCollection = 'reports';

  // Storage Paths
  static const String userProfilePicturesPath = 'profile_pictures';
  static const String podcastAudioPath = 'podcasts';

  // Notification Channels
  static const String moodReminderChannelId = 'daily_mood_channel';
  static const String podcastChannelId = 'podcast_channel';
  static const String communityChannelId = 'community_channel';

  // SharedPreferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String selectedMoodTimeKey = 'selected_mood_time';
  static const String blockedAppsKey = 'blocked_apps';
  static const String lastCheckInDateKey = 'last_checkin_date';

  // Default Values
  static const int maxGroupMembers = 50;
  static const int moodHistoryLimit = 30;
  static const int messagePageSize = 50;

  // URLs
  static const String privacyPolicyUrl = 'https://soar-app.com/privacy';
  static const String termsOfServiceUrl = 'https://soar-app.com/terms';
  static const String supportEmail = 'support@soar-app.com';
  static const String crisisHelplineUrl = 'tel:988'; // National Suicide Prevention Lifeline

  // Crisis Resources
  static const List<Map<String, String>> crisisResources = [
    {
      'name': 'National Suicide Prevention Lifeline',
      'phone': '988',
      'website': 'https://988lifeline.org/',
    },
    {
      'name': 'Crisis Text Line',
      'phone': '741741',
      'website': 'https://www.crisistextline.org/',
      'info': 'Text HOME to 741741',
    },
    {
      'name': 'SAMHSA National Helpline',
      'phone': '1-800-662-4357',
      'website': 'https://www.samhsa.gov/find-help/national-helpline',
    },
  ];

  // Mood Check-in Prompts
  static const List<String> journalPrompts = [
    'What is one thing you\'re grateful for today?',
    'Describe a moment that made you smile recently.',
    'What\'s weighing on your mind right now?',
    'How are you taking care of yourself today?',
    'What would make today a good day for you?',
    'What emotion are you feeling most strongly right now?',
    'Write about a time you overcame a fear.',
    'What are three things you love about yourself?',
    'What activities help you feel most at peace?',
    'If you could talk to your future self, what would you say?',
  ];

  // Wellness Tips
  static const List<String> wellnessTips = [
    'Take deep breaths: Inhale for 4 counts, hold for 4, exhale for 4.',
    'Drink a glass of water. Hydration affects your mood and energy.',
    'Take a 5-minute walk outside. Nature can be healing.',
    'Write down three things you\'re grateful for.',
    'Call or text someone you care about.',
    'Listen to your favorite music.',
    'Do a quick stretch or yoga pose.',
    'Put your phone away for 15 minutes and just be present.',
    'Practice self-compassion. Treat yourself like you would a good friend.',
    'Remember: It\'s okay to not be okay. Seek help when you need it.',
  ];

  // Affirmations
  static const List<String> affirmations = [
    'I am stronger than my challenges.',
    'I deserve peace and happiness.',
    'My feelings are valid and important.',
    'I am enough, just as I am.',
    'Every day is a new opportunity.',
    'I choose progress over perfection.',
    'I have the power to create positive change.',
    'I am worthy of love and respect.',
    'I trust myself to make good decisions.',
    'I am resilient and capable.',
  ];

  // Community Group Categories
  static const List<String> communityCategories = [
    'General Support',
    'Anxiety & Stress',
    'Depression',
    'ADHD & Focus',
    'Grief & Loss',
    'Relationships',
    'Work & Productivity',
    'Self-Care',
    'LGBTQ+ Support',
    'Young Adults',
  ];
}


/// API Configuration Template
/// 
/// Copy this file to api_config.dart and fill in your actual API keys
/// 
/// To get your Google Cloud API keys:
/// 1. Go to https://console.cloud.google.com/
/// 2. Create a new project or select existing one
/// 3. Enable the APIs you need from "APIs & Services" > "Library"
/// 4. Create credentials from "APIs & Services" > "Credentials"

class ApiConfig {
  // YouTube Data API v3
  static const String youtubeApiKey = 'YOUR_YOUTUBE_API_KEY_HERE';

  // Google Books API
  static const String googleBooksApiKey = 'YOUR_GOOGLE_BOOKS_API_KEY_HERE';

  // Google Cloud Speech-to-Text API (if needed)
  static const String speechToTextApiKey = 'YOUR_SPEECH_TO_TEXT_API_KEY_HERE';

  // Google Cloud Text-to-Speech API (if needed)
  static const String textToSpeechApiKey = 'YOUR_TEXT_TO_SPEECH_API_KEY_HERE';

  // Other third-party APIs
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
  static const String yelpApiKey = 'YOUR_YELP_API_KEY_HERE';

  // Cloud Functions URL (get from Firebase Console)
  // Format: https://REGION-PROJECT_ID.cloudfunctions.net
  static const String cloudFunctionsUrl = 'YOUR_CLOUD_FUNCTIONS_URL_HERE';

  // Validate if keys are configured
  static bool get isConfigured {
    return youtubeApiKey != 'YOUR_YOUTUBE_API_KEY_HERE' &&
           googleBooksApiKey != 'YOUR_GOOGLE_BOOKS_API_KEY_HERE';
  }

  // Get API key for specific service
  static String getApiKey(String service) {
    switch (service) {
      case 'youtube':
        return youtubeApiKey;
      case 'books':
        return googleBooksApiKey;
      case 'speech':
        return speechToTextApiKey;
      case 'tts':
        return textToSpeechApiKey;
      case 'tmdb':
        return tmdbApiKey;
      case 'yelp':
        return yelpApiKey;
      default:
        throw Exception('Unknown API service: $service');
    }
  }
}


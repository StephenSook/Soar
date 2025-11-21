import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Text-to-Speech Service using Google Cloud TTS API
/// 
/// This service can be used directly from the Flutter app or through Cloud Functions.
/// Using it directly from the app is simpler but less secure.
/// 
/// For production, it's recommended to use Cloud Functions (see tts_cloud_function.js)
class TtsService {
  /// Generate speech from text using Google Cloud TTS API
  /// 
  /// Direct API approach (simpler, but API key is exposed in the app)
  /// For production, consider using the Cloud Function approach instead
  static Future<List<int>?> generateSpeechDirect({
    required String text,
    String languageCode = 'en-US',
    String voiceName = 'en-US-Neural2-F', // Female neural voice
    double speakingRate = 1.0,
    double pitch = 0.0,
  }) async {
    try {
      final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=${ApiConfig.textToSpeechApiKey}',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'input': {'text': text},
          'voice': {
            'languageCode': languageCode,
            'name': voiceName,
            'ssmlGender': 'FEMALE', // or 'MALE', 'NEUTRAL'
          },
          'audioConfig': {
            'audioEncoding': 'MP3',
            'speakingRate': speakingRate,
            'pitch': pitch,
            'effectsProfileId': ['small-bluetooth-speaker-class-device'],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audioContent = data['audioContent'] as String;
        
        // Decode base64 audio
        return base64.decode(audioContent);
      } else {
        debugPrint('TTS API Error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating speech: $e');
      return null;
    }
  }

  /// Generate speech through Cloud Function (more secure - recommended for production)
  /// 
  /// This approach keeps your API keys secure on the server side
  static Future<String?> generateSpeechViaCloudFunction({
    required String text,
    String languageCode = 'en-US',
    String voiceName = 'en-US-Neural2-F',
    double speakingRate = 1.0,
    double pitch = 0.0,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.cloudFunctionsUrl}/generatePodcast');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'voice': voiceName,
          'languageCode': languageCode,
          'speakingRate': speakingRate,
          'pitch': pitch,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['audioUrl']; // URL to the generated MP3 in Cloud Storage
      } else {
        debugPrint('Cloud Function Error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error calling Cloud Function: $e');
      return null;
    }
  }

  /// Available voice options
  static const List<Map<String, String>> availableVoices = [
    {
      'name': 'en-US-Neural2-F',
      'language': 'en-US',
      'gender': 'Female',
      'description': 'Neural voice - warm and friendly'
    },
    {
      'name': 'en-US-Neural2-J',
      'language': 'en-US',
      'gender': 'Male',
      'description': 'Neural voice - calm and professional'
    },
    {
      'name': 'en-US-Wavenet-F',
      'language': 'en-US',
      'gender': 'Female',
      'description': 'Wavenet voice - natural sounding'
    },
    {
      'name': 'en-US-Standard-C',
      'language': 'en-US',
      'gender': 'Female',
      'description': 'Standard voice - clear and reliable'
    },
  ];

  /// Check if TTS API is configured
  static bool get isConfigured {
    return ApiConfig.textToSpeechApiKey != 'YOUR_TEXT_TO_SPEECH_API_KEY_HERE';
  }
}


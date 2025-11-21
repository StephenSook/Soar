# 🎙️ Text-to-Speech Quick Start

## What's Been Set Up

✅ **TTS Service** (`lib/services/tts_service.dart`) - Ready to use!  
✅ **Updated Podcast Service** - Now uses TTS API  
✅ **Cloud Function** (`functions/tts_cloud_function.js`) - For production  
✅ **API Config** - TTS key already added  
✅ **Dependencies** - `path_provider` added to pubspec.yaml

## Quick Start (5 Minutes)

### Step 1: Enable Text-to-Speech API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project (or create new one)
3. Go to **"APIs & Services"** > **"Library"**
4. Search for **"Cloud Text-to-Speech API"**
5. Click **"Enable"**

### Step 2: Create API Key

1. Go to **"APIs & Services"** > **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** > **"API key"**
3. **Copy the key immediately!**
4. Click **"RESTRICT KEY"**:
   - Under "API restrictions" → Select "Restrict key"
   - Check only ✓ "Cloud Text-to-Speech API"
   - Click "Save"

### Step 3: Add to Your App

Open `lib/config/api_config.dart`:

```dart
static const String textToSpeechApiKey = 'AIzaSy...'; // ← Paste your key here
```

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Test It!

Run your app and try generating a podcast:

```bash
flutter run
```

## Two Ways to Use TTS

### 🔧 Method 1: Direct API (Development)

**Already working!** The podcast service will automatically use this if Cloud Functions URL is not configured.

**Pros**: Simple, immediate  
**Cons**: API key in app (less secure)

### 🔐 Method 2: Cloud Functions (Production) - Recommended

**To enable**:

1. **Update `functions/index.js`**:
   ```javascript
   const { generatePodcast } = require('./tts_cloud_function');
   exports.generatePodcast = generatePodcast;
   ```

2. **Deploy**:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

3. **Get URL** from Firebase Console > Functions

4. **Add to config**:
   ```dart
   static const String cloudFunctionsUrl = 
     'https://us-central1-your-project.cloudfunctions.net';
   ```

**Pros**: Secure, professional  
**Cons**: Requires deployment

## How It Works in Your App

The `podcast_service.dart` is already integrated:

```dart
// When user generates a podcast:
final audioUrl = await generateDailyPodcast(mood, history);

// Behind the scenes:
// 1. Generates personalized script based on mood
// 2. Calls TTS API (direct or Cloud Function)
// 3. Saves audio file
// 4. Returns URL to play
```

## Available Voices

You can change the voice in `podcast_service.dart`:

```dart
voiceName: 'en-US-Neural2-F',  // Female (default)
voiceName: 'en-US-Neural2-J',  // Male
voiceName: 'en-US-Wavenet-F',  // Female WaveNet
```

See all voices: [Google TTS Voices](https://cloud.google.com/text-to-speech/docs/voices)

## Pricing

**Free Tier (per month)**:
- Standard voices: 1M characters FREE
- WaveNet voices: 1M characters FREE (first year)
- Neural2 voices: 1M characters FREE

**After Free Tier**:
- Standard: $4 per 1M characters
- WaveNet: $16 per 1M characters
- Neural2: $16 per 1M characters

**Your app** generates ~500-1000 characters per podcast, so:
- Free tier = ~1,000-2,000 podcasts/month per user!

## Testing Your Setup

Add this to any screen to test:

```dart
import 'package:soar/services/tts_service.dart';

// Test button
ElevatedButton(
  onPressed: () async {
    if (TtsService.isConfigured) {
      final audio = await TtsService.generateSpeechDirect(
        text: 'Hello from SOAR! Your text-to-speech is working!',
      );
      
      if (audio != null) {
        print('✅ Success! Generated ${audio.length} bytes of audio');
      } else {
        print('❌ Failed to generate audio');
      }
    } else {
      print('❌ TTS API key not configured');
    }
  },
  child: Text('Test TTS'),
)
```

## Common Issues

### "API key not valid"
- ✓ Make sure API is enabled in Cloud Console
- ✓ Check if key restrictions allow TTS API
- ✓ Wait 2-3 minutes for changes to propagate

### "Quota exceeded"
- ✓ Check usage in Cloud Console
- ✓ Enable billing if needed
- ✓ Implement caching to reduce calls

### "Path provider error"
- ✓ Run `flutter pub get`
- ✓ Restart your IDE

## Next Steps

1. ✅ Enable TTS API
2. ✅ Add API key to `api_config.dart`
3. ✅ Run `flutter pub get`
4. ✅ Test with your app
5. 🚀 (Optional) Deploy Cloud Functions for production

## Files Modified/Created

- ✅ `lib/services/tts_service.dart` - NEW! TTS wrapper
- ✅ `lib/services/podcast_service.dart` - Updated to use TTS
- ✅ `functions/tts_cloud_function.js` - NEW! Cloud Function
- ✅ `lib/config/api_config.dart` - Added TTS key field
- ✅ `pubspec.yaml` - Added path_provider dependency

## Resources

- [Google Cloud TTS Docs](https://cloud.google.com/text-to-speech/docs)
- [TTS Pricing](https://cloud.google.com/text-to-speech/pricing)
- [Voice List](https://cloud.google.com/text-to-speech/docs/voices)
- [SSML Guide](https://cloud.google.com/text-to-speech/docs/ssml) (Advanced)

---

**Your app is ready to speak!** 🎙️✨


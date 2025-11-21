# How to Restrict API Keys (Critical for Security!)

## Why This Matters

Your YouTube and Books API implementations are **correct and secure** - BUT only if you restrict the keys properly!

Without restrictions:
- ❌ Anyone who extracts your key can use it anywhere
- ❌ Could drain your quota quickly
- ❌ Potential for abuse

With restrictions:
- ✅ Key only works in YOUR app
- ✅ Protected by your app's signature/bundle ID
- ✅ Can't be used elsewhere even if extracted

## Step-by-Step: Restrict Your API Keys

### For YouTube Data API Key

1. **Go to Google Cloud Console**
   ```
   https://console.cloud.google.com/apis/credentials
   ```

2. **Find your YouTube API key** and click the pencil icon (Edit)

3. **Set Application Restrictions**

   **For Android:**
   ```
   Application restrictions:
   • Select: "Android apps"
   
   Add an item:
   • Package name: com.soar.wellness
   • SHA-1 certificate fingerprint: [See below how to get this]
   
   Click "Done"
   ```

   **For iOS:**
   ```
   Application restrictions:
   • Select: "iOS apps"
   
   Add an item:
   • Bundle ID: com.soar.wellness
   
   Click "Done"
   ```

   **For Both Platforms:**
   - Create TWO separate API keys (recommended):
     - One restricted to Android
     - One restricted to iOS
   - OR use platform detection in your code

4. **Set API Restrictions**
   ```
   API restrictions:
   • Select: "Restrict key"
   • Check ONLY: ✓ YouTube Data API v3
   
   Click "Save"
   ```

### For Google Books API Key

Repeat the same process:

```
Application restrictions:
• Android apps: com.soar.wellness + SHA-1
• iOS apps: com.soar.wellness

API restrictions:
• Restrict key
• Check ONLY: ✓ Google Books API

Save
```

### For Text-to-Speech API Key

```
Application restrictions:
• Android apps: com.soar.wellness + SHA-1
• iOS apps: com.soar.wellness

API restrictions:
• Restrict key
• Check ONLY: ✓ Cloud Text-to-Speech API

Save
```

## How to Get Your SHA-1 Certificate Fingerprint (Android)

### For Debug Build (Development)

```bash
# On macOS/Linux:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# On Windows:
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Look for:
```
Certificate fingerprints:
  SHA1: A1:B2:C3:D4:E5:F6:... ← Copy this!
```

### For Release Build (Production)

```bash
# Using your release keystore
keytool -list -v -keystore /path/to/your-release-key.jks -alias your-key-alias

# OR from Google Play Console:
# App integrity → App signing → SHA-1 certificate fingerprint
```

## How to Get Your iOS Bundle ID

### Option 1: From Your Code
Check: `ios/Runner/Info.plist`

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

Default is: `com.soar.wellness`

### Option 2: From Xcode
1. Open `ios/Runner.xcworkspace`
2. Select "Runner" project
3. Go to "Signing & Capabilities"
4. Look at "Bundle Identifier"

## Platform-Specific API Keys in Code

If you create separate keys for Android and iOS:

```dart
import 'dart:io' show Platform;

class ApiConfig {
  // YouTube API Keys (one for each platform)
  static const String _youtubeApiKeyAndroid = 'AIza_ANDROID_KEY';
  static const String _youtubeApiKeyIOS = 'AIza_IOS_KEY';
  
  static String get youtubeApiKey {
    if (Platform.isAndroid) {
      return _youtubeApiKeyAndroid;
    } else if (Platform.isIOS) {
      return _youtubeApiKeyIOS;
    } else {
      // Web or other platforms
      return _youtubeApiKeyAndroid; // fallback
    }
  }
  
  // Or simpler: Use the same key restricted to both platforms
  static const String youtubeApiKey = 'AIza_KEY_RESTRICTED_TO_BOTH';
}
```

## Verification Checklist

After restricting your keys, verify:

### ✅ Test in Your App
```dart
// Should work
final response = await http.get(
  Uri.parse('https://www.googleapis.com/youtube/v3/search?'
    'key=${ApiConfig.youtubeApiKey}&...')
);
print('Status: ${response.statusCode}'); // Should be 200
```

### ✅ Test from Browser (Should Fail!)
Try this URL in your browser:
```
https://www.googleapis.com/youtube/v3/search?part=snippet&q=meditation&key=YOUR_KEY
```

**Expected result:**
```json
{
  "error": {
    "code": 403,
    "message": "The request is not from an authorized app"
  }
}
```

If you get actual results → ❌ Your key is NOT restricted!

### ✅ Test Wrong Package Name (Should Fail!)
If someone tries to use your key with a different package name, it should fail.

## Common Issues

### "API key not valid" error in app

**Causes:**
1. Wrong package name in restrictions
2. Wrong SHA-1 certificate
3. Wrong bundle ID
4. Changes take 5-10 minutes to propagate

**Solutions:**
1. Double-check package name matches exactly: `com.soar.wellness`
2. Verify SHA-1 from the keystore you're actually using
3. For development, use debug keystore SHA-1
4. Wait 5-10 minutes after making changes
5. Restart your app

### Key works in browser but not in app

**Cause:** Restrictions are set, but don't match your app

**Solution:**
1. Temporarily remove restrictions
2. Test if it works (should work everywhere now)
3. Re-add restrictions carefully
4. Use EXACT package name and SHA-1

### Different behavior in debug vs release

**Cause:** Different signing certificates

**Solution:**
- Add BOTH debug and release SHA-1 fingerprints to the same key
- OR use separate keys for debug and release

```
Application restrictions: Android apps
  
  Add items:
  1. Package: com.soar.wellness
     SHA-1: [Debug certificate]
  
  2. Package: com.soar.wellness
     SHA-1: [Release certificate]
```

## Development vs Production Strategy

### Option 1: Same Key, Both Certificates (Simpler)
```
One YouTube API Key:
├─ Android: com.soar.wellness + Debug SHA-1
├─ Android: com.soar.wellness + Release SHA-1
└─ iOS: com.soar.wellness
```

**Pros:** Simple, one key to manage  
**Cons:** Debug and prod share quota

### Option 2: Separate Keys (Recommended)
```
Development YouTube API Key:
├─ Android: com.soar.wellness.dev + Debug SHA-1
└─ iOS: com.soar.wellness.dev

Production YouTube API Key:
├─ Android: com.soar.wellness + Release SHA-1
└─ iOS: com.soar.wellness
```

**Pros:** Separate quotas, better monitoring  
**Cons:** Need to manage multiple keys

## Quick Reference

| Restriction Type | Purpose | Example |
|-----------------|---------|---------|
| **Android apps** | Restrict to your Android app | `com.soar.wellness` + SHA-1 |
| **iOS apps** | Restrict to your iOS app | `com.soar.wellness` |
| **HTTP referrers** | For websites only | Not for mobile apps |
| **IP addresses** | For servers/backends | Not for mobile apps |

## After Restricting Keys

Your `api_config.dart` stays the same:

```dart
class ApiConfig {
  // Keys are the same, just restricted in Cloud Console
  static const String youtubeApiKey = 'AIzaSy...';
  static const String googleBooksApiKey = 'AIzaSy...';
  static const String textToSpeechApiKey = 'AIzaSy...';
}
```

**The magic happens in Google Cloud Console, not in your code!**

## Security Status

### Before Restrictions:
```
Your API Key → ❌ Can be used anywhere
              ❌ By anyone who extracts it
              ❌ Quota can be drained
```

### After Restrictions:
```
Your API Key → ✅ Only works in com.soar.wellness
              ✅ Only with your certificate/bundle ID
              ✅ Protected even if extracted
```

---

## Final Checklist

Before going to production:

- [ ] YouTube API key restricted
- [ ] Google Books API key restricted
- [ ] TTS API key restricted (if using direct calls)
- [ ] Tested keys work in your app
- [ ] Tested keys DON'T work in browser
- [ ] Both debug and release certificates added
- [ ] Separate dev and prod keys (optional but recommended)
- [ ] Budget alerts set up
- [ ] Usage monitoring enabled

---

**Once you restrict your keys properly, your direct API implementation is as secure as using Cloud Functions for these read-only APIs!** 🔒


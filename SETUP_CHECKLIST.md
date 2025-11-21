# 🚀 Setup Checklist - Do This NOW!

## ⚠️ URGENT: Security Steps (Do First!)

Since you shared API keys in conversation, regenerate them:

### Step 1: Regenerate Your API Keys

1. **Go to Google Cloud Console**:
   ```
   https://console.cloud.google.com/apis/credentials
   ```

2. **Delete compromised keys**:
   - Find: `AIzaSyBmZKv5FHQbwvSzqCVAGcm2UivNOqdtrb4`
   - Click trash icon → Delete
   - Find: `AIzaSyAYSikkS1oouTe-oCviim-O72IJKO4ozQg`
   - Click trash icon → Delete

3. **Create new keys**:
   - Click "+ CREATE CREDENTIALS" → "API key"
   - Copy the new key immediately
   - Repeat for each key you need

### Step 2: Restrict New Keys Immediately

#### For YouTube/Books API Key (if using one key for both):

```
Click "Edit API key" (pencil icon)

Application restrictions:
  ○ None (temporarily for testing)
  ● Android apps
    Add: 
    - Package: com.soar.wellness
    - SHA-1: [Run command below to get this]
  ● iOS apps
    Add:
    - Bundle ID: com.soar.wellness

API restrictions:
  ● Restrict key
  Select:
    ✓ YouTube Data API v3
    ✓ Google Books API
  
Click "Save"
```

#### For Text-to-Speech API Key:

```
Application restrictions:
  ● Android apps (com.soar.wellness + SHA-1)
  ● iOS apps (com.soar.wellness)

API restrictions:
  ● Restrict key
  Select:
    ✓ Cloud Text-to-Speech API
  
Click "Save"
```

### Step 3: Get Your SHA-1 Fingerprint

**For development (debug keystore):**

```bash
# On macOS/Linux:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Look for:
# SHA1: A1:B2:C3:D4:... ← Copy this
```

**For production (when ready):**
```bash
# Get from your release keystore
keytool -list -v -keystore /path/to/your-release.keystore -alias your-alias
```

### Step 4: Update api_config.dart

Replace with your NEW keys:

```dart
class ApiConfig {
  static const String youtubeApiKey = 'NEW_KEY_HERE';
  static const String googleBooksApiKey = 'NEW_KEY_HERE'; // Can be same as above
  static const String textToSpeechApiKey = 'NEW_KEY_HERE';
  
  // These are fine as-is:
  static const String tmdbApiKey = '9e32438292423421dc5a59fac6ecd29e';
  static const String yelpApiKey = 'x-zb_iv8...';
  
  // Optional - leave as placeholder if not using yet:
  static const String speechToTextApiKey = 'YOUR_SPEECH_TO_TEXT_API_KEY_HERE';
  static const String cloudFunctionsUrl = 'YOUR_CLOUD_FUNCTIONS_URL_HERE';
}
```

### Step 5: Verify .gitignore

Check that api_config.dart won't be committed:

```bash
cd /Users/tylin/Soar
git status
```

You should NOT see `lib/config/api_config.dart` in the list.

If you see it:
```bash
git rm --cached lib/config/api_config.dart
git commit -m "Remove api_config.dart from tracking"
```

---

## ✅ Regular Setup Steps

### Files Status Check

- [x] `lib/config/api_config.dart` - ✅ Has your keys
- [ ] `lib/config/api_config.example.dart` - ✅ Keep this! (Do NOT delete)
- [x] `.gitignore` - ✅ Excludes api_config.dart

### Install Dependencies

```bash
cd /Users/tylin/Soar
flutter pub get
```

### Test Your APIs

```bash
flutter run
```

Then:
1. Go to Recommendations screen
2. Should see YouTube videos ✓
3. Should see Books ✓
4. Should see Movies ✓

Check console for errors.

### Monitor Usage

Bookmark these:
- [API Dashboard](https://console.cloud.google.com/apis/dashboard)
- [Quotas](https://console.cloud.google.com/apis/quotas)
- [Credentials](https://console.cloud.google.com/apis/credentials)

---

## 📝 Your Current API Configuration

| API | Key Status | Needs Restriction? | Notes |
|-----|-----------|-------------------|-------|
| YouTube | ✅ Added | ⚠️ YES - Do now! | Same key as Books |
| Google Books | ✅ Added | ⚠️ YES - Do now! | Same key as YouTube |
| TTS | ✅ Added | ⚠️ YES - Do now! | Separate key |
| TMDB | ✅ Added | ℹ️ If supported | Third-party API |
| Yelp | ✅ Added | ℹ️ N/A | Uses Bearer token |
| Speech-to-Text | ➖ Optional | - | Not needed yet |
| Cloud Functions | ➖ Optional | - | For production TTS |

---

## ⚠️ What NOT to Do

- ❌ **Do NOT delete** `api_config.example.dart`
- ❌ **Do NOT commit** `api_config.dart` to Git
- ❌ **Do NOT share** API keys in conversations/chat/Slack
- ❌ **Do NOT skip** restricting your keys
- ❌ **Do NOT use** production keys for development

---

## ✅ What TO Do

- ✅ **Keep** `api_config.example.dart` for your team
- ✅ **Restrict** all API keys in Google Cloud Console
- ✅ **Monitor** usage weekly
- ✅ **Use** separate keys for dev and production (later)
- ✅ **Test** thoroughly before deploying

---

## 🆘 If You See Errors

### "API key not valid"
- Wait 5-10 minutes after creating/restricting keys
- Check restrictions match your package name exactly
- Verify SHA-1 is from correct keystore

### "Quota exceeded"
- Check usage in Cloud Console
- Implement caching (see recommendations)
- Consider upgrading quota if needed

### "403 Forbidden"
- Key restrictions are blocking you
- Double-check package name: `com.soar.wellness`
- Verify bundle ID for iOS

---

## 📚 Reference Docs

- `HOW_TO_RESTRICT_API_KEYS.md` - Detailed restriction guide
- `API_SECURITY_GUIDE.md` - Security best practices
- `DIRECT_API_IMPLEMENTATION_SUMMARY.md` - Your implementation verified

---

## Next Steps Priority

1. 🔴 **HIGH PRIORITY**: Regenerate exposed API keys
2. 🔴 **HIGH PRIORITY**: Restrict new keys in Console
3. 🟡 **MEDIUM**: Test app with new keys
4. 🟢 **LOW**: Set up monitoring/alerts
5. 🟢 **LOW**: Consider separate dev/prod keys

---

**Don't forget: Keep `api_config.example.dart` - it's meant to be there!** ✅


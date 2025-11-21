# Google Cloud API Keys Setup Guide

This guide will walk you through setting up Google Cloud API keys for the SOAR app.

## Step 1: Create or Select a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Either:
   - **Create a new project**: Click "Select a project" > "New Project"
     - Give it a name (e.g., "SOAR App")
     - Click "Create"
   - **Or use existing project**: Click "Select a project" and choose one

## Step 2: Enable Required APIs

For each API you need, follow these steps:

1. In the Google Cloud Console, click **"APIs & Services"** > **"Library"**
2. Search for and enable these APIs:

### Required APIs for SOAR:

#### **YouTube Data API v3**
- Search for "YouTube Data API v3"
- Click on it
- Click **"Enable"**
- Use case: Fetch podcast videos and related content

#### **Google Books API**
- Search for "Google Books API"
- Click on it
- Click **"Enable"**
- Use case: Book recommendations for wellness

#### **Optional APIs** (enable if needed):

- **Cloud Speech-to-Text API**: For voice input features
- **Cloud Text-to-Speech API**: For audio content generation
- **Maps JavaScript API**: If you need location services
- **Places API**: For location-based recommendations

## Step 3: Create API Keys

1. Go to **"APIs & Services"** > **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"** > **"API key"**
3. A dialog will show your new API key - **COPY IT IMMEDIATELY**
4. Click **"RESTRICT KEY"** (recommended for security)

## Step 4: Restrict Your API Keys (IMPORTANT for Security)

For each API key you create:

### Application Restrictions:
- **For mobile app**: Choose "iOS apps" or "Android apps"
  - For Android: Add your package name `com.soar.wellness` and SHA-1 fingerprint
  - For iOS: Add your bundle ID `com.soar.wellness`
- **For testing**: Choose "None" (but be careful!)

### API Restrictions:
- Choose **"Restrict key"**
- Select only the APIs this key should access:
  - ✓ YouTube Data API v3
  - ✓ Google Books API
  - ✓ Other APIs as needed

### Example: YouTube API Key Setup
1. Create API key
2. Click "Edit API key"
3. Under "API restrictions" → Select "Restrict key"
4. Check only "YouTube Data API v3"
5. Click "Save"

## Step 5: Add Keys to Your App

1. Open the file: `lib/config/api_config.dart`
2. Replace the placeholder values with your actual API keys:

```dart
class ApiConfig {
  static const String youtubeApiKey = 'AIzaSy...'; // Your actual key
  static const String googleBooksApiKey = 'AIzaSy...'; // Your actual key
  // ... other keys
}
```

**IMPORTANT**: 
- ✅ The file `lib/config/api_config.dart` is already in `.gitignore`
- ✅ Your keys will NOT be committed to Git
- ❌ NEVER commit actual API keys to version control
- ❌ NEVER share your API keys publicly

## Step 6: Test Your Setup

Run your app and verify the APIs are working:

```bash
flutter run
```

Check for any API-related errors in the console.

## Step 7: Monitor API Usage

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **"APIs & Services"** > **"Dashboard"**
3. You can see:
   - API calls per day
   - Errors
   - Quota usage

## Quota and Pricing

### Free Tier Quotas:

- **YouTube Data API v3**: 10,000 units/day (free)
  - Each search = ~100 units
  - Each video details request = ~1 unit

- **Google Books API**: 1,000 requests/day (free)

- **Speech-to-Text**: 60 minutes/month (free)
- **Text-to-Speech**: 1 million characters/month (free)

### If You Exceed Free Tier:
- You'll need to enable billing
- Set up budget alerts
- Review pricing at [Google Cloud Pricing](https://cloud.google.com/pricing)

## Best Practices

### Security:
1. ✅ Always restrict API keys to specific APIs
2. ✅ Use application restrictions (iOS/Android package names)
3. ✅ Rotate keys periodically
4. ✅ Monitor usage for unusual activity
5. ✅ Use different keys for development and production
6. ❌ Never hardcode keys in public repositories

### Development vs Production:
Consider having separate API keys for:
- **Development**: Less restricted, easier testing
- **Production**: Fully restricted, monitored closely

### For Team Development:
1. Share the `api_config.example.dart` file (it's safe)
2. Each developer gets their own API keys
3. Keys stay local in `api_config.dart` (ignored by Git)

## Troubleshooting

### "API key not valid" error:
- ✓ Check if the API is enabled in Cloud Console
- ✓ Verify API restrictions match your app
- ✓ Wait a few minutes for changes to propagate
- ✓ Check if key has correct application restrictions

### "Quota exceeded" error:
- Check your usage in Cloud Console
- Consider upgrading or optimizing API calls
- Implement caching to reduce redundant requests

### "This API project is not authorized" error:
- Make sure the API is enabled
- Check application restrictions (package name/bundle ID)
- Verify API restrictions list includes the required API

## Alternative: Using Environment Variables (Optional)

For server-side code or Cloud Functions, use environment variables instead:

```bash
# Set in Firebase Functions
firebase functions:config:set \
  youtube.key="YOUR_YOUTUBE_KEY" \
  books.key="YOUR_GOOGLE_BOOKS_KEY"
```

Then access in your Cloud Functions:

```javascript
const functions = require('firebase-functions');
const youtubeKey = functions.config().youtube.key;
```

## Additional Resources

- [Google Cloud Console](https://console.cloud.google.com/)
- [YouTube Data API Documentation](https://developers.google.com/youtube/v3)
- [Google Books API Documentation](https://developers.google.com/books)
- [API Key Best Practices](https://cloud.google.com/docs/authentication/api-keys)

## Support

If you run into issues:
1. Check the [Google Cloud Status Dashboard](https://status.cloud.google.com/)
2. Review [Stack Overflow](https://stackoverflow.com/questions/tagged/google-cloud-platform)
3. Consult [Google Cloud Support](https://cloud.google.com/support)

---

**Remember**: Keep your API keys secret and never commit them to version control! 🔒


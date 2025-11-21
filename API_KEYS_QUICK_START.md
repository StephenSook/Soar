# 🔑 API Keys Quick Start Guide

## What I've Set Up For You

✅ Created `/lib/config/api_config.dart` - Your API keys configuration file  
✅ Added `.gitignore` entries - Your keys won't be committed to Git  
✅ Your services are already connected - They're importing and using the config

## Next Steps (Takes about 10 minutes)

### 1. Get Your Google Cloud API Keys

Go to [Google Cloud Console](https://console.cloud.google.com/) and:

1. **Create/Select a Project**
2. **Enable These APIs** (from "APIs & Services" > "Library"):
   - ✓ YouTube Data API v3
   - ✓ Google Books API
   - ✓ (Optional) Cloud Text-to-Speech API

3. **Create API Keys** (from "APIs & Services" > "Credentials"):
   - Click "+ CREATE CREDENTIALS" > "API key"
   - Copy each key immediately
   - Click "RESTRICT KEY" for security (recommended)

### 2. Add Your Keys to the App

Open `/lib/config/api_config.dart` and replace the placeholder values:

```dart
static const String youtubeApiKey = 'AIzaSyABC...'; // ← Paste your key here
static const String googleBooksApiKey = 'AIzaSyDEF...'; // ← Paste your key here
```

### 3. Test It

Run your app:
```bash
flutter run
```

Check the recommendations and podcast features to make sure the APIs work!

## Files Created

1. **`/lib/config/api_config.dart`** - Your actual keys (PRIVATE, in .gitignore)
2. **`/lib/config/api_config.example.dart`** - Template file (SAFE to share)
3. **`/GOOGLE_CLOUD_SETUP.md`** - Detailed setup guide
4. **`/API_KEYS_QUICK_START.md`** - This file

## Where Keys Are Used

Your app services are already set up to use these keys:

- **`recommendation_service.dart`** uses:
  - YouTube API → For video recommendations
  - Google Books API → For book recommendations
  - TMDB API → For movie recommendations
  - Yelp API → For therapist recommendations

- **`podcast_service.dart`** uses:
  - Cloud Functions URL → For generating voice podcasts

## Important Security Notes

🔒 **DO:**
- Keep your keys in `api_config.dart`
- Use API restrictions in Google Cloud Console
- Monitor your usage in Cloud Console
- Use different keys for dev/production

❌ **DON'T:**
- Commit `api_config.dart` to Git (it's already in .gitignore)
- Share your keys publicly
- Use the same keys for multiple projects
- Ignore quota exceeded warnings

## Need More Help?

- **Detailed Guide**: See `/GOOGLE_CLOUD_SETUP.md`
- **Firebase Setup**: See `/SETUP_GUIDE.md`
- **Google Cloud Console**: https://console.cloud.google.com/

## Free Tier Quotas

- **YouTube API**: 10,000 units/day (free)
- **Google Books API**: 1,000 requests/day (free)
- **TTS API**: 1M characters/month (free)

You'll get plenty of free usage for development and testing!

---

**Quick tip**: Start with just YouTube and Google Books APIs. Add others as you need them! 🚀


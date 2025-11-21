const functions = require('firebase-functions');
const admin = require('firebase-admin');
const textToSpeech = require('@google-cloud/text-to-speech');
const {Storage} = require('@google-cloud/storage');
const axios = require('axios');
const {v4: uuidv4} = require('uuid');

admin.initializeApp();
const db = admin.firestore();
const storage = new Storage();
const ttsClient = new textToSpeech.TextToSpeechClient();

// API Keys (should be stored in Firebase config)
const TMDB_API_KEY = functions.config().tmdb?.key || process.env.TMDB_API_KEY;
const YOUTUBE_API_KEY = functions.config().youtube?.key || process.env.YOUTUBE_API_KEY;
const YELP_API_KEY = functions.config().yelp?.key || process.env.YELP_API_KEY;

/**
 * Generate personalized recommendations based on user mood and profile
 */
exports.getRecommendations = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated',
    );
  }

  const {mood, userProfile} = data;
  const recommendations = [];

  try {
    // Fetch movies from TMDB
    const movies = await fetchMovies(mood);
    recommendations.push(...movies);

    // Fetch videos from YouTube
    const videos = await fetchVideos(mood);
    recommendations.push(...videos);

    // Fetch therapists from Yelp
    const therapists = await fetchTherapists(userProfile.location);
    recommendations.push(...therapists);

    // Add affirmation
    const affirmation = getAffirmation();
    recommendations.push(affirmation);

    return {recommendations};
  } catch (error) {
    console.error('Error fetching recommendations:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Failed to fetch recommendations',
    );
  }
});

/**
 * Generate AI voice podcast based on user's mood and history
 */
exports.generatePodcast = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated',
    );
  }

  const {text, voice = 'en-US-Neural2-F', languageCode = 'en-US'} = data;
  const userId = context.auth.uid;

  try {
    // Prepare TTS request
    const request = {
      input: {text},
      voice: {
        languageCode,
        name: voice,
      },
      audioConfig: {
        audioEncoding: 'MP3',
        speakingRate: 0.95,
        pitch: 0.0,
      },
    };

    // Generate audio
    const [response] = await ttsClient.synthesizeSpeech(request);
    const audioContent = response.audioContent;

    // Upload to Cloud Storage - use default bucket
    const bucket = admin.storage().bucket();
    const fileName = `podcasts/${userId}/${uuidv4()}.mp3`;
    const file = bucket.file(fileName);

    await file.save(audioContent, {
      metadata: {
        contentType: 'audio/mpeg',
        cacheControl: 'public, max-age=31536000',
        metadata: {
          userId,
          createdAt: new Date().toISOString(),
        },
      },
      public: true,
    });

    // Get the public download URL with proper CORS headers
    const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;

    return {audioUrl: publicUrl};
  } catch (error) {
    console.error('Error generating podcast:', error);
    throw new functions.https.HttpsError(
        'internal',
        'Failed to generate podcast',
    );
  }
});

/**
 * Send daily mood reminder notification
 */
exports.sendDailyReminders = functions.pubsub
    .schedule('every day 08:00')
    .timeZone('America/New_York')
    .onRun(async (context) => {
      // Get all users who have notifications enabled
      const usersSnapshot = await db.collection('users')
          .where('notificationsEnabled', '==', true)
          .get();

      const notifications = [];

      usersSnapshot.forEach((doc) => {
        const user = doc.data();
        if (user.fcmToken) {
          notifications.push({
            token: user.fcmToken,
            notification: {
              title: 'Time for your daily check-in! 🌟',
              body: 'Take a moment to reflect on your mood',
            },
            data: {
              type: 'mood_reminder',
            },
          });
        }
      });

      // Send notifications in batches
      const batchSize = 500;
      for (let i = 0; i < notifications.length; i += batchSize) {
        const batch = notifications.slice(i, i + batchSize);
        await admin.messaging().sendAll(batch);
      }

      console.log(`Sent ${notifications.length} daily reminders`);
      return null;
    });

/**
 * Notify community members of new message
 */
exports.notifyNewMessage = functions.firestore
    .document('communityGroups/{groupId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
      const message = snap.data();
      const groupId = context.params.groupId;

      // Get group data
      const groupDoc = await db.collection('communityGroups').doc(groupId).get();
      const group = groupDoc.data();

      // Get all group members except the sender
      const memberIds = group.memberIds.filter((id) => id !== message.senderId);

      // Get FCM tokens for members
      const usersSnapshot = await db.collection('users')
          .where(admin.firestore.FieldPath.documentId(), 'in', memberIds)
          .get();

      const notifications = [];
      usersSnapshot.forEach((doc) => {
        const user = doc.data();
        if (user.fcmToken) {
          notifications.push({
            token: user.fcmToken,
            notification: {
              title: `New message in ${group.name}`,
              body: `${message.senderAlias}: ${message.text.substring(0, 100)}`,
            },
            data: {
              type: 'community_message',
              groupId,
              messageId: snap.id,
            },
          });
        }
      });

      // Send notifications
      if (notifications.length > 0) {
        await admin.messaging().sendAll(notifications);
      }

      return null;
    });

/**
 * Clean up old podcast files (keep only last 7 days)
 */
exports.cleanupOldPodcasts = functions.pubsub
    .schedule('every day 02:00')
    .timeZone('UTC')
    .onRun(async (context) => {
      const bucket = admin.storage().bucket();
      const [files] = await bucket.getFiles({prefix: 'podcasts/'});

      const sevenDaysAgo = Date.now() - (7 * 24 * 60 * 60 * 1000);
      let deletedCount = 0;

      for (const file of files) {
        const [metadata] = await file.getMetadata();
        const createdAt = new Date(metadata.timeCreated).getTime();

        if (createdAt < sevenDaysAgo) {
          await file.delete();
          deletedCount++;
        }
      }

      console.log(`Deleted ${deletedCount} old podcast files`);
      return null;
    });

// Helper Functions

async function fetchMovies(mood) {
  try {
    const genre = getMoodBasedGenre(mood);
    const response = await axios.get(
        `https://api.themoviedb.org/3/discover/movie`,
        {
          params: {
            api_key: TMDB_API_KEY,
            with_genres: genre,
            sort_by: 'popularity.desc',
            page: 1,
          },
        },
    );

    return response.data.results.slice(0, 3).map((movie) => ({
      id: movie.id.toString(),
      type: 'movie',
      title: movie.title,
      description: movie.overview,
      imageUrl: `https://image.tmdb.org/t/p/w500${movie.poster_path}`,
      actionUrl: `https://www.themoviedb.org/movie/${movie.id}`,
      relevanceScore: movie.vote_average,
    }));
  } catch (error) {
    console.error('Error fetching movies:', error);
    return [];
  }
}

async function fetchVideos(mood) {
  try {
    const query = getMoodBasedVideoQuery(mood);
    const response = await axios.get(
        `https://www.googleapis.com/youtube/v3/search`,
        {
          params: {
            part: 'snippet',
            q: query,
            type: 'video',
            maxResults: 3,
            key: YOUTUBE_API_KEY,
          },
        },
    );

    return response.data.items.map((video) => ({
      id: video.id.videoId,
      type: 'video',
      title: video.snippet.title,
      description: video.snippet.description,
      imageUrl: video.snippet.thumbnails.high.url,
      actionUrl: `https://www.youtube.com/watch?v=${video.id.videoId}`,
      relevanceScore: 8.0,
    }));
  } catch (error) {
    console.error('Error fetching videos:', error);
    return [];
  }
}

async function fetchTherapists(location) {
  try {
    const response = await axios.get(
        `https://api.yelp.com/v3/businesses/search`,
        {
          params: {
            term: 'therapist',
            location: location || 'New York, NY',
            limit: 3,
          },
          headers: {
            'Authorization': `Bearer ${YELP_API_KEY}`,
          },
        },
    );

    return response.data.businesses.map((business) => ({
      id: business.id,
      type: 'therapist',
      title: business.name,
      subtitle: business.location.address1,
      description: `Rating: ${business.rating} ⭐ (${business.review_count} reviews)`,
      imageUrl: business.image_url,
      actionUrl: business.url,
      relevanceScore: business.rating,
    }));
  } catch (error) {
    console.error('Error fetching therapists:', error);
    return [];
  }
}

function getAffirmation() {
  const affirmations = [
    'You are stronger than you think.',
    'Every day is a new opportunity.',
    'You deserve peace and happiness.',
    'Your feelings are valid.',
    'You are enough, just as you are.',
  ];

  return {
    id: 'affirmation_' + Date.now(),
    type: 'affirmation',
    title: 'Daily Affirmation',
    description: affirmations[Date.now() % affirmations.length],
    relevanceScore: 9.0,
  };
}

function getMoodBasedGenre(mood) {
  const genreMap = {
    'sad': 35, // Comedy
    'verySad': 35, // Comedy
    'anxious': 18, // Drama
    'stressed': 18, // Drama
    'happy': 12, // Adventure
    'veryHappy': 12, // Adventure
    'calm': 99, // Documentary
  };

  return genreMap[mood] || 35;
}

function getMoodBasedVideoQuery(mood) {
  const queryMap = {
    'anxious': 'calming meditation anxiety relief',
    'stressed': 'stress relief breathing exercise',
    'sad': 'motivational uplifting',
    'tired': 'energizing morning yoga',
  };

  return queryMap[mood] || 'guided meditation mindfulness';
}


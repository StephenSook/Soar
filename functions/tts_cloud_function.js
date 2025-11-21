/**
 * Google Cloud Function for Text-to-Speech
 * 
 * This is the RECOMMENDED approach for production because:
 * 1. API keys stay secure on the server
 * 2. Better error handling
 * 3. Can store audio files in Cloud Storage
 * 4. Easier to monitor and rate-limit
 * 
 * Setup:
 * 1. Enable Cloud Text-to-Speech API in Google Cloud Console
 * 2. Deploy this function: firebase deploy --only functions
 * 3. The function will use Firebase's service account (no API key needed!)
 */

const functions = require('firebase-functions');
const textToSpeech = require('@google-cloud/text-to-speech');
const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

// Initialize Firebase Admin (if not already done in index.js)
if (!admin.apps.length) {
  admin.initializeApp();
}

const ttsClient = new textToSpeech.TextToSpeechClient();

/**
 * Generate podcast audio from text
 * 
 * @param {string} text - The text to convert to speech
 * @param {string} voice - Voice name (e.g., 'en-US-Neural2-F')
 * @param {string} languageCode - Language code (e.g., 'en-US')
 * @param {number} speakingRate - Speaking rate (0.25 to 4.0, default 1.0)
 * @param {number} pitch - Voice pitch (-20.0 to 20.0, default 0.0)
 * 
 * @returns {object} - { audioUrl: string, success: boolean }
 */
exports.generatePodcast = functions.https.onCall(async (data, context) => {
  try {
    // Verify user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to generate podcasts.'
      );
    }

    const {
      text,
      voice = 'en-US-Neural2-F',
      languageCode = 'en-US',
      speakingRate = 1.0,
      pitch = 0.0,
    } = data;

    // Validate input
    if (!text || typeof text !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Text parameter is required and must be a string.'
      );
    }

    // Limit text length to prevent abuse (adjust as needed)
    const maxLength = 5000; // ~5-10 minutes of speech
    if (text.length > maxLength) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Text is too long. Maximum length is ${maxLength} characters.`
      );
    }

    // Construct the request for Google Cloud TTS
    const request = {
      input: { text },
      voice: {
        languageCode,
        name: voice,
      },
      audioConfig: {
        audioEncoding: 'MP3',
        speakingRate,
        pitch,
        effectsProfileId: ['small-bluetooth-speaker-class-device'],
      },
    };

    // Perform the text-to-speech request
    const [response] = await ttsClient.synthesizeSpeech(request);

    // Generate unique filename
    const fileName = `podcasts/${context.auth.uid}/${uuidv4()}.mp3`;

    // Upload to Firebase Storage
    const bucket = admin.storage().bucket();
    const file = bucket.file(fileName);

    await file.save(response.audioContent, {
      metadata: {
        contentType: 'audio/mpeg',
        metadata: {
          userId: context.auth.uid,
          generatedAt: new Date().toISOString(),
          voice,
          languageCode,
        },
      },
    });

    // Make the file publicly accessible (or use signed URLs for private access)
    // For public access:
    await file.makePublic();
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    // For private access with signed URL (expires after 7 days):
    // const [signedUrl] = await file.getSignedUrl({
    //   action: 'read',
    //   expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
    // });

    // Save metadata to Firestore
    await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .collection('podcasts')
      .add({
        audioUrl: publicUrl,
        script: text,
        voice,
        languageCode,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        listenedAt: null,
        completed: false,
      });

    return {
      success: true,
      audioUrl: publicUrl,
      fileName,
    };

  } catch (error) {
    console.error('Error generating podcast:', error);
    
    // Return user-friendly error
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      'Failed to generate podcast. Please try again later.',
      error.message
    );
  }
});

/**
 * HTTP endpoint version (for testing or direct API calls)
 * Use the callable function above for production
 */
exports.generatePodcastHttp = functions.https.onRequest(async (req, res) => {
  // Set CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    const { text, voice = 'en-US-Neural2-F', languageCode = 'en-US' } = req.body;

    if (!text) {
      res.status(400).json({ error: 'Text parameter is required' });
      return;
    }

    const request = {
      input: { text },
      voice: { languageCode, name: voice },
      audioConfig: { audioEncoding: 'MP3' },
    };

    const [response] = await ttsClient.synthesizeSpeech(request);

    // Return base64 encoded audio
    res.json({
      success: true,
      audioContent: response.audioContent.toString('base64'),
    });

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to generate speech' });
  }
});


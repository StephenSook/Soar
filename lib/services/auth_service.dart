import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Conditionally import google_sign_in only for non-web platforms
import 'package:google_sign_in/google_sign_in.dart'
    if (dart.library.html) '../utils/google_sign_in_stub.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn? _googleSignIn;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  AuthService() {
    // Initialize GoogleSignIn only for non-web platforms
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
    }
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadUserModel(user.uid);
    } else {
      _currentUserModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUserModel = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmail(String email, String password, {
    String? displayName,
    int? age,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _createUserDocument(
          credential.user!,
          displayName: displayName,
          age: age,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.message}');
      rethrow;
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.message}');
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web, use popup-based sign-in
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        
        if (userCredential.user != null) {
          await _createUserDocument(userCredential.user!);
        }
        
        return userCredential;
      }
      
      // For mobile platforms
      if (_googleSignIn == null) {
        throw Exception('Google Sign In not available on this platform');
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  // Sign in with Apple (iOS)
  // TODO: Implement Apple Sign In when running on iOS
  Future<UserCredential?> signInWithApple() async {
    // Requires apple_sign_in package and iOS configuration
    throw UnimplementedError('Apple Sign In not yet implemented');
  }

  // Create or update user document in Firestore
  Future<void> _createUserDocument(User user, {
    String? displayName,
    int? age,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final newUser = UserModel(
        id: user.uid,
        email: user.email!,
        displayName: displayName ?? user.displayName,
        photoUrl: user.photoURL,
        age: age,
        createdAt: DateTime.now(),
      );
      await userDoc.set(newUser.toFirestore());
      _currentUserModel = newUser;
    } else {
      await _loadUserModel(user.uid);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    int? age,
    List<String>? interests,
    List<String>? mentalHealthHistory,
    Map<String, bool>? contentPreferences,
    String? moodCheckInTime,
    String? communityAlias,
  }) async {
    if (currentUser == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (age != null) updates['age'] = age;
    if (interests != null) updates['interests'] = interests;
    if (mentalHealthHistory != null) updates['mentalHealthHistory'] = mentalHealthHistory;
    if (contentPreferences != null) updates['contentPreferences'] = contentPreferences;
    if (moodCheckInTime != null) updates['moodCheckInTime'] = moodCheckInTime;
    if (communityAlias != null) updates['communityAlias'] = communityAlias;

    await _firestore.collection('users').doc(currentUser!.uid).update(updates);
    await _loadUserModel(currentUser!.uid);
    notifyListeners();
  }

  // Sign Out
  Future<void> signOut() async {
    if (_googleSignIn != null && !kIsWeb) {
      try {
        await _googleSignIn!.signOut();
      } catch (e) {
        debugPrint('Google sign out error: $e');
      }
    }
    await _auth.signOut();
    _currentUserModel = null;
    notifyListeners();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Delete Account
  Future<void> deleteAccount() async {
    if (currentUser == null) return;

    // Delete user data from Firestore
    await _firestore.collection('users').doc(currentUser!.uid).delete();
    
    // Delete user from Firebase Auth
    await currentUser!.delete();
    
    _currentUserModel = null;
    notifyListeners();
  }
}


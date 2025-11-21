// Stub implementation for web platform where google_sign_in has compatibility issues
// Web uses Firebase Auth popup instead

class GoogleSignIn {
  GoogleSignIn({List<String>? scopes});
  
  Future<GoogleSignInAccount?> signIn() async {
    throw UnsupportedError('Google Sign In not supported on web, use Firebase Auth popup instead');
  }
  
  Future<GoogleSignInAccount?> signOut() async {
    return null;
  }
}

class GoogleSignInAccount {
  Future<GoogleSignInAuthentication> get authentication async {
    throw UnsupportedError('Google Sign In not supported on web');
  }
}

class GoogleSignInAuthentication {
  String? get accessToken => null;
  String? get idToken => null;
}


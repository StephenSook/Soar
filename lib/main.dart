import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/mood_service.dart';
import 'services/notification_service.dart';
import 'services/recommendation_service.dart';
import 'services/podcast_service.dart';
import 'services/community_service.dart';
import 'services/journal_service.dart';
import 'services/meditation_service.dart';
import 'services/breathing_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'utils/theme.dart';

// Background task callback
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Handle daily mood check-in reminder
    if (task == 'dailyMoodReminder') {
      await NotificationService().showDailyMoodReminder();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services (notifications disabled for web)
  // await NotificationService().init();
  // await Workmanager().initialize(callbackDispatcher);
  
  runApp(const SoarApp());
}

class SoarApp extends StatelessWidget {
  const SoarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MoodService()),
        ChangeNotifierProvider(create: (_) => RecommendationService()),
        ChangeNotifierProvider(create: (_) => PodcastService()),
        ChangeNotifierProvider(create: (_) => CommunityService()),
        ChangeNotifierProvider(create: (_) => JournalService()),
        ChangeNotifierProvider(create: (_) => MeditationService()),
        ChangeNotifierProvider(create: (_) => BreathingService()),
      ],
      child: MaterialApp(
        title: 'SOAR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}


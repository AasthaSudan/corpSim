import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:negotium/screens/brief_screen.dart';
import 'package:negotium/screens/scenarios_screen.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  runApp(const NegotiumApp());
}

class NegotiumApp extends StatelessWidget {
  const NegotiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Negotium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: AppRoutes.onboarding,
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: AppRoutes.scenarios,
          page: () => const ScenariosScreen(),
        ),
        GetPage(
          name: AppRoutes.brief,
          page: () => const BriefScreen(),
        ),
        GetPage(
          name: AppRoutes.chat,
          page: () => const ChatScreen(),
        ),
      ],
    );
  }
}
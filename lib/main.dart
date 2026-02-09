import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/services.dart';
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0A0A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await StorageService.instance.init();

  runApp(const NegotiumApp());
}

class NegotiumApp extends StatelessWidget {
  const NegotiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NegotiationProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: MaterialApp(
        title: 'Negotium',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,

        scrollBehavior: kIsWeb
            ? const MaterialScrollBehavior().copyWith(
          scrollbars: true,
        )
            : null,

        home: StorageService.instance.isLoggedIn
            ? const DashboardScreen()
            : const LandingScreen(),
      ),
    );
  }
}
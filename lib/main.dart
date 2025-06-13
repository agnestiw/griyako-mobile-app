import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:griyako/screens/notifications_screen.dart';
import 'package:griyako/widgets/detail_property.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/languages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/form_marketplace_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/detail_property_screen.dart';
import 'utils/app_colors.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real Estate App',
      theme: ThemeData(
        // primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/': (context) => const HomeScreen(),
        '/search_input': (context) => const SearchScreen(),
        '/search_results': (context) => const SearchResultsScreen(),
        '/marketplace': (context) => const MarketplaceScreen(),
        '/languages': (context) => const LanguageScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/form_marketplace': (context) => const FormMarketplaceScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'routes/app_routes.dart';

import 'package:iqnock/presentation/screens/leaderboard/leaderboard_screen.dart'; //bisa dihapus, dibuat cek desain leaderboard

void main() {
  runApp(const IqnockApp());
}

class IqnockApp extends StatelessWidget {
  const IqnockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iqnock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Baloo-Regular',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary, width: 2),
          ),
        ),
      ),

      home:
          const LeaderboardScreen(), //bisa dihapus, dibuat cek desain leaderboard
      //initialRoute: AppRoutes.login,
      //onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

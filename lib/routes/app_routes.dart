import 'package:flutter/material.dart';
import '../presentation/screens/auth/welcome_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/game/game_screen.dart';
import '../presentation/screens/leaderboard/leaderboard_screen.dart';
import '../presentation/screens/feedback/feedback_screen.dart';
import '../presentation/screens/account/account_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String game = '/game';
  static const String leaderboard = '/leaderboard';
  static const String feedback = '/feedback';
  static const String account = '/account';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash: // 👈 Tambah case
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case game:
        // Get levelNumber from arguments
        final levelNumber = settings.arguments as int?;
        if (levelNumber == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Error: Level number is required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => GameScreen(startLevelNumber: levelNumber),
        );
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}

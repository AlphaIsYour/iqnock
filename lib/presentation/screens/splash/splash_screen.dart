// pindahkan disini
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      // Fallback: Langsung ke welcome kalau error
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/iqnock.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(75),
                  ),
                  child: const Icon(
                    Icons.emoji_emotions,
                    size: 80,
                    color: AppColors.maroon,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'IQNOCK',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo-Regular',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tebak Gambar Challenge',
              style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 16,
                fontFamily: 'Baloo-Regular',
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Title
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo-Regular',
                ),
              ),
              const SizedBox(height: 40),
              // Logo/Mascot
              Image.asset(
                'assets/logo/iqnock.png',
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.emoji_emotions,
                      size: 100,
                      color: AppColors.maroon,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Description
              const Text(
                'Selamat datang di game kami! Ayo uji kemampuanmu dalam menebak gambar dan raih skor tertinggi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontFamily: 'Baloo-Regular',
                ),
              ),
              const Spacer(),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.maroon,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo-Regular',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo-Regular',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import 'guess_image_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        centerTitle: true,
        title: const Text("Level 1", style: AppText.heading),
        actions: [
          // Info Nyawa
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Image.asset('assets/icons/heart.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text('5', style: AppText.bodyWhite.copyWith(fontSize: 18)),
              ],
            ),
          ),
          // Info Hint
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Image.asset('assets/icons/bulb.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text('5', style: AppText.bodyGold.copyWith(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            final int levelNumber = index + 1;
            final bool isUnlocked = levelNumber == 1;

            return GestureDetector(
              onTap: isUnlocked
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GuessImageScreen(levelNumber: levelNumber),
                        ),
                      );
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.red : AppColors.maroon,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked ? AppColors.gold : AppColors.brownGold,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isUnlocked)
                      Text(
                        '$levelNumber',
                        style: AppText.bodyWhite.copyWith(
                          fontSize: 28,
                          color: AppColors.white,
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: AppColors.lightGrey,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$levelNumber',
                            style: AppText.bodyWhite.copyWith(
                              fontSize: 16,
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.maroon,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.gold,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/main_menu.png',
              width: 20,
              height: 20,
            ),
            label: "Main Menu",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/papan_peringkat.png',
              width: 24,
              height: 24,
            ),
            label: "Papan Peringkat",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/kirim_soal.png',
              width: 22,
              height: 22,
            ),
            label: "Kirim Soal",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/akun.png', width: 26, height: 26),
            label: "Akun",
          ),
        ],
      ),
    );
  }
}

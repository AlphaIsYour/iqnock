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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Level 1-10", style: AppText.heading),
        actions: [
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
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: 10,
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked ? AppColors.gold : AppColors.brownGold,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '$levelNumber',
                          style: AppText.bodyWhite.copyWith(
                            fontSize: 24,
                            color: AppColors.white,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock,
                              color: AppColors.lightGrey,
                              size: 24,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$levelNumber',
                              style: AppText.bodyWhite.copyWith(
                                fontSize: 12,
                                color: AppColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

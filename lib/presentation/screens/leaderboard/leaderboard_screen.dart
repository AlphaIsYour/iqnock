import 'package:flutter/material.dart';
import 'package:iqnock/core/constants/app_colors.dart';
import 'package:iqnock/core/constants/app_text.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data leaderboard
    final List<Map<String, String>> leaderboard = List.generate(12, (index) {
      if (index == 11) {
        return {"rank": "${index + 1}", "name": "Kamu", "points": "xxx poin"};
      } else {
        return {
          "rank": "${index + 1}",
          "name": "User",
          "points": "x.xxx.xxx poin",
        };
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        centerTitle: true,
        title: const Text("Papan Peringkat", style: AppText.heading),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final item = leaderboard[index];
            final bool isUser = item['name'] == 'Kamu';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: isUser ? AppColors.red : AppColors.maroon,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Rank badge (bintang)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              isUser
                                  ? 'assets/icons/star_highlight.png' // badge terang
                                  : 'assets/icons/star_offlight.png', // badge gelap
                              width: 48,
                              height: 48,
                            ),
                            Text(
                              item['rank']!,
                              style: isUser
                                  ? AppText.bodyWhite.copyWith(
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          AppColors.white, // teks putih terang
                                    )
                                  : AppText.bodyWhite.copyWith(
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          AppColors.lightGrey, // teks abu-abu
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Username
                        Text(
                          item['name']!,
                          style: isUser
                              ? AppText.bodyWhite.copyWith(
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.white, // teks putih terang
                                )
                              : AppText.bodyWhite.copyWith(
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.lightGrey, // teks abu-abu
                                ),
                        ),
                      ],
                    ),
                    // Points
                    Text(
                      item['points']!,
                      style: AppText.bodyGold.copyWith(
                        //fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isUser
                            ? AppColors
                                  .gold // poin emas terang
                            : AppColors.brownGold, // poin emas gelap
                      ),
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
        selectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
        unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
        currentIndex: 1,
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
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/feedback');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/account');
              break;
            case 4:
              break;
          }
        },
      ),
    );
  }
}

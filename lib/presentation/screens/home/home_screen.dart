import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo/iqnock.png', height: 40),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings, color: AppColors.maroon, size: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Total Poin Section
          Container(
            width: double.infinity,
            color: AppColors.maroon,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Poin',
                  style: AppText.bodyGold.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '0',
                    style: AppText.bodyWhite.copyWith(
                      fontSize: 16,
                      color: AppColors.maroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Level List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLevelCard(context, 'LEVEL 1-10', 'Mulai', true),
                const SizedBox(height: 15),
                _buildLevelCard(context, 'LEVEL 11-20', 'Terkunci', false),
                const SizedBox(height: 15),
                _buildLevelCard(context, 'LEVEL 21-30', 'Terkunci', false),
                const SizedBox(height: 15),
                _buildLevelCard(context, 'LEVEL 31-40', 'Terkunci', false),
                const SizedBox(height: 15),
                _buildLevelCard(context, 'LEVEL 41-50', 'Terkunci', false),
                const SizedBox(height: 15),
                _buildLevelCard(context, 'LEVEL 51-60', 'Terkunci', false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.maroon,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.gold,
        currentIndex: 0,
        selectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
        unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
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
              break;
            case 1:
              Navigator.pushNamed(context, '/leaderboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/feedback');
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

  Widget _buildLevelCard(
    BuildContext context,
    String level,
    String buttonText,
    bool isUnlocked,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              level,
              style: AppText.bodyWhite.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.lock, color: AppColors.gold, size: 20),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: isUnlocked
                  ? () {
                      Navigator.pushNamed(context, '/game');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.maroon,
                disabledBackgroundColor: AppColors.gold.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                buttonText,
                style: AppText.bodyWhite.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.maroon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

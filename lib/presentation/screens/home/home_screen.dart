import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/level_model.dart';
import '../game/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<LevelModel> _levels = [];
  UserStats? _userStats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getLevels();

      if (response['success'] == true) {
        final data = response['data'];

        setState(() {
          _levels = (data['levels'] as List)
              .map((json) => LevelModel.fromJson(json))
              .toList();
          _userStats = UserStats.fromJson(data['user_stats']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load levels';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToGame(int levelNumber) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(startLevelNumber: levelNumber),
      ),
    );

    // Refresh data setelah kembali dari game screen
    if (result == true) {
      _loadLevels();
    }
  }

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
            GestureDetector(
              onTap: () {
                // TODO: Navigate to settings
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings, color: AppColors.maroon, size: 20),
              ),
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
                    '${_userStats?.coins ?? 0}',
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
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.maroon),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppText.bodyWhite.copyWith(
                  color: AppColors.maroon,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLevels,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_levels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: AppColors.maroon),
            const SizedBox(height: 16),
            Text(
              'No levels available',
              style: AppText.bodyWhite.copyWith(
                color: AppColors.maroon,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Group levels by 10s (1-10, 11-20, etc)
    Map<String, List<LevelModel>> groupedLevels = {};
    for (var level in _levels) {
      int groupStart = ((level.levelNumber - 1) ~/ 10) * 10 + 1;
      int groupEnd = groupStart + 9;
      String groupKey = 'LEVEL $groupStart-$groupEnd';

      if (!groupedLevels.containsKey(groupKey)) {
        groupedLevels[groupKey] = [];
      }
      groupedLevels[groupKey]!.add(level);
    }

    return RefreshIndicator(
      onRefresh: _loadLevels,
      color: AppColors.maroon,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: groupedLevels.entries.map((entry) {
          String groupName = entry.key;
          List<LevelModel> levelsInGroup = entry.value;

          // Check if any level in group is unlocked
          bool hasUnlockedLevel = levelsInGroup.any((l) => l.isUnlocked);

          // Get first level in group
          LevelModel firstLevel = levelsInGroup.first;

          // Count completed levels in group
          int completedCount = levelsInGroup.where((l) => l.isCompleted).length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildLevelCard(
              context,
              groupName,
              hasUnlockedLevel,
              firstLevel.levelNumber,
              completedCount,
              levelsInGroup.length,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    String levelName,
    bool isUnlocked,
    int startLevelNumber,
    int completedCount,
    int totalCount,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        levelName,
                        style: AppText.bodyWhite.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isUnlocked)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.lock,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  if (isUnlocked && completedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$completedCount/$totalCount selesai',
                        style: AppText.bodyGold.copyWith(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isUnlocked
                  ? () => _navigateToGame(startLevelNumber)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.maroon,
                disabledBackgroundColor: AppColors.gold.withOpacity(0.5),
                disabledForegroundColor: AppColors.maroon.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                isUnlocked ? 'Mulai' : 'Terkunci',
                style: AppText.bodyWhite.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isUnlocked
                      ? AppColors.maroon
                      : AppColors.maroon.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.maroon,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.gold.withOpacity(0.6),
      currentIndex: 0,
      selectedLabelStyle: AppText.bodyGold.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: AppColors.gold,
          ),
          label: "Main Menu",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/papan_peringkat.png',
            width: 24,
            height: 24,
            color: AppColors.gold,
          ),
          label: "Papan Peringkat",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/kirim_soal.png',
            width: 22,
            height: 22,
            color: AppColors.gold,
          ),
          label: "Masukan",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
            'assets/icons/akun.png',
            width: 26,
            height: 26,
            color: AppColors.gold,
          ),
          label: "Akun",
        ),
      ],
      onTap: (index) async {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            await Navigator.pushNamed(context, '/leaderboard');
            // Refresh data setelah kembali
            _loadLevels();
            break;
          case 2:
            await Navigator.pushNamed(context, '/feedback');
            break;
          case 3:
            await Navigator.pushReplacementNamed(context, '/account');
            break;
        }
      },
    );
  }
}

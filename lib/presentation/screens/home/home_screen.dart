import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/level_model.dart';

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
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppText.bodyWhite.copyWith(
                color: AppColors.maroon,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLevels,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: AppColors.gold,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_levels.isEmpty) {
      return Center(
        child: Text(
          'No levels available',
          style: AppText.bodyWhite.copyWith(
            color: AppColors.maroon,
            fontSize: 16,
          ),
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

          // Get first unlocked level or first level in group
          LevelModel? representativeLevel = levelsInGroup.firstWhere(
            (l) => l.isUnlocked,
            orElse: () => levelsInGroup.first,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildLevelCard(
              context,
              groupName,
              hasUnlockedLevel ? 'Mulai' : 'Terkunci',
              hasUnlockedLevel,
              representativeLevel,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    String level,
    String buttonText,
    bool isUnlocked,
    LevelModel levelModel,
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
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: levelModel.levelNumber,
                      );
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

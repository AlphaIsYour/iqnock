import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/level_model.dart';
import '../settings/audio_manager.dart';
import '../game/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AudioManager _audioManager = AudioManager();

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
    _audioManager.playSFX('klik.mp3');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(startLevelNumber: levelNumber),
      ),
    );

    if (result == true) {
      _loadLevels();
    }
  }

  Future<void> _unlockPremiumLevel(int levelNumber) async {
    _audioManager.playSFX('klik.mp3');

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.maroon,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Beli Level?',
          style: AppText.bodyGold.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Kamu akan membeli level ini dengan 80 coin. level dalam grup ini akan terbuka.',
          style: AppText.bodyWhite,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: AppText.bodyGold),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.maroon,
            ),
            child: Text(
              'Beli (80 Coin)',
              style: AppText.bodyWhite.copyWith(
                color: AppColors.maroon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );

    try {
      final response = await _apiService.unlockPremiumLevel(levelNumber);
      Navigator.pop(context); // Close loading

      if (response['success'] == true) {
        _audioManager.playSFX('klik.mp3');
        await _loadLevels();

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.maroon,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.gold, size: 32),
                const SizedBox(width: 10),
                Text(
                  'Berhasil!',
                  style: AppText.bodyGold.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              response['message'] ?? 'Level berhasil dibuka!',
              style: AppText.bodyWhite,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.maroon,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.maroon,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.red, size: 32),
                const SizedBox(width: 10),
                Text(
                  'Gagal',
                  style: AppText.bodyGold.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              response['message'] ?? 'Gagal membeli level',
              style: AppText.bodyWhite,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.maroon,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.maroon,
          title: Text('Error', style: AppText.bodyGold),
          content: Text('Terjadi kesalahan: $e', style: AppText.bodyWhite),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.maroon,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo/iqnock.png', height: 40),
            GestureDetector(
              onTap: () async {
                _audioManager.playSFX('klik.mp3');
                await Navigator.pushNamed(context, '/setting');
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
          Container(
            width: double.infinity,
            color: AppColors.maroon,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Coin',
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
              onPressed: () {
                _audioManager.playSFX('klik.mp3');
                _loadLevels();
              },
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

    // Group levels by 10s
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

          LevelModel firstLevel = levelsInGroup.first;
          bool isPremiumGroup = firstLevel.isPremium;

          // Cek apakah grup premium sudah dibeli (level pertama grup sudah unlock)
          bool isGroupPurchased = firstLevel.isUnlocked;

          // Cek apakah ada level yang bisa dimainkan di grup ini
          bool hasPlayableLevel = levelsInGroup.any((l) => l.isUnlocked);

          int completedCount = levelsInGroup.where((l) => l.isCompleted).length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildLevelCard(
              context,
              groupName,
              isPremiumGroup,
              isGroupPurchased,
              hasPlayableLevel,
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
    bool isPremiumGroup,
    bool isPurchased,
    bool canPlay,
    int startLevelNumber,
    int completedCount,
    int totalCount,
  ) {
    // Tentukan status tombol
    String buttonText;
    VoidCallback? onPressed;
    bool isEnabled = true;

    if (isPremiumGroup && !isPurchased) {
      // Premium belum dibeli
      buttonText = 'Beli (80 Coin)';
      onPressed = () => _unlockPremiumLevel(startLevelNumber);
      isEnabled = (_userStats?.coins ?? 0) >= 80;
    } else if (!canPlay) {
      // Level terkunci
      buttonText = 'Terkunci';
      onPressed = null;
      isEnabled = false;
    } else {
      // Level sudah bisa dimainkan
      buttonText = 'Mulai';
      onPressed = () => _navigateToGame(startLevelNumber);
      isEnabled = true;
    }

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
                      if (!canPlay && !isPremiumGroup)
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
                  if (isPurchased && completedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$completedCount/$totalCount selesai',
                        style: AppText.bodyGold.copyWith(fontSize: 12),
                      ),
                    ),
                  if (isPremiumGroup && !isPurchased)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: AppColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Harga: 80 Coin',
                            style: AppText.bodyGold.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isEnabled
                  ? onPressed
                  : () {
                      _audioManager.playSFX('klik.mp3');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled
                    ? AppColors.gold
                    : AppColors.gold.withOpacity(0.5),
                foregroundColor: isEnabled
                    ? AppColors.maroon
                    : AppColors.maroon.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
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
                  fontSize: 13,
                  color: isEnabled
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
        _audioManager.playSFX('klik.mp3');
        switch (index) {
          case 0:
            break;
          case 1:
            await Navigator.pushNamed(context, '/leaderboard');
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

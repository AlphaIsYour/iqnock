import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/level_model.dart';
import '../settings/audio_manager.dart'; // TAMBAHKAN INI
import 'guess_image_screen.dart';

class GameScreen extends StatefulWidget {
  final int startLevelNumber; // Level number dari home_screen

  const GameScreen({super.key, required this.startLevelNumber});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ApiService _apiService = ApiService();
  final AudioManager _audioManager = AudioManager(); // TAMBAHKAN INI

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
          // Filter levels berdasarkan group (1-10, 11-20, dst)
          int groupStart = ((widget.startLevelNumber - 1) ~/ 10) * 10 + 1;
          int groupEnd = groupStart + 9;

          _levels = (data['levels'] as List)
              .map((json) => LevelModel.fromJson(json))
              .where(
                (level) =>
                    level.levelNumber >= groupStart &&
                    level.levelNumber <= groupEnd,
              )
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.red),
              SizedBox(height: 16),
              Text(_errorMessage!, style: AppText.bodyWhite),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                  _loadLevels();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    int groupStart = ((widget.startLevelNumber - 1) ~/ 10) * 10 + 1;
    int groupEnd = groupStart + 9;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () {
            _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
            Navigator.pop(context);
          },
        ),
        title: Text("Level $groupStart-$groupEnd", style: AppText.heading),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Image.asset('assets/icons/heart.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text(
                  '${_userStats?.hearts ?? 0}',
                  style: AppText.bodyWhite.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Image.asset('assets/icons/bulb.png', width: 24, height: 24),
                const SizedBox(width: 4),
                Text(
                  '${_userStats?.hints ?? 0}',
                  style: AppText.bodyGold.copyWith(fontSize: 18),
                ),
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
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final level = _levels[index];

            return GestureDetector(
              onTap: level.isUnlocked
                  ? () async {
                      _audioManager.playSFX('klik.mp3'); // TAMBAHKAN SFX
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GuessImageScreen(levelNumber: level.levelNumber),
                        ),
                      );

                      // Refresh levels setelah kembali dari guess screen
                      if (result == true) {
                        _loadLevels();
                      }
                    }
                  : () {
                      // Play sound berbeda untuk locked level (optional)
                      _audioManager.playSFX('klik.mp3');
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: level.isUnlocked ? AppColors.red : AppColors.maroon,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: level.isUnlocked
                        ? AppColors.gold
                        : AppColors.brownGold,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: level.isUnlocked
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${level.levelNumber}',
                              style: AppText.bodyWhite.copyWith(
                                fontSize: 24,
                                color: AppColors.white,
                              ),
                            ),
                            if (level.isCompleted)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.gold,
                                size: 16,
                              ),
                          ],
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
                              '${level.levelNumber}',
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

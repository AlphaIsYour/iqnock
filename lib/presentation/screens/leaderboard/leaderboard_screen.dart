import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/leaderboard_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _apiService = ApiService();

  List<LeaderboardEntry> _leaderboard = [];
  MyRankResponse? _myRank;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load leaderboard
      final leaderboardResponse = await _apiService.getLeaderboard();

      if (leaderboardResponse['success'] == true) {
        final data = leaderboardResponse['data'] as List;

        setState(() {
          _leaderboard = data
              .map((json) => LeaderboardEntry.fromJson(json))
              .toList();
          _isLoading = false;
        });

        // Load my rank separately (optional)
        _loadMyRank();
      } else {
        setState(() {
          _errorMessage =
              leaderboardResponse['message'] ?? 'Failed to load leaderboard';
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

  Future<void> _loadMyRank() async {
    try {
      final response = await _apiService.getMyRank();
      if (response['success'] == true) {
        setState(() {
          _myRank = MyRankResponse.fromJson(response);
        });
      }
    } catch (e) {
      // Silently fail, my rank is optional
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        centerTitle: true,
        title: const Text("Papan Peringkat", style: AppText.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // My Rank Card
          if (_myRank != null) _buildMyRankCard(),
          // Leaderboard List
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMyRankCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_myRank!.rank}',
                  style: AppText.bodyWhite.copyWith(
                    fontSize: 20,
                    color: AppColors.maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peringkat Saya',
                    style: AppText.bodyGold.copyWith(fontSize: 12),
                  ),
                  Text(
                    '${_myRank!.levelsCompleted} level selesai',
                    style: AppText.bodyWhite.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_myRank!.totalScore}',
                style: AppText.bodyGold.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('poin', style: AppText.bodyWhite.copyWith(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.maroon));
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
              onPressed: _loadLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text('Retry', style: AppText.bodyGold),
            ),
          ],
        ),
      );
    }

    if (_leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.maroon,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data leaderboard',
              style: AppText.bodyWhite.copyWith(
                color: AppColors.maroon,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: AppColors.maroon,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final entry = _leaderboard[index];
          return _buildLeaderboardItem(entry, index);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isCurrentUser = entry.isCurrentUser;
    final isTopThree = entry.rank <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser ? AppColors.red : AppColors.maroon,
          borderRadius: BorderRadius.circular(20),
          border: isTopThree && !isCurrentUser
              ? Border.all(color: AppColors.gold, width: 2)
              : null,
          boxShadow: isCurrentUser
              ? [
                  BoxShadow(
                    color: AppColors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank badge
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isTopThree)
                    Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: entry.rank == 1
                          ? AppColors.gold
                          : entry.rank == 2
                          ? Colors.grey[400]
                          : Colors.brown[400],
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? AppColors.gold
                            : AppColors.brownGold.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    '${entry.rank}',
                    style: AppText.bodyWhite.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser || isTopThree
                          ? AppColors.white
                          : AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Username & levels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.userName,
                    style: AppText.bodyWhite.copyWith(
                      fontSize: 16,
                      fontWeight: isCurrentUser
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrentUser
                          ? AppColors.white
                          : AppColors.lightGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.levelsCompleted} level selesai',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser
                          ? AppColors.gold.withOpacity(0.8)
                          : AppColors.brownGold.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.formattedScore,
                  style: AppText.bodyGold.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? AppColors.gold : AppColors.brownGold,
                  ),
                ),
              ],
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
      selectedLabelStyle: AppText.bodyGold.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: AppText.bodyGold.copyWith(fontSize: 12),
      currentIndex: 1,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/main_menu.png',
            width: 20,
            height: 20,
            color: AppColors.gold.withOpacity(0.6),
          ),
          activeIcon: Image.asset(
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
          label: "Kirim Soal",
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
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            // Already on leaderboard
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

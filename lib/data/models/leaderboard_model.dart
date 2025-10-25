class LeaderboardEntry {
  final int rank;
  final int userId;
  final String userName;
  final int totalScore;
  final int levelsCompleted;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.totalScore,
    required this.levelsCompleted,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Unknown',
      totalScore: json['total_score'] ?? 0,
      levelsCompleted: json['levels_completed'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }

  String get formattedScore {
    if (totalScore >= 1000000) {
      return '${(totalScore / 1000000).toStringAsFixed(1)}M';
    } else if (totalScore >= 1000) {
      return '${(totalScore / 1000).toStringAsFixed(1)}K';
    } else {
      return '$totalScore';
    }
  }
}

class MyRankResponse {
  final int rank;
  final int totalScore;
  final int levelsCompleted;

  MyRankResponse({
    required this.rank,
    required this.totalScore,
    required this.levelsCompleted,
  });

  factory MyRankResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return MyRankResponse(
      rank: data['rank'] ?? 0,
      totalScore: data['total_score'] ?? 0,
      levelsCompleted: data['levels_completed'] ?? 0,
    );
  }
}

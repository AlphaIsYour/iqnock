class LevelModel {
  final int id;
  final int levelNumber;
  final String levelName;
  final bool isPremium;
  final int? coinPrice;
  final int? rewardCoins;
  final bool isUnlocked;
  final bool isCompleted;

  LevelModel({
    required this.id,
    required this.levelNumber,
    required this.levelName,
    required this.isPremium,
    this.coinPrice,
    this.rewardCoins,
    required this.isUnlocked,
    required this.isCompleted,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'],
      levelNumber: json['level_number'],
      levelName: json['level_name'],
      isPremium: json['is_premium'] ?? false,
      coinPrice: json['coin_price'],
      rewardCoins: json['reward_coins'],
      isUnlocked: json['is_unlocked'] ?? false,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_number': levelNumber,
      'level_name': levelName,
      'is_premium': isPremium,
      'coin_price': coinPrice,
      'reward_coins': rewardCoins,
      'is_unlocked': isUnlocked,
      'is_completed': isCompleted,
    };
  }
}

class UserStats {
  final int coins;
  final int hearts;
  final int hints;
  final int currentLevel;

  UserStats({
    required this.coins,
    required this.hearts,
    required this.hints,
    required this.currentLevel,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      coins: json['coins'] ?? 0,
      hearts: json['hearts'] ?? 0,
      hints: json['hints'] ?? 0,
      currentLevel: json['current_level'] ?? 1,
    );
  }
}

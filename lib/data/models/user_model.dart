class UserModel {
  final int id;
  final String name;
  final String email;
  final int coins;
  final int hearts;
  final int hints;
  final int currentLevel;
  final int totalScore;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.coins,
    required this.hearts,
    required this.hints,
    required this.currentLevel,
    required this.totalScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      coins: json['coins'] ?? 0,
      hearts: json['hearts'] ?? 5,
      hints: json['hints'] ?? 5,
      currentLevel: json['current_level'] ?? 1,
      totalScore: json['total_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'coins': coins,
      'hearts': hearts,
      'hints': hints,
      'current_level': currentLevel,
      'total_score': totalScore,
    };
  }

  String get formattedScore {
    if (totalScore >= 1000000) {
      return '${(totalScore / 1000000).toStringAsFixed(1)}M poin';
    } else if (totalScore >= 1000) {
      return '${(totalScore / 1000).toStringAsFixed(1)}K poin';
    } else {
      return '$totalScore poin';
    }
  }
}

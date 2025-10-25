class QuestionModel {
  final int questionId;
  final int levelNumber;
  final String imageUrl;
  final int points;

  QuestionModel({
    required this.questionId,
    required this.levelNumber,
    required this.imageUrl,
    required this.points,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionId: json['question_id'],
      levelNumber: json['level_number'],
      // Support both image_url and image_data from API
      imageUrl: json['image_data'] ?? json['image_url'] ?? '',
      points: json['points'],
    );
  }
}

class AnswerResponse {
  final bool success;
  final String message;
  final bool isCorrect;
  final int? pointsEarned;
  final int? totalScore;
  final int? coins;
  final int? hearts;
  final int? nextLevelUnlocked;
  final bool? gameOver;

  AnswerResponse({
    required this.success,
    required this.message,
    required this.isCorrect,
    this.pointsEarned,
    this.totalScore,
    this.coins,
    this.hearts,
    this.nextLevelUnlocked,
    this.gameOver,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AnswerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isCorrect: data?['is_correct'] ?? false,
      pointsEarned: data?['points_earned'],
      totalScore: data?['total_score'],
      coins: data?['coins'],
      hearts: data?['hearts'],
      nextLevelUnlocked: data?['next_level_unlocked'],
      gameOver: data?['game_over'],
    );
  }
}

class HintResponse {
  final bool success;
  final String hint;
  final int remainingHints;

  HintResponse({
    required this.success,
    required this.hint,
    required this.remainingHints,
  });

  factory HintResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return HintResponse(
      success: json['success'] ?? false,
      hint: data?['hint'] ?? '',
      remainingHints: data?['remaining_hints'] ?? 0,
    );
  }
}

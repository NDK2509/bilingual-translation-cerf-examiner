import 'dart:convert';

class UserStats {
  final int streak;
  final String? lastPracticeDate;
  final int totalCompleted;
  final double averageScore;
  final Map<String, int> levelDistribution;

  UserStats({
    required this.streak,
    this.lastPracticeDate,
    required this.totalCompleted,
    required this.averageScore,
    required this.levelDistribution,
  });

  factory UserStats.initial() {
    return UserStats(
      streak: 0,
      lastPracticeDate: null,
      totalCompleted: 0,
      averageScore: 0.0,
      levelDistribution: {'B2': 0, 'C1': 0, 'C2': 0},
    );
  }

  UserStats copyWith({
    int? streak,
    String? lastPracticeDate,
    int? totalCompleted,
    double? averageScore,
    Map<String, int>? levelDistribution,
  }) {
    return UserStats(
      streak: streak ?? this.streak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      averageScore: averageScore ?? this.averageScore,
      levelDistribution: levelDistribution ?? this.levelDistribution,
    );
  }

  UserStats recordSession({
    required String cefrLevel,
    required int score,
  }) {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    int newStreak = streak;

    if (lastPracticeDate == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime.parse(lastPracticeDate!);
      final today = DateTime.parse(todayStr);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      } // If difference == 0, streak remains the same
    }

    final newTotal = totalCompleted + 1;
    final newAvg = ((averageScore * totalCompleted) + score) / newTotal;

    final newDistribution = Map<String, int>.from(levelDistribution);
    newDistribution[cefrLevel] = (newDistribution[cefrLevel] ?? 0) + 1;

    return copyWith(
      streak: newStreak,
      lastPracticeDate: todayStr,
      totalCompleted: newTotal,
      averageScore: newAvg,
      levelDistribution: newDistribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'lastPracticeDate': lastPracticeDate,
      'totalCompleted': totalCompleted,
      'averageScore': averageScore,
      'levelDistribution': levelDistribution,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streak: json['streak'] as int? ?? 0,
      lastPracticeDate: json['lastPracticeDate'] as String?,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      averageScore: (json['averageScore'] as num? ?? 0.0).toDouble(),
      levelDistribution: Map<String, int>.from(json['levelDistribution'] ?? {'B2': 0, 'C1': 0, 'C2': 0}),
    );
  }

  String toJsonString() => json.encode(toJson());

  factory UserStats.fromJsonString(String source) =>
      UserStats.fromJson(json.decode(source) as Map<String, dynamic>);
}

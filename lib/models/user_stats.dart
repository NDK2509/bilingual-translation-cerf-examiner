import 'dart:convert';
import 'dart:math' as math;

class UserStats {
  final int streak;
  final int bestStreak;
  final String? lastPracticeDate;
  final int totalCompleted;
  final double averageScore;
  final Map<String, int> levelDistribution;
  final List<String> practiceDates;

  UserStats({
    required this.streak,
    this.bestStreak = 0,
    this.lastPracticeDate,
    required this.totalCompleted,
    required this.averageScore,
    required this.levelDistribution,
    this.practiceDates = const [],
  });

  factory UserStats.initial() {
    return UserStats(
      streak: 0,
      bestStreak: 0,
      lastPracticeDate: null,
      totalCompleted: 0,
      averageScore: 0.0,
      levelDistribution: {'B2': 0, 'C1': 0, 'C2': 0},
      practiceDates: const [],
    );
  }

  // Format a DateTime as YYYY-MM-DD
  static String formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // Checks if user practiced today
  bool get hasPracticedToday {
    if (lastPracticeDate == null) return false;
    final todayStr = formatDate(DateTime.now());
    return lastPracticeDate == todayStr;
  }

  // Calculates active streak considering days without practice
  int get activeStreak {
    if (lastPracticeDate == null || streak == 0) return 0;
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final last = DateTime.parse(lastPracticeDate!);
      final lastDay = DateTime(last.year, last.month, last.day);
      final difference = today.difference(lastDay).inDays;

      if (difference == 0 || difference == 1) {
        // 0: practiced today, 1: practiced yesterday (still alive for today)
        return streak;
      }
      return 0; // Streak broken if > 1 day gap
    } catch (_) {
      return streak;
    }
  }

  // Check if user practiced on a specific date
  bool hasPracticedOn(DateTime date) {
    final dateStr = formatDate(date);
    return practiceDates.contains(dateStr);
  }

  UserStats copyWith({
    int? streak,
    int? bestStreak,
    String? lastPracticeDate,
    int? totalCompleted,
    double? averageScore,
    Map<String, int>? levelDistribution,
    List<String>? practiceDates,
  }) {
    return UserStats(
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      averageScore: averageScore ?? this.averageScore,
      levelDistribution: levelDistribution ?? this.levelDistribution,
      practiceDates: practiceDates ?? this.practiceDates,
    );
  }

  UserStats recordSession({
    required String cefrLevel,
    required int score,
    DateTime? customDate,
  }) {
    final sessionDate = customDate ?? DateTime.now();
    final todayStr = formatDate(sessionDate);
    final today = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
    int newStreak = streak;

    if (lastPracticeDate == null) {
      newStreak = 1;
    } else {
      final last = DateTime.parse(lastPracticeDate!);
      final lastDate = DateTime(last.year, last.month, last.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Practicing again on the same day maintains streak
        newStreak = streak > 0 ? streak : 1;
      } else if (difference == 1) {
        // Consecutive calendar day
        newStreak = (streak > 0 ? streak : 0) + 1;
      } else if (difference > 1) {
        // Streak broken
        newStreak = 1;
      }
    }

    final newBestStreak = math.max(bestStreak, newStreak);
    final newTotal = totalCompleted + 1;
    final newAvg = ((averageScore * totalCompleted) + score) / newTotal;

    final newDistribution = Map<String, int>.from(levelDistribution);
    newDistribution[cefrLevel] = (newDistribution[cefrLevel] ?? 0) + 1;

    final updatedDates = Set<String>.from(practiceDates)..add(todayStr);
    final sortedDates = updatedDates.toList()..sort();

    return copyWith(
      streak: newStreak,
      bestStreak: newBestStreak,
      lastPracticeDate: todayStr,
      totalCompleted: newTotal,
      averageScore: newAvg,
      levelDistribution: newDistribution,
      practiceDates: sortedDates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'bestStreak': bestStreak,
      'lastPracticeDate': lastPracticeDate,
      'totalCompleted': totalCompleted,
      'averageScore': averageScore,
      'levelDistribution': levelDistribution,
      'practiceDates': practiceDates,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final streak = json['streak'] as int? ?? 0;
    final bestStreak = json['bestStreak'] as int? ?? streak;
    final practiceDatesRaw = json['practiceDates'] as List<dynamic>?;
    final practiceDates = practiceDatesRaw != null
        ? practiceDatesRaw.map((e) => e.toString()).toList()
        : <String>[];

    final lastDate = json['lastPracticeDate'] as String?;
    if (lastDate != null && !practiceDates.contains(lastDate)) {
      practiceDates.add(lastDate);
    }
    practiceDates.sort();

    return UserStats(
      streak: streak,
      bestStreak: bestStreak,
      lastPracticeDate: lastDate,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      averageScore: (json['averageScore'] as num? ?? 0.0).toDouble(),
      levelDistribution: Map<String, int>.from(
        json['levelDistribution'] ?? {'B2': 0, 'C1': 0, 'C2': 0},
      ),
      practiceDates: practiceDates,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory UserStats.fromJsonString(String source) =>
      UserStats.fromJson(json.decode(source) as Map<String, dynamic>);
}

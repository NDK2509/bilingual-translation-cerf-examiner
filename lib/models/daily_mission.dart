import 'dart:convert';

enum MissionType {
  translation,
  cloze,
  wordMatch,
  highScore, // score >= 80%
  totalExercises,
  saveWord,
}

class DailyMission {
  final String id;
  final String title;
  final String description;
  final String iconKey; // 'translation', 'cloze', 'wordmatch', 'trophy', 'fire', 'bookmark'
  final int target;
  int current;
  final int expReward;
  bool isClaimed;
  final MissionType type;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.target,
    this.current = 0,
    required this.expReward,
    this.isClaimed = false,
    required this.type,
  });

  bool get isCompleted => current >= target;
  double get progressRatio => target <= 0 ? 1.0 : (current / target).clamp(0.0, 1.0);

  DailyMission copyWith({
    String? id,
    String? title,
    String? description,
    String? iconKey,
    int? target,
    int? current,
    int? expReward,
    bool? isClaimed,
    MissionType? type,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      target: target ?? this.target,
      current: current ?? this.current,
      expReward: expReward ?? this.expReward,
      isClaimed: isClaimed ?? this.isClaimed,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconKey': iconKey,
    'target': target,
    'current': current,
    'expReward': expReward,
    'isClaimed': isClaimed,
    'type': type.name,
  };

  factory DailyMission.fromJson(Map<String, dynamic> json) => DailyMission(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    iconKey: json['iconKey'] as String? ?? 'trophy',
    target: json['target'] as int? ?? 1,
    current: json['current'] as int? ?? 0,
    expReward: json['expReward'] as int? ?? 30,
    isClaimed: json['isClaimed'] as bool? ?? false,
    type: MissionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MissionType.totalExercises,
    ),
  );
}

class ClaimedGift {
  final String id;
  final String title;
  final String category; // 'treat', 'gaming', 'entertainment', 'food', 'relax', 'custom'
  final String iconKey; // 'coffee', 'gamepad', 'movie', 'pizza', 'book', 'music', 'gift'
  final String claimedAt; // ISO String
  final String? customNote;

  ClaimedGift({
    required this.id,
    required this.title,
    required this.category,
    required this.iconKey,
    required this.claimedAt,
    this.customNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'iconKey': iconKey,
    'claimedAt': claimedAt,
    'customNote': customNote,
  };

  factory ClaimedGift.fromJson(Map<String, dynamic> json) => ClaimedGift(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'gift',
    iconKey: json['iconKey'] as String? ?? 'gift',
    claimedAt: json['claimedAt'] as String,
    customNote: json['customNote'] as String?,
  );
}

class RewardOption {
  final String id;
  final String title;
  final String description;
  final String category;
  final String iconKey;

  const RewardOption({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconKey,
  });
}

const List<RewardOption> defaultRewardOptions = [
  RewardOption(
    id: 'coffee',
    title: 'Treat to Favorite Drink',
    description: 'Enjoy a delicious coffee, matcha latte, or boba tea guilt-free!',
    category: 'treat',
    iconKey: 'coffee',
  ),
  RewardOption(
    id: 'gaming',
    title: '30-Minute Guilt-Free Gaming',
    description: 'Play your favorite video or mobile game for 30 minutes with peace of mind.',
    category: 'gaming',
    iconKey: 'gamepad',
  ),
  RewardOption(
    id: 'movie',
    title: 'Watch an Episode / Movie',
    description: 'Relax and watch one episode of your favorite show, anime, or YouTube series.',
    category: 'entertainment',
    iconKey: 'movie',
  ),
  RewardOption(
    id: 'food',
    title: 'Delicious Snack or Meal Perk',
    description: 'Treat yourself to your favorite dessert, bakery snack, or comforting dish.',
    category: 'food',
    iconKey: 'pizza',
  ),
  RewardOption(
    id: 'book',
    title: 'Leisure Reading Time',
    description: 'Cozy up and read a chapter of your favorite fiction book or light novel.',
    category: 'relax',
    iconKey: 'book',
  ),
  RewardOption(
    id: 'music',
    title: 'Relaxing Walk or Music Break',
    description: 'Put on headphones for a rejuvenating outdoor walk or take a power nap.',
    category: 'relax',
    iconKey: 'music',
  ),
];

class DailyMissionState {
  final String date; // YYYY-MM-DD
  final List<DailyMission> missions;
  final int currentExp;
  final int totalExpEarned;
  final List<ClaimedGift> claimedGifts;
  final List<String> customWishlist;

  DailyMissionState({
    required this.date,
    required this.missions,
    required this.currentExp,
    this.totalExpEarned = 0,
    this.claimedGifts = const [],
    this.customWishlist = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'missions': missions.map((m) => m.toJson()).toList(),
    'currentExp': currentExp,
    'totalExpEarned': totalExpEarned,
    'claimedGifts': claimedGifts.map((g) => g.toJson()).toList(),
    'customWishlist': customWishlist,
  };

  factory DailyMissionState.fromJson(Map<String, dynamic> json) => DailyMissionState(
    date: json['date'] as String,
    missions: (json['missions'] as List<dynamic>? ?? [])
        .map((m) => DailyMission.fromJson(m as Map<String, dynamic>))
        .toList(),
    currentExp: json['currentExp'] as int? ?? 0,
    totalExpEarned: json['totalExpEarned'] as int? ?? 0,
    claimedGifts: (json['claimedGifts'] as List<dynamic>? ?? [])
        .map((g) => ClaimedGift.fromJson(g as Map<String, dynamic>))
        .toList(),
    customWishlist: (json['customWishlist'] as List<dynamic>? ?? [])
        .map((w) => w.toString())
        .toList(),
  );

  String toJsonString() => json.encode(toJson());

  factory DailyMissionState.fromJsonString(String source) =>
      DailyMissionState.fromJson(json.decode(source) as Map<String, dynamic>);
}

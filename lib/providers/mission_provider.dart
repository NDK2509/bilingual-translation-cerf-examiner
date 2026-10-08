import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/daily_mission.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';

class MissionProvider extends ChangeNotifier {
  final StorageService _storageService;

  String _currentDate = '';
  List<DailyMission> _missions = [];
  int _currentExp = 0;
  int _totalExpEarned = 0;
  List<ClaimedGift> _claimedGifts = [];
  List<String> _customWishlist = [];

  MissionProvider(this._storageService) {
    _loadState();
  }

  // Getters
  String get currentDate => _currentDate;
  List<DailyMission> get dailyMissions => List.unmodifiable(_missions);
  int get currentExp => _currentExp;
  int get totalExpEarned => _totalExpEarned;
  List<ClaimedGift> get claimedGifts => List.unmodifiable(_claimedGifts);
  List<String> get customWishlist => List.unmodifiable(_customWishlist);

  bool get isGiftReady => _currentExp >= 100;
  int get completedMissionsCount => _missions.where((m) => m.isCompleted).length;
  int get unclaimedMissionsCount =>
      _missions.where((m) => m.isCompleted && !m.isClaimed).length;

  static String _todayStr() => UserStats.formatDate(DateTime.now());

  // Load or initialize daily missions
  void _loadState() {
    final today = _todayStr();
    final jsonStr = _storageService.getDailyMissionsJson();

    if (jsonStr != null) {
      try {
        final state = DailyMissionState.fromJsonString(jsonStr);
        _claimedGifts = List.from(state.claimedGifts);
        _customWishlist = List.from(state.customWishlist);
        _totalExpEarned = state.totalExpEarned;

        if (state.date == today && state.missions.isNotEmpty) {
          // Same day, restore today's missions and exp
          _currentDate = state.date;
          _missions = List.from(state.missions);
          _currentExp = state.currentExp;
          notifyListeners();
          return;
        } else {
          // Rollover to new day: preserve EXP if user already reached 100 or had progress
          _currentExp = state.currentExp;
        }
      } catch (_) {
        // Fallback to fresh generation on error
      }
    }

    _generateDailyMissions(today);
  }

  // Generates 3 balanced daily missions that together award 100 EXP
  void _generateDailyMissions(String date) {
    _currentDate = date;

    // Mission 1: Translation (30 EXP)
    final mission1 = DailyMission(
      id: '${date}_m1',
      title: 'Sentence Explorer',
      description: 'Complete 1 Translation exercise with AI feedback',
      iconKey: 'translation',
      target: 1,
      current: 0,
      expReward: 30,
      type: MissionType.translation,
    );

    // Mission 2: Cloze or Word Match (35 EXP)
    final mission2 = DailyMission(
      id: '${date}_m2',
      title: 'Vocabulary Master',
      description: 'Complete 1 Cloze Test or Word Match challenge',
      iconKey: 'cloze',
      target: 1,
      current: 0,
      expReward: 35,
      type: MissionType.cloze,
    );

    // Mission 3: High Precision / Quality (35 EXP)
    // 30 + 35 + 35 = 100 EXP!
    final mission3 = DailyMission(
      id: '${date}_m3',
      title: 'Accuracy Star',
      description: 'Score 80%+ on any practice exercise',
      iconKey: 'trophy',
      target: 1,
      current: 0,
      expReward: 35,
      type: MissionType.highScore,
    );

    _missions = [mission1, mission2, mission3];
    _saveState();
    notifyListeners();
  }

  // Save state to StorageService
  Future<void> _saveState() async {
    final state = DailyMissionState(
      date: _currentDate,
      missions: _missions,
      currentExp: _currentExp,
      totalExpEarned: _totalExpEarned,
      claimedGifts: _claimedGifts,
      customWishlist: _customWishlist,
    );
    await _storageService.saveDailyMissionsJson(state.toJsonString());
  }

  // Check and roll over date if midnight has passed
  void checkDateRollover() {
    final today = _todayStr();
    if (_currentDate != today) {
      _loadState();
    }
  }

  // Record an exercise completion across providers
  void recordExerciseCompleted({
    required String type, // 'translation', 'cloze', 'wordmatch'
    required int score,
    String? cefrLevel,
  }) {
    checkDateRollover();
    bool hasChanged = false;

    for (var mission in _missions) {
      if (mission.isCompleted) continue;

      if (mission.type == MissionType.translation && type == 'translation') {
        mission.current = math.min(mission.target, mission.current + 1);
        hasChanged = true;
      } else if (mission.type == MissionType.cloze &&
          (type == 'cloze' || type == 'wordmatch')) {
        mission.current = math.min(mission.target, mission.current + 1);
        hasChanged = true;
      } else if (mission.type == MissionType.wordMatch && type == 'wordmatch') {
        mission.current = math.min(mission.target, mission.current + 1);
        hasChanged = true;
      } else if (mission.type == MissionType.highScore && score >= 80) {
        mission.current = math.min(mission.target, mission.current + 1);
        hasChanged = true;
      } else if (mission.type == MissionType.totalExercises) {
        mission.current = math.min(mission.target, mission.current + 1);
        hasChanged = true;
      }
    }

    if (hasChanged) {
      _saveState();
      notifyListeners();
    }
  }

  // Record a vocabulary save
  void recordVocabularySaved() {
    checkDateRollover();
    bool hasChanged = false;

    for (var mission in _missions) {
      if (mission.isCompleted) continue;
      if (mission.type == MissionType.saveWord) {
        mission.current = math.min(mission.target, mission.current + 1);
        hasChanged = true;
      }
    }

    if (hasChanged) {
      _saveState();
      notifyListeners();
    }
  }

  // Claim EXP for a single completed mission
  int claimMissionExp(String missionId) {
    checkDateRollover();
    final missionIndex = _missions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) return 0;

    final mission = _missions[missionIndex];
    if (mission.isCompleted && !mission.isClaimed) {
      mission.isClaimed = true;
      final reward = mission.expReward;
      _currentExp += reward;
      _totalExpEarned += reward;
      _saveState();
      notifyListeners();
      return reward;
    }
    return 0;
  }

  // Claim all eligible completed missions at once
  int claimAllCompleted() {
    checkDateRollover();
    int totalClaimed = 0;
    for (var mission in _missions) {
      if (mission.isCompleted && !mission.isClaimed) {
        mission.isClaimed = true;
        totalClaimed += mission.expReward;
      }
    }

    if (totalClaimed > 0) {
      _currentExp += totalClaimed;
      _totalExpEarned += totalClaimed;
      _saveState();
      notifyListeners();
    }
    return totalClaimed;
  }

  // Unlock and claim a gift/reward when currentExp >= 100
  ClaimedGift? claimGift({
    required String title,
    required String category,
    required String iconKey,
    String? customNote,
  }) {
    if (_currentExp < 100) return null;

    // Deduct 100 EXP
    _currentExp = math.max(0, _currentExp - 100);

    final newGift = ClaimedGift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      iconKey: iconKey,
      claimedAt: DateTime.now().toIso8601String(),
      customNote: customNote,
    );

    _claimedGifts.insert(0, newGift);
    _saveState();
    notifyListeners();
    return newGift;
  }

  // Add a custom treat/wish to user's personalized wishlist
  void addCustomWishlist(String item) {
    final trimmed = item.trim();
    if (trimmed.isEmpty || _customWishlist.contains(trimmed)) return;
    _customWishlist.insert(0, trimmed);
    _saveState();
    notifyListeners();
  }

  // Remove custom wish
  void removeCustomWishlist(String item) {
    _customWishlist.removeWhere((w) => w == item);
    _saveState();
    notifyListeners();
  }

  // For testing/debugging/demo purposes: add custom EXP
  void debugAddExp(int amount) {
    _currentExp = math.max(0, _currentExp + amount);
    _totalExpEarned += amount;
    _saveState();
    notifyListeners();
  }

  // Reset missions for testing
  void debugResetMissions() {
    _generateDailyMissions(_todayStr());
  }
}

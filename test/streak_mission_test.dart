import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice_translating_english/models/user_stats.dart';
import 'package:practice_translating_english/services/storage_service.dart';
import 'package:practice_translating_english/services/ai_service.dart';
import 'package:practice_translating_english/providers/mission_provider.dart';
import 'package:practice_translating_english/providers/translation_provider.dart';
import 'package:practice_translating_english/providers/settings_provider.dart';
import 'package:practice_translating_english/screens/streak_calendar_screen.dart';
import 'package:practice_translating_english/screens/missions_rewards_screen.dart';

void main() {
  group('Streak & UserStats Tests', () {
    test('Initial stats start with 0 streak and empty practice dates', () {
      final stats = UserStats.initial();
      expect(stats.streak, 0);
      expect(stats.activeStreak, 0);
      expect(stats.bestStreak, 0);
      expect(stats.practiceDates, isEmpty);
      expect(stats.hasPracticedToday, isFalse);
    });

    test('First practice session creates 1 day streak and records date', () {
      final initial = UserStats.initial();
      final day1 = DateTime(2026, 10, 1);
      final stats1 = initial.recordSession(
        cefrLevel: 'B2',
        score: 85,
        customDate: day1,
      );

      expect(stats1.streak, 1);
      expect(stats1.bestStreak, 1);
      expect(stats1.lastPracticeDate, '2026-10-01');
      expect(stats1.hasPracticedOn(day1), isTrue);
      expect(stats1.practiceDates, contains('2026-10-01'));
    });

    test('Practicing again on the same day keeps the streak intact', () {
      final initial = UserStats.initial();
      final day1 = DateTime(2026, 10, 1);
      final stats1 = initial.recordSession(
        cefrLevel: 'B2',
        score: 80,
        customDate: day1,
      );
      final stats2 = stats1.recordSession(
        cefrLevel: 'C1',
        score: 90,
        customDate: day1,
      );

      expect(stats2.streak, 1);
      expect(stats2.bestStreak, 1);
      expect(stats2.totalCompleted, 2);
      expect(stats2.practiceDates.length, 1);
    });

    test('Consecutive day practice increments streak and updates best streak', () {
      final initial = UserStats.initial();
      final day1 = DateTime(2026, 10, 1);
      final day2 = DateTime(2026, 10, 2);
      final day3 = DateTime(2026, 10, 3);

      final stats1 = initial.recordSession(cefrLevel: 'B2', score: 80, customDate: day1);
      final stats2 = stats1.recordSession(cefrLevel: 'C1', score: 85, customDate: day2);
      final stats3 = stats2.recordSession(cefrLevel: 'C2', score: 90, customDate: day3);

      expect(stats3.streak, 3);
      expect(stats3.bestStreak, 3);
      expect(stats3.practiceDates.length, 3);
      expect(stats3.hasPracticedOn(day1), isTrue);
      expect(stats3.hasPracticedOn(day2), isTrue);
      expect(stats3.hasPracticedOn(day3), isTrue);
    });

    test('Skipping a day resets streak to 1 but retains best streak', () {
      final initial = UserStats.initial();
      final day1 = DateTime(2026, 10, 1);
      final day2 = DateTime(2026, 10, 2);
      final day5 = DateTime(2026, 10, 5); // 3 days gap

      final stats1 = initial.recordSession(cefrLevel: 'B2', score: 80, customDate: day1);
      final stats2 = stats1.recordSession(cefrLevel: 'B2', score: 85, customDate: day2);
      expect(stats2.streak, 2);
      expect(stats2.bestStreak, 2);

      final stats3 = stats2.recordSession(cefrLevel: 'C1', score: 90, customDate: day5);
      expect(stats3.streak, 1); // Reset to 1
      expect(stats3.bestStreak, 2); // Retains highest streak
      expect(stats3.practiceDates.length, 3);
    });

    test('JSON serialization preserves streak, bestStreak and practiceDates', () {
      final stats = UserStats(
        streak: 5,
        bestStreak: 12,
        lastPracticeDate: '2026-10-03',
        totalCompleted: 15,
        averageScore: 88.5,
        levelDistribution: {'B2': 5, 'C1': 8, 'C2': 2},
        practiceDates: ['2026-10-01', '2026-10-02', '2026-10-03'],
      );

      final jsonStr = stats.toJsonString();
      final restored = UserStats.fromJsonString(jsonStr);

      expect(restored.streak, 5);
      expect(restored.bestStreak, 12);
      expect(restored.lastPracticeDate, '2026-10-03');
      expect(restored.totalCompleted, 15);
      expect(restored.averageScore, 88.5);
      expect(restored.practiceDates, ['2026-10-01', '2026-10-02', '2026-10-03']);
    });
  });

  group('MissionProvider & 100 EXP Gift System Tests', () {
    late StorageService storageService;
    late MissionProvider missionProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      missionProvider = MissionProvider(storageService);
    });

    test('Generates exactly 3 daily missions totaling 100 EXP', () {
      final missions = missionProvider.dailyMissions;
      expect(missions.length, 3);

      final totalExp = missions.fold<int>(0, (sum, m) => sum + m.expReward);
      expect(totalExp, 100);
      expect(missions[0].expReward, 30);
      expect(missions[1].expReward, 35);
      expect(missions[2].expReward, 35);
    });

    test('Completing translation exercise advances mission 1 and high score mission if score >= 80', () {
      expect(missionProvider.dailyMissions[0].current, 0);
      expect(missionProvider.dailyMissions[2].current, 0);

      missionProvider.recordExerciseCompleted(
        type: 'translation',
        score: 85,
        cefrLevel: 'B2',
      );

      // Mission 1 (Translation) is complete
      expect(missionProvider.dailyMissions[0].current, 1);
      expect(missionProvider.dailyMissions[0].isCompleted, isTrue);

      // Mission 3 (Accuracy/High score >= 80) is complete
      expect(missionProvider.dailyMissions[2].current, 1);
      expect(missionProvider.dailyMissions[2].isCompleted, isTrue);
    });

    test('Claiming mission rewards gives exact EXP and unlocks gift at 100 EXP', () {
      expect(missionProvider.currentExp, 0);
      expect(missionProvider.isGiftReady, isFalse);

      // Complete all 3 missions
      missionProvider.recordExerciseCompleted(
        type: 'translation',
        score: 85,
      );
      missionProvider.recordExerciseCompleted(
        type: 'cloze',
        score: 90,
      );

      expect(missionProvider.dailyMissions[0].isCompleted, isTrue);
      expect(missionProvider.dailyMissions[1].isCompleted, isTrue);
      expect(missionProvider.dailyMissions[2].isCompleted, isTrue);

      // Claim Mission 1 (30 EXP)
      final exp1 = missionProvider.claimMissionExp(missionProvider.dailyMissions[0].id);
      expect(exp1, 30);
      expect(missionProvider.currentExp, 30);
      expect(missionProvider.isGiftReady, isFalse);

      // Claim remaining (35 + 35 = 70 EXP)
      final expRest = missionProvider.claimAllCompleted();
      expect(expRest, 70);
      expect(missionProvider.currentExp, 100);

      // Full 100 EXP reached! Gift is ready to unlock
      expect(missionProvider.isGiftReady, isTrue);
    });

    test('User can choose and claim a gift, deducting 100 EXP and adding to history', () {
      missionProvider.debugAddExp(100);
      expect(missionProvider.isGiftReady, isTrue);
      expect(missionProvider.claimedGifts, isEmpty);

      final gift = missionProvider.claimGift(
        title: 'Treat Yourself to Boba Tea',
        category: 'treat',
        iconKey: 'coffee',
        customNote: 'Celebrated completing all 3 CEFR missions!',
      );

      expect(gift, isNotNull);
      expect(gift!.title, 'Treat Yourself to Boba Tea');
      expect(gift.category, 'treat');
      expect(missionProvider.currentExp, 0); // 100 EXP consumed
      expect(missionProvider.isGiftReady, isFalse);
      expect(missionProvider.claimedGifts.length, 1);
      expect(missionProvider.claimedGifts.first.title, 'Treat Yourself to Boba Tea');
    });

    test('User can manage personalized custom reward wishlist', () {
      expect(missionProvider.customWishlist, isEmpty);

      missionProvider.addCustomWishlist('Buy new mechanical keyboard');
      missionProvider.addCustomWishlist('30 minutes guilt-free nap');

      expect(missionProvider.customWishlist.length, 2);
      expect(missionProvider.customWishlist, contains('Buy new mechanical keyboard'));
      expect(missionProvider.customWishlist, contains('30 minutes guilt-free nap'));

      missionProvider.removeCustomWishlist('Buy new mechanical keyboard');
      expect(missionProvider.customWishlist.length, 1);
      expect(missionProvider.customWishlist, contains('30 minutes guilt-free nap'));
    });
  });

  group('Widget Navigation & Screen Tests', () {
    testWidgets('StreakCalendarScreen renders streak details and calendar grid', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storageService = await StorageService.init();
      final aiService = AIService();
      final missionProvider = MissionProvider(storageService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>(
              create: (_) => SettingsProvider(storageService),
            ),
            ChangeNotifierProvider<MissionProvider>.value(
              value: missionProvider,
            ),
            ChangeNotifierProvider<TranslationProvider>(
              create: (_) => TranslationProvider(
                storageService,
                aiService,
                missionProvider: missionProvider,
              ),
            ),
          ],
          child: const MaterialApp(
            home: StreakCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Streak Calendar'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('Best Record'), findsOneWidget);
      expect(find.text('STREAK MILESTONES'), findsOneWidget);
      expect(find.text('MON'), findsOneWidget);
      expect(find.text('SUN'), findsOneWidget);
    });

    testWidgets('MissionsRewardsScreen renders EXP status and daily mission cards', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storageService = await StorageService.init();
      final missionProvider = MissionProvider(storageService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MissionProvider>.value(
              value: missionProvider,
            ),
          ],
          child: const MaterialApp(
            home: MissionsRewardsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Missions & Gifts'), findsOneWidget);
      expect(find.text('DAILY EXP GOAL'), findsOneWidget);
      expect(find.textContaining('Today\'s Missions'), findsOneWidget);
      expect(find.textContaining('Gifts History'), findsOneWidget);
      expect(find.text('Sentence Explorer'), findsOneWidget);
      expect(find.text('Vocabulary Master'), findsOneWidget);
    });
  });
}

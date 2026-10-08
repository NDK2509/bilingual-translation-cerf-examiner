import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice_translating_english/main.dart';
import 'package:practice_translating_english/services/storage_service.dart';
import 'package:practice_translating_english/services/ai_service.dart';
import 'package:practice_translating_english/providers/settings_provider.dart';
import 'package:practice_translating_english/providers/translation_provider.dart';

import 'package:practice_translating_english/providers/vocabulary_provider.dart';
import 'package:practice_translating_english/providers/cloze_provider.dart';
import 'package:practice_translating_english/providers/word_match_provider.dart';
import 'package:practice_translating_english/providers/mission_provider.dart';

void main() {
  testWidgets('App compiles and runs smoke test', (WidgetTester tester) async {
    // Set up mock shared preferences
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
          ChangeNotifierProvider<VocabularyProvider>(
            create: (_) => VocabularyProvider(
              storageService,
              aiService,
              missionProvider: missionProvider,
            ),
          ),
          ChangeNotifierProvider<ClozeProvider>(
            create: (_) => ClozeProvider(
              storageService,
              aiService,
              missionProvider: missionProvider,
            ),
          ),
          ChangeNotifierProvider<WordMatchProvider>(
            create: (_) => WordMatchProvider(
              storageService,
              aiService,
              missionProvider: missionProvider,
            ),
          ),
        ],
        child: const TranslationPracticeApp(),
      ),
    );

    // Verify dashboard renders key streak and mission components
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Weekly Streak'), findsOneWidget);
    expect(find.text('Daily Missions'), findsOneWidget);
    expect(find.text('Select CEFR Level'), findsOneWidget);
  });
}

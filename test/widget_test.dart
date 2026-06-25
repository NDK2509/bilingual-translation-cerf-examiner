import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice_translating_english/main.dart';
import 'package:practice_translating_english/services/storage_service.dart';
import 'package:practice_translating_english/services/ai_service.dart';
import 'package:practice_translating_english/providers/settings_provider.dart';
import 'package:practice_translating_english/providers/translation_provider.dart';

import 'package:practice_translating_english/providers/vocabulary_provider.dart';

void main() {
  testWidgets('App compiles and runs smoke test', (WidgetTester tester) async {
    // Set up mock shared preferences
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final aiService = AIService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(storageService),
          ),
          ChangeNotifierProvider<TranslationProvider>(
            create: (_) => TranslationProvider(storageService, aiService),
          ),
          ChangeNotifierProvider<VocabularyProvider>(
            create: (_) => VocabularyProvider(storageService, aiService),
          ),
        ],
        child: const TranslationPracticeApp(),
      ),
    );

    // Verify dashboard renders
    expect(find.text('Translation practice'), findsOneWidget);
    expect(find.text('Select CEFR Proficiency Level'), findsOneWidget);
  });
}

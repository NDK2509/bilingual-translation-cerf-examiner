import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice_translating_english/models/saved_word.dart';
import 'package:practice_translating_english/services/storage_service.dart';
import 'package:practice_translating_english/services/ai_service.dart';
import 'package:practice_translating_english/providers/vocabulary_provider.dart';

void main() {
  group('VocabularyProvider Tests', () {
    late StorageService storageService;
    late AIService aiService;
    late VocabularyProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      aiService = AIService();
      provider = VocabularyProvider(storageService, aiService);
    });

    test('Initial vocabulary should be empty', () {
      expect(provider.vocabulary, isEmpty);
    });

    test('Save and retrieve word details', () async {
      final testWord = SavedWord(
        word: 'stubborn',
        definition: 'bướng bỉnh',
        context: 'He is stubborn.',
        phonetic: '/ˈstʌbərn/',
        contextExplanation: 'Giải thích',
        createdAt: DateTime.now(),
      );

      await provider.saveWord(testWord);
      expect(provider.vocabulary.length, 1);
      expect(provider.isWordSaved('stubborn'), isTrue);
      expect(provider.isWordSaved('STUBBORN '), isTrue); // Case & whitespace insensitive
      
      final retrieved = provider.getSavedWord('stubborn');
      expect(retrieved?.definition, 'bướng bỉnh');
    });

    test('Remove word details', () async {
      final testWord = SavedWord(
        word: 'stubborn',
        definition: 'bướng bỉnh',
        context: 'He is stubborn.',
        phonetic: '/ˈstʌbərn/',
        contextExplanation: 'Giải thích',
        createdAt: DateTime.now(),
      );

      await provider.saveWord(testWord);
      expect(provider.isWordSaved('stubborn'), isTrue);

      await provider.removeWord('stubborn');
      expect(provider.isWordSaved('stubborn'), isFalse);
      expect(provider.vocabulary, isEmpty);
    });

    test('Update mastery score', () async {
      final testWord = SavedWord(
        word: 'stubborn',
        definition: 'bướng bỉnh',
        context: 'He is stubborn.',
        phonetic: '/ˈstʌbərn/',
        contextExplanation: 'Giải thích',
        createdAt: DateTime.now(),
        masteryLevel: 20,
      );

      await provider.saveWord(testWord);
      await provider.updateMastery('stubborn', 60);

      final retrieved = provider.getSavedWord('stubborn');
      expect(retrieved?.masteryLevel, 60);
    });
  });
}

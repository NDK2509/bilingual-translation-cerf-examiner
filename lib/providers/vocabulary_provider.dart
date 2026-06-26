import 'package:flutter/material.dart';
import '../models/saved_word.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class VocabularyProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AIService _aiService;

  List<SavedWord> _vocabulary = [];
  bool _isLoadingDetails = false;

  VocabularyProvider(this._storageService, this._aiService) {
    _loadVocabulary();
  }

  // Getters
  List<SavedWord> get vocabulary => _vocabulary;
  bool get isLoadingDetails => _isLoadingDetails;

  // Load from Storage
  void _loadVocabulary() {
    _vocabulary = _storageService.getVocabulary();
    // Sort words by creation date (newest first)
    _vocabulary.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // Check if a word is already saved
  bool isWordSaved(String word) {
    final cleanWord = word.trim().toLowerCase();
    return _vocabulary.any((w) => w.word.trim().toLowerCase() == cleanWord);
  }

  // Get saved word if it exists
  SavedWord? getSavedWord(String word) {
    final cleanWord = word.trim().toLowerCase();
    try {
      return _vocabulary.firstWhere((w) => w.word.trim().toLowerCase() == cleanWord);
    } catch (_) {
      return null;
    }
  }

  // Fetch word details from AI
  Future<Map<String, dynamic>> fetchWordDetails({
    required String word,
    required String contextSentence,
    required bool useMock,
    required String apiKey,
    required String modelName,
    required bool translateToEnglish,
  }) async {
    _isLoadingDetails = true;
    notifyListeners();

    try {
      final details = await _aiService.defineWord(
        word: word,
        contextSentence: contextSentence,
        useMock: useMock,
        apiKey: apiKey,
        modelName: modelName,
        translateToEnglish: translateToEnglish,
      );
      return details;
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // Add a new word
  Future<void> saveWord(SavedWord word) async {
    // Check if already saved
    if (isWordSaved(word.word)) {
      // Remove it first to update it
      _vocabulary.removeWhere((w) => w.word.trim().toLowerCase() == word.word.trim().toLowerCase());
    }

    _vocabulary.insert(0, word);
    await _storageService.saveVocabulary(_vocabulary);
    notifyListeners();
  }

  // Remove a word
  Future<void> removeWord(String word) async {
    final cleanWord = word.trim().toLowerCase();
    _vocabulary.removeWhere((w) => w.word.trim().toLowerCase() == cleanWord);
    await _storageService.saveVocabulary(_vocabulary);
    notifyListeners();
  }

  // Update mastery level of a word
  Future<void> updateMastery(String word, int newLevel) async {
    final cleanWord = word.trim().toLowerCase();
    for (var w in _vocabulary) {
      if (w.word.trim().toLowerCase() == cleanWord) {
        w.masteryLevel = newLevel.clamp(0, 100);
        break;
      }
    }
    await _storageService.saveVocabulary(_vocabulary);
    notifyListeners();
  }

  // Clear all saved vocabulary
  Future<void> clearAll() async {
    _vocabulary.clear();
    await _storageService.clearVocabulary();
    notifyListeners();
  }
}

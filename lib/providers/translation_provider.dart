import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../models/translation_session.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class TranslationProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AIService _aiService;

  late UserStats _stats;
  bool _isLoadingSentence = false;
  bool _isEvaluating = false;
  GeneratedSentence? _currentSentence;
  EvaluationResult? _evaluationResult;
  String? _currentLevel;
  String? _errorMessage;

  TranslationProvider(this._storageService, this._aiService) {
    _stats = _storageService.getStats();
  }

  // Getters
  UserStats get stats => _stats;
  bool get isLoadingSentence => _isLoadingSentence;
  bool get isEvaluating => _isEvaluating;
  GeneratedSentence? get currentSentence => _currentSentence;
  EvaluationResult? get evaluationResult => _evaluationResult;
  String? get currentLevel => _currentLevel;
  String? get errorMessage => _errorMessage;

  // Set level and fetch a new sentence
  Future<void> generateNewSentence({
    required String cefrLevel,
    required String apiKey,
    required bool useMock,
    required String modelName,
  }) async {
    _isLoadingSentence = true;
    _errorMessage = null;
    _evaluationResult = null;
    _currentLevel = cefrLevel;
    notifyListeners();

    try {
      _currentSentence = await _aiService.generateSentence(
        cefrLevel: cefrLevel,
        useMock: useMock,
        apiKey: apiKey,
        modelName: modelName,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _currentSentence = null;
    } finally {
      _isLoadingSentence = false;
      notifyListeners();
    }
  }

  // Submit translation and request evaluation
  Future<void> evaluateTranslation({
    required String userTranslation,
    required String apiKey,
    required bool useMock,
    required String modelName,
  }) async {
    if (_currentSentence == null) return;

    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _aiService.evaluateTranslation(
        cefrLevel: _currentSentence!.cefrLevel,
        englishSource: _currentSentence!.englishSentence,
        userTranslation: userTranslation,
        useMock: useMock,
        apiKey: apiKey,
        modelName: modelName,
      );

      _evaluationResult = result;

      // Update statistics only if acceptable or has a score above a basic threshold (e.g., 50)
      if (result.score >= 50) {
        _stats = _stats.recordSession(
          cefrLevel: _currentSentence!.cefrLevel,
          score: result.score,
        );
        await _storageService.saveStats(_stats);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _evaluationResult = null;
    } finally {
      _isEvaluating = false;
      notifyListeners();
    }
  }

  // Reset the current practice state
  void resetSession() {
    _currentSentence = null;
    _evaluationResult = null;
    _currentLevel = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset stats completely
  Future<void> resetStats() async {
    await _storageService.resetStats();
    _stats = UserStats.initial();
    notifyListeners();
  }
}

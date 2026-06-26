import 'package:flutter/material.dart';
import '../models/cloze_session.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class ClozeProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AIService _aiService;

  late UserStats _stats;
  bool _isLoadingSentence = false;
  bool _isChecking = false;
  ClozeSentence? _currentSentence;
  String? _currentLevel;
  String? _errorMessage;
  
  // Maps blank index -> user's selected option
  final Map<int, String> _userAnswers = {};
  bool _isEvaluated = false;
  int _score = 0;

  ClozeProvider(this._storageService, this._aiService) {
    _stats = _storageService.getStats();
  }

  // Getters
  UserStats get stats => _stats;
  bool get isLoadingSentence => _isLoadingSentence;
  bool get isChecking => _isChecking;
  ClozeSentence? get currentSentence => _currentSentence;
  String? get currentLevel => _currentLevel;
  String? get errorMessage => _errorMessage;
  Map<int, String> get userAnswers => _userAnswers;
  bool get isEvaluated => _isEvaluated;
  int get score => _score;

  // Generate a new cloze sentence
  Future<void> generateNewSentence({
    required String cefrLevel,
    required String apiKey,
    required bool useMock,
    required String modelName,
    required bool translateToEnglish,
  }) async {
    _isLoadingSentence = true;
    _errorMessage = null;
    _isEvaluated = false;
    _score = 0;
    _userAnswers.clear();
    _currentLevel = cefrLevel;
    notifyListeners();

    try {
      _currentSentence = await _aiService.generateClozeSentence(
        cefrLevel: cefrLevel,
        useMock: useMock,
        apiKey: apiKey,
        modelName: modelName,
        translateToEnglish: translateToEnglish,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _currentSentence = null;
    } finally {
      _isLoadingSentence = false;
      notifyListeners();
    }
  }

  // Select an option for a specific blank
  void selectAnswer(int blankIndex, String answer) {
    if (_isEvaluated) return;
    _userAnswers[blankIndex] = answer;
    notifyListeners();
  }

  // Check answers and calculate score
  Future<void> checkAnswers() async {
    final sentence = _currentSentence;
    if (sentence == null || sentence.blanks.isEmpty || _isEvaluated) return;

    _isChecking = true;
    notifyListeners();

    try {
      int correctCount = 0;
      for (final blank in sentence.blanks) {
        final userAnswer = _userAnswers[blank.index]?.trim().toLowerCase();
        final correctAnswer = blank.correctAnswer.trim().toLowerCase();
        if (userAnswer == correctAnswer) {
          correctCount++;
        }
      }

      _score = ((correctCount / sentence.blanks.length) * 100).round();
      _isEvaluated = true;

      // Update statistics only if acceptable or score >= 50
      if (_score >= 50) {
        // Refresh stats from storage just in case it was updated in another provider
        _stats = _storageService.getStats();
        _stats = _stats.recordSession(
          cefrLevel: sentence.cefrLevel,
          score: _score,
        );
        await _storageService.saveStats(_stats);
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi kiểm tra kết quả: $e';
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  // Reset the current cloze practice state
  void resetSession() {
    _currentSentence = null;
    _isEvaluated = false;
    _score = 0;
    _userAnswers.clear();
    _currentLevel = null;
    _errorMessage = null;
    notifyListeners();
  }
}

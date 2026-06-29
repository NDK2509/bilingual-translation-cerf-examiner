import 'package:flutter/material.dart';
import '../models/word_match_session.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class WordMatchProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AIService _aiService;

  late UserStats _stats;
  bool _isLoadingExercise = false;
  WordMatchExercise? _currentExercise;
  String? _currentLevel;
  String? _errorMessage;

  String? _selectedAnswer;
  bool _isEvaluated = false;
  bool _isCorrect = false;

  WordMatchProvider(this._storageService, this._aiService) {
    _stats = _storageService.getStats();
  }

  // Getters
  UserStats get stats => _stats;
  bool get isLoadingExercise => _isLoadingExercise;
  WordMatchExercise? get currentExercise => _currentExercise;
  String? get currentLevel => _currentLevel;
  String? get errorMessage => _errorMessage;
  String? get selectedAnswer => _selectedAnswer;
  bool get isEvaluated => _isEvaluated;
  bool get isCorrect => _isCorrect;

  // Generate a new word match exercise
  Future<void> generateNewExercise({
    required String cefrLevel,
    required String apiKey,
    required bool useMock,
    required String modelName,
    required bool translateToEnglish,
    String? topic,
  }) async {
    _isLoadingExercise = true;
    _errorMessage = null;
    _isEvaluated = false;
    _isCorrect = false;
    _selectedAnswer = null;
    _currentLevel = cefrLevel;
    notifyListeners();

    try {
      _currentExercise = await _aiService.generateWordMatchExercise(
        cefrLevel: cefrLevel,
        useMock: useMock,
        apiKey: apiKey,
        modelName: modelName,
        translateToEnglish: translateToEnglish,
        topic: topic,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _currentExercise = null;
    } finally {
      _isLoadingExercise = false;
      notifyListeners();
    }
  }

  // Select an answer and evaluate
  void selectAnswer(String answer) {
    if (_isEvaluated) return;
    _selectedAnswer = answer;
    notifyListeners();
  }

  // Check the selected answer
  Future<void> checkAnswer() async {
    final exercise = _currentExercise;
    if (exercise == null || _selectedAnswer == null || _isEvaluated) return;

    _isCorrect = _selectedAnswer!.trim().toLowerCase() ==
        exercise.correctAnswer.trim().toLowerCase();
    _isEvaluated = true;

    final score = _isCorrect ? 100 : 0;

    // Update statistics
    if (_isCorrect) {
      _stats = _storageService.getStats();
      _stats = _stats.recordSession(
        cefrLevel: exercise.cefrLevel,
        score: score,
      );
      await _storageService.saveStats(_stats);
    }

    notifyListeners();
  }

  // Reset session state
  void resetSession() {
    _currentExercise = null;
    _isEvaluated = false;
    _isCorrect = false;
    _selectedAnswer = null;
    _currentLevel = null;
    _errorMessage = null;
    notifyListeners();
  }
}

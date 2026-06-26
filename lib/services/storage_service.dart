import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../models/saved_word.dart';

class StorageService {
  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyUseMockMode = 'use_mock_mode';
  static const String _keyStats = 'user_stats';
  static const String _keyVocabulary = 'saved_vocabulary';
  static const String _keyTranslateToEnglish = 'translate_to_english';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Initialize service
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // API Key management
  String getApiKey() {
    return _prefs.getString(_keyApiKey) ?? '';
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_keyApiKey, apiKey);
  }

  // Mock Mode state
  bool getUseMockMode() {
    return _prefs.getBool(_keyUseMockMode) ?? true; // Defaults to true if no key setup
  }

  Future<void> setUseMockMode(bool useMock) async {
    await _prefs.setBool(_keyUseMockMode, useMock);
  }

  // Translation direction management
  bool getTranslateToEnglish() {
    return _prefs.getBool(_keyTranslateToEnglish) ?? false;
  }

  Future<void> setTranslateToEnglish(bool value) async {
    await _prefs.setBool(_keyTranslateToEnglish, value);
  }

  // User Stats management
  UserStats getStats() {
    final statsStr = _prefs.getString(_keyStats);
    if (statsStr == null) {
      return UserStats.initial();
    }
    try {
      return UserStats.fromJsonString(statsStr);
    } catch (_) {
      return UserStats.initial();
    }
  }

  Future<void> saveStats(UserStats stats) async {
    await _prefs.setString(_keyStats, stats.toJsonString());
  }

  Future<void> resetStats() async {
    await _prefs.remove(_keyStats);
  }

  // Vocabulary management
  List<SavedWord> getVocabulary() {
    final vocabStr = _prefs.getString(_keyVocabulary);
    if (vocabStr == null) return [];
    try {
      final List<dynamic> decoded = json.decode(vocabStr);
      return decoded.map((item) => SavedWord.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVocabulary(List<SavedWord> list) async {
    final encoded = json.encode(list.map((item) => item.toJson()).toList());
    await _prefs.setString(_keyVocabulary, encoded);
  }

  Future<void> clearVocabulary() async {
    await _prefs.remove(_keyVocabulary);
  }
}

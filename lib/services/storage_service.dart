import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

class StorageService {
  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyUseMockMode = 'use_mock_mode';
  static const String _keyStats = 'user_stats';

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
}

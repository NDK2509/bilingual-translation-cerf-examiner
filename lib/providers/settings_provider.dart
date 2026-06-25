import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  late String _apiKey;
  late bool _useMockMode;
  String _selectedModel = 'gemini-3.5-flash';

  SettingsProvider(this._storageService) {
    _apiKey = _storageService.getApiKey();
    _useMockMode = _storageService.getUseMockMode();
    // Default to mock mode if key is empty
    if (_apiKey.isEmpty && !_useMockMode) {
      _useMockMode = true;
      _storageService.setUseMockMode(true);
    }
  }

  String get apiKey => _apiKey;
  bool get useMockMode => _useMockMode;
  String get selectedModel => _selectedModel;

  Future<void> updateApiKey(String key) async {
    _apiKey = key.trim();
    await _storageService.setApiKey(_apiKey);
    
    // Automatically toggle off mock mode if a key is provided, unless user explicitly sets it
    if (_apiKey.isNotEmpty && _useMockMode) {
      await updateUseMockMode(false);
    }
    notifyListeners();
  }

  Future<void> updateUseMockMode(bool useMock) async {
    // Cannot toggle off mock if there is no API key
    if (!useMock && _apiKey.isEmpty) {
      return;
    }
    _useMockMode = useMock;
    await _storageService.setUseMockMode(useMock);
    notifyListeners();
  }

  void updateSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }
}

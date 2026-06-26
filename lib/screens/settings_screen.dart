import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/translation_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _apiKeyController = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey(SettingsProvider settings) {
    settings.updateApiKey(_apiKeyController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('API Key saved successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmResetStats(TranslationProvider translation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Reset Statistics?'),
          content: const Text(
            'This action will permanently erase your practice scores, level completions, and streak progress. This cannot be undone.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                translation.resetStats();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Statistics reset successfully!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Reset Everything'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final translation = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini AI Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppColors.glassCardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Key Setting',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To use online generation & grading, provide your Gemini API key. If left blank, Mock Mode will be active.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Gemini API Key',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save, color: AppColors.primary),
                        onPressed: () => _saveApiKey(settings),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mock Practice Mode',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            settings.apiKey.isEmpty
                                ? 'Forced: No API key set'
                                : 'Simulate LLM without API usage',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      Switch(
                        value: settings.useMockMode,
                        activeColor: AppColors.primary,
                        onChanged: settings.apiKey.isEmpty
                            ? null
                            : (val) => settings.updateUseMockMode(val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Model Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppColors.glassCardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Gemini Model',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: settings.selectedModel,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'gemini-3.5-flash',
                        child: Text('Gemini 3.5 Flash (Fast, default)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-3.1-pro',
                        child: Text('Gemini 3.1 Pro (Precise, heavier)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.updateSelectedModel(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Translation Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppColors.glassCardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Translation Mode',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Practice translating from English to Vietnamese (default) or toggle to practice translating from Vietnamese to English.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Translate to English (VN ➔ EN)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Translate Vietnamese prompts to English',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      Switch(
                        value: settings.translateToEnglish,
                        activeColor: AppColors.primary,
                        onChanged: (val) => settings.updateTranslateToEnglish(val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Application Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppColors.glassCardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Erase History & Progress',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Resetting deletes all streaks and average score metrics stored on this device.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _confirmResetStats(translation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.2),
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1),
                      ),
                      child: const Text('Reset All Practice Data'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

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
      const SnackBar(
        content: Text('API Key saved successfully!'),
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
          title: const Text('Reset Statistics?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: const Text(
            'This action will permanently erase your practice scores, level completions, and streak progress. This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Reset Everything', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(
                color: AppColors.border.withOpacity(0.3),
                width: 1.0,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.bgGlow))),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Gemini AI Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: AppColors.glassCardDecoration(color: AppColors.surface, radius: 20),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API Key Setting',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'To use online generation & grading, provide your Gemini API key. If left blank, Mock Mode will be active.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _apiKeyController,
                            obscureText: true,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Gemini API Key',
                              labelStyle: const TextStyle(color: AppColors.textSecondary),
                              fillColor: AppColors.surfaceElevated,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.save_rounded, color: AppColors.primary),
                                onPressed: () => _saveApiKey(settings),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mock Practice Mode',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      settings.apiKey.isEmpty
                                          ? 'Forced: No API key set'
                                          : 'Simulate LLM without API usage',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.useMockMode,
                                activeColor: AppColors.primary,
                                activeTrackColor: AppColors.primary.withOpacity(0.3),
                                inactiveTrackColor: AppColors.border,
                                onChanged: settings.apiKey.isEmpty
                                    ? null
                                    : (val) => settings.updateUseMockMode(val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Model Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: AppColors.glassCardDecoration(color: AppColors.surface, radius: 20),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Gemini Model',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: settings.selectedModel,
                            dropdownColor: AppColors.surfaceElevated,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              fillColor: AppColors.surfaceElevated,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
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
                    const SizedBox(height: 32),

                    const Text(
                      'Translation Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: AppColors.glassCardDecoration(color: AppColors.surface, radius: 20),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Translation Mode',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Practice translating from English to Vietnamese (default) or toggle to practice translating from Vietnamese to English.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Translate to English (VN ➔ EN)',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Translate Vietnamese prompts to English',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.translateToEnglish,
                                activeColor: AppColors.primary,
                                activeTrackColor: AppColors.primary.withOpacity(0.3),
                                inactiveTrackColor: AppColors.border,
                                onChanged: (val) => settings.updateTranslateToEnglish(val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Application Metrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: AppColors.glassCardDecoration(color: AppColors.surface, radius: 20),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Erase History & Progress',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Resetting deletes all streaks and average score metrics stored on this device.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: TextButton(
                              onPressed: () => _confirmResetStats(translation),
                              style: TextButton.styleFrom(
                                side: const BorderSide(color: AppColors.error, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text(
                                'Reset All Practice Data',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

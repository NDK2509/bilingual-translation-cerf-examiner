import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../theme/app_colors.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'vocabulary_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _startPractice(BuildContext context, String cefrLevel) {
    final translation = Provider.of<TranslationProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Trigger sentence generation
    translation.generateNewSentence(
      cefrLevel: cefrLevel,
      apiKey: settings.apiKey,
      useMock: settings.useMockMode,
      modelName: settings.selectedModel,
      translateToEnglish: settings.translateToEnglish,
    );

    // Reset previous screen and navigate
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PracticeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translation = Provider.of<TranslationProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final stats = translation.stats;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              settings.translateToEnglish
                                  ? 'Vietnamese ➔ English'
                                  : 'English ➔ Vietnamese',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.swap_horiz_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                settings.updateTranslateToEnglish(!settings.translateToEnglish);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      settings.translateToEnglish
                                          ? 'Switched to Vietnamese ➔ English'
                                          : 'Switched to English ➔ Vietnamese',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              tooltip: 'Swap translation direction',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Translation practice',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 28),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // API Status Banner
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                child: Container(
                  decoration: AppColors.glassCardDecoration(
                    color: settings.useMockMode ? AppColors.surface : AppColors.primary.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        settings.useMockMode ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                        color: settings.useMockMode ? AppColors.warning : AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.useMockMode ? 'Mock Mode Active' : 'Connected to Gemini API',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              settings.useMockMode
                                  ? 'Configure an API Key in settings for real-time grading.'
                                  : 'Using model: ${settings.selectedModel}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Stats Row
              Row(
                children: [
                  // Streak Card
                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: AppColors.glassCardDecoration(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Streak', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              Icon(Icons.local_fire_department_rounded, color: AppColors.warning),
                            ],
                          ),
                          Text(
                            '${stats.streak} Days',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Average Score Card
                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: AppColors.glassCardDecoration(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Avg Score', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              Icon(Icons.stars_rounded, color: AppColors.accent),
                            ],
                          ),
                          Text(
                            '${stats.averageScore.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Total Completed Card
              Container(
                width: double.infinity,
                decoration: AppColors.glassCardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Exercises Completed', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'B2: ${stats.levelDistribution['B2'] ?? 0}  |  C1: ${stats.levelDistribution['C1'] ?? 0}  |  C2: ${stats.levelDistribution['C2'] ?? 0}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${stats.totalCompleted}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Saved Vocabulary Card
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VocabularyScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: AppColors.glassCardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.accent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Saved Vocabulary', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text(
                              'Tap to practice or review your saved words',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Consumer<VocabularyProvider>(
                        builder: (context, vocabProvider, _) {
                          return Text(
                            '${vocabProvider.vocabulary.length}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Level Select Header
              const Text(
                'Select CEFR Proficiency Level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // CEFR Levels list
              _buildLevelCard(
                context: context,
                level: 'B2',
                title: 'Upper Intermediate (B2)',
                description: 'Understand main ideas of complex texts, clear expression, typical advanced idioms and vocabulary.',
                gradientColors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
              const SizedBox(height: 16),
              _buildLevelCard(
                context: context,
                level: 'C1',
                title: 'Advanced Language Skills (C1)',
                description: 'Express ideas fluently, complex sentence grammar structures, academic vocabulary and deep idioms.',
                gradientColors: [AppColors.primary, AppColors.accent],
              ),
              const SizedBox(height: 16),
              _buildLevelCard(
                context: context,
                level: 'C2',
                title: 'Mastery & Proficiency (C2)',
                description: 'Understand and translate subtle shades of meaning, demanding native-level flow, precise tone and registers.',
                gradientColors: [const Color(0xFFEC4899), const Color(0xFFBE185D)],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required String level,
    required String title,
    required String description,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startPractice(context, level),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          level,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

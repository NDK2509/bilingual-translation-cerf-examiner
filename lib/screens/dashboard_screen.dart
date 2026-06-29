import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../theme/app_colors.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'vocabulary_screen.dart';

import '../providers/cloze_provider.dart';
import 'cloze_practice_screen.dart';
import 'topic_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _practiceMode = 'translation'; // 'translation' or 'cloze'

  void _startPractice(BuildContext context, String cefrLevel) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final topicArg = settings.selectedTopic;

    if (_practiceMode == 'cloze') {
      final cloze = Provider.of<ClozeProvider>(context, listen: false);
      cloze.generateNewSentence(
        cefrLevel: cefrLevel,
        apiKey: settings.apiKey,
        useMock: settings.useMockMode,
        modelName: settings.selectedModel,
        translateToEnglish: settings.translateToEnglish,
        topic: topicArg,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ClozePracticeScreen(),
        ),
      );
    } else {
      final translation = Provider.of<TranslationProvider>(context, listen: false);
      translation.generateNewSentence(
        cefrLevel: cefrLevel,
        apiKey: settings.apiKey,
        useMock: settings.useMockMode,
        modelName: settings.selectedModel,
        translateToEnglish: settings.translateToEnglish,
        topic: topicArg,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PracticeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
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
              // Background Glow effect
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.bgGlow,
                  ),
                ),
              ),
              
              // Main Scrollable Area
              SafeArea(
                child: Column(
                  children: [
                    // Top Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Language Chip (left side)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Text(
                              settings.translateToEnglish
                                  ? 'VIETNAMESE ➔ ENGLISH'
                                  : 'ENGLISH ➔ VIETNAMESE',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          
                          // Action Icons (settings & translation swapper, no hamburger) (right side)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
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
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 24),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Home screen content directly (no bottom nav)
                    Expanded(
                      child: _buildHomeTab(context, settings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HOME TAB ---
  Widget _buildHomeTab(BuildContext context, SettingsProvider settings) {
    final translation = Provider.of<TranslationProvider>(context);
    final stats = translation.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Custom Stats Grid (Streak, Avg Score, Total, Vocabulary)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: AppColors.premiumCardDecoration(radius: 20),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Streak', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                          Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 20),
                        ],
                      ),
                      Text(
                        '${stats.streak} Days',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: AppColors.premiumCardDecoration(radius: 20),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Avg Score', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                          Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                      Text(
                        '${stats.averageScore.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Exercises Breakdown Card
          Container(
            decoration: AppColors.premiumCardDecoration(radius: 20),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Exercises Completed',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'B2: ${stats.levelDistribution['B2'] ?? 0}  |  C1: ${stats.levelDistribution['C1'] ?? 0}  |  C2: ${stats.levelDistribution['C2'] ?? 0}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${stats.totalCompleted}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vocabulary Card
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VocabularyScreen(),
                ),
              );
            },
            child: Container(
              decoration: AppColors.premiumCardDecoration(radius: 20),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Saved Vocabulary',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Practice and review your words list',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Consumer<VocabularyProvider>(
                    builder: (context, vocabProvider, _) {
                      return Text(
                        '${vocabProvider.vocabulary.length}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Practice Mode Selector
          const Text(
            'Select Practice Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppColors.premiumCardDecoration(radius: 20),
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _practiceMode = 'translation';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _practiceMode == 'translation'
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: _practiceMode == 'translation'
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Bilingual Translation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _practiceMode == 'translation'
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _practiceMode = 'cloze';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _practiceMode == 'cloze'
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: _practiceMode == 'cloze'
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cloze (Fill-in-blank)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _practiceMode == 'cloze'
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Topic Selector Card
          const Text(
            'Practice Topic',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TopicSelectionScreen(),
                ),
              );
            },
            child: Container(
              decoration: AppColors.premiumCardDecoration(radius: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.topic_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.selectedTopic != null && settings.selectedTopic!.isNotEmpty
                              ? settings.selectedTopic!
                              : 'Any Topic (Random)',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap to choose or type a custom topic',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (settings.useMockMode) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.info_outline_rounded, size: 12, color: AppColors.warning),
                SizedBox(width: 6),
                Text(
                  'Mock mode is active. Topic filtering will not apply.',
                  style: TextStyle(fontSize: 10, color: AppColors.warning),
                ),
              ],
            ),
          ],
          const SizedBox(height: 36),

          // Level Select Header
          const Text(
            'Select CEFR Level',
            style: TextStyle(
              fontSize: 18,
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
            gradientColors: [const Color(0xFF0052FF), const Color(0xFF00D1FF)],
          ),
          const SizedBox(height: 16),
          _buildLevelCard(
            context: context,
            level: 'C1',
            title: 'Advanced Language Skills (C1)',
            description: 'Express ideas fluently, complex sentence grammar structures, academic vocabulary and deep idioms.',
            gradientColors: [const Color(0xFF6366F1), const Color(0xFFEC4899)],
            isGlowing: true,
          ),
          const SizedBox(height: 16),
          _buildLevelCard(
            context: context,
            level: 'C2',
            title: 'Mastery & Proficiency (C2)',
            description: 'Understand and translate subtle shades of meaning, demanding native-level flow, precise tone and registers.',
            gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
            borderAccent: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required String level,
    required String title,
    required String description,
    required List<Color> gradientColors,
    bool isGlowing = false,
    Color? borderAccent,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderAccent ?? (isGlowing ? AppColors.primary : AppColors.border.withOpacity(0.5)),
          width: isGlowing || borderAccent != null ? 1.5 : 1.0,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startPractice(context, level),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGlowing ? AppColors.primary : Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isGlowing ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.70),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



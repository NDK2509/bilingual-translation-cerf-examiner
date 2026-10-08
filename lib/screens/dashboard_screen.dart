import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/cloze_provider.dart';
import '../providers/word_match_provider.dart';
import '../providers/mission_provider.dart';
import '../models/user_stats.dart';
import '../theme/app_colors.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'vocabulary_screen.dart';
import 'cloze_practice_screen.dart';
import 'word_match_practice_screen.dart';
import 'topic_selection_screen.dart';
import 'streak_calendar_screen.dart';
import 'missions_rewards_screen.dart';
import '../widgets/choose_gift_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _practiceMode = 'translation'; // 'translation', 'cloze', or 'wordmatch'

  static const List<String> _modes = ['translation', 'cloze', 'wordmatch'];

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
    } else if (_practiceMode == 'wordmatch') {
      final wm = Provider.of<WordMatchProvider>(context, listen: false);
      wm.generateNewExercise(
        cefrLevel: cefrLevel,
        apiKey: settings.apiKey,
        useMock: settings.useMockMode,
        modelName: settings.selectedModel,
        translateToEnglish: settings.translateToEnglish,
        topic: topicArg,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const WordMatchPracticeScreen(),
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
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                settings.translateToEnglish
                                    ? 'VI ➔ EN'
                                    : 'EN ➔ VI',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Action Icons (Streak, Missions, Settings & translation swapper)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.warning,
                                  size: 22,
                                ),
                                tooltip: 'Streak Calendar',
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const StreakCalendarScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Consumer<MissionProvider>(
                                builder: (context, missionProvider, _) {
                                  final isGiftReady = missionProvider.isGiftReady;
                                  final unclaimed = missionProvider.unclaimedMissionsCount;

                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.card_giftcard_rounded,
                                          color: isGiftReady
                                              ? const Color(0xFFF59E0B)
                                              : AppColors.textSecondary,
                                          size: 22,
                                        ),
                                        tooltip: 'Daily Missions & Gifts',
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MissionsRewardsScreen(),
                                          ),
                                        ),
                                      ),
                                      if (isGiftReady || unclaimed > 0)
                                        Positioned(
                                          right: 2,
                                          top: 2,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: isGiftReady
                                                  ? const Color(0xFFEF4444)
                                                  : AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: AppColors.primary,
                                  size: 22,
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
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 22),
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
          // Custom Stats Grid (Streak, Avg Score)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StreakCalendarScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 115,
                    decoration: AppColors.premiumCardDecoration(radius: 20),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Streak',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.local_fire_department_rounded,
                              color: AppColors.warning,
                              size: 20,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${stats.activeStreak} Days',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'View Calendar ➔',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

          // Weekly Streak Strip
          _buildWeeklyStreakStrip(context, stats),
          const SizedBox(height: 16),

          // Daily Missions & EXP Card
          _buildDailyMissionsCard(context),
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
            padding: const EdgeInsets.all(5),
            height: 52,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final modeIndex = _modes.indexOf(_practiceMode);
                final tabWidth = constraints.maxWidth / _modes.length;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      left: tabWidth * modeIndex,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildModeTab('translation', 'Translation'),
                        _buildModeTab('cloze', 'Cloze'),
                        _buildModeTab('wordmatch', 'Word Match'),
                      ],
                    ),
                  ],
                );
              },
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
                Expanded(
                  child: Text(
                    'Mock mode is active. Topic filtering will not apply.',
                    style: TextStyle(fontSize: 10, color: AppColors.warning),
                  ),
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

  Widget _buildModeTab(String mode, String label) {
    final isActive = _practiceMode == mode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _practiceMode = mode;
          });
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  // --- WEEKLY STREAK STRIP ---
  Widget _buildWeeklyStreakStrip(BuildContext context, UserStats stats) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find Monday of this week (Dart weekday: Monday=1, Sunday=7)
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: AppColors.premiumCardDecoration(radius: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Streak',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StreakCalendarScreen()),
                ),
                child: Row(
                  children: const [
                    Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final day = weekDays[index];
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final isPracticed = stats.hasPracticedOn(day);
              final isFuture = day.isAfter(today);

              return Column(
                children: [
                  Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isPracticed
                          ? const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isPracticed
                          ? null
                          : (isToday ? AppColors.surfaceElevated : Colors.transparent),
                      border: Border.all(
                        color: isToday
                            ? AppColors.primary
                            : (isPracticed ? Colors.transparent : AppColors.border),
                        width: isToday ? 2.0 : 1.0,
                      ),
                      boxShadow: isPracticed
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isPracticed
                          ? const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : (isToday
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isFuture
                                        ? AppColors.textMuted
                                        : AppColors.textSecondary,
                                  ),
                                )),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- DAILY MISSIONS & EXP CARD ---
  Widget _buildDailyMissionsCard(BuildContext context) {
    return Consumer<MissionProvider>(
      builder: (context, missionProvider, _) {
        final missions = missionProvider.dailyMissions;
        final currentExp = missionProvider.currentExp;
        final isGiftReady = missionProvider.isGiftReady;
        final progress = (currentExp / 100.0).clamp(0.0, 1.0);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isGiftReady
                  ? [
                      const Color(0xFFB45309).withValues(alpha: 0.3),
                      AppColors.surfaceElevated.withValues(alpha: 0.9),
                    ]
                  : [
                      AppColors.surfaceElevated.withValues(alpha: 0.8),
                      AppColors.surface.withValues(alpha: 0.85),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isGiftReady
                  ? const Color(0xFFF59E0B)
                  : AppColors.borderLight.withValues(alpha: 0.4),
              width: isGiftReady ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isGiftReady ? const Color(0xFFF59E0B) : Colors.black)
                    .withValues(alpha: isGiftReady ? 0.25 : 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.military_tech_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Daily Missions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '3 missions / day to earn 100 EXP',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: isGiftReady
                          ? const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            )
                          : null,
                      color: isGiftReady
                          ? null
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGiftReady
                            ? const Color(0xFFF59E0B)
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$currentExp / 100 EXP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isGiftReady ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // EXP Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isGiftReady ? const Color(0xFFF59E0B) : AppColors.primary,
                  ),
                ),
              ),

              // Gift Ready Banner
              if (isGiftReady) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => ChooseGiftDialog.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '100 EXP Full! Choose Your Gift',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Missions list (compact)
              ...missions.map((m) {
                final isDone = m.isCompleted;
                final isClaimed = m.isClaimed;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isClaimed
                              ? Icons.check_circle_rounded
                              : (isDone
                                  ? Icons.stars_rounded
                                  : Icons.radio_button_unchecked_rounded),
                          color: isClaimed
                              ? AppColors.success
                              : (isDone
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.textMuted),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isClaimed
                                  ? AppColors.textSecondary
                                  : Colors.white,
                              decoration: isClaimed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text(
                          '${m.current}/${m.target}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDone ? const Color(0xFFF59E0B) : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isDone && !isClaimed)
                          InkWell(
                            onTap: () {
                              final claimed = missionProvider.claimMissionExp(m.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 Claimed +$claimed EXP!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'CLAIM',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            '+${m.expReward} EXP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isClaimed
                                  ? AppColors.textMuted
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 6),

              // Bottom View Hub Link
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MissionsRewardsScreen(),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View All Missions & Gifts Log',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.primary,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



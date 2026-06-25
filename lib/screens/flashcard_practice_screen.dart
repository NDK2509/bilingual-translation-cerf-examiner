import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/saved_word.dart';
import '../theme/app_colors.dart';

class FlashcardPracticeScreen extends StatefulWidget {
  const FlashcardPracticeScreen({super.key});

  @override
  State<FlashcardPracticeScreen> createState() => _FlashcardPracticeScreenState();
}

class _FlashcardPracticeScreenState extends State<FlashcardPracticeScreen> {
  List<SavedWord> _practiceStack = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isFinished = false;

  // Track session stats
  int _rememberedCount = 0;
  int _forgotCount = 0;
  final List<String> _upgradedWords = [];

  @override
  void initState() {
    super.initState();
    _initializeStack();
  }

  void _initializeStack() {
    final vocab = Provider.of<VocabularyProvider>(context, listen: false).vocabulary;
    // Copy and shuffle
    _practiceStack = List<SavedWord>.from(vocab);
    _practiceStack.shuffle(Random());
    _currentIndex = 0;
    _isFlipped = false;
    _isFinished = _practiceStack.isEmpty;
    _rememberedCount = 0;
    _forgotCount = 0;
    _upgradedWords.clear();
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _handleReviewResult(bool remembered) async {
    final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
    final currentWord = _practiceStack[_currentIndex];
    
    int newMastery = currentWord.masteryLevel;
    if (remembered) {
      _rememberedCount++;
      newMastery = min(100, currentWord.masteryLevel + 20);
      if (newMastery >= 100 && currentWord.masteryLevel < 100) {
        _upgradedWords.add(currentWord.word);
      }
    } else {
      _forgotCount++;
      newMastery = max(0, currentWord.masteryLevel - 20); // penalty for forgetfulness
    }

    // Save changes to database
    await vocabProvider.updateMastery(currentWord.word, newMastery);

    // Proceed to next card
    if (_currentIndex < _practiceStack.length - 1) {
      setState(() {
        _isFlipped = false; // reset flip before transition
        // Short delay to allow card to flip back before moving index
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _currentIndex++;
            });
          }
        });
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildSummaryScreen();
    }

    if (_practiceStack.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('No words to practice.')),
      );
    }

    final word = _practiceStack[_currentIndex];
    final progress = (_currentIndex + 1) / _practiceStack.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Session (${_currentIndex + 1}/${_practiceStack.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Exit Session?'),
                content: const Text('Your current practice progress will not be summarized, though saved scores remain. Exit anyway?'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Resume', style: TextStyle(color: AppColors.primary)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Pop dialog
                      Navigator.pop(context); // Exit practice screen
                    },
                    child: const Text('Exit', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          children: [
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 32),

            // Card Container with 3D Flip
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  builder: (context, val, child) {
                    final isBack = val > 90;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012) // Perspective depth
                        ..rotateY(val * pi / 180),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(pi), // correct mirrored text
                              alignment: Alignment.center,
                              child: _buildCardBack(word),
                            )
                          : _buildCardFront(word),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Flip / Score Button Panels
            AnimatedCrossFade(
              firstChild: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _flipCard,
                  icon: const Icon(Icons.flip_rounded),
                  label: const Text('REVEAL TRANSLATION'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevated,
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              secondChild: Row(
                children: [
                  // Forgot Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleReviewResult(false),
                        icon: const Icon(Icons.sentiment_very_dissatisfied_rounded, color: AppColors.error),
                        label: const Text('FORGOT', style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Remembered Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleReviewResult(true),
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                        label: const Text('REMEMBERED'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: _isFlipped ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(SavedWord word) {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: AppColors.glassCardDecoration(
        color: AppColors.surface,
        borderWidth: 1.5,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.help_center_rounded,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            word.word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          if (word.phonetic.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.phonetic,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 48),
          Text(
            'Tap the button below or card to flip',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(SavedWord word) {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: AppColors.glassCardDecoration(
        color: AppColors.surfaceElevated,
        borderWidth: 1.5,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title / English Word
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                ],
              ),
              const Divider(color: AppColors.border, height: 16),
              
              // Definition Section
              const Text(
                'Translation / Definition:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                word.definition,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),

              // Context Sentence Section
              const Text(
                'Sentence Context:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                word.context,
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Detailed Nuance
              if (word.contextExplanation.isNotEmpty) ...[
                const Text(
                  'Contextual Nuance (Giải thích):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  word.contextExplanation,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryScreen() {
    final hasUpgrades = _upgradedWords.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Confetti / Celebration Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.success.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 72,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Practice Complete!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You finished reviewing your practice stack.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Summary Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryMetric(
                      'Remembered',
                      '$_rememberedCount',
                      AppColors.success,
                      Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Forgot',
                      '$_forgotCount',
                      AppColors.error,
                      Icons.sentiment_dissatisfied_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mastery Upgraded Card
              if (hasUpgrades)
                Container(
                  width: double.infinity,
                  decoration: AppColors.glassCardDecoration(
                    color: AppColors.success.withOpacity(0.06),
                    borderWidth: 1.0,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.rocket_launch_rounded, color: AppColors.success, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mastery Upgraded!',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_upgradedWords.join(", ")} reached 100% mastery.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _initializeStack();
                        });
                      },
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'PRACTICE AGAIN',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // return to VocabularyScreen
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('DONE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color, IconData icon) {
    return Container(
      decoration: AppColors.glassCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

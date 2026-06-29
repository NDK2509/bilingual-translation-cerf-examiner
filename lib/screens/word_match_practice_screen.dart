import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_match_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/saved_word.dart';
import '../theme/app_colors.dart';

class WordMatchPracticeScreen extends StatefulWidget {
  const WordMatchPracticeScreen({super.key});

  @override
  State<WordMatchPracticeScreen> createState() => _WordMatchPracticeScreenState();
}

class _WordMatchPracticeScreenState extends State<WordMatchPracticeScreen> {
  bool _wordSaved = false;
  bool _matchSaved = false;

  void _showWordDefinitionBottomSheet(
    BuildContext context,
    String word,
    String contextSentence,
  ) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final vocab = Provider.of<VocabularyProvider>(context, listen: false);

    final cleanWord = word.replaceAll(RegExp(r"[^a-zA-Z0-9'-]"), '').trim();
    if (cleanWord.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _WordLookupSheet(
              word: cleanWord,
              contextSentence: contextSentence,
              settings: settings,
              vocab: vocab,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WordMatchProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // 1. Loading state
    if (provider.isLoadingExercise) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                Positioned.fill(
                    child: Container(
                        decoration:
                            const BoxDecoration(gradient: AppColors.bgGlow))),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Generating ${provider.currentLevel ?? "Word Match"} challenge...',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chờ trong giây lát...',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
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

    // 2. Error state
    if (provider.errorMessage != null && provider.currentExercise == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                Positioned.fill(
                    child: Container(
                        decoration:
                            const BoxDecoration(gradient: AppColors.bgGlow))),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load Word Match exercise',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            if (provider.currentLevel != null) {
                              provider.generateNewExercise(
                                cefrLevel: provider.currentLevel!,
                                apiKey: settings.apiKey,
                                useMock: settings.useMockMode,
                                modelName: settings.selectedModel,
                                translateToEnglish: settings.translateToEnglish,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Try Again',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final exercise = provider.currentExercise;
    if (exercise == null) {
      return const Scaffold(
        body: Center(child: Text('No active word match session.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${exercise.cefrLevel} Word Match',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () {
            provider.resetSession();
            Navigator.of(context).pop();
          },
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
              Positioned.fill(
                  child: Container(
                      decoration:
                          const BoxDecoration(gradient: AppColors.bgGlow))),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: exercise.isSynonym
                              ? AppColors.info.withOpacity(0.15)
                              : AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exercise.isSynonym
                                ? AppColors.info.withOpacity(0.3)
                                : AppColors.warning.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              exercise.isSynonym
                                  ? Icons.swap_horiz_rounded
                                  : Icons.compare_arrows_rounded,
                              color: exercise.isSynonym
                                  ? AppColors.info
                                  : AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              exercise.isSynonym
                                  ? 'Find the SYNONYM'
                                  : 'Find the ANTONYM',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: exercise.isSynonym
                                    ? AppColors.info
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sentence Card with highlighted target word
                      Container(
                        width: double.infinity,
                        decoration: AppColors.glassCardDecoration(
                            color: AppColors.surface),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.menu_book_rounded,
                                    color: AppColors.primary, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Read the sentence:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const Divider(
                                color: AppColors.border, height: 20),
                            _buildHighlightedSentence(
                                context, exercise.sentence, exercise.targetWord),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vietnamese Translation
                      Container(
                        width: double.infinity,
                        decoration: AppColors.glassCardDecoration(
                            color: AppColors.surface),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.g_translate_rounded,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                exercise.translation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Question prompt
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.textPrimary),
                          children: [
                            TextSpan(
                              text: exercise.isSynonym
                                  ? 'Which word is a synonym of '
                                  : 'Which word is an antonym of ',
                            ),
                            TextSpan(
                              text: '"${exercise.targetWord}"',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const TextSpan(text: '?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Options Grid
                      _buildOptionsGrid(context, exercise, provider),
                      const SizedBox(height: 24),

                      // Check / Result
                      if (!provider.isEvaluated)
                        _buildCheckButton(context, provider)
                      else
                        _buildResultCard(context, exercise, provider, settings),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedSentence(
      BuildContext context, String sentence, String targetWord) {
    // Split the sentence around the target word (case-insensitive)
    final lowerSentence = sentence.toLowerCase();
    final lowerTarget = targetWord.toLowerCase();
    final targetIndex = lowerSentence.indexOf(lowerTarget);

    if (targetIndex == -1) {
      // Fallback: show sentence as-is
      return Text(sentence,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.6));
    }

    final before = sentence.substring(0, targetIndex);
    final target =
        sentence.substring(targetIndex, targetIndex + targetWord.length);
    final after = sentence.substring(targetIndex + targetWord.length);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.6),
        children: [
          TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => _showWordDefinitionBottomSheet(
                  context, target, sentence),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4), width: 1.5),
                ),
                child: Text(
                  target,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, exercise, WordMatchProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.2,
      ),
      itemCount: exercise.options.length,
      itemBuilder: (context, index) {
        final option = exercise.options[index];
        final isSelected = provider.selectedAnswer == option;

        Color bgColor = AppColors.surface;
        Color borderColor = AppColors.borderLight;
        Color textColor = AppColors.textPrimary;
        double borderWidth = 1.0;
        Widget? trailingIcon;

        if (provider.isEvaluated) {
          final isCorrectOption =
              option.trim().toLowerCase() == exercise.correctAnswer.trim().toLowerCase();
          final isUserChoice = provider.selectedAnswer == option;

          if (isCorrectOption) {
            bgColor = AppColors.success.withOpacity(0.15);
            borderColor = AppColors.success;
            borderWidth = 2.0;
            textColor = AppColors.success;
            trailingIcon = const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 18);
          } else if (isUserChoice && !isCorrectOption) {
            bgColor = AppColors.error.withOpacity(0.15);
            borderColor = AppColors.error;
            borderWidth = 2.0;
            textColor = AppColors.error;
            trailingIcon = const Icon(Icons.cancel_rounded,
                color: AppColors.error, size: 18);
          }
        } else if (isSelected) {
          bgColor = AppColors.primary.withOpacity(0.15);
          borderColor = AppColors.primary;
          borderWidth = 2.0;
          textColor = Colors.white;
        }

        return GestureDetector(
          onTap: provider.isEvaluated ? null : () => provider.selectAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: isSelected && !provider.isEvaluated
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (trailingIcon != null) ...[
                    trailingIcon,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckButton(BuildContext context, WordMatchProvider provider) {
    final hasAnswer = provider.selectedAnswer != null;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GestureDetector(
        onTap: hasAnswer ? () => provider.checkAnswer() : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: hasAnswer ? AppColors.primaryGradient : null,
            color: hasAnswer ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: hasAnswer ? null : Border.all(color: AppColors.border),
            boxShadow: hasAnswer
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            hasAnswer ? 'CHECK ANSWER' : 'SELECT AN OPTION',
            style: TextStyle(
              color: hasAnswer ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, exercise,
      WordMatchProvider provider, SettingsProvider settings) {
    final isCorrect = provider.isCorrect;
    final statusColor = isCorrect ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: AppColors.glassCardDecoration(
              color: AppColors.surface, radius: 20),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_outline_rounded
                        : Icons.highlight_off_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCorrect ? 'CHÍNH XÁC! 🎉' : 'CHƯA ĐÚNG!',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 28),
              // Explanation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giải thích:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exercise.explanation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: 'Đáp án đúng: '),
                            TextSpan(
                              text: exercise.correctAnswer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Save Word Button
        _buildSaveWordButton(context, exercise),
        const SizedBox(height: 10),

        // Save Synonym/Antonym Button
        _buildSaveMatchButton(context, exercise),
        const SizedBox(height: 16),

        // Next Challenge Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: GestureDetector(
            onTap: () {
              if (provider.currentLevel != null) {
                setState(() {
                  _wordSaved = false;
                  _matchSaved = false;
                });
                provider.generateNewExercise(
                  cefrLevel: provider.currentLevel!,
                  apiKey: settings.apiKey,
                  useMock: settings.useMockMode,
                  modelName: settings.selectedModel,
                  translateToEnglish: settings.translateToEnglish,
                  topic: settings.selectedTopic,
                );
              }
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT CHALLENGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveWordButton(BuildContext context, exercise) {
    final vocab = Provider.of<VocabularyProvider>(context, listen: false);
    final isAlreadySaved = vocab.isWordSaved(exercise.targetWord);

    if (_wordSaved || isAlreadySaved) {
      return Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_rounded, color: AppColors.success, size: 20),
            SizedBox(width: 8),
            Text(
              'WORD SAVED ✓',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: () async {
          final word = SavedWord(
            word: exercise.targetWord,
            definition: exercise.explanation,
            context: exercise.sentence,
            phonetic: '',
            contextExplanation:
                '${exercise.isSynonym ? "Từ đồng nghĩa" : "Từ trái nghĩa"}: ${exercise.correctAnswer}\nDịch câu: ${exercise.translation}',
            createdAt: DateTime.now(),
          );
          await vocab.saveWord(word);
          setState(() {
            _wordSaved = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${exercise.targetWord}" saved to vocabulary!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_add_outlined,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'SAVE WORD TO VOCABULARY',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveMatchButton(BuildContext context, exercise) {
    final vocab = Provider.of<VocabularyProvider>(context, listen: false);
    final isAlreadySaved = vocab.isWordSaved(exercise.correctAnswer);
    final labelType = exercise.isSynonym ? 'SYNONYM' : 'ANTONYM';

    if (_matchSaved || isAlreadySaved) {
      return Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              '$labelType SAVED ✓',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: () async {
          final word = SavedWord(
            word: exercise.correctAnswer,
            definition: exercise.isSynonym
                ? 'Từ đồng nghĩa của "${exercise.targetWord}".'
                : 'Từ trái nghĩa của "${exercise.targetWord}".',
            context: exercise.sentence,
            phonetic: '',
            contextExplanation: exercise.isSynonym
                ? 'Từ đồng nghĩa của "${exercise.targetWord}" trong câu: "${exercise.sentence}"\nDịch câu: ${exercise.translation}'
                : 'Từ trái nghĩa của "${exercise.targetWord}" trong câu: "${exercise.sentence}"\nDịch câu: ${exercise.translation}',
            createdAt: DateTime.now(),
          );
          await vocab.saveWord(word);
          setState(() {
            _matchSaved = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${exercise.correctAnswer}" ($labelType) saved to vocabulary!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_add_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'SAVE $labelType TO VOCABULARY',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple word lookup bottom sheet (reused pattern)
class _WordLookupSheet extends StatefulWidget {
  final String word;
  final String contextSentence;
  final SettingsProvider settings;
  final VocabularyProvider vocab;

  const _WordLookupSheet({
    required this.word,
    required this.contextSentence,
    required this.settings,
    required this.vocab,
  });

  @override
  State<_WordLookupSheet> createState() => _WordLookupSheetState();
}

class _WordLookupSheetState extends State<_WordLookupSheet> {
  bool _isLoading = true;
  Map<String, dynamic>? _definition;
  String? _error;

  @override
  void initState() {
    super.initState();
    _lookupWord();
  }

  Future<void> _lookupWord() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.vocab.fetchWordDetails(
        word: widget.word,
        contextSentence: widget.contextSentence,
        apiKey: widget.settings.apiKey,
        useMock: widget.settings.useMockMode,
        modelName: widget.settings.selectedModel,
        translateToEnglish: widget.settings.translateToEnglish,
      );
      if (mounted) {
        setState(() {
          _definition = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.word,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Divider(color: AppColors.border, height: 24),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            )
          else if (_definition != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_definition!['pronunciation'] != null)
                      Text(
                        _definition!['pronunciation'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (_definition!['meaning'] != null)
                      Text(
                        _definition!['meaning'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    if (_definition!['examples'] != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Examples:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_definition!['examples'] as List<dynamic>).map(
                        (ex) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      color: AppColors.primary, fontSize: 14)),
                              Expanded(
                                child: Text(
                                  ex.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cloze_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/cloze_session.dart';
import '../models/saved_word.dart';
import '../theme/app_colors.dart';

class ClozePracticeScreen extends StatefulWidget {
  const ClozePracticeScreen({super.key});

  @override
  State<ClozePracticeScreen> createState() => _ClozePracticeScreenState();
}

class _ClozePracticeScreenState extends State<ClozePracticeScreen> {
  int _activeBlankIndex = 0;

  void _showWordDefinitionBottomSheet(
    BuildContext context,
    String word,
    String contextSentence,
  ) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final vocab = Provider.of<VocabularyProvider>(context, listen: false);

    final cleanWord = settings.translateToEnglish
        ? word.replaceAll(RegExp(r"[^a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'-]"), '').trim()
        : word.replaceAll(RegExp(r"[^a-zA-Z0-9'-]"), '').trim();
    if (cleanWord.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.58,
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _WordDefinitionSheet(
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

  void _checkAnswers(BuildContext context, ClozeProvider provider) {
    provider.checkAnswers();
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _nextChallenge(BuildContext context, ClozeProvider provider, SettingsProvider settings) {
    if (provider.currentLevel != null) {
      provider.generateNewSentence(
        cefrLevel: provider.currentLevel!,
        apiKey: settings.apiKey,
        useMock: settings.useMockMode,
        modelName: settings.selectedModel,
        translateToEnglish: settings.translateToEnglish,
      );
      setState(() {
        _activeBlankIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClozeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // 1. Loading state
    if (provider.isLoadingSentence) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.bgGlow))),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Generating ${provider.currentLevel ?? "Cloze"} challenge...',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chờ trong giây lát...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
    if (provider.errorMessage != null && provider.currentSentence == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
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
            child: Stack(
              children: [
                Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.bgGlow))),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load cloze exercise',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            if (provider.currentLevel != null) {
                              provider.generateNewSentence(
                                cefrLevel: provider.currentLevel!,
                                apiKey: settings.apiKey,
                                useMock: settings.useMockMode,
                                modelName: settings.selectedModel,
                                translateToEnglish: settings.translateToEnglish,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    final sentence = provider.currentSentence;
    if (sentence == null) {
      return const Scaffold(
        body: Center(child: Text('No active cloze session.')),
      );
    }

    // Ensure _activeBlankIndex is within bounds
    if (_activeBlankIndex >= sentence.blanks.length) {
      _activeBlankIndex = 0;
    }

    final isAllFilled = provider.userAnswers.length >= sentence.blanks.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${sentence.cefrLevel} Cloze Challenge', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
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
              Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppColors.bgGlow))),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Direction Prompt
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          settings.translateToEnglish
                              ? 'Fill the blanks in English:'
                              : 'Dịch câu tiếng Anh bằng cách điền từ:',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Translation/Context sentence Card
                      Container(
                        width: double.infinity,
                        decoration: AppColors.glassCardDecoration(
                          color: AppColors.surface,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.g_translate_rounded, color: AppColors.primary, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Context Translation (Bản dịch)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.border, height: 20),
                            InteractiveSentence(
                              sentence: sentence.translation,
                              onWordTapped: (w) => _showWordDefinitionBottomSheet(context, w, sentence.translation),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cloze Masked Sentence Card
                      const Text(
                        'Complete this sentence:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: AppColors.glassCardDecoration(
                          color: AppColors.surface,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: _buildMaskedSentenceWidget(context, sentence, provider),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            'Tap options below to fill blanks. Tap words to look up.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Options & Hints Section
                      if (!provider.isEvaluated) ...[
                        _buildActiveBlankClue(sentence),
                        const SizedBox(height: 20),
                        _buildOptionsGrid(sentence, provider),
                      ] else ...[
                        _buildResultsCard(context, provider, settings),
                      ],

                      const SizedBox(height: 36),

                      // Check Answer Button (only show if not evaluated)
                      if (!provider.isEvaluated)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: provider.isChecking
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: isAllFilled ? () => _checkAnswers(context, provider) : null,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: isAllFilled ? AppColors.primaryGradient : null,
                                      color: isAllFilled ? null : AppColors.surface,
                                      borderRadius: BorderRadius.circular(30),
                                      border: isAllFilled ? null : Border.all(color: AppColors.border),
                                      boxShadow: isAllFilled
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
                                      isAllFilled ? 'CHECK ANSWERS' : 'FILL ALL BLANKS',
                                      style: TextStyle(
                                        color: isAllFilled ? Colors.white : AppColors.textMuted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
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

  // Parses maskedSentence and builds inline blanks
  Widget _buildMaskedSentenceWidget(
    BuildContext context,
    ClozeSentence sentence,
    ClozeProvider provider,
  ) {
    final RegExp regExp = RegExp(r"(\{\d+\})");
    final matches = regExp.allMatches(sentence.maskedSentence);

    if (matches.isEmpty) {
      return Text(sentence.maskedSentence, style: const TextStyle(fontSize: 18, color: AppColors.textPrimary));
    }

    final List<Widget> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      // Plain text before match
      if (match.start > lastEnd) {
        final text = sentence.maskedSentence.substring(lastEnd, match.start);
        spans.add(_buildInteractiveSpan(text, sentence.fullSentence));
      }

      // Placeholder
      final placeholder = match.group(0)!;
      final blankIndex = int.parse(placeholder.replaceAll(RegExp(r'[{}]'), ''));
      spans.add(_buildBlankWidget(context, sentence, provider, blankIndex));

      lastEnd = match.end;
    }

    // Plain text after last match
    if (lastEnd < sentence.maskedSentence.length) {
      final text = sentence.maskedSentence.substring(lastEnd);
      spans.add(_buildInteractiveSpan(text, sentence.fullSentence));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: spans,
    );
  }

  // Renders a segment of normal text as clickable words
  Widget _buildInteractiveSpan(String text, String fullSentence) {
    final RegExp wordRegExp = RegExp(
        r"([a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'-]+|[^a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ\s]+|\s+)"
    );
    final tokens = wordRegExp.allMatches(text).map((m) => m.group(0)!).toList();

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: tokens.map((token) {
        final isWord = RegExp(
            r"^[a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'-]+$"
        ).hasMatch(token);

        if (isWord) {
          return InkWell(
            onTap: () => _showWordDefinitionBottomSheet(context, token, fullSentence),
            borderRadius: BorderRadius.circular(4),
            hoverColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              token,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          );
        } else {
          return Text(
            token,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          );
        }
      }).toList(),
    );
  }

  // Renders the blank itself
  Widget _buildBlankWidget(
    BuildContext context,
    ClozeSentence sentence,
    ClozeProvider provider,
    int index,
  ) {
    final isSelected = _activeBlankIndex == index;
    final answer = provider.userAnswers[index];
    final hasAnswer = answer != null && answer.isNotEmpty;

    Color containerColor = Colors.transparent;
    Color textColor = AppColors.primary;
    Border border = Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5, style: BorderStyle.solid);
    Widget icon = const SizedBox.shrink();

    if (provider.isEvaluated) {
      final blank = sentence.blanks.firstWhere((b) => b.index == index);
      final isCorrect = answer?.trim().toLowerCase() == blank.correctAnswer.trim().toLowerCase();

      if (isCorrect) {
        containerColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        border = Border.all(color: AppColors.success, width: 2);
        icon = const Padding(
          padding: EdgeInsets.only(right: 4.0),
          child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
        );
      } else {
        containerColor = AppColors.error.withOpacity(0.12);
        textColor = AppColors.error;
        border = Border.all(color: AppColors.error, width: 2);
        icon = const Padding(
          padding: EdgeInsets.only(right: 4.0),
          child: Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
        );
      }
    } else {
      if (hasAnswer) {
        containerColor = AppColors.primary.withOpacity(0.15);
        textColor = Colors.white;
        border = Border.all(color: AppColors.primary, width: 2);
      } else {
        border = Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: isSelected ? 2.0 : 1.5,
          style: BorderStyle.solid,
        );
      }
    }

    return GestureDetector(
      onTap: () {
        if (provider.isEvaluated) return;
        setState(() {
          _activeBlankIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
          boxShadow: isSelected && !provider.isEvaluated
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            Text(
              hasAnswer ? answer : ' (Blank ${index + 1}) ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active blank clue/hint box
  Widget _buildActiveBlankClue(ClozeSentence sentence) {
    if (_activeBlankIndex >= sentence.blanks.length) return const SizedBox.shrink();
    final currentBlank = sentence.blanks[_activeBlankIndex];

    return Container(
      width: double.infinity,
      decoration: AppColors.glassCardDecoration(
        color: AppColors.surface,
        borderWidth: 1.0,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gợi ý cho ô trống ${_activeBlankIndex + 1}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentBlank.hint,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Multiple choice options selector grid
  Widget _buildOptionsGrid(ClozeSentence sentence, ClozeProvider provider) {
    if (_activeBlankIndex >= sentence.blanks.length) return const SizedBox.shrink();
    final currentBlank = sentence.blanks[_activeBlankIndex];
    final selectedAnswer = provider.userAnswers[_activeBlankIndex];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.2,
      ),
      itemCount: currentBlank.options.length,
      itemBuilder: (context, index) {
        final option = currentBlank.options[index];
        final isSelected = selectedAnswer == option;

        return Container(
          decoration: AppColors.glassCardDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderWidth: isSelected ? 2.0 : 1.0,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                provider.selectAnswer(_activeBlankIndex, option);
                _autoAdvanceBlank(sentence, provider);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    option,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Automatically switches active focus to the next empty blank, if any
  void _autoAdvanceBlank(ClozeSentence sentence, ClozeProvider provider) {
    for (int i = 0; i < sentence.blanks.length; i++) {
      final nextIdx = (_activeBlankIndex + 1 + i) % sentence.blanks.length;
      if (provider.userAnswers[nextIdx] == null) {
        setState(() {
          _activeBlankIndex = nextIdx;
        });
        break;
      }
    }
  }

  // Results display box
  Widget _buildResultsCard(
    BuildContext context,
    ClozeProvider provider,
    SettingsProvider settings,
  ) {
    final score = provider.score;
    final isPassed = score >= 50;
    final statusColor = isPassed ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Gauge & Feedback Card
        Container(
          width: double.infinity,
          decoration: AppColors.glassCardDecoration(color: AppColors.surface, radius: 20),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPassed ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPassed ? 'HOÀN THÀNH ĐẠT YÊU CẦU!' : 'CẦN CẢI THIỆN THÊM!',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Điểm Số',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Số ô chính xác',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_getCorrectCount(provider)} / ${provider.currentSentence?.blanks.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (score < 100) ...[
                const Divider(color: AppColors.border, height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Đáp án đúng:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.currentSentence!.blanks.map((b) {
                  final uAnswer = provider.userAnswers[b.index];
                  final isCorrect = uAnswer?.trim().toLowerCase() == b.correctAnswer.trim().toLowerCase();
                  if (isCorrect) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded, color: AppColors.error, size: 18),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                              children: [
                                TextSpan(
                                  text: 'Chỗ trống ${b.index + 1}: Bạn chọn ',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                TextSpan(
                                  text: '"${uAnswer ?? "chưa chọn"}"',
                                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: ' ➔ Đáp án đúng là ',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                TextSpan(
                                  text: '"${b.correctAnswer}"',
                                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Action Buttons (Dashboard vs Next Challenge)
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  provider.resetSession();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: TextButton.styleFrom(
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'DASHBOARD',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => _nextChallenge(context, provider, settings),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'NEXT CHALLENGE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _getCorrectCount(ClozeProvider provider) {
    final sentence = provider.currentSentence;
    if (sentence == null) return 0;
    int correctCount = 0;
    for (final blank in sentence.blanks) {
      final u = provider.userAnswers[blank.index]?.trim().toLowerCase();
      final c = blank.correctAnswer.trim().toLowerCase();
      if (u == c) {
        correctCount++;
      }
    }
    return correctCount;
  }
}

class _WordDefinitionSheet extends StatefulWidget {
  final String word;
  final String contextSentence;
  final SettingsProvider settings;
  final VocabularyProvider vocab;

  const _WordDefinitionSheet({
    required this.word,
    required this.contextSentence,
    required this.settings,
    required this.vocab,
  });

  @override
  State<_WordDefinitionSheet> createState() => _WordDefinitionSheetState();
}

class _WordDefinitionSheetState extends State<_WordDefinitionSheet> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchDetails());
  }

  Future<_WordDefinitionSheetState> _fetchDetails() async {
    try {
      final details = await widget.vocab.fetchWordDetails(
        word: widget.word,
        contextSentence: widget.contextSentence,
        useMock: widget.settings.useMockMode,
        apiKey: widget.settings.apiKey,
        modelName: widget.settings.selectedModel,
        translateToEnglish: widget.settings.translateToEnglish,
      );
      if (mounted) {
        setState(() {
          _details = details;
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
    return this;
  }

  Future<void> _toggleSave(bool isSaved) async {
    if (isSaved) {
      await widget.vocab.removeWord(widget.word);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${widget.word}" from vocabulary.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      if (_details == null) return;
      final savedWord = SavedWord(
        word: widget.word,
        definition: _details!['vietnamese_definition'] ?? 'Không rõ nghĩa',
        context: widget.contextSentence,
        phonetic: _details!['phonetic'] ?? '',
        contextExplanation: _details!['context_explanation'] ?? '',
        createdAt: DateTime.now(),
      );
      await widget.vocab.saveWord(savedWord);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "${widget.word}" to practice list!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = widget.vocab.isWordSaved(widget.word);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading) ...[
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ] else if (_error.isNotEmpty) ...[
            Expanded(
              child: Center(
                child: Text('Lỗi: $_error', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ] else if (_details != null) ...[
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.word,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_details!['phonetic'] != null && (_details!['phonetic'] as String).trim().isNotEmpty && _details!['phonetic'] != '/.../') ...[
                                const SizedBox(height: 4),
                                Text(
                                  _details!['phonetic'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                            color: isSaved ? AppColors.primary : AppColors.textSecondary,
                            size: 28,
                          ),
                          onPressed: () => _toggleSave(isSaved),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    const Text(
                      'Định nghĩa / Dịch nghĩa:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        _details!['vietnamese_definition'] ?? 'Không rõ nghĩa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Giải thích ngữ cảnh:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _details!['context_explanation'] ?? 'Không có giải thích chi tiết.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GestureDetector(
                onTap: () => _toggleSave(isSaved),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isSaved ? null : AppColors.primaryGradient,
                    color: isSaved ? AppColors.surface : null,
                    borderRadius: BorderRadius.circular(30),
                    border: isSaved ? Border.all(color: AppColors.border) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded, color: isSaved ? AppColors.success : Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        isSaved ? 'SAVED TO PRACTICE' : 'SAVE WORD TO PRACTICE',
                        style: TextStyle(
                          color: isSaved ? AppColors.success : Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class InteractiveSentence extends StatelessWidget {
  final String sentence;
  final Function(String word) onWordTapped;

  const InteractiveSentence({
    super.key,
    required this.sentence,
    required this.onWordTapped,
  });

  @override
  Widget build(BuildContext context) {
    final RegExp regExp = RegExp(
        r"([a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'-]+|[^a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ\s]+|\s+)"
    );
    final matches = regExp.allMatches(sentence).map((m) => m.group(0)!).toList();

    return Wrap(
      spacing: 0,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: matches.map((token) {
        final isWord = RegExp(
            r"^[a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'-]+$"
        ).hasMatch(token);
        if (isWord) {
          return InkWell(
            onTap: () => onWordTapped(token),
            borderRadius: BorderRadius.circular(4),
            hoverColor: AppColors.primary.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Text(
                token,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dashed,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          );
        } else {
          return Text(
            token,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          );
        }
      }).toList(),
    );
  }
}
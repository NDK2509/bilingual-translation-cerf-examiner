import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../models/saved_word.dart';
import '../theme/app_colors.dart';
import 'evaluation_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TextEditingController _translationController = TextEditingController();
  bool _hintRevealed = false;
  String? _lastSentenceText;

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _submitTranslation(
    BuildContext context,
    TranslationProvider translation,
    SettingsProvider settings,
  ) async {
    final text = _translationController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập bản dịch của bạn!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await translation.evaluateTranslation(
      userTranslation: text,
      apiKey: settings.apiKey,
      useMock: settings.useMockMode,
      modelName: settings.selectedModel,
      translateToEnglish: settings.translateToEnglish,
    );

    if (!mounted) return;

    if (translation.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${translation.errorMessage}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (translation.evaluationResult != null) {
      // Navigate to evaluation screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const EvaluationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = Provider.of<TranslationProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Automatically clear user input and hint state when a new sentence is generated
    final sentence = translation.currentSentence;
    if (sentence != null && sentence.sourceSentence != _lastSentenceText) {
      _translationController.clear();
      _hintRevealed = false;
      _lastSentenceText = sentence.sourceSentence;
    }

    // 1. Loading Sentence State
    if (translation.isLoadingSentence) {
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
                        'Generating ${translation.currentLevel} sentence...',
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

    // 2. Error State
    if (translation.errorMessage != null && translation.currentSentence == null) {
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
                          'Failed to fetch challenge',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          translation.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            if (translation.currentLevel != null) {
                              translation.generateNewSentence(
                                cefrLevel: translation.currentLevel!,
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

    if (sentence == null) {
      return const Scaffold(
        body: Center(child: Text('No active practice session.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${sentence.cefrLevel} Challenge', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            translation.resetSession();
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
                      // Prompt Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          settings.translateToEnglish
                              ? 'Translate this sentence into English'
                              : 'Translate this sentence into Vietnamese',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Source Sentence Card
                      Container(
                        width: double.infinity,
                        decoration: AppColors.glassCardDecoration(
                          color: AppColors.surface,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: InteractiveSentence(
                          sentence: sentence.sourceSentence,
                          onWordTapped: (word) => _showWordDefinitionBottomSheet(context, word, sentence.sourceSentence),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            'Tap any word to look up and save definitions',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Hint section
                      AnimatedCrossFade(
                        firstChild: SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _hintRevealed = true;
                              });
                            },
                            icon: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning),
                            label: const Text(
                              'Show Hint (Gợi ý dịch)',
                              style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.warning.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        secondChild: Container(
                          width: double.infinity,
                          decoration: AppColors.glassCardDecoration(
                            color: AppColors.surface,
                            borderWidth: 1.0,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded, color: AppColors.warning, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gợi ý ngữ pháp / Từ vựng:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  sentence.hint,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _hintRevealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 36),

                  // Your Translation Label
                  const Text(
                    'Bản dịch của bạn:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Box with glowing focused border
                  TextField(
                    controller: _translationController,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: settings.translateToEnglish
                          ? 'Nhập câu dịch tiếng Anh tại đây...'
                          : 'Nhập câu dịch tiếng Việt tại đây...',
                      alignLabelWithHint: true,
                      fillColor: AppColors.surface,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    enabled: !translation.isEvaluating,
                  ),
                  const SizedBox(height: 36),

                  // Submit Actions (Glowing Gradient button)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: translation.isEvaluating
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _submitTranslation(context, translation, settings),
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
                                  )
                                ],
                              ),
                              child: const Text(
                                'SUBMIT TRANSLATION',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: matches.map((token) {
        final isWord = RegExp(
            r"^[a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'-]+$"
        ).hasMatch(token);
        if (isWord) {
          return InkWell(
            onTap: () => onWordTapped(token),
            borderRadius: BorderRadius.circular(4),
            hoverColor: AppColors.primary.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
              child: Text(
                token,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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

  Future<void> _fetchDetails() async {
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
    setState(() {}); // Refresh state
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

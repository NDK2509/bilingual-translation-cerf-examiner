import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
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

    // 1. Loading Sentence State
    if (translation.isLoadingSentence) {
      return Scaffold(
        body: Center(
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chờ trong giây lát...',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Error State
    if (translation.errorMessage != null && translation.currentSentence == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text(
                  'Failed to fetch challenge',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  translation.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (translation.currentLevel != null) {
                      translation.generateNewSentence(
                        cefrLevel: translation.currentLevel!,
                        apiKey: settings.apiKey,
                        useMock: settings.useMockMode,
                        modelName: settings.selectedModel,
                      );
                    }
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Main Practice Interface
    final sentence = translation.currentSentence;
    if (sentence == null) {
      return const Scaffold(
        body: Center(child: Text('No active practice session.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${sentence.cefrLevel} Translation Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            translation.resetSession();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prompt Label
              const Text(
                'Translate this sentence into Vietnamese:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Source English Sentence Card
              Container(
                width: double.infinity,
                decoration: AppColors.glassCardDecoration(
                  color: AppColors.surfaceElevated,
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  sentence.englishSentence,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                      style: TextStyle(color: AppColors.warning),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                secondChild: Container(
                  width: double.infinity,
                  decoration: AppColors.glassCardDecoration(
                    color: AppColors.warning.withOpacity(0.06),
                    borderWidth: 1.0,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppColors.warning),
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
                            const SizedBox(height: 4),
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
              const SizedBox(height: 32),

              // Your Translation Label
              const Text(
                'Bản dịch của bạn:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Input Box
              TextField(
                controller: _translationController,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 15, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'Nhập câu dịch tiếng Việt tại đây...',
                  alignLabelWithHint: true,
                ),
                enabled: !translation.isEvaluating,
              ),
              const SizedBox(height: 32),

              // Submit Actions
              SizedBox(
                width: double.infinity,
                height: 54,
                child: translation.isEvaluating
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => _submitTranslation(context, translation, settings),
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                        ),
                        child: const Text('SUBMIT TRANSLATION'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

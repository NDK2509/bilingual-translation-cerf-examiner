import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  void _nextChallenge(
    BuildContext context,
    TranslationProvider translation,
    SettingsProvider settings,
  ) {
    if (translation.currentLevel != null) {
      translation.generateNewSentence(
        cefrLevel: translation.currentLevel!,
        apiKey: settings.apiKey,
        useMock: settings.useMockMode,
        modelName: settings.selectedModel,
        translateToEnglish: settings.translateToEnglish,
      );
      Navigator.of(context).pop();
    }
  }

  void _exitToDashboard(BuildContext context, TranslationProvider translation) {
    translation.resetSession();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final translation = Provider.of<TranslationProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final evaluation = translation.evaluationResult;

    if (evaluation == null) {
      return const Scaffold(
        body: Center(child: Text('No active evaluation results.')),
      );
    }

    final isPassed = evaluation.isAcceptable;
    final statusColor = isPassed ? AppColors.primary : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Translation Report', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Acceptability Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPassed ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                            color: statusColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPassed ? 'ACCEPTED (ĐẠT YÊU CẦU)' : 'REVISION NEEDED (CẦN CẢI THIỆN)',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Score Circular Gauge with Halo Glow
                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          children: [
                            // Soft Glow Backdrop
                            Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                width: 130,
                                height: 130,
                                child: CircularProgressIndicator(
                                  value: evaluation.score / 100,
                                  strokeWidth: 8,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${evaluation.score}',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    '/ 100',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Original Source Sentence Card
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        settings.translateToEnglish ? 'Câu gốc tiếng Việt:' : 'Câu gốc tiếng Anh:',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: AppColors.glassCardDecoration(
                        color: AppColors.surface,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        translation.currentSentence?.sourceSentence ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // User's Translation Card
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Bản dịch của bạn:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: AppColors.glassCardDecoration(
                        color: AppColors.surface,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        translation.userTranslation ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Professor's Feedback Card
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Nhận xét từ Giảng viên:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Đánh giá chi tiết',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          Text(
                            evaluation.feedback,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Suggested Translations
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        settings.translateToEnglish
                            ? 'Bản dịch đề xuất (Suggested translations):'
                            : 'Bản dịch đề xuất tham khảo:',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...evaluation.suggestedTranslations.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          width: double.infinity,
                          decoration: AppColors.glassCardDecoration(
                            color: AppColors.surface,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.star_border_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 36),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _exitToDashboard(context, translation),
                            style: TextButton.styleFrom(
                              side: const BorderSide(color: AppColors.border, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'DASHBOARD',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _nextChallenge(context, translation, settings),
                            child: Container(
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Text(
                                'NEXT CHALLENGE',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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

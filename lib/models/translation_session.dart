class GeneratedSentence {
  final String action;
  final String cefrLevel;
  final String englishSentence;
  final String hint;

  GeneratedSentence({
    required this.action,
    required this.cefrLevel,
    required this.englishSentence,
    required this.hint,
  });

  String get sourceSentence => englishSentence;

  factory GeneratedSentence.fromJson(Map<String, dynamic> json) {
    return GeneratedSentence(
      action: json['action'] as String? ?? 'GENERATE',
      cefrLevel: json['cefr_level'] as String? ?? '',
      englishSentence: (json['source_sentence'] ?? json['english_sentence']) as String? ?? '',
      hint: json['hint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'cefr_level': cefrLevel,
      'english_sentence': englishSentence,
      'source_sentence': englishSentence,
      'hint': hint,
    };
  }
}

class EvaluationResult {
  final String action;
  final bool isAcceptable;
  final int score;
  final String feedback;
  final List<String> suggestedTranslations;

  EvaluationResult({
    required this.action,
    required this.isAcceptable,
    required this.score,
    required this.feedback,
    required this.suggestedTranslations,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      action: json['action'] as String? ?? 'EVALUATE',
      isAcceptable: json['is_acceptable'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      feedback: json['feedback'] as String? ?? '',
      suggestedTranslations: List<String>.from(json['suggested_translations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'is_acceptable': isAcceptable,
      'score': score,
      'feedback': feedback,
      'suggested_translations': suggestedTranslations,
    };
  }
}

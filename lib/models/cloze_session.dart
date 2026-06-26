class ClozeBlank {
  final int index;
  final String correctAnswer;
  final List<String> options;
  final String hint;

  ClozeBlank({
    required this.index,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });

  factory ClozeBlank.fromJson(Map<String, dynamic> json) {
    // Safely extract options list
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    List<String> parsedOptions = rawOptions.map((o) => o.toString()).toList();
    
    // Ensure correct answer is in the options list
    final correct = json['correct_answer'] as String? ?? json['correctAnswer'] as String? ?? '';
    if (correct.isNotEmpty && !parsedOptions.contains(correct)) {
      parsedOptions.add(correct);
    }
    
    return ClozeBlank(
      index: json['index'] as int? ?? 0,
      correctAnswer: correct,
      options: parsedOptions,
      hint: json['hint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'correct_answer': correctAnswer,
      'options': options,
      'hint': hint,
    };
  }
}

class ClozeSentence {
  final String cefrLevel;
  final String fullSentence;
  final String maskedSentence;
  final List<ClozeBlank> blanks;
  final String translation;

  ClozeSentence({
    required this.cefrLevel,
    required this.fullSentence,
    required this.maskedSentence,
    required this.blanks,
    required this.translation,
  });

  factory ClozeSentence.fromJson(Map<String, dynamic> json) {
    final rawBlanks = json['blanks'] as List<dynamic>? ?? [];
    final parsedBlanks = rawBlanks.map((b) => ClozeBlank.fromJson(b as Map<String, dynamic>)).toList();

    return ClozeSentence(
      cefrLevel: json['cefr_level'] as String? ?? json['cefrLevel'] as String? ?? '',
      fullSentence: json['full_sentence'] as String? ?? json['fullSentence'] as String? ?? '',
      maskedSentence: json['masked_sentence'] as String? ?? json['maskedSentence'] as String? ?? '',
      blanks: parsedBlanks,
      translation: json['translation'] as String? ?? json['vietnamese_translation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cefr_level': cefrLevel,
      'full_sentence': fullSentence,
      'masked_sentence': maskedSentence,
      'blanks': blanks.map((b) => b.toJson()).toList(),
      'translation': translation,
    };
  }
}

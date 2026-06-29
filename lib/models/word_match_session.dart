/// Model for the Word Match (Synonym/Antonym) exercise.
///
/// A sentence is displayed with a highlighted target word.
/// The user must pick the correct synonym or antonym from multiple options.
class WordMatchExercise {
  final String cefrLevel;
  final String sentence;
  final String targetWord;
  final String matchType; // "synonym" or "antonym"
  final String correctAnswer;
  final List<String> options;
  final String translation;
  final String explanation;

  WordMatchExercise({
    required this.cefrLevel,
    required this.sentence,
    required this.targetWord,
    required this.matchType,
    required this.correctAnswer,
    required this.options,
    required this.translation,
    required this.explanation,
  });

  factory WordMatchExercise.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    List<String> parsedOptions = rawOptions.map((o) => o.toString()).toList();

    final correct = json['correct_answer'] as String? ?? '';
    if (correct.isNotEmpty && !parsedOptions.contains(correct)) {
      parsedOptions.add(correct);
    }

    return WordMatchExercise(
      cefrLevel: json['cefr_level'] as String? ?? '',
      sentence: json['sentence'] as String? ?? '',
      targetWord: json['target_word'] as String? ?? '',
      matchType: json['match_type'] as String? ?? 'synonym',
      correctAnswer: correct,
      options: parsedOptions,
      translation: json['translation'] as String? ?? json['vietnamese_translation'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cefr_level': cefrLevel,
      'sentence': sentence,
      'target_word': targetWord,
      'match_type': matchType,
      'correct_answer': correctAnswer,
      'options': options,
      'translation': translation,
      'explanation': explanation,
    };
  }

  bool get isSynonym => matchType.toLowerCase() == 'synonym';
}

import 'dart:convert';

class SavedWord {
  final String word;
  final String definition;
  final String context;
  final String phonetic;
  final String contextExplanation;
  final DateTime createdAt;
  int masteryLevel; // 0 to 100 for flashcard practice progression

  SavedWord({
    required this.word,
    required this.definition,
    required this.context,
    required this.phonetic,
    required this.contextExplanation,
    required this.createdAt,
    this.masteryLevel = 0,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'definition': definition,
    'context': context,
    'phonetic': phonetic,
    'context_explanation': contextExplanation,
    'created_at': createdAt.toIso8601String(),
    'mastery_level': masteryLevel,
  };

  factory SavedWord.fromJson(Map<String, dynamic> json) => SavedWord(
    word: json['word'] as String,
    definition: json['definition'] as String,
    context: json['context'] as String,
    phonetic: json['phonetic'] as String? ?? '',
    contextExplanation: json['context_explanation'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    masteryLevel: json['mastery_level'] as int? ?? 0,
  );

  String toJsonString() => json.encode(toJson());

  factory SavedWord.fromJsonString(String str) =>
      SavedWord.fromJson(json.decode(str) as Map<String, dynamic>);
}

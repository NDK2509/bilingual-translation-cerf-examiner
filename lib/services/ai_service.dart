import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/translation_session.dart';

class AIService {
  // Pre-coded mock data for offline/no-key usage
  static final Map<String, List<Map<String, String>>> _mockSentences = {
    'B2': [
      {
        'english_sentence': 'Although the company faced severe financial difficulties, they managed to pull through thanks to a timely government bailout.',
        'hint': 'Chú ý cấu trúc "pull through" (vượt qua khó khăn) và cụm từ "government bailout" (gói cứu trợ tài chính của chính phủ).'
      },
      {
        'english_sentence': 'If we had known the meeting was cancelled, we wouldn\'t have travelled all this way in the pouring rain.',
        'hint': 'Sử dụng câu điều kiện loại 3 để diễn tả sự tiếc nuối trong quá khứ, chú ý dịch thoát ý "all this way".'
      },
    ],
    'C1': [
      {
        'english_sentence': 'The project\'s success is contingent upon the seamless integration of our cloud infrastructure with the legacy systems.',
        'hint': 'Cụm "contingent upon" (phụ thuộc vào) và "legacy systems" (hệ thống cũ/di sản) cần được chuyển ngữ một cách chuyên nghiệp.'
      },
      {
        'english_sentence': 'Had it not been for the whistleblower\'s timely disclosure, the systemic corruption within the firm would have gone unnoticed.',
        'hint': 'Đảo ngữ câu điều kiện loại 3 ("Had it not been for..."). Dịch chuẩn xác cụm "whistleblower" (người tố giác) và "systemic corruption" (tham nhũng có hệ thống).'
      },
    ],
    'C2': [
      {
        'english_sentence': 'Her speech was a masterclass in diplomacy, subtly shifting the blame without ever explicitly naming her detractors.',
        'hint': 'Một câu có sắc thái rất tinh tế. Hãy chú ý từ "masterclass" (bài học xuất sắc/khuôn mẫu), và cụm "detractors" (những kẻ gièm pha/phản đối).'
      },
      {
        'english_sentence': 'The protagonist\'s descent into madness is portrayed not as a sudden break from reality, but as a slow, insidious erosion of the self.',
        'hint': 'Chú ý tính từ "insidious" (âm thầm nhưng nguy hại) và cụm "erosion of the self" (sự bào mòn/băng hoại bản ngã).'
      },
    ],
  };

  static final Map<String, Map<String, dynamic>> _mockEvaluations = {
    'B2': {
      'is_acceptable': true,
      'score': 85,
      'feedback': 'Bản dịch khá tốt và truyền đạt đầy đủ ý nghĩa cốt lõi của câu gốc. Việc xử lý cụm "pull through" bằng từ "vượt qua" hoặc "vực dậy" là hợp lý. Điểm trừ nhẹ là câu từ hơi cứng nhắc một chút ở đoạn cuối, có thể diễn đạt mượt mà hơn.',
      'suggested_translations': [
        'Mặc dù công ty đối mặt với những khó khăn tài chính trầm trọng, họ đã vượt qua được nhờ có gói cứu trợ kịp thời từ chính phủ.',
        'Dù phải đối mặt với khó khăn tài chính nghiêm trọng, công ty vẫn xoay xở vượt qua được nhờ gói cứu trợ kịp thời của chính phủ.'
      ]
    },
    'C1': {
      'is_acceptable': true,
      'score': 88,
      'feedback': 'Bản dịch đạt yêu cầu của trình độ C1. Bạn đã chuyển ngữ chính xác cụm "contingent upon" thành "phụ thuộc vào" và "legacy systems" thành "các hệ thống cũ". Cách hành văn tự nhiên và giữ được sắc thái trang trọng của văn bản gốc.',
      'suggested_translations': [
        'Sự thành công của dự án phụ thuộc vào sự tích hợp liền mạch giữa cơ sở hạ tầng đám mây của chúng tôi với các hệ thống sẵn có từ trước.',
        'Thành công của dự án tùy thuộc vào việc tích hợp trơn tru giữa hạ tầng điện toán đám mây của chúng ta và các hệ thống di sản.'
      ]
    },
    'C2': {
      'is_acceptable': true,
      'score': 92,
      'feedback': 'Xuất sắc! Bản dịch thể hiện sự nhạy cảm ngôn ngữ cao, truyền tải được sắc thái văn chương tinh tế của trình độ C2. Cụm "erosion of the self" được dịch rất tốt thành "sự bào mòn bản ngã". Nhịp điệu câu tiếng Việt trôi chảy, tự nhiên như người bản xứ.',
      'suggested_translations': [
        'Sự rơi vào điên loạn của nhân vật chính được khắc họa không phải như một sự đứt gãy đột ngột khỏi thực tại, mà như một sự bào mòn bản ngã âm thầm và chậm rãi.',
        'Hành trình trượt dài vào điên loạn của nhân vật chính được miêu tả không phải là sự tách rời tức thời khỏi thế giới thực, mà là một sự băng hoại dần dần, âm thầm của cái tôi.'
      ]
    }
  };

  // Helper to clean response strings from markdown wrappers
  String _cleanJsonString(String raw) {
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      // Find start of json body
      final firstLineBreak = cleaned.indexOf('\n');
      if (firstLineBreak != -1) {
        cleaned = cleaned.substring(firstLineBreak).trim();
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3).trim();
      }
    }
    return cleaned;
  }

  // Action A: Generate
  Future<GeneratedSentence> generateSentence({
    required String cefrLevel,
    required bool useMock,
    required String apiKey,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate API call
      await Future.delayed(const Duration(milliseconds: 1200));
      final sentences = _mockSentences[cefrLevel] ?? _mockSentences['B2']!;
      // Pick a random sentence from the pool
      final index = DateTime.now().millisecond % sentences.length;
      final selected = sentences[index];
      return GeneratedSentence(
        action: 'GENERATE',
        cefrLevel: cefrLevel,
        englishSentence: selected['english_sentence']!,
        hint: selected['hint']!,
      );
    }

    // Call Real Gemini API
    final systemInstruction = '''
You are an expert bilingual English-Vietnamese language professor and elite translation examiner specializing in the CEFR language frameworks (B2, C1, C2).

You handle two distinct operational actions for an English-to-Vietnamese translation practice application. Depending on the user's requested "action", process the logic strictly according to the corresponding ruleset below.

You must respond ONLY with a valid, clean JSON object. Do not wrap the JSON output in markdown formatting (such as ```json), do not include backticks, and do not include any conversational prose outside the JSON structure.

---

Action A: "GENERATE"
Use this action when a user wants a new sentence to translate.
- Rules:
  1. Generate a single, highly natural English sentence tailored precisely to the requested `cefr_level` (B2, C1, or C2).
  2. The sentence must utilize grammatical structures, idioms, and vocabulary typical of that specific tier.
  3. Provide a brief contextual clue (`hint`) in Vietnamese highlighting a tricky nuance or setup, without revealing the actual vocabulary solutions.
- Expected Output JSON Schema:
  {
    "action": "GENERATE",
    "cefr_level": "string (B2, C1, or C2)",
    "english_sentence": "string",
    "hint": "string"
  }
''';

    final prompt = 'Generate a sentence with action "GENERATE" for CEFR level: $cefrLevel.';

    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final content = [
        Content.text(systemInstruction),
        Content.text(prompt),
      ];

      final response = await model.generateContent(content);
      final rawText = response.text;
      if (rawText == null || rawText.isEmpty) {
        throw Exception('Received empty response from Gemini.');
      }

      final cleanedJson = _cleanJsonString(rawText);
      final parsed = json.decode(cleanedJson) as Map<String, dynamic>;
      return GeneratedSentence.fromJson(parsed);
    } catch (e) {
      throw Exception('Failed to generate sentence via Gemini: $e');
    }
  }

  // Action B: Evaluate
  Future<EvaluationResult> evaluateTranslation({
    required String cefrLevel,
    required String englishSource,
    required String userTranslation,
    required bool useMock,
    required String apiKey,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));
      if (userTranslation.trim().length < 8) {
        return EvaluationResult(
          action: 'EVALUATE',
          isAcceptable: false,
          score: 30,
          feedback: 'Bản dịch quá ngắn hoặc không hoàn thiện. Hãy cố dịch đầy đủ ý nghĩa của câu nguồn trước khi gửi đánh giá.',
          suggestedTranslations: [
            'Vui lòng hoàn thành bản dịch đầy đủ dựa trên gợi ý từ bài học.'
          ],
        );
      }

      // Return a mock result appropriate for the level
      final result = _mockEvaluations[cefrLevel] ?? _mockEvaluations['B2']!;
      return EvaluationResult.fromJson(result);
    }

    // Call Real Gemini API
    final systemInstruction = '''
You are an expert bilingual English-Vietnamese language professor and elite translation examiner specializing in the CEFR language frameworks (B2, C1, C2).

You handle two distinct operational actions for an English-to-Vietnamese translation practice application. Depending on the user's requested "action", process the logic strictly according to the corresponding ruleset below.

You must respond ONLY with a valid, clean JSON object. Do not wrap the JSON output in markdown formatting (such as ```json), do not include backticks, and do not include any conversational prose outside the JSON structure.

---

Action B: "EVALUATE"
Use this action when evaluating a submitted user translation.
- Rules:
  1. Compare `english_source` with `user_translation` based on the targeted `cefr_level`.
  2. Be constructive but strict: For B2, allow minor stiffness if the fundamental meaning is intact. For C2, demand native-like flow, precise contextual tone, and exact register match.
  3. Provide your `feedback` assessment completely in natural, encouraging Vietnamese. Explain errors or stylistic choices clearly.
  4. Assign a numerical `score` from 0 to 100.
- Expected Output JSON Schema:
  {
    "action": "EVALUATE",
    "is_acceptable": boolean,
    "score": integer (0 to 100),
    "feedback": "string (Feedback text in Vietnamese)",
    "suggested_translations": ["string (Option 1)", "string (Option 2)"]
  }
''';

    final requestJson = json.encode({
      'cefr_level': cefrLevel,
      'english_source': englishSource,
      'user_translation': userTranslation,
    });

    final prompt = 'Evaluate the user translation. Details:\n$requestJson';

    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final content = [
        Content.text(systemInstruction),
        Content.text(prompt),
      ];

      final response = await model.generateContent(content);
      final rawText = response.text;
      if (rawText == null || rawText.isEmpty) {
        throw Exception('Received empty response from Gemini during evaluation.');
      }

      final cleanedJson = _cleanJsonString(rawText);
      final parsed = json.decode(cleanedJson) as Map<String, dynamic>;
      return EvaluationResult.fromJson(parsed);
    } catch (e) {
      throw Exception('Failed to evaluate translation via Gemini: $e');
    }
  }

  // Action C: Define Word
  Future<Map<String, dynamic>> defineWord({
    required String word,
    required String contextSentence,
    required bool useMock,
    required String apiKey,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate network call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final lowerWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '');
      
      String phonetic = '/.../';
      String definition = 'Định nghĩa giả lập cho từ "$word".';
      String contextExplanation = 'Cách dùng đặc biệt trong ngữ cảnh câu này.';
      
      if (lowerWord.contains('pull') || lowerWord.contains('through')) {
        phonetic = '/pʊl θruː/';
        definition = 'vượt qua (một giai đoạn khó khăn, bệnh tật)';
        contextExplanation = 'Trong câu này, "pull through" diễn tả việc doanh nghiệp xoay xở và hồi phục thành công sau khi gặp khủng hoảng tài chính nghiêm trọng.';
      } else if (lowerWord.contains('bailout')) {
        phonetic = '/ˈbeɪlaʊt/';
        definition = 'sự cứu trợ tài chính, gói cứu trợ';
        contextExplanation = 'Ám chỉ khoản hỗ trợ tiền tệ khẩn cấp từ chính phủ giúp cứu doanh nghiệp khỏi nguy cơ phá sản.';
      } else if (lowerWord.contains('legacy')) {
        phonetic = '/ˈleɡəsi/';
        definition = 'di sản, hệ thống cũ, đời trước';
        contextExplanation = 'Ở đây "legacy systems" là các phần mềm hoặc máy tính cũ đã lỗi thời nhưng vẫn đang được doanh nghiệp sử dụng.';
      } else if (lowerWord.contains('contingent')) {
        phonetic = '/kənˈtɪndʒənt/';
        definition = 'phụ thuộc vào, tùy thuộc vào';
        contextExplanation = 'Cụm "contingent upon" nghĩa là thành công của dự án hoàn toàn phụ thuộc vào việc tích hợp hệ thống.';
      } else if (lowerWord.contains('insidious')) {
        phonetic = '/ɪnˈsɪdiəs/';
        definition = 'âm thầm nguy hại, tiến triển ngấm ngầm';
        contextExplanation = 'Miêu tả sự tàn phá, xói mòn bản ngã của nhân vật một cách từ từ, không ồn ào nhưng để lại hậu quả nghiêm trọng.';
      } else if (lowerWord.contains('whistleblogger') || lowerWord.contains('whistleblower')) {
        phonetic = '/ˈwɪslbləʊər/';
        definition = 'người tố giác, người thổi còi';
        contextExplanation = 'Người phát giác và báo cáo các hành vi tham nhũng, sai phạm nội bộ công ty ra ánh sáng.';
      }
      
      return {
        'word': word,
        'phonetic': phonetic,
        'vietnamese_definition': definition,
        'context_explanation': contextExplanation,
      };
    }

    final systemInstruction = '''
You are a highly experienced English-Vietnamese dictionary compiler and bilingual language tutor.
Given an English word or phrase and the context sentence it appears in, output a JSON object containing:
1. The standard IPA phonetic pronunciation.
2. The most appropriate Vietnamese translation/definition as it is used in that specific context.
3. A detailed explanation in Vietnamese of how the word functions in that context sentence, what nuances it carries, and how to translate it properly.

You must respond ONLY with a valid, clean JSON object. Do not wrap the JSON output in markdown formatting, do not include backticks, and do not include any prose outside the JSON structure.

Expected Output JSON Schema:
{
  "word": "string",
  "phonetic": "string",
  "vietnamese_definition": "string (the core translation of the word/phrase)",
  "context_explanation": "string (detailed explanation of the word's contextual meaning and nuances)"
}
''';

    final prompt = 'Analyze the word/phrase: "$word"\nContext Sentence: "$contextSentence"';

    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final content = [
        Content.text(systemInstruction),
        Content.text(prompt),
      ];

      final response = await model.generateContent(content);
      final rawText = response.text;
      if (rawText == null || rawText.isEmpty) {
        throw Exception('Received empty response from Gemini.');
      }

      final cleanedJson = _cleanJsonString(rawText);
      return json.decode(cleanedJson) as Map<String, dynamic>;
    } catch (e) {
      return {
        'word': word,
        'phonetic': '/.../',
        'vietnamese_definition': 'Không tải được nghĩa trực tuyến.',
        'context_explanation': 'Đã xảy ra lỗi khi kết nối với máy chủ AI: $e',
      };
    }
  }
}

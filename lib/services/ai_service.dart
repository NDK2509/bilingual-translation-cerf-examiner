import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/translation_session.dart';
import '../models/cloze_session.dart';

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

  static final Map<String, List<Map<String, String>>> _mockSentencesVnToEn = {
    'B2': [
      {
        'vietnamese_sentence': 'Mặc dù công ty đối mặt với những khó khăn tài chính nghiêm trọng, họ vẫn vượt qua được nhờ có gói cứu trợ kịp thời của chính phủ.',
        'hint': 'Sử dụng cấu trúc "although" hoặc "despite", cụm từ "pull through" (vượt qua khó khăn) và cụm từ "government bailout" (gói cứu trợ tài chính).'
      },
      {
        'vietnamese_sentence': 'Nếu chúng tôi biết cuộc họp bị hủy, chúng tôi đã không lặn lội đường xa dưới trời mưa như trút nước thế này.',
        'hint': 'Sử dụng câu điều kiện loại 3 (Third Conditional) để nói về sự việc trái với quá khứ. Cụm "mưa như trút nước" dịch là "pouring rain".'
      },
    ],
    'C1': [
      {
        'vietnamese_sentence': 'Thành công của dự án tùy thuộc vào việc tích hợp trơn tru giữa hạ tầng điện toán đám mây của chúng ta và các hệ thống sẵn có từ trước.',
        'hint': 'Sử dụng cụm "contingent upon" (tùy thuộc vào), "seamless integration" (tích hợp trơn tru) và "legacy systems" (hệ thống cũ từ trước).'
      },
      {
        'vietnamese_sentence': 'Nếu không nhờ sự tiết lộ kịp thời của người tố giác, hành vi tham nhũng có hệ thống trong công ty đã bị che giấu.',
        'hint': 'Sử dụng cấu trúc đảo ngữ điều kiện loại 3 ("Had it not been for..."). Chú ý từ "whistleblower" (người tố giác) và "systemic corruption".'
      },
    ],
    'C2': [
      {
        'vietnamese_sentence': 'Bài phát biểu của cô ấy là một bài học xuất sắc về mặt ngoại giao, khéo léo đổ lỗi mà không hề nêu đích danh những kẻ gièm pha.',
        'hint': 'Sử dụng từ "masterclass" (bài học xuất sắc), "subtly shifting the blame" (khéo léo đổ lỗi) và "detractors" (những kẻ gièm pha).'
      },
      {
        'vietnamese_sentence': 'Hành trình trượt dài vào điên loạn của nhân vật chính được miêu tả không phải là sự tách rời tức thời khỏi thế giới thực, mà là một sự băng hoại dần dần, âm thầm của cái tôi.',
        'hint': 'Sử dụng cụm "descent into madness" (trượt dài vào điên loạn), "insidious erosion of the self" (bào mòn âm thầm của cái tôi) và liên từ "not as... but as...".'
      },
    ],
  };

  static final Map<String, Map<String, dynamic>> _mockEvaluationsVnToEn = {
    'B2': {
      'is_acceptable': true,
      'score': 85,
      'feedback': 'Bản dịch tiếng Anh khá tốt và truyền đạt đầy đủ ý nghĩa của câu gốc. Việc sử dụng cấu trúc "Although the company faced..." và cụm "pull through" rất chính xác. Bạn có thể cải thiện thêm độ trôi chảy bằng cách dùng đại từ thích hợp.',
      'suggested_translations': [
        'Although the company faced severe financial difficulties, they managed to pull through thanks to a timely government bailout.',
        'Despite facing severe financial difficulties, the company managed to pull through thanks to a timely government bailout.'
      ]
    },
    'C1': {
      'is_acceptable': true,
      'score': 88,
      'feedback': 'Bản dịch đạt yêu cầu của trình độ C1. Bạn đã chuyển ngữ chính xác cụm "contingent upon" thành "tùy thuộc vào" trong tiếng Anh, sử dụng cụm danh từ "seamless integration" và "legacy systems" trôi chảy, tự nhiên.',
      'suggested_translations': [
        'The project\'s success is contingent upon the seamless integration of our cloud infrastructure with the legacy systems.',
        'Success of the project is contingent upon the seamless integration of our cloud infrastructure with the legacy systems.'
      ]
    },
    'C2': {
      'is_acceptable': true,
      'score': 92,
      'feedback': 'Bản dịch xuất sắc! Thể hiện sự nhạy bén cao về mặt ngôn ngữ ở cấp độ C2. Việc dịch "sự băng hoại bản ngã âm thầm" thành "insidious erosion of the self" cực kỳ chính xác. Nhịp điệu câu văn tiếng Anh tự nhiên như người bản xứ.',
      'suggested_translations': [
        'The protagonist\'s descent into madness is portrayed not as a sudden break from reality, but as a slow, insidious erosion of the self.',
        'The main character\'s descent into madness is depicted not as a sudden break from reality, but as a slow, insidious erosion of the self.'
      ]
    }
  };

  static final Map<String, List<Map<String, dynamic>>> _mockClozeEn = {
    'B2': [
      {
        'full_sentence': 'Although the company faced severe financial difficulties, they managed to pull through thanks to a timely government bailout.',
        'masked_sentence': 'Although the company faced severe financial difficulties, they managed to {0} thanks to a timely government {1}.',
        'vietnamese_translation': 'Mặc dù công ty đối mặt với những khó khăn tài chính nghiêm trọng, họ vẫn vượt qua được nhờ có gói cứu trợ kịp thời của chính phủ.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'pull through',
            'options': ['pull through', 'pull over', 'pull off', 'pull down'],
            'hint': 'vượt qua khó khăn'
          },
          {
            'index': 1,
            'correct_answer': 'bailout',
            'options': ['bailout', 'subsidy', 'investment', 'loan'],
            'hint': 'gói cứu trợ tài chính'
          }
        ]
      },
      {
        'full_sentence': 'If we had known the meeting was cancelled, we wouldn\'t have travelled all this way in the pouring rain.',
        'masked_sentence': 'If we had known the meeting was cancelled, we wouldn\'t have travelled {0} in the {1}.',
        'vietnamese_translation': 'Nếu chúng tôi biết cuộc họp bị hủy, chúng tôi đã không lặn lội đường xa dưới trời mưa như trút nước thế này.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'all this way',
            'options': ['all this way', 'this road', 'long distance', 'so far away'],
            'hint': 'lặn lội đường xa/đến tận đây'
          },
          {
            'index': 1,
            'correct_answer': 'pouring rain',
            'options': ['pouring rain', 'drizzling rain', 'heavy storm', 'wet weather'],
            'hint': 'mưa như trút nước'
          }
        ]
      }
    ],
    'C1': [
      {
        'full_sentence': 'The project\'s success is contingent upon the seamless integration of our cloud infrastructure with the legacy systems.',
        'masked_sentence': 'The project\'s success is {0} upon the seamless {1} of our cloud infrastructure with the legacy systems.',
        'vietnamese_translation': 'Thành công của dự án tùy thuộc vào việc tích hợp trơn tru giữa hạ tầng điện toán đám mây của chúng ta và các hệ thống sẵn có từ trước.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'contingent',
            'options': ['contingent', 'dependent', 'reliant', 'based'],
            'hint': 'tùy thuộc vào (đi với upon)'
          },
          {
            'index': 1,
            'correct_answer': 'integration',
            'options': ['integration', 'separation', 'connection', 'installation'],
            'hint': 'sự tích hợp trơn tru (seamless...)'
          }
        ]
      },
      {
        'full_sentence': 'Had it not been for the whistleblower\'s timely disclosure, the systemic corruption within the firm would have gone unnoticed.',
        'masked_sentence': '{0} it not been for the whistleblower\'s timely disclosure, the systemic {1} within the firm would have gone unnoticed.',
        'vietnamese_translation': 'Nếu không nhờ sự tiết lộ kịp thời của người tố giác, hành vi tham nhũng có hệ thống trong công ty đã bị che giấu.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'Had',
            'options': ['Had', 'If', 'Should', 'Were'],
            'hint': 'Đảo ngữ câu điều kiện loại 3'
          },
          {
            'index': 1,
            'correct_answer': 'corruption',
            'options': ['corruption', 'incompetence', 'governance', 'bribery'],
            'hint': 'sự tham nhũng (systemic ...)'
          }
        ]
      }
    ],
    'C2': [
      {
        'full_sentence': 'Her speech was a masterclass in diplomacy, subtly shifting the blame without ever explicitly naming her detractors.',
        'masked_sentence': 'Her speech was a {0} in diplomacy, subtly shifting the blame without ever explicitly naming her {1}.',
        'vietnamese_translation': 'Bài phát biểu của cô ấy là một bài học xuất sắc về mặt ngoại giao, khéo léo đổ lỗi mà không hề nêu đích danh những kẻ gièm pha.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'masterclass',
            'options': ['masterclass', 'lesson', 'lecture', 'guide'],
            'hint': 'bài học xuất sắc/mẫu mực'
          },
          {
            'index': 1,
            'correct_answer': 'detractors',
            'options': ['detractors', 'defenders', 'allies', 'advocates'],
            'hint': 'những kẻ gièm pha/chỉ trích'
          }
        ]
      },
      {
        'full_sentence': 'The protagonist\'s descent into madness is portrayed not as a sudden break from reality, but as a slow, insidious erosion of the self.',
        'masked_sentence': 'The protagonist\'s {0} into madness is portrayed not as a sudden break from reality, but as a slow, {1} erosion of the self.',
        'vietnamese_translation': 'Hành trình trượt dài vào điên loạn của nhân vật chính được miêu tả không phải là sự tách rời tức thời khỏi thế giới thực, mà là một sự bào mòn dần dần, âm thầm của cái tôi.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'descent',
            'options': ['descent', 'fall', 'journey', 'slide'],
            'hint': 'hành trình đi xuống/trượt dài'
          },
          {
            'index': 1,
            'correct_answer': 'insidious',
            'options': ['insidious', 'obvious', 'silent', 'gradual'],
            'hint': 'ngấm ngầm/âm thầm nguy hại'
          }
        ]
      }
    ]
  };

  static final Map<String, List<Map<String, dynamic>>> _mockClozeVn = {
    'B2': [
      {
        'full_sentence': 'Mặc dù công ty đối mặt với những khó khăn tài chính nghiêm trọng, họ vẫn vượt qua được nhờ có gói cứu trợ kịp thời của chính phủ.',
        'masked_sentence': 'Mặc dù công ty đối mặt với những khó khăn tài chính nghiêm trọng, họ vẫn {0} được nhờ có {1} kịp thời của chính phủ.',
        'vietnamese_translation': 'Although the company faced severe financial difficulties, they managed to pull through thanks to a timely government bailout.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'vượt qua',
            'options': ['vượt qua', 'tránh né', 'giải quyết', 'chi trả'],
            'hint': 'to pull through'
          },
          {
            'index': 1,
            'correct_answer': 'gói cứu trợ',
            'options': ['gói cứu trợ', 'khoản đầu tư', 'tiền vay', 'sự hỗ trợ'],
            'hint': 'bailout'
          }
        ]
      },
      {
        'full_sentence': 'Nếu chúng tôi biết cuộc họp bị hủy, chúng tôi đã không lặn lội đường xa dưới trời mưa như trút nước thế này.',
        'masked_sentence': 'Nếu chúng tôi biết cuộc họp bị hủy, chúng tôi đã không lặn lội đường xa dưới trời {0} thế này.',
        'vietnamese_translation': 'If we had known the meeting was cancelled, we wouldn\'t have travelled all this way in the pouring rain.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'mưa như trút nước',
            'options': ['mưa như trút nước', 'mưa phùn', 'bão bùng', 'nắng gắt'],
            'hint': 'pouring rain'
          }
        ]
      }
    ],
    'C1': [
      {
        'full_sentence': 'Thành công của dự án tùy thuộc vào việc tích hợp trơn tru giữa hạ tầng điện toán đám mây của chúng ta và các hệ thống sẵn có từ trước.',
        'masked_sentence': 'Thành công của dự án {0} vào việc {1} trơn tru giữa hạ tầng điện toán đám mây của chúng ta và các hệ thống sẵn có từ trước.',
        'vietnamese_translation': 'The project\'s success is contingent upon the seamless integration of our cloud infrastructure with the legacy systems.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'tùy thuộc',
            'options': ['tùy thuộc', 'dựa dẫm', 'quyết định', 'ảnh hưởng'],
            'hint': 'is contingent upon'
          },
          {
            'index': 1,
            'correct_answer': 'tích hợp',
            'options': ['tích hợp', 'chia rẽ', 'kết nối', 'nâng cấp'],
            'hint': 'integration'
          }
        ]
      },
      {
        'full_sentence': 'Nếu không nhờ sự tiết lộ kịp thời của người tố giác, hành vi tham nhũng có hệ thống trong công ty đã bị che giấu.',
        'masked_sentence': 'Nếu không nhờ sự tiết lộ kịp thời của {0}, hành vi {1} có hệ thống trong công ty đã bị che giấu.',
        'vietnamese_translation': 'Had it not been for the whistleblower\'s timely disclosure, the systemic corruption within the firm would have gone unnoticed.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'người tố giác',
            'options': ['người tố giác', 'nhân chứng', 'luật sư', 'nhân viên'],
            'hint': 'whistleblower'
          },
          {
            'index': 1,
            'correct_answer': 'tham nhũng',
            'options': ['tham nhũng', 'suy thoái', 'gian lận', 'hối lộ'],
            'hint': 'corruption'
          }
        ]
      }
    ],
    'C2': [
      {
        'full_sentence': 'Bài phát biểu của cô ấy là một bài học xuất sắc về mặt ngoại giao, khéo léo đổ lỗi mà không hề nêu đích danh những kẻ gièm pha.',
        'masked_sentence': 'Bài phát biểu của cô ấy là một {0} về mặt ngoại giao, khéo léo đổ lỗi mà không hề nêu đích danh những kẻ {1}.',
        'vietnamese_translation': 'Her speech was a masterclass in diplomacy, subtly shifting the blame without ever explicitly naming her detractors.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'bài học xuất sắc',
            'options': ['bài học xuất sắc', 'thất bại lớn', 'kế hoạch hoàn hảo', 'ví dụ thông thường'],
            'hint': 'masterclass'
          },
          {
            'index': 1,
            'correct_answer': 'gièm pha',
            'options': ['gièm pha', 'ủng hộ', 'đồng minh', 'bảo vệ'],
            'hint': 'detractors'
          }
        ]
      },
      {
        'full_sentence': 'Hành trình trượt dài vào điên loạn của nhân vật chính được miêu tả không phải là sự tách rời tức thời khỏi thế giới thực, mà là một sự bào mòn dần dần, âm thầm của cái tôi.',
        'masked_sentence': 'Hành trình trượt dài vào điên loạn của nhân vật chính được miêu tả không phải là sự tách rời tức thời khỏi thế giới thực, mà là một sự {0} dần dần, {1} của cái tôi.',
        'vietnamese_translation': 'The protagonist\'s descent into madness is portrayed not as a sudden break from reality, but as a slow, insidious erosion of the self.',
        'blanks': [
          {
            'index': 0,
            'correct_answer': 'bào mòn',
            'options': ['bào mòn', 'phá vỡ', 'nâng cao', 'củng cố'],
            'hint': 'erosion'
          },
          {
            'index': 1,
            'correct_answer': 'âm thầm',
            'options': ['âm thầm', 'rõ ràng', 'đột ngột', 'nhanh chóng'],
            'hint': 'insidious'
          }
        ]
      }
    ]
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
    required bool translateToEnglish,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate API call
      await Future.delayed(const Duration(milliseconds: 1200));
      if (translateToEnglish) {
        final sentences = _mockSentencesVnToEn[cefrLevel] ?? _mockSentencesVnToEn['B2']!;
        final index = DateTime.now().millisecond % sentences.length;
        final selected = sentences[index];
        return GeneratedSentence(
          action: 'GENERATE',
          cefrLevel: cefrLevel,
          englishSentence: selected['vietnamese_sentence']!,
          hint: selected['hint']!,
        );
      } else {
        final sentences = _mockSentences[cefrLevel] ?? _mockSentences['B2']!;
        final index = DateTime.now().millisecond % sentences.length;
        final selected = sentences[index];
        return GeneratedSentence(
          action: 'GENERATE',
          cefrLevel: cefrLevel,
          englishSentence: selected['english_sentence']!,
          hint: selected['hint']!,
        );
      }
    }

    // Call Real Gemini API
    final systemInstruction = translateToEnglish
        ? '''
You are an expert bilingual English-Vietnamese language professor and elite translation examiner specializing in the CEFR language frameworks (B2, C1, C2).

You handle two distinct operational actions for a Vietnamese-to-English translation practice application. Depending on the user's requested "action", process the logic strictly according to the corresponding ruleset below.

You must respond ONLY with a valid, clean JSON object. Do not wrap the JSON output in markdown formatting (such as ```json), do not include backticks, and do not include any conversational prose outside the JSON structure.

---

Action A: "GENERATE"
Use this action when a user wants a new sentence to translate.
- Rules:
  1. Generate a single, highly natural Vietnamese sentence representing a complexity level corresponding to the requested `cefr_level` (B2, C1, or C2) in English.
  2. The sentence should require the user to employ B2/C1/C2 level grammatical structures, idioms, and vocabulary in English to translate it accurately.
  3. Provide a brief contextual clue (`hint`) in Vietnamese highlighting a tricky nuance, grammar point, or vocabulary setup in English, without revealing the actual English vocabulary solutions.
- Expected Output JSON Schema:
  {
    "action": "GENERATE",
    "cefr_level": "string (B2, C1, or C2)",
    "source_sentence": "string",
    "hint": "string"
  }
'''
        : '''
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
    "source_sentence": "string",
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

  // Action Cloze: Generate Cloze Sentence
  Future<ClozeSentence> generateClozeSentence({
    required String cefrLevel,
    required bool useMock,
    required String apiKey,
    required bool translateToEnglish,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate API call
      await Future.delayed(const Duration(milliseconds: 1200));
      final sentences = translateToEnglish
          ? (_mockClozeEn[cefrLevel] ?? _mockClozeEn['B2']!)
          : (_mockClozeVn[cefrLevel] ?? _mockClozeVn['B2']!);
      final index = DateTime.now().millisecond % sentences.length;
      final selected = sentences[index];
      return ClozeSentence.fromJson(selected);
    }

    final systemInstruction = '''
You are an expert bilingual English-Vietnamese language professor and elite translation examiner specializing in the CEFR language frameworks (B2, C1, C2).

You generate high-quality language practice exercises for a mobile app. 
Depending on the request parameters, generate a single cloze (fill-in-the-blank) exercise corresponding to the level: $cefrLevel.

Here are the strict generation rules:
1. If translateToEnglish is true:
   - Generate a single natural, beautiful English sentence corresponding to the complexity level $cefrLevel.
   - Choose 1 to 2 key advanced vocabulary words or grammatical phrasal verbs in this sentence to blank out.
   - Replace these words with placeholders '{0}', '{1}'... in the `masked_sentence`.
   - Provide the complete sentence in `full_sentence`.
   - Provide a clean, natural Vietnamese translation of the entire sentence in `vietnamese_translation`.
   - For each blank, provide:
     * `index`: 0, 1, etc.
     * `correct_answer`: The exact word/phrase from the sentence.
     * `options`: A list of 4 options. They must be grammatically plausible alternatives for this level, and ONE of them MUST be the correct_answer. The options must be in English.
     * `hint`: A brief clue/explanation in Vietnamese (e.g. meaning of the word in Vietnamese).
2. If translateToEnglish is false:
   - Generate a single natural Vietnamese sentence that represents a complexity level of $cefrLevel in translation.
   - Choose 1 to 2 key phrases or words in this Vietnamese sentence to blank out.
   - Replace these with placeholders '{0}', '{1}'... in the `masked_sentence`.
   - Provide the complete Vietnamese sentence in `full_sentence`.
   - Provide a clean, natural English translation of the entire sentence in `vietnamese_translation`.
   - For each blank, provide:
     * `index`: 0, 1, etc.
     * `correct_answer`: The exact Vietnamese word/phrase.
     * `options`: A list of 4 options in Vietnamese, ONE of which MUST be the correct_answer.
     * `hint`: A brief clue in English (e.g. corresponding English phrasal verb or vocabulary).

Expected Output JSON Schema:
{
  "cefr_level": "string ($cefrLevel)",
  "full_sentence": "string",
  "masked_sentence": "string",
  "vietnamese_translation": "string",
  "blanks": [
    {
      "index": integer,
      "correct_answer": "string",
      "options": ["string", "string", "string", "string"],
      "hint": "string"
    }
  ]
}

You must respond ONLY with a valid, clean JSON object. Do not wrap the JSON output in markdown formatting (such as ```json), do not include backticks, and do not include any conversational prose outside the JSON structure.
''';

    final prompt = 'Generate a cloze exercise with CEFR level: $cefrLevel. Translate to English: $translateToEnglish.';

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
      return ClozeSentence.fromJson(parsed);
    } catch (e) {
      throw Exception('Failed to generate cloze challenge via Gemini: $e');
    }
  }

  // Action B: Evaluate
  Future<EvaluationResult> evaluateTranslation({
    required String cefrLevel,
    required String englishSource,
    required String userTranslation,
    required bool useMock,
    required String apiKey,
    required bool translateToEnglish,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));
      if (userTranslation.trim().length < 5) {
        return EvaluationResult(
          action: 'EVALUATE',
          isAcceptable: false,
          score: 30,
          feedback: 'Bản dịch quá ngắn hoặc không hoàn thiện. Hãy cố dịch đầy đủ ý nghĩa của câu nguồn trước khi gửi đánh giá.',
          suggestedTranslations: [
            translateToEnglish
                ? 'Please complete the translation fully.'
                : 'Vui lòng hoàn thành bản dịch đầy đủ dựa trên gợi ý từ bài học.'
          ],
        );
      }

      // Return a mock result appropriate for the level
      if (translateToEnglish) {
        final result = _mockEvaluationsVnToEn[cefrLevel] ?? _mockEvaluationsVnToEn['B2']!;
        return EvaluationResult.fromJson(result);
      } else {
        final result = _mockEvaluations[cefrLevel] ?? _mockEvaluations['B2']!;
        return EvaluationResult.fromJson(result);
      }
    }

    // Call Real Gemini API
    final systemInstruction = translateToEnglish
        ? '''
You are an expert bilingual English-Vietnamese language professor and elite translation examiner specializing in the CEFR language frameworks (B2, C1, C2).

You handle two distinct operational actions for a Vietnamese-to-English translation practice application. Depending on the user's requested "action", process the logic strictly according to the corresponding ruleset below.

You must respond ONLY with a valid, clean JSON object. Do not wrap the JSON output in markdown formatting (such as ```json), do not include backticks, and do not include any conversational prose outside the JSON structure.

---

Action B: "EVALUATE"
Use this action when evaluating a submitted user translation.
- Rules:
  1. Compare the Vietnamese source sentence `source_sentence` with the user's English translation `user_translation` based on the targeted `cefr_level`.
  2. Be constructive but strict: For B2, allow minor stiffness if the fundamental meaning is intact. For C2, demand native-like flow, precise contextual tone, and exact register match in English.
  3. Provide your `feedback` assessment completely in natural, encouraging Vietnamese. Explain errors, grammar mistakes, or stylistic choices in the English translation clearly.
  4. Assign a numerical `score` from 0 to 100.
- Expected Output JSON Schema:
  {
    "action": "EVALUATE",
    "is_acceptable": boolean,
    "score": integer (0 to 100),
    "feedback": "string (Feedback text in Vietnamese)",
    "suggested_translations": ["string (Option 1)", "string (Option 2)"]
  }
'''
        : '''
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
      'source_sentence': englishSource,
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
    required bool translateToEnglish,
    String modelName = 'gemini-3.5-flash',
  }) async {
    if (useMock || apiKey.isEmpty) {
      // Delay to simulate network call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (translateToEnglish) {
        final cleanWord = word.trim().toLowerCase();
        
        String definition = 'Định nghĩa giả lập cho từ tiếng Việt "$word".';
        String contextExplanation = 'Cách dùng đặc biệt trong ngữ cảnh câu này.';
        
        if (cleanWord.contains('vượt qua')) {
          definition = 'to pull through, overcome, pass';
          contextExplanation = 'Trong ngữ cảnh này, "vượt qua" diễn tả việc công ty vượt qua khó khăn tài chính ("pull through").';
        } else if (cleanWord.contains('cứu trợ')) {
          definition = 'bailout, rescue, relief';
          contextExplanation = 'Ám chỉ gói cứu trợ tài chính khẩn cấp từ chính phủ ("government bailout").';
        } else if (cleanWord.contains('tùy thuộc') || cleanWord.contains('phụ thuộc')) {
          definition = 'contingent upon, dependent on';
          contextExplanation = 'Ở mức độ C1, "tùy thuộc vào" nên dịch là "contingent upon".';
        } else if (cleanWord.contains('tích hợp')) {
          definition = 'integrate, integration';
          contextExplanation = 'Cụm từ "tích hợp trơn tru" dịch thành "seamless integration".';
        } else if (cleanWord.contains('trượt dài')) {
          definition = 'descent, slide';
          contextExplanation = 'Cụm từ "trượt dài vào điên loạn" dịch là "descent into madness".';
        } else if (cleanWord.contains('băng hoại')) {
          definition = 'erosion, decay, degradation';
          contextExplanation = 'Cụm "băng hoại bản ngã" dịch thành "insidious erosion of the self".';
        } else if (cleanWord.contains('âm thầm')) {
          definition = 'insidious, silent, stealthy';
          contextExplanation = 'Từ "insidious" dùng để chỉ thứ gì đó diễn tiến âm thầm nhưng để lại tác hại vô cùng lớn.';
        }
        
        return {
          'word': word,
          'phonetic': '',
          'vietnamese_definition': definition,
          'context_explanation': contextExplanation,
        };
      } else {
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
    }

    final systemInstruction = '''
You are a highly experienced English-Vietnamese dictionary compiler and bilingual language tutor.
Given a word or phrase (which can be English or Vietnamese) and the context sentence it appears in, output a JSON object containing:
1. The standard IPA phonetic pronunciation (if English).
2. The most appropriate translation/definition as it is used in that specific context (English translation if the word is Vietnamese; Vietnamese translation if the word is English).
3. A detailed explanation in Vietnamese of how the word functions in that context sentence, what nuances it carries, and how to translate it properly (including CEFR B2/C1/C2 suggestions if relevant).

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

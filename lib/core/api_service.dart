import 'dart:convert';
import 'package:http/http.dart' as http;
import 'learning_models.dart';
import 'models.dart';

class APIService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY'; // TODO: Move to env
  static const String _model = 'claude-sonnet-4-20250514';

  static Future<AITeacherResponse> getTeacherResponse({
    required String skillName,
    required String skillType,
    required List<Message> conversationHistory,
    required String userResponse,
    required double currentKnowledgeScore,
  }) async {
    try {
      final messages = _buildConversationMessages(
        conversationHistory,
        userResponse,
      );

      final systemPrompt = _buildTeacherSystemPrompt(
        skillName: skillName,
        skillType: skillType,
        knowledgeScore: currentKnowledgeScore,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['content'][0]['text'];

        return _parseTeacherResponse(aiText, userResponse);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('API Service Error: $e');
      return AITeacherResponse(
        text: "I'm having trouble connecting. Let's try that again.",
        knowledgeGain: 0.0,
      );
    }
  }

  static String _buildTeacherSystemPrompt({
    required String skillName,
    required String skillType,
    required double knowledgeScore,
  }) {
    return '''You are a Socratic teacher specializing in $skillName.

Your teaching philosophy:
- NEVER give direct answers
- Ask leading questions that make the student think
- If student is correct: Acknowledge, then ask deeper question
- If partially correct: Guide them with hints
- If incorrect: Don't say "wrong" - ask questions that reveal the gap

Current student knowledge level: ${(knowledgeScore * 100).toStringAsFixed(0)}%

Your goal: Help them discover the answer themselves.

Response format (JSON):
{
  "response": "Your Socratic question or guidance",
  "feedback": {
    "type": "correct|partially_correct|incorrect|needs_thinking|excellent",
    "message": "Brief assessment",
    "hints": ["hint1", "hint2"] // optional
  },
  "knowledge_gain": 0.0 to 0.2, // how much they learned from this exchange
  "suggested_topics": ["topic1"], // optional: what to explore next
  "should_end_session": false // true if they've mastered the concept
}

Keep responses conversational and encouraging. Maximum 3 sentences.''';
  }

  static List<Map<String, dynamic>> _buildConversationMessages(
      List<Message> history,
      String newMessage,
      ) {
    final messages = <Map<String, dynamic>>[];

    for (final msg in history) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    messages.add({
      'role': 'user',
      'content': newMessage,
    });

    return messages;
  }

  static AITeacherResponse _parseTeacherResponse(
      String aiText,
      String userResponse,
      ) {
    try {
      final json = jsonDecode(aiText);
      return AITeacherResponse.fromJson(json);
    } catch (e) {
      return AITeacherResponse(
        text: aiText,
        knowledgeGain: _estimateKnowledgeGain(aiText, userResponse),
        feedback: _inferFeedback(aiText),
      );
    }
  }

  static double _estimateKnowledgeGain(String aiText, String userResponse) {
    if (aiText.toLowerCase().contains('excellent') ||
        aiText.toLowerCase().contains('exactly')) {
      return 0.15;
    } else if (aiText.toLowerCase().contains('good') ||
        aiText.toLowerCase().contains('close')) {
      return 0.10;
    } else if (aiText.toLowerCase().contains('think about') ||
        aiText.toLowerCase().contains('consider')) {
      return 0.05;
    }
    return 0.02;
  }

  static MessageFeedback? _inferFeedback(String aiText) {
    final lowerText = aiText.toLowerCase();

    if (lowerText.contains('excellent') || lowerText.contains('exactly')) {
      return MessageFeedback(
        type: FeedbackType.excellent,
        message: 'Strong understanding!',
      );
    } else if (lowerText.contains('good') || lowerText.contains('close')) {
      return MessageFeedback(
          type: FeedbackType.partiallyCorrect,
          message: 'You are on the right track',
      );
    } else if (lowerText.contains('think about') ||
        lowerText.contains('consider')) {
      return MessageFeedback(
        type: FeedbackType.needsThinking,
        message: 'Keep thinking...',
      );
    }

    return null;
  }

  static Future<List<QuizQuestion>> generateQuiz({
    required String skillName,
    required String skillType,
    int questionCount = 3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 2048,
          'messages': [
            {
              'role': 'user',
              'content': '''Generate $questionCount quiz questions about $skillName.

Format as JSON array:
[
  {
    "question": "Question text?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_index": 0,
    "explanation": "Why this is correct"
  }
]

Questions should:
- Test understanding, not memorization
- Have plausible wrong answers
- Cover key concepts
- Be practical/applied

Return ONLY the JSON array.'''
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'];

        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final List<dynamic> questionsJson = jsonDecode(jsonStr);

          return questionsJson
              .asMap()
              .entries
              .map((entry) => QuizQuestion(
            id: entry.key.toString(),
            question: entry.value['question'],
            options: List<String>.from(entry.value['options']),
            correctAnswerIndex: entry.value['correct_index'],
            explanation: entry.value['explanation'],
          ))
              .toList();
        }
      }

      return _getFallbackQuestions(skillType);
    } catch (e) {
      print('Quiz Generation Error: $e');
      return _getFallbackQuestions(skillType);
    }
  }

  static List<QuizQuestion> _getFallbackQuestions(String skillType) {
    if (skillType.toLowerCase().contains('batna')) {
      return const [
        QuizQuestion(
          id: '1',
          question: 'What does BATNA stand for?',
          options: [
            'Best Alternative To Negotiated Agreement',
            'Basic Approach To New Agreements',
            'Better Alternatives Than No Agreement',
            'Best Action To Negotiate Advantage'
          ],
          correctAnswerIndex: 0,
          explanation:
          'BATNA stands for Best Alternative To Negotiated Agreement - your plan B if negotiations fail.',
        ),
        QuizQuestion(
          id: '2',
          question: 'When should you develop your BATNA?',
          options: [
            'After the negotiation starts',
            'Before entering the negotiation',
            'Only if negotiations are failing',
            'After receiving the first offer'
          ],
          correctAnswerIndex: 1,
          explanation:
          'You should always develop your BATNA before entering negotiations to understand your walk-away power.',
        ),
        QuizQuestion(
          id: '3',
          question: 'A strong BATNA gives you:',
          options: [
            'Leverage and confidence',
            'Guaranteed success',
            'The ability to make demands',
            'No need to negotiate'
          ],
          correctAnswerIndex: 0,
          explanation:
          'A strong BATNA gives you leverage (you have good alternatives) and confidence (you\'re not desperate).',
        ),
      ];
    }

    return const [
      QuizQuestion(
        id: '1',
        question: 'What is the key to effective negotiation?',
        options: [
          'Being aggressive',
          'Understanding interests',
          'Making the first offer',
          'Never compromising'
        ],
        correctAnswerIndex: 1,
        explanation:
        'Understanding both parties\' interests leads to better outcomes.',
      ),
    ];
  }
}
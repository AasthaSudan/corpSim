import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/scenario.dart';

class ClaudeService {
  static const String apiUrl = 'https://api.anthropic.com/v1/messages';

  static String get apiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  Future<String> sendMessage({
    required List<Map<String, String>> conversationHistory,
    required Scenario scenario,
    required double patience,
    required int leverage,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(
        scenario: scenario,
        patience: patience,
        leverage: leverage,
      );

      final requestBody = {
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': conversationHistory,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['content'] != null && data['content'].isNotEmpty) {
          return data['content'][0]['text'] ?? 'I understand.';
        }
        return 'I understand.';
      } else {
        print('API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to get response from Claude');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      throw Exception('Error communicating with AI: $e');
    }
  }

  String _buildSystemPrompt({
    required Scenario scenario,
    required double patience,
    required int leverage,
  }) {
    return '''You are ${scenario.opponentName}, ${scenario.opponentRole}.

SCENARIO: ${scenario.title}
Your personality traits:
${scenario.opponentTraits.map((t) => '- $t').join('\n')}

HIDDEN INFORMATION (User doesn't know this):
${scenario.hiddenBATNA != null ? 'Your maximum offer: \$${scenario.hiddenBATNA}' : 'You have specific limits on what you can offer.'}

CURRENT STATE:
- Patience level: ${patience.toStringAsFixed(0)}/10 (Lower = more frustrated)
- User's leverage: $leverage/5 (Higher = stronger position)

INSTRUCTIONS:
1. Respond realistically as this character would
2. React to the user's arguments and tone
3. If patience is low (<4), show frustration in your responses
4. If user has high leverage (>3), be more accommodating
5. Keep responses conversational and natural (2-4 sentences)
6. Don't reveal your hidden limits unless pressured
7. Be a realistic negotiation opponent - not too easy, not impossible
8. React emotionally when appropriate based on patience level

CHALLENGE CONTEXT:
${scenario.challenge}

Remember: You are a REAL person in this situation. Respond authentically based on your current emotional state (patience level) and the strength of their arguments (leverage).''';
  }

  Map<String, dynamic> analyzeMessage({
    required String userMessage,
    required double currentPatience,
    required int currentLeverage,
  }) {
    double patienceChange = 0;
    int leverageChange = 0;

    final messageLower = userMessage.toLowerCase();

    if (messageLower.contains('fuck') ||
        messageLower.contains('damn') ||
        messageLower.contains('stupid')) {
      patienceChange = -2;
    } else if (messageLower.contains('unfair') ||
        messageLower.contains('ridiculous')) {
      patienceChange = -1;
    } else if (messageLower.length < 10) {
      patienceChange = -0.5;
    }

    if (messageLower.contains('understand') ||
        messageLower.contains('appreciate')) {
      patienceChange += 0.5;
    }
    if (messageLower.contains('please') ||
        messageLower.contains('thank')) {
      patienceChange += 0.5;
    }

    if (messageLower.contains('%') ||
        messageLower.contains('data') ||
        messageLower.contains('results') ||
        messageLower.contains('market') ||
        messageLower.contains('industry')) {
      leverageChange = 1;
    }

    if (messageLower.contains('other offer') ||
        messageLower.contains('competitor') ||
        messageLower.contains('alternative')) {
      leverageChange = 1;
    }

    if (userMessage.length > 100) {
      leverageChange += 1;
    }

    if (messageLower.contains('deserve') ||
        messageLower.contains('need') ||
        messageLower.contains('want')) {
      leverageChange = -1;
    }

    if (messageLower.contains('please please') ||
        messageLower.contains('beg')) {
      leverageChange = -1;
    }

    final newPatience = (currentPatience + patienceChange).clamp(0.0, 10.0);
    final newLeverage = (currentLeverage + leverageChange).clamp(1, 5);

    return {
      'patience': newPatience,
      'leverage': newLeverage,
      'patienceChange': patienceChange,
      'leverageChange': leverageChange,
    };
  }

  String getEmotion(double patience) {
    if (patience >= 8) return '😊';
    if (patience >= 6) return '🙂';
    if (patience >= 4) return '😐';
    if (patience >= 2) return '😠';
    return '😡';
  }
}
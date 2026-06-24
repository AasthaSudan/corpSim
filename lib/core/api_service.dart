// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'learning_models.dart';

/// API Service for Negotium
/// Connects Flutter app to FastAPI backend with Opik integration
class APIService {
  // Backend Configuration
  static String get _baseUrl => kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';  // Change for production
  static const String _apiVersion = 'api';

  // Timeout configuration
  static const Duration _timeout = Duration(seconds: 30);

  /// Get full API URL for endpoint
  static String _getUrl(String endpoint) => '$_baseUrl/$_apiVersion/$endpoint';

  /// Common headers for all requests
  static Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Handle HTTP errors
  static void _handleError(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
        'API Error ${response.statusCode}: ${response.body}',
      );
    }
  }

  // ==================== Health Check ====================

  /// Check if backend is online
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // ==================== Socratic Teacher ====================

  /// Get AI Socratic teacher response
  ///
  /// This calls the backend which uses Claude with Opik tracing
  static Future<AITeacherResponse> getTeacherResponse({
    required String skillName,
    required String skillType,
    required List<Message> conversationHistory,
    required String userResponse,
    required double currentKnowledgeScore,
  }) async {
    try {
      final url = Uri.parse(_getUrl('teacher/respond'));

      final requestBody = {
        'skill_name': skillName,
        'skill_type': skillType,
        'conversation_history': conversationHistory
            .map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
          'timestamp': msg.timestamp.toIso8601String(),
        })
            .toList(),
        'user_response': userResponse,
        'current_knowledge_score': currentKnowledgeScore,
      };

      print('🔄 Calling teacher API...');

      final response = await http
          .post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      )
          .timeout(_timeout);

      _handleError(response);

      final data = jsonDecode(response.body);
      print('✅ Teacher response received');

      return AITeacherResponse(
        text: data['text'],
        knowledgeGain: (data['knowledge_gain'] as num).toDouble(),
        feedback: data['feedback'] != null
            ? MessageFeedback(
          type: _parseFeedbackType(data['feedback']['type']),
          message: data['feedback']['message'],
          hints: data['feedback']['hints'] != null
              ? List<String>.from(data['feedback']['hints'])
              : null,
        )
            : null,
        suggestedTopics: data['suggested_topics'] != null
            ? List<String>.from(data['suggested_topics'])
            : null,
        shouldEndSession: data['should_end_session'] ?? false,
      );
    } catch (e) {
      print('❌ Teacher API Error: $e');

      // Friendly fallback response
      return AITeacherResponse(
        text: "I'm having trouble connecting to my teaching system. "
            "Let's try that again in a moment.",
        knowledgeGain: 0.0,
      );
    }
  }

  // ==================== Quiz Generation ====================

  /// Generate quiz questions for a skill
  static Future<List<QuizQuestion>> generateQuiz({
    required String skillName,
    required String skillType,
    int questionCount = 3,
  }) async {
    try {
      final url = Uri.parse(_getUrl('quiz/generate'));

      final requestBody = {
        'skill_name': skillName,
        'skill_type': skillType,
        'question_count': questionCount,
      };

      print('🔄 Generating quiz...');

      final response = await http
          .post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      )
          .timeout(_timeout);

      _handleError(response);

      final List<dynamic> data = jsonDecode(response.body);
      print('✅ Quiz generated: ${data.length} questions');

      return data
          .map((q) => QuizQuestion(
        id: q['id'],
        question: q['question'],
        options: List<String>.from(q['options']),
        correctAnswerIndex: q['correct_answer_index'],
        explanation: q['explanation'],
      ))
          .toList();
    } catch (e) {
      print('❌ Quiz Generation Error: $e');

      // Return fallback questions
      return _getFallbackQuestions(skillType);
    }
  }

  // ==================== Negotiation Simulation ====================

  /// Get AI opponent response in negotiation
  static Future<NegotiationResponse> getOpponentResponse({
    required String scenarioType,
    required String userMessage,
    required List<Message> conversationHistory,
    Map<String, dynamic>? opponentState,
  }) async {
    try {
      final url = Uri.parse(_getUrl('negotiation/respond'));

      final requestBody = {
        'scenario_type': scenarioType,
        'user_message': userMessage,
        'conversation_history': conversationHistory
            .map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        })
            .toList(),
        'opponent_state': opponentState,
      };

      print('🔄 Getting opponent response...');

      final response = await http
          .post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      )
          .timeout(_timeout);

      _handleError(response);

      final data = jsonDecode(response.body);
      print('✅ Opponent responded');

      return NegotiationResponse(
        opponentMessage: data['opponent_message'],
        opponentMood: data['opponent_mood'],
        patienceLevel: data['patience_level'],
        leverageScore: (data['leverage_score'] as num).toDouble(),
        hiddenState: Map<String, dynamic>.from(data['hidden_state']),
      );
    } catch (e) {
      print('❌ Opponent Response Error: $e');

      // Fallback response
      return NegotiationResponse(
        opponentMessage: "I need a moment to think about that...",
        opponentMood: "neutral",
        patienceLevel: 7,
        leverageScore: 5.0,
        hiddenState: {},
      );
    }
  }

  /// Analyze completed negotiation
  static Future<NegotiationAnalysis> analyzeNegotiation({
    required String scenarioType,
    required List<Message> conversationHistory,
    required Map<String, dynamic> finalOutcome,
  }) async {
    try {
      final url = Uri.parse(_getUrl('negotiation/analyze'));

      final requestBody = {
        'scenario_type': scenarioType,
        'conversation_history': conversationHistory
            .map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        })
            .toList(),
        'final_outcome': finalOutcome,
      };

      print('🔄 Analyzing negotiation...');

      final response = await http
          .post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      )
          .timeout(_timeout);

      _handleError(response);

      final data = jsonDecode(response.body);
      print('✅ Analysis complete');

      return NegotiationAnalysis(
        overallScore: (data['overall_score'] as num).toDouble(),
        strengths: List<String>.from(data['strengths']),
        weaknesses: List<String>.from(data['weaknesses']),
        keyMoments: List<Map<String, dynamic>>.from(
          data['key_moments'].map((m) => Map<String, dynamic>.from(m)),
        ),
        skillRecommendations: List<String>.from(data['skill_recommendations']),
        leverageTrajectory: List<double>.from(
          data['leverage_trajectory'].map((v) => (v as num).toDouble()),
        ),
      );
    } catch (e) {
      print('❌ Analysis Error: $e');

      // Fallback analysis
      return NegotiationAnalysis(
        overallScore: 5.0,
        strengths: ['You completed the negotiation'],
        weaknesses: ['Analysis temporarily unavailable'],
        keyMoments: [],
        skillRecommendations: ['Practice active listening'],
        leverageTrajectory: [],
      );
    }
  }

  // ==================== Helper Functions ====================

  /// Parse feedback type from string
  static FeedbackType _parseFeedbackType(String type) {
    switch (type.toLowerCase()) {
      case 'correct':
        return FeedbackType.correct;
      case 'partially_correct':
        return FeedbackType.partiallyCorrect;
      case 'incorrect':
        return FeedbackType.incorrect;
      case 'needs_thinking':
        return FeedbackType.needsThinking;
      case 'excellent':
        return FeedbackType.excellent;
      default:
        return FeedbackType.needsThinking;
    }
  }

  /// Fallback quiz questions when API fails
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
          'BATNA stands for Best Alternative To Negotiated Agreement - '
              'your plan B if negotiations fail.',
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
          'You should always develop your BATNA before entering '
              'negotiations to understand your walk-away power.',
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
          'A strong BATNA gives you leverage (you have good alternatives) '
              'and confidence (you\'re not desperate).',
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

// ==================== New Response Models ====================

/// Negotiation opponent response
class NegotiationResponse {
  final String opponentMessage;
  final String opponentMood;
  final int patienceLevel;
  final double leverageScore;
  final Map<String, dynamic> hiddenState;

  NegotiationResponse({
    required this.opponentMessage,
    required this.opponentMood,
    required this.patienceLevel,
    required this.leverageScore,
    required this.hiddenState,
  });
}

/// Negotiation analysis from Shadow Coach
class NegotiationAnalysis {
  final double overallScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<Map<String, dynamic>> keyMoments;
  final List<String> skillRecommendations;
  final List<double> leverageTrajectory;

  NegotiationAnalysis({
    required this.overallScore,
    required this.strengths,
    required this.weaknesses,
    required this.keyMoments,
    required this.skillRecommendations,
    required this.leverageTrajectory,
  });
}
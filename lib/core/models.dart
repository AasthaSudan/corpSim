import 'package:equatable/equatable.dart';

enum Difficulty {
  beginner,
  medium,
  advanced,
  hard;

  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.advanced:
        return 'Advanced';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}

class Scenario extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int duration;
  final Difficulty difficulty;
  final String colorHex;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
    required this.difficulty,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [id, title, description, icon, duration, difficulty, colorHex];
}

class MockData {
  static final List<Scenario> scenarios = [
    const Scenario(
      id: '1',
      title: 'Annual Salary Raise',
      description: 'Negotiate a 20% raise with your manager.',
      icon: '💰',
      duration: 15,
      difficulty: Difficulty.medium,
      colorHex: '14b8a6',
    ),
    const Scenario(
      id: '2',
      title: 'Promotion Discussion',
      description: 'Transition from Senior Dev to Lead.',
      icon: '💼',
      duration: 20,
      difficulty: Difficulty.medium,
      colorHex: 'a855f7',
    ),
    const Scenario(
      id: '3',
      title: 'Client Rate Increase',
      description: 'Convince a legacy client to accept new rates.',
      icon: '👥',
      duration: 18,
      difficulty: Difficulty.hard,
      colorHex: 'f59e0b',
    ),
    const Scenario(
      id: '4',
      title: 'Entry-Level Offer',
      description: 'First job offer negotiation.',
      icon: '📄',
      duration: 12,
      difficulty: Difficulty.beginner,
      colorHex: '06b6d4',
    ),
    const Scenario(
      id: '5',
      title: 'Project Timeline',
      description: 'Push back on an impossible deadline.',
      icon: '⏰',
      duration: 10,
      difficulty: Difficulty.advanced,
      colorHex: 'ef4444',
    ),
    const Scenario(
      id: '6',
      title: 'Vendor Contract',
      description: 'Negotiate software licensing costs.',
      icon: '📦',
      duration: 14,
      difficulty: Difficulty.medium,
      colorHex: '14b8a6',
    ),
  ];
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiMessage() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': content,
    };
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp];
}

class APIRequest {
  final String scenario;
  final List<Map<String, dynamic>> history;
  final double currentLeverage;
  final String? sessionId;

  const APIRequest({
    required this.scenario,
    required this.history,
    required this.currentLeverage,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'scenario': scenario,
      'history': history,
      'current_leverage': currentLeverage,
      'session_id': sessionId,
    };
  }
}

class APIResponse {
  final String opponentReply;
  final String coachTip;
  final double newLeverage;
  final double newPatience;
  final String newMood;
  final String sessionId;

  const APIResponse({
    required this.opponentReply,
    required this.coachTip,
    required this.newLeverage,
    required this.newPatience,
    required this.newMood,
    required this.sessionId,
  });

  factory APIResponse.fromJson(Map<String, dynamic> json) {
    return APIResponse(
      opponentReply: json['opponent_reply'] as String,
      coachTip: json['coach_tip'] as String,
      newLeverage: (json['new_leverage'] as num).toDouble(),
      newPatience: (json['new_patience'] as num?)?.toDouble() ?? 1.0,
      newMood: json['new_mood'] as String,
      sessionId: json['session_id'] as String,
    );
  }
}

class SavedSession extends Equatable {
  final String id;
  final String scenario;
  final double leverage;
  final String timestamp;
  final String mood;

  const SavedSession({
    required this.id,
    required this.scenario,
    required this.leverage,
    required this.timestamp,
    required this.mood,
  });

  factory SavedSession.fromJson(Map<String, dynamic> json) {
    return SavedSession(
      id: json['_id'] as String,
      scenario: json['scenario'] as String,
      leverage: (json['leverage'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
      mood: json['mood'] as String? ?? 'neutral',
    );
  }

  @override
  List<Object?> get props => [id, scenario, leverage, timestamp];
}

class AnalysisPoint extends Equatable {
  final String point;
  final String explanation;

  const AnalysisPoint({
    required this.point,
    required this.explanation,
  });

  factory AnalysisPoint.fromJson(Map<String, dynamic> json) {
    return AnalysisPoint(
      point: json['point'] as String,
      explanation: json['explanation'] as String,
    );
  }

  @override
  List<Object?> get props => [point, explanation];
}

class AnalysisResponse extends Equatable {
  final String summary;
  final String outcome;
  final List<AnalysisPoint> strengths;
  final List<AnalysisPoint> mistakes;
  final List<String> skillGaps;
  final List<Map<String, dynamic>>? chatHistory;

  const AnalysisResponse({
    required this.summary,
    required this.outcome,
    required this.strengths,
    required this.mistakes,
    required this.skillGaps,
    this.chatHistory,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      summary: json['summary'] as String,
      outcome: json['outcome'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => AnalysisPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      mistakes: (json['mistakes'] as List<dynamic>)
          .map((e) => AnalysisPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillGaps: (json['skill_gaps'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      chatHistory: json['chat_history'] != null
          ? (json['chat_history'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    outcome,
    strengths,
    mistakes,
    skillGaps,
    chatHistory,
  ];
}

class LearningResource {
  final String id;
  final String title;
  final String type;
  final String duration;
  final String icon;

  const LearningResource({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.icon,
  });
}
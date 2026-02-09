class LearningResource {
  final String id;
  final String title;
  final String type;
  final String duration;
  final String icon;
  final String? url;

  const LearningResource({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.icon,
    this.url,
  });
}

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageFeedback? feedback;
  final double? knowledgeImpact;

  Message({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.feedback,
    this.knowledgeImpact,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'feedback': feedback?.toJson(),
    'knowledgeImpact': knowledgeImpact,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    feedback: json['feedback'] != null
        ? MessageFeedback.fromJson(json['feedback'])
        : null,
    knowledgeImpact: json['knowledgeImpact'],
  );
}

class MessageFeedback {
  final FeedbackType type;
  final String message;
  final List<String>? hints;

  MessageFeedback({
    required this.type,
    required this.message,
    this.hints,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'hints': hints,
  };

  factory MessageFeedback.fromJson(Map<String, dynamic> json) =>
      MessageFeedback(
        type: FeedbackType.values.firstWhere((e) => e.name == json['type']),
        message: json['message'],
        hints: json['hints'] != null ? List<String>.from(json['hints']) : null,
      );
}

enum FeedbackType {
  correct,
  partiallyCorrect,
  incorrect,
  needsThinking,
  excellent,
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class SkillMastery {
  final String skillId;
  final String skillName;
  final double theoryScore; // 0.0 - 1.0
  final double practiceScore; // 0.0 - 1.0
  final int quizzesTaken;
  final int practiceSessionsCompleted;
  final DateTime lastPracticed;
  final List<String> strengthAreas;
  final List<String> weakAreas;

  SkillMastery({
    required this.skillId,
    required this.skillName,
    required this.theoryScore,
    required this.practiceScore,
    required this.quizzesTaken,
    required this.practiceSessionsCompleted,
    required this.lastPracticed,
    required this.strengthAreas,
    required this.weakAreas,
  });

  double get overallMastery => (theoryScore + practiceScore) / 2;

  Map<String, dynamic> toJson() => {
    'skillId': skillId,
    'skillName': skillName,
    'theoryScore': theoryScore,
    'practiceScore': practiceScore,
    'quizzesTaken': quizzesTaken,
    'practiceSessionsCompleted': practiceSessionsCompleted,
    'lastPracticed': lastPracticed.toIso8601String(),
    'strengthAreas': strengthAreas,
    'weakAreas': weakAreas,
  };

  factory SkillMastery.fromJson(Map<String, dynamic> json) => SkillMastery(
    skillId: json['skillId'],
    skillName: json['skillName'],
    theoryScore: json['theoryScore'],
    practiceScore: json['practiceScore'],
    quizzesTaken: json['quizzesTaken'],
    practiceSessionsCompleted: json['practiceSessionsCompleted'],
    lastPracticed: DateTime.parse(json['lastPracticed']),
    strengthAreas: List<String>.from(json['strengthAreas']),
    weakAreas: List<String>.from(json['weakAreas']),
  );
}

class AITeacherResponse {
  final String text;
  final MessageFeedback? feedback;
  final double knowledgeGain;
  final List<String>? suggestedTopics;
  final bool shouldEndSession;

  AITeacherResponse({
    required this.text,
    this.feedback,
    required this.knowledgeGain,
    this.suggestedTopics,
    this.shouldEndSession = false,
  });

  factory AITeacherResponse.fromJson(Map<String, dynamic> json) {
    return AITeacherResponse(
      text: json['response'] ?? json['text'] ?? '',
      feedback: json['feedback'] != null
          ? MessageFeedback(
        type: _parseFeedbackType(json['feedback']['type']),
        message: json['feedback']['message'] ?? '',
        hints: json['feedback']['hints'] != null
            ? List<String>.from(json['feedback']['hints'])
            : null,
      )
          : null,
      knowledgeGain: (json['knowledge_gain'] ?? 0.0).toDouble(),
      suggestedTopics: json['suggested_topics'] != null
          ? List<String>.from(json['suggested_topics'])
          : null,
      shouldEndSession: json['should_end_session'] ?? false,
    );
  }

  static FeedbackType _parseFeedbackType(String? type) {
    switch (type?.toLowerCase()) {
      case 'correct':
        return FeedbackType.correct;
      case 'partially_correct':
        return FeedbackType.partiallyCorrect;
      case 'incorrect':
        return FeedbackType.incorrect;
      case 'excellent':
        return FeedbackType.excellent;
      default:
        return FeedbackType.needsThinking;
    }
  }
}
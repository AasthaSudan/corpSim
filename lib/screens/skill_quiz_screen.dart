import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/learning_models.dart';
import '../widgets/glass_card.dart';

class SkillQuizScreen extends StatefulWidget {
  final String skillName;
  final String skillType;

  const SkillQuizScreen({
    super.key,
    required this.skillName,
    required this.skillType,
  });

  @override
  State<SkillQuizScreen> createState() => _SkillQuizScreenState();
}

class _SkillQuizScreenState extends State<SkillQuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  List<int?> _selectedAnswers = [];
  bool _showResults = false;
  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _questions = _getQuestionsForSkill();
    _selectedAnswers = List.filled(_questions.length, null);
  }

  List<QuizQuestion> _getQuestionsForSkill() {
    switch (widget.skillType.toLowerCase()) {
      case 'batna':
        return [
          QuizQuestion(
            id: 'batna_1',
            question: 'What does BATNA stand for?',
            options: [
              'Best Alternative To a Negotiated Agreement',
              'Better Approach To New Agreements',
              'Basic Alternative Trading Negotiation Act',
              'Best Attempt To Negotiate Accordingly',
            ],
            correctAnswerIndex: 0,
            explanation:
            'BATNA stands for Best Alternative To a Negotiated Agreement. It\'s your backup plan if negotiations fail.',
          ),
          QuizQuestion(
            id: 'batna_2',
            question: 'When should you develop your BATNA?',
            options: [
              'After the negotiation fails',
              'During the negotiation',
              'Before entering any negotiation',
              'Only if asked by the other party',
            ],
            correctAnswerIndex: 2,
            explanation:
            'Always develop your BATNA before entering negotiations. It gives you power and clarity about when to walk away.',
          ),
          QuizQuestion(
            id: 'batna_3',
            question: 'A strong BATNA means you should:',
            options: [
              'Always walk away from the negotiation',
              'Have more confidence and leverage',
              'Accept any offer made',
              'Hide it from the other party',
            ],
            correctAnswerIndex: 1,
            explanation:
            'A strong BATNA gives you confidence and leverage, but doesn\'t mean you should walk away - it means you can negotiate from strength.',
          ),
        ];

      case 'anchoring':
        return [
          QuizQuestion(
            id: 'anchor_1',
            question: 'What is the anchoring effect in negotiation?',
            options: [
              'Staying fixed on your initial position',
              'The first number sets a reference point for discussion',
              'Refusing to move from your offer',
              'Using emotional appeals',
            ],
            correctAnswerIndex: 1,
            explanation:
            'The anchoring effect occurs when the first number mentioned becomes a psychological reference point that influences the entire negotiation.',
          ),
          QuizQuestion(
            id: 'anchor_2',
            question: 'Who should make the first offer?',
            options: [
              'Always the buyer',
              'Always the seller',
              'Whoever has better information',
              'It doesn\'t matter',
            ],
            correctAnswerIndex: 2,
            explanation:
            'The party with better market information should typically anchor first, as they can set a more informed and strategic reference point.',
          ),
          QuizQuestion(
            id: 'anchor_3',
            question: 'If the other party anchors too aggressively, you should:',
            options: [
              'Walk away immediately',
              'Match their aggressive anchor',
              'Counter-anchor with facts and reasoning',
              'Accept defeat',
            ],
            correctAnswerIndex: 2,
            explanation:
            'Use counter-anchoring by providing objective data, market comparisons, and logical reasoning to reset the reference point.',
          ),
        ];

      case 'active_listening':
        return [
          QuizQuestion(
            id: 'listening_1',
            question: 'What is the primary goal of active listening?',
            options: [
              'To prepare your response',
              'To understand the speaker\'s perspective',
              'To find weaknesses in their argument',
              'To appear interested',
            ],
            correctAnswerIndex: 1,
            explanation:
            'Active listening focuses on truly understanding the other person\'s perspective, needs, and concerns - not just waiting to speak.',
          ),
          QuizQuestion(
            id: 'listening_2',
            question: 'Which technique shows you\'re actively listening?',
            options: [
              'Interrupting with solutions',
              'Paraphrasing what they said',
              'Checking your phone',
              'Thinking about your response',
            ],
            correctAnswerIndex: 1,
            explanation:
            'Paraphrasing demonstrates understanding and gives the speaker a chance to clarify if you\'ve misunderstood.',
          ),
          QuizQuestion(
            id: 'listening_3',
            question: 'In negotiation, active listening helps you:',
            options: [
              'Win every argument',
              'Discover hidden interests and needs',
              'Appear more intelligent',
              'Waste time',
            ],
            correctAnswerIndex: 1,
            explanation:
            'Active listening reveals underlying interests and needs that aren\'t explicitly stated, opening paths to creative solutions.',
          ),
        ];

      default:
        return [
          QuizQuestion(
            id: 'general_1',
            question: 'What is the most important skill in negotiation?',
            options: [
              'Being aggressive',
              'Understanding both parties\' interests',
              'Having the lowest price',
              'Talking the most',
            ],
            correctAnswerIndex: 1,
            explanation:
            'Understanding interests (the why behind positions) is crucial for finding mutually beneficial solutions.',
          ),
          QuizQuestion(
            id: 'general_2',
            question: 'A win-win negotiation outcome means:',
            options: [
              'Both parties feel they won',
              'Everyone gets exactly what they want',
              'Nobody is happy',
              'Both sides create value',
            ],
            correctAnswerIndex: 3,
            explanation:
            'Win-win means creating value for both parties, even if they don\'t get everything they initially wanted.',
          ),
          QuizQuestion(
            id: 'general_3',
            question: 'When should you make concessions?',
            options: [
              'Immediately to show goodwill',
              'Never',
              'Strategically, when you get something in return',
              'At the end only',
            ],
            correctAnswerIndex: 2,
            explanation:
            'Concessions should be strategic and reciprocal - trade concessions to build value and momentum.',
          ),
        ];
    }
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestion] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswers[_currentQuestion] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an answer'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_selectedAnswers[_currentQuestion] ==
        _questions[_currentQuestion].correctAnswerIndex) {
      _score++;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      setState(() {
        _showResults = true;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswers = List.filled(_questions.length, null);
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultsScreen();
    }

    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedOrb(
                color: AppColors.amber,
                size: 300,
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: AnimatedOrb(
                color: AppColors.purple,
                size: 350,
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                'Knowledge Check',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Progress Bar
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${_currentQuestion + 1} of ${_questions.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: AppColors.amber,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                AppColors.surface.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.amber,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),

                  // Question Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Question Card
                          GlassContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.amber,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                          AppColors.amber.withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.help_outline_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    question.question,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms),

                          const SizedBox(height: 24),

                          // Answer Options
                          ...question.options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final answer = entry.value;
                            final isSelected =
                                _selectedAnswers[_currentQuestion] == index;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAnswerOption(
                                answer,
                                index,
                                isSelected,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms),
                            );
                          }),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        if (_currentQuestion > 0)
                          Expanded(
                            child: GlassCard(
                              color: Colors.transparent,
                              border: Border.all(
                                color: AppColors.textSecondary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              child: InkWell(
                                onTap: _previousQuestion,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      'Previous',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_currentQuestion > 0) const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: GlassCard(
                            gradient: AppGradients.amber,
                            child: InkWell(
                              onTap: _nextQuestion,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    _currentQuestion == _questions.length - 1
                                        ? 'See Results'
                                        : 'Next Question',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String answer, int index, bool isSelected) {
    return GlassContainer(
      color: isSelected
          ? AppColors.amber.withValues(alpha: 0.1)
          : Colors.transparent,
      border: Border.all(
        color: isSelected
            ? AppColors.amber
            : AppColors.textSecondary.withValues(alpha: 0.2),
        width: isSelected ? 2 : 1,
      ),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.amber
                      : AppColors.surface.withValues(alpha: 0.3),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.amber
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answer,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final isPerfect = _score == _questions.length;
    final isGood = percentage >= 70;
    final isFair = percentage >= 50;

    String title;
    String message;
    Color accentColor;
    IconData icon;

    if (isPerfect) {
      title = 'Perfect Score! 🎉';
      message = 'You\'ve mastered the fundamentals of ${widget.skillName}!';
      accentColor = AppColors.success;
      icon = Icons.emoji_events_rounded;
    } else if (isGood) {
      title = 'Great Job! 👏';
      message = 'Strong understanding! Review the areas you missed.';
      accentColor = AppColors.teal;
      icon = Icons.thumb_up_rounded;
    } else if (isFair) {
      title = 'Good Start! 💪';
      message = 'You\'re on the right track. Keep learning!';
      accentColor = AppColors.amber;
      icon = Icons.trending_up_rounded;
    } else {
      title = 'Keep Learning! 📚';
      message = 'Focus on the fundamentals and try again.';
      accentColor = AppColors.purple;
      icon = Icons.school_rounded;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedOrb(
                color: accentColor,
                size: 300,
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: AnimatedOrb(
                color: AppColors.purple,
                size: 350,
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Trophy Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 60,
                      ),
                    )
                        .animate()
                        .scale(
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                        delay: 200.ms)
                        .shake(duration: 600.ms, delay: 1000.ms),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      title,
                      style:
                      Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                    const SizedBox(height: 40),

                    // Score Card
                    GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Text(
                              'Your Score',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$_score',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    color: accentColor,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  ' / ${_questions.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '$percentage% Correct',
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

                    const SizedBox(height: 32),

                    // Review Answers
                    GlassContainer(
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.all(20),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        title: Row(
                          children: [
                            Icon(
                              Icons.fact_check_rounded,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Review Your Answers',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        iconColor: AppColors.textPrimary,
                        collapsedIconColor: AppColors.textSecondary,
                        children: _questions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final question = entry.value;
                          final userAnswer = _selectedAnswers[index];
                          final isCorrect = userAnswer == question.correctAnswerIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isCorrect
                                            ? AppColors.success
                                            : AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isCorrect ? Icons.check : Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Q${index + 1}: ${question.question}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (!isCorrect) ...[
                                            Text(
                                              'Your answer: ${question.options[userAnswer ?? 0]}',
                                              style: TextStyle(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.8),
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          Text(
                                            'Correct answer: ${question.options[question.correctAnswerIndex]}',
                                            style: TextStyle(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.9),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            question.explanation,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (index < _questions.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Divider(
                                      color: AppColors.surface.withValues(alpha: 0.3),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            color: Colors.transparent,
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            child: InkWell(
                              onTap: _retakeQuiz,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(vertical: 18),
                                child: Center(
                                  child: Text(
                                    'Retake Quiz',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            gradient: AppGradients.tealPurple,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(vertical: 18),
                                child: Center(
                                  child: Text(
                                    'Continue Learning',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),

                    const SizedBox(height: 40),
                  ],
                  ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
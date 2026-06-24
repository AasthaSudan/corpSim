import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/learning_models.dart';
import '../core/theme.dart';
import '../core/api_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/knowledge_indicator.dart';

class AITeacherScreen extends StatefulWidget {
  final String skill;
  final String? skillType;

  const AITeacherScreen({
    super.key,
    required this.skill,
    this.skillType,
  });

  @override
  State<AITeacherScreen> createState() => _AITeacherScreenState();
}

class _AITeacherScreenState extends State<AITeacherScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double _knowledgeScore = 0.0;
  bool _isLoading = false;
  bool _sessionComplete = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startSession() {
    final introMessage = _getIntroMessage();
    setState(() {
      _messages.add(Message(
        text: introMessage,
        isUser: false,
      ));
    });
    _scrollToBottom();
  }

  String _getIntroMessage() {
    final skillType = widget.skillType?.toLowerCase() ?? '';

    if (skillType.contains('batna')) {
      return "Welcome! Let's explore BATNA together. 🎯\n\n"
          "Imagine you're negotiating a job offer. Before we discuss tactics, "
          "let me ask you: What do you think is the most important thing to know "
          "before entering any negotiation?";
    } else if (skillType.contains('anchor')) {
      return "Great! Let's dive into anchoring. ⚓\n\n"
          "Think about buying a car. If the seller starts by asking \$30,000, "
          "but you know it's worth \$20,000, how does that first number affect "
          "your thinking?";
    } else {
      return "Welcome to your practice session! 💡\n\n"
          "I'm here to help you master ${widget.skill} through conversation. "
          "I won't just give you answers - I'll guide you to discover them yourself.\n\n"
          "Ready to begin?";
    }
  }

  Future<void> _handleSendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
      ));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await APIService.getTeacherResponse(
        skillName: widget.skill,
        skillType: widget.skillType ?? widget.skill,
        conversationHistory: _messages.where((m) => !m.isUser).toList(),
        userResponse: text,
        currentKnowledgeScore: _knowledgeScore,
      );

      setState(() {
        _knowledgeScore =
            (_knowledgeScore + response.knowledgeGain).clamp(0.0, 1.0);
        _sessionComplete = response.shouldEndSession;

        _messages.add(Message(
          text: response.text,
          isUser: false,
          feedback: response.feedback,
          knowledgeImpact: response.knowledgeGain,
        ));

        _isLoading = false;
      });

      _scrollToBottom();

      if (_sessionComplete && _knowledgeScore >= 0.7) {
        _showCompletionDialog();
      }
    } catch (e) {
      setState(() {
        _messages.add(Message(
          text: "I encountered an error. Let's try again!",
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Text('🎉 ', style: TextStyle(fontSize: 32)),
            Text('Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You've shown strong understanding of ${widget.skill}!",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${(_knowledgeScore * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Knowledge Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to apply this in a real negotiation?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Learning', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.black,
            ),
            child: const Text('Practice in Scenario'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Teacher',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.skill,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () => _showInfoDialog(),
                    ),
                  ],
                ),
              ),

              KnowledgeIndicator(
                knowledgeScore: _knowledgeScore,
                skillName: widget.skill,
              ),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Thinking...',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                          .fadeIn(duration: 600.ms)
                          .then()
                          .fadeOut(duration: 600.ms);
                    }

                    return MessageBubble(message: _messages[index]);
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: _isLoading ? null : AppGradients.teal,
                        color: _isLoading ? Colors.white10 : null,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.send,
                          color: _isLoading ? AppColors.textTertiary : Colors.black,
                        ),
                        onPressed: _isLoading ? null : _handleSendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('💡 ', style: TextStyle(fontSize: 24)),
            Text('How This Works'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Socratic Teaching Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.teal,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• I ask questions instead of giving answers\n'
                  '• You think through problems yourself\n'
                  '• Your knowledge score increases as you understand\n'
                  '• Reach 70%+ to complete the session',
              style: TextStyle(height: 1.5, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            Text(
              'Tips:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.amber),
            ),
            SizedBox(height: 8),
            Text(
              '• Take your time to think\n'
                  '• Explain your reasoning\n'
                  '• Ask for hints if stuck\n'
                  '• It is okay to be wrong - that is how we learn!',
              style: TextStyle(height: 1.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: AppColors.teal)),
          ),
        ],
      ),
    );
  }
}
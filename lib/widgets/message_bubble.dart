import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/learning_models.dart';
import '../core/theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isUser ? 60 : 16,
          right: message.isUser ? 16 : 60,
          top: 8,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? AppGradients.teal
                    : null,
                color: message.isUser ? null : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                border: message.isUser
                    ? null
                    : Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideX(
              begin: message.isUser ? 0.1 : -0.1,
              duration: 300.ms,
            ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),

            // Feedback indicator
            if (message.feedback != null && !message.isUser) ...[
              const SizedBox(height: 8),
              _buildFeedbackCard(context, message.feedback!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, MessageFeedback feedback) {
    Color feedbackColor;
    IconData feedbackIcon;
    String feedbackLabel;

    switch (feedback.type) {
      case FeedbackType.excellent:
        feedbackColor = AppColors.success;
        feedbackIcon = Icons.star;
        feedbackLabel = 'Excellent!';
        break;
      case FeedbackType.correct:
        feedbackColor = AppColors.success;
        feedbackIcon = Icons.check_circle;
        feedbackLabel = 'Correct';
        break;
      case FeedbackType.partiallyCorrect:
        feedbackColor = AppColors.amber;
        feedbackIcon = Icons.lightbulb_outline;
        feedbackLabel = 'Close';
        break;
      case FeedbackType.incorrect:
        feedbackColor = Colors.red.shade300;
        feedbackIcon = Icons.info_outline;
        feedbackLabel = 'Think Again';
        break;
      case FeedbackType.needsThinking:
        feedbackColor = AppColors.purple;
        feedbackIcon = Icons.psychology;
        feedbackLabel = 'Consider';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feedbackColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(feedbackIcon, color: feedbackColor, size: 16),
              const SizedBox(width: 6),
              Text(
                feedbackLabel,
                style: TextStyle(
                  color: feedbackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (feedback.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              feedback.message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ],
          if (feedback.hints != null && feedback.hints!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...feedback.hints!.map((hint) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 ',
                    style: TextStyle(fontSize: 12),
                  ),
                  Expanded(
                    child: Text(
                      hint,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
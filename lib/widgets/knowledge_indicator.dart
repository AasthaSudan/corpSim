import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class KnowledgeIndicator extends StatelessWidget {
  final double knowledgeScore;
  final String skillName;

  const KnowledgeIndicator({
    super.key,
    required this.knowledgeScore,
    required this.skillName,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (knowledgeScore * 100).toInt();
    final color = _getColorForScore(knowledgeScore);
    final emoji = _getEmojiForScore(knowledgeScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Knowledge Score',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: knowledgeScore,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            _getLevelDescription(knowledgeScore),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate(
      target: knowledgeScore > 0.5 ? 1 : 0,
    ).shimmer(
      duration: 2000.ms,
      color: color.withValues(alpha: 0.5),
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.teal;
    if (score >= 0.4) return AppColors.amber;
    return AppColors.purple;
  }

  String _getEmojiForScore(double score) {
    if (score >= 0.9) return '🎓';
    if (score >= 0.7) return '🧠';
    if (score >= 0.5) return '💡';
    if (score >= 0.3) return '📚';
    return '🌱';
  }

  String _getLevelDescription(double score) {
    if (score >= 0.9) return 'Expert level! You\'ve mastered this concept.';
    if (score >= 0.7) return 'Strong understanding! Keep reinforcing.';
    if (score >= 0.5) return 'Good progress! You\'re getting there.';
    if (score >= 0.3) return 'Building foundations. Keep exploring!';
    return 'Just starting. Every expert was once a beginner.';
  }
}
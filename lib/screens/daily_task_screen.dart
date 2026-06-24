import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:negotium/screens/skill_roadmap_screen.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import 'package:confetti/confetti.dart';

class DailyTaskScreen extends StatefulWidget {
  final DailyTask task;
  final String skillName;

  const DailyTaskScreen({
    super.key,
    required this.task,
    required this.skillName,
  });

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  late ConfettiController _confettiController;
  List<TaskStep> steps = [];
  int completedSteps = 0;
  int? confidenceRating;
  bool showConfidenceRating = false;
  String notes = '';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadSteps();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadSteps() {
    steps = [
      TaskStep(
        id: '1',
        title: 'Watch Introduction Video',
        description: 'Watch the 5-minute overview of today\'s concept',
        isCompleted: false,
        hasHint: true,
        hint: 'Take notes on key concepts as you watch',
      ),
      TaskStep(
        id: '2',
        title: 'Read Core Concepts',
        description: 'Review the fundamental principles',
        isCompleted: false,
        hasHint: true,
        hint: 'Focus on understanding "why" not just "how"',
      ),
      TaskStep(
        id: '3',
        title: 'Hands-On Practice',
        description: 'Complete the practice exercise',
        isCompleted: false,
        hasHint: true,
        hint: 'Don\'t worry about mistakes - they\'re part of learning!',
      ),
      TaskStep(
        id: '4',
        title: 'Quick Reflection',
        description: 'Write down what you learned in your own words',
        isCompleted: false,
        hasHint: true,
        hint: 'Teaching yourself is the best way to learn',
      ),
    ];
  }

  void _toggleStep(int index) {
    setState(() {
      steps[index].isCompleted = !steps[index].isCompleted;
      completedSteps = steps.where((s) => s.isCompleted).length;

      if (completedSteps == steps.length && !showConfidenceRating) {
        showConfidenceRating = true;
        _confettiController.play();
      }
    });
  }

  void _completeTask() {
    if (confidenceRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please rate your confidence level'),
          backgroundColor: AppColors.amber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildCompletionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = completedSteps / steps.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedOrb(color: AppColors.purple, size: 300),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: AnimatedOrb(color: AppColors.teal, size: 350),
            ),

            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: [AppColors.teal, AppColors.purple, AppColors.amber, AppColors.success],
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Day ${widget.task.day}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    widget.skillName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars_rounded, color: AppColors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${widget.task.xpReward} XP',
                                    style: const TextStyle(
                                      color: AppColors.amber,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$completedSteps of ${steps.length} steps',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.surface.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.flag_rounded, color: AppColors.teal, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Today\'s Goal',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.task.description,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms),

                          const SizedBox(height: 24),

                          Text(
                            'Steps to Complete',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...steps.asMap().entries.map((entry) {
                            final index = entry.key;
                            final step = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildStepCard(step, index).animate()
                                  .fadeIn(duration: 400.ms),
                            );
                          }),

                          const SizedBox(height: 24),
                          if (showConfidenceRating) ...[
                            _buildConfidenceRating().animate()
                                .fadeIn(duration: 400.ms),
                            const SizedBox(height: 24),
                          ],

                          if (showConfidenceRating) ...[
                            _buildNotesSection(),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),

                  if (showConfidenceRating)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: GlassCard(
                        gradient: AppGradients.tealPurple,
                        child: InkWell(
                          onTap: _completeTask,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Complete Task',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
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

  Widget _buildStepCard(TaskStep step, int index) {
    return GlassContainer(
      color: step.isCompleted
          ? AppColors.success.withValues(alpha: 0.05)
          : Colors.transparent,
      border: step.isCompleted
          ? Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => _toggleStep(index),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: step.isCompleted
                          ? AppColors.success
                          : Colors.transparent,
                      border: Border.all(
                        color: step.isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: step.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: step.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: step.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      if (step.hasHint && !step.isCompleted) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.amber, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step.hint ?? '',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceRating() {
    return GlassContainer(
      color: AppColors.purple.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppColors.purple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'How confident do you feel?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your honest feedback helps us adapt to your learning pace',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = confidenceRating == rating;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      confidenceRating = rating;
                    });
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.amber
                          : AppColors.surface.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        '$rating',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ).animate(target: isSelected ? 1 : 0)
                      .scale(duration: 200.ms),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not confident',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Very confident',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.teal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Quick Notes (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'What did you learn today? Any challenges?',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                notes = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.tealPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 40),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shake(duration: 600.ms, delay: 600.ms),
              const SizedBox(height: 24),
              Text(
                'Day ${widget.task.day} Complete! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You earned ${widget.task.xpReward} XP!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                gradient: AppGradients.teal,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'Continue',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskStep {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final bool hasHint;
  final String? hint;

  TaskStep({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.hasHint = false,
    this.hint,
  });
}
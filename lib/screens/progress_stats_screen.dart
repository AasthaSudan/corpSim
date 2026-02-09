import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class ProgressStatsScreen extends StatefulWidget {
  final String skillName;

  const ProgressStatsScreen({
    super.key,
    required this.skillName,
  });

  @override
  State<ProgressStatsScreen> createState() => _ProgressStatsScreenState();
}

class _ProgressStatsScreenState extends State<ProgressStatsScreen> {
  String selectedPeriod = '7 Days';

  // Mock data - would come from database
  final List<double> confidenceData = [2.5, 3.0, 3.5, 3.8, 4.0, 4.2, 4.5];
  final List<String> labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: Stack(
          children: [
            // Background orbs
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

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Progress & Insights',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Overview Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewCard(
                                Icons.local_fire_department_rounded,
                                'Current Streak',
                                '7 Days',
                                AppColors.amber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                Icons.trending_up_rounded,
                                'Avg Confidence',
                                '4.2/5.0',
                                AppColors.success,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewCard(
                                Icons.timer_outlined,
                                'Total Time',
                                '3h 45m',
                                AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                Icons.stars_rounded,
                                'Total XP',
                                '1,250',
                                AppColors.purple,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        // Confidence Trend Chart
                        _buildSectionHeader('Confidence Trend'),
                        const SizedBox(height: 16),

                        _buildConfidenceChart().animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 32),

                        // Weekly Breakdown
                        _buildSectionHeader('This Week'),
                        const SizedBox(height: 16),

                        _buildWeeklyCalendar().animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 32),

                        // Achievements
                        _buildSectionHeader('Recent Achievements'),
                        const SizedBox(height: 16),

                        _buildAchievementsList(),

                        const SizedBox(height: 32),

                        // Learning Insights
                        _buildSectionHeader('AI Insights'),
                        const SizedBox(height: 16),

                        _buildInsightsCard().animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideY(begin: 0.1),

                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(IconData icon, String label, String value, Color color) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: AppGradients.teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceChart() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How confident you feel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Period Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPeriod,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.teal),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.surface.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: confidenceData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      gradient: AppGradients.tealPurple,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: AppColors.teal,
                            strokeWidth: 3,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.teal.withOpacity(0.2),
                            AppColors.purple.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final completed = [true, true, true, true, true, true, true];

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Streak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                final isCompleted = completed[index];

                return Column(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isCompleted ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ] : null,
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: AppColors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7 Day Streak! 🔥',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Keep it up! You\'re on fire!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList() {
    final achievements = [
      Achievement(
        icon: Icons.emoji_events_rounded,
        title: 'First Step',
        description: 'Completed your first task',
        color: AppColors.amber,
        unlocked: true,
      ),
      Achievement(
        icon: Icons.local_fire_department_rounded,
        title: '7 Day Streak',
        description: '7 consecutive days of learning',
        color: AppColors.success,
        unlocked: true,
      ),
      Achievement(
        icon: Icons.trending_up_rounded,
        title: 'Rising Star',
        description: 'Improved confidence 3 days in a row',
        color: AppColors.teal,
        unlocked: true,
      ),
      Achievement(
        icon: Icons.stars_rounded,
        title: 'XP Master',
        description: 'Earn 1,000 XP',
        color: AppColors.purple,
        unlocked: false,
      ),
    ];

    return Column(
      children: achievements.asMap().entries.map((entry) {
        final index = entry.key;
        final achievement = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAchievementCard(achievement).animate()
              .fadeIn(duration: 600.ms, delay: (400 + index * 100).ms)
              .slideX(begin: 0.1),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return GlassContainer(
      color: achievement.unlocked
          ? achievement.color.withOpacity(0.05)
          : AppColors.surface.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: achievement.unlocked
                    ? achievement.color.withOpacity(0.15)
                    : AppColors.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                achievement.icon,
                color: achievement.unlocked
                    ? achievement.color
                    : AppColors.textSecondary.withOpacity(0.5),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: achievement.unlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (achievement.unlocked)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              )
            else
              Icon(
                Icons.lock_rounded,
                color: AppColors.textSecondary.withOpacity(0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    return GlassContainer(
      color: AppColors.info.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInsightItem(
              Icons.trending_up_rounded,
              'Consistent Progress',
              'Your confidence has improved 80% this week. Great job!',
              AppColors.success,
            ),
            const SizedBox(height: 16),

            _buildInsightItem(
              Icons.access_time_rounded,
              'Peak Performance',
              'You learn best between 9 AM - 11 AM. Try scheduling tasks then.',
              AppColors.teal,
            ),
            const SizedBox(height: 16),

            _buildInsightItem(
              Icons.lightbulb_outline_rounded,
              'Recommendation',
              'You\'re ready for harder challenges. Next task will be adjusted.',
              AppColors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Achievement {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool unlocked;

  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.unlocked,
  });
}
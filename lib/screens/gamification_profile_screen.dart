import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class GamificationProfileScreen extends StatefulWidget {
  const GamificationProfileScreen({super.key});

  @override
  State<GamificationProfileScreen> createState() => _GamificationProfileScreenState();
}

class _GamificationProfileScreenState extends State<GamificationProfileScreen> {
  final int currentLevel = 3;
  final int currentXP = 1250;
  final int xpForNextLevel = 2000;
  final int totalSkillsLearning = 2;
  final int totalDaysActive = 23;
  final int longestStreak = 12;

  @override
  Widget build(BuildContext context) {
    final xpProgress = currentXP / xpForNextLevel;

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
              child: AnimatedOrb(color: AppColors.amber, size: 300),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: AnimatedOrb(color: AppColors.purple, size: 350),
            ),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      'Profile & Achievements',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProfileHeader(xpProgress),
                        const SizedBox(height: 32),

                        _buildQuickStats(),
                        const SizedBox(height: 32),

                        _buildSectionHeader('Achievements'),
                        const SizedBox(height: 16),
                        _buildAchievements(),
                        const SizedBox(height: 32),

                        _buildSectionHeader('Badges'),
                        const SizedBox(height: 16),
                        _buildBadges(),
                        const SizedBox(height: 32),

                        _buildSectionHeader('Level Milestones'),
                        const SizedBox(height: 16),
                        _buildLevelMilestones(),

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

  Widget _buildProfileHeader(double xpProgress) {
    return GlassCard(
      gradient: AppGradients.tealPurple,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: xpProgress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$currentLevel',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 20),

            Text(
              'Learner',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Level $currentLevel - ${_getLevelTitle(currentLevel)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentXP XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$xpForNextLevel XP',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${xpForNextLevel - currentXP} XP to Level ${currentLevel + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.school_rounded,
            'Skills',
            '$totalSkillsLearning',
            AppColors.teal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.calendar_today_rounded,
            'Days Active',
            '$totalDaysActive',
            AppColors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.local_fire_department_rounded,
            'Best Streak',
            '$longestStreak',
            AppColors.amber,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
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
            gradient: AppGradients.amber,
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

  Widget _buildAchievements() {
    final achievements = [
      AchievementBadge(
        icon: '🎯',
        title: 'First Step',
        description: 'Completed first task',
        unlocked: true,
        rarity: 'Common',
      ),
      AchievementBadge(
        icon: '🔥',
        title: 'Week Warrior',
        description: '7-day streak',
        unlocked: true,
        rarity: 'Rare',
      ),
      AchievementBadge(
        icon: '📈',
        title: 'Rising Star',
        description: 'Improved 3 days straight',
        unlocked: true,
        rarity: 'Rare',
      ),
      AchievementBadge(
        icon: '⭐',
        title: 'XP Master',
        description: 'Earned 1,000 XP',
        unlocked: true,
        rarity: 'Epic',
      ),
      AchievementBadge(
        icon: '👑',
        title: 'Champion',
        description: 'Reach Level 5',
        unlocked: false,
        rarity: 'Legendary',
      ),
      AchievementBadge(
        icon: '💎',
        title: 'Perfectionist',
        description: '100% on all tasks',
        unlocked: false,
        rarity: 'Legendary',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementBadge(achievements[index]).animate()
            .fadeIn(duration: 600.ms, delay: (300 + index * 100).ms)
            .scale(duration: 600.ms, delay: (300 + index * 100).ms);
      },
    );
  }

  Widget _buildAchievementBadge(AchievementBadge badge) {
    final rarityColor = _getRarityColor(badge.rarity);

    return GlassContainer(
      color: badge.unlocked
          ? rarityColor.withOpacity(0.05)
          : AppColors.surface.withOpacity(0.02),
      border: badge.unlocked
          ? Border.all(color: rarityColor.withOpacity(0.3), width: 2)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? rarityColor.withOpacity(0.15)
                    : AppColors.surface.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: badge.unlocked ? [
                  BoxShadow(
                    color: rarityColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: badge.unlocked
                        ? null
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: badge.unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge.rarity,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: rarityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges() {
    final badges = [
      Badge(icon: '🎓', title: 'Scholar', earned: true),
      Badge(icon: '⚡', title: 'Fast Learner', earned: true),
      Badge(icon: '🎯', title: 'Focused', earned: true),
      Badge(icon: '💪', title: 'Persistent', earned: true),
      Badge(icon: '🌟', title: 'Excellence', earned: false),
      Badge(icon: '🏆', title: 'Champion', earned: false),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: badges.asMap().entries.map((entry) {
        final index = entry.key;
        final badge = entry.value;

        return _buildBadgeItem(badge).animate()
            .fadeIn(duration: 600.ms, delay: (400 + index * 80).ms)
            .scale(duration: 600.ms, delay: (400 + index * 80).ms);
      }).toList(),
    );
  }

  Widget _buildBadgeItem(Badge badge) {
    return GlassContainer(
      color: badge.earned
          ? AppColors.teal.withOpacity(0.05)
          : AppColors.surface.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 24,
                color: badge.earned ? null : Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              badge.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: badge.earned
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelMilestones() {
    final milestones = [
      LevelMilestone(level: 1, title: 'Novice', description: 'Just getting started', reached: true),
      LevelMilestone(level: 2, title: 'Learner', description: 'Building momentum', reached: true),
      LevelMilestone(level: 3, title: 'Practitioner', description: 'Making progress', reached: true),
      LevelMilestone(level: 4, title: 'Skilled', description: 'Getting good', reached: false),
      LevelMilestone(level: 5, title: 'Expert', description: 'Mastering skills', reached: false),
      LevelMilestone(level: 10, title: 'Master', description: 'Elite status', reached: false),
    ];

    return Column(
      children: milestones.asMap().entries.map((entry) {
        final index = entry.key;
        final milestone = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMilestoneCard(milestone).animate()
              .fadeIn(duration: 600.ms, delay: (500 + index * 100).ms)
              .slideX(begin: 0.1, delay: (500 + index * 100).ms),
        );
      }).toList(),
    );
  }

  Widget _buildMilestoneCard(LevelMilestone milestone) {
    return GlassContainer(
      color: milestone.reached
          ? AppColors.success.withOpacity(0.05)
          : Colors.transparent,
      border: milestone.level == currentLevel
          ? Border.all(color: AppColors.teal.withOpacity(0.5), width: 2)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: milestone.reached
                    ? AppGradients.teal
                    : null,
                color: milestone.reached
                    ? null
                    : AppColors.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${milestone.level}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: milestone.reached
                        ? Colors.white
                        : AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: milestone.reached
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (milestone.reached)
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
            else if (milestone.level == currentLevel)
              Icon(Icons.radio_button_checked_rounded, color: AppColors.teal, size: 24)
            else
              Icon(Icons.lock_rounded, color: AppColors.textSecondary.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 10) return 'Master';
    if (level >= 5) return 'Expert';
    if (level >= 3) return 'Practitioner';
    if (level >= 2) return 'Learner';
    return 'Novice';
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return AppColors.textSecondary;
      case 'rare':
        return AppColors.teal;
      case 'epic':
        return AppColors.purple;
      case 'legendary':
        return AppColors.amber;
      default:
        return AppColors.textSecondary;
    }
  }
}

class AchievementBadge {
  final String icon;
  final String title;
  final String description;
  final bool unlocked;
  final String rarity;

  AchievementBadge({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.rarity,
  });
}

class Badge {
  final String icon;
  final String title;
  final bool earned;

  Badge({
    required this.icon,
    required this.title,
    required this.earned,
  });
}

class LevelMilestone {
  final int level;
  final String title;
  final String description;
  final bool reached;

  LevelMilestone({
    required this.level,
    required this.title,
    required this.description,
    required this.reached,
  });
}
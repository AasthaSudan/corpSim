import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/models.dart' hide LearningResource;
import '../core/learning_models.dart';
import '../widgets/glass_card.dart';
import 'ai_teacher_screen.dart';
import 'skill_quiz_screen.dart';
import 'skill_roadmap_screen.dart';
import 'progress_stats_screen.dart';

class LearnSkillScreen extends StatefulWidget {
  final String skillName;

  const LearnSkillScreen({super.key, required this.skillName});

  @override
  State<LearnSkillScreen> createState() => _LearnSkillScreenState();
}

class _LearnSkillScreenState extends State<LearnSkillScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getSkillType() {
    final skillLower = widget.skillName.toLowerCase();
    if (skillLower.contains('batna')) return 'batna';
    if (skillLower.contains('anchor')) return 'anchoring';
    return 'negotiation';
  }

  List<Map<String, dynamic>> _getResourcesForSkill(String skillType) {
    switch (skillType) {
      case 'batna':
        return [
          {
            't': 'Understanding BATNA',
            'type': 'VIDEO',
            'd': '15m',
            'i': '🎥',
            'c': AppColors.teal,
            'progress': 0.8,
            'desc': 'Your Best Alternative explained',
            'url': 'https://www.youtube.com/results?search_query=BATNA+negotiation+tutorial'
          },
          {
            't': 'Harvard Negotiation Project',
            'type': 'ARTICLE',
            'd': '8m',
            'i': '📰',
            'c': AppColors.purple,
            'progress': 0.5,
            'desc': 'Original BATNA framework',
            'url': 'https://www.pon.harvard.edu/tag/batna/'
          },
          {
            't': 'BATNA Worksheet',
            'type': 'PDF',
            'd': '5m',
            'i': '📄',
            'c': AppColors.amber,
            'progress': 0.0,
            'desc': 'Calculate your alternatives',
            'url': 'https://www.google.com/search?q=BATNA+worksheet+PDF'
          },
          {
            't': 'Getting to Yes',
            'type': 'BOOK',
            'd': '4h',
            'i': '📚',
            'c': Colors.green,
            'progress': 0.3,
            'desc': 'Classic negotiation book',
            'url': 'https://www.google.com/search?q=Getting+to+Yes+book'
          },
          {
            't': 'BATNA Case Studies',
            'type': 'COURSE',
            'd': '45m',
            'i': '🎓',
            'c': Colors.blueAccent,
            'progress': 0.0,
            'desc': 'Real-world examples',
            'url': 'https://www.coursera.org/search?query=negotiation%20batna'
          },
        ];

      case 'anchoring':
        return [
          {
            't': 'Anchoring Effect Explained',
            'type': 'VIDEO',
            'd': '10m',
            'i': '🎥',
            'c': AppColors.teal,
            'progress': 0.6,
            'desc': 'Psychological pricing tactics',
            'url': 'https://www.youtube.com/results?search_query=anchoring+effect+negotiation'
          },
          {
            't': 'First Offer Advantage',
            'type': 'ARTICLE',
            'd': '7m',
            'i': '📰',
            'c': AppColors.purple,
            'progress': 0.4,
            'desc': 'When and how to anchor',
            'url': 'https://hbr.org/search?term=anchoring+negotiation'
          },
          {
            't': 'Counter-Anchoring Guide',
            'type': 'PDF',
            'd': '6m',
            'i': '📄',
            'c': AppColors.amber,
            'progress': 0.0,
            'desc': 'Defend against anchors',
            'url': 'https://www.google.com/search?q=counter+anchoring+negotiation+PDF'
          },
          {
            't': 'Thinking, Fast and Slow',
            'type': 'BOOK',
            'd': '6h',
            'i': '📚',
            'c': Colors.green,
            'progress': 0.2,
            'desc': 'Kahneman on cognitive biases',
            'url': 'https://www.google.com/search?q=Thinking+Fast+and+Slow+book'
          },
          {
            't': 'Price Anchoring in Sales',
            'type': 'PODCAST',
            'd': '35m',
            'i': '🎙️',
            'c': Colors.orange,
            'progress': 0.0,
            'desc': 'Real sales scenarios',
            'url': 'https://www.google.com/search?q=anchoring+sales+negotiation+podcast'
          },
        ];

      default: // negotiation
        return [
          {
            't': 'Negotiation Fundamentals',
            'type': 'VIDEO',
            'd': '18m',
            'i': '🎥',
            'c': AppColors.teal,
            'progress': 0.7,
            'desc': 'Essential skills and tactics',
            'url': 'https://www.youtube.com/results?search_query=negotiation+fundamentals+tutorial'
          },
          {
            't': 'Win-Win Strategies',
            'type': 'ARTICLE',
            'd': '10m',
            'i': '📰',
            'c': AppColors.purple,
            'progress': 0.5,
            'desc': 'Create mutual value',
            'url': 'https://hbr.org/topic/negotiation'
          },
          {
            't': 'Body Language in Negotiation',
            'type': 'VIDEO',
            'd': '12m',
            'i': '🎥',
            'c': Colors.red,
            'progress': 0.3,
            'desc': 'Non-verbal communication',
            'url': 'https://www.youtube.com/results?search_query=body+language+negotiation'
          },
          {
            't': 'Negotiation Prep Checklist',
            'type': 'PDF',
            'd': '5m',
            'i': '📄',
            'c': AppColors.amber,
            'progress': 0.0,
            'desc': 'Pre-negotiation planning',
            'url': 'https://www.google.com/search?q=negotiation+preparation+checklist+PDF'
          },
          {
            't': 'Never Split the Difference',
            'type': 'BOOK',
            'd': '5h',
            'i': '📚',
            'c': Colors.green,
            'progress': 0.4,
            'desc': 'FBI negotiation tactics',
            'url': 'https://www.google.com/search?q=Never+Split+the+Difference+book'
          },
          {
            't': 'Salary Negotiation Guide',
            'type': 'COURSE',
            'd': '1h 15m',
            'i': '🎓',
            'c': Colors.blueAccent,
            'progress': 0.0,
            'desc': 'Maximize your offer',
            'url': 'https://www.coursera.org/search?query=salary%20negotiation'
          },
          {
            't': 'Difficult Conversations',
            'type': 'PODCAST',
            'd': '42m',
            'i': '🎙️',
            'c': Colors.orange,
            'progress': 0.0,
            'desc': 'Handle tough talks',
            'url': 'https://www.google.com/search?q=difficult+conversations+negotiation+podcast'
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillType = _getSkillType();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildEnhancedHeader(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 12),

                      // --- PROGRESS INDICATOR ---
                      _buildProgressBadge(),
                      const SizedBox(height: 20),

                      // --- 1. HERO FEATURE: 30-DAY MASTERY PATH ---
                      _buildEnhancedHeroPath(context, skillType),
                      const SizedBox(height: 24),

                      // --- 2. CORE FEATURES ---
                      _buildSectionHeader('Interactive Training', 'Choose your learning style'),
                      const SizedBox(height: 12),
                      _buildEnhancedFeatureCards(context, skillType),
                      const SizedBox(height: 24),

                      // --- 4. CURATED RESOURCES ---
                      _buildSectionHeader('Curated Resources', 'Hand-picked content'),
                      const SizedBox(height: 12),
                      _buildEnhancedResourceCards(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      pinned: false,
      expandedHeight: 0,
      toolbarHeight: 60,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.teal.withOpacity(0.5)),
            ),
            child: const Text(
              "ACTIVE MODULE",
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 8,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.skillName,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppGradients.tealPurple,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildProgressBadge() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: 0.65,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                  ),
                ),
                const Text(
                  '65%',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Keep up the great work!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.trending_up_rounded, color: AppColors.teal, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeroPath(BuildContext context, String type) {
    return GlassCard(
      gradient: AppGradients.tealPurple,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SkillRoadmapScreen(skillName: widget.skillName, skillType: type),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_motion_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30-Day Mastery Path',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Structured learning roadmap',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('12/30', 'Days'),
                      Container(width: 1, height: 24, color: Colors.white30),
                      _buildStatItem('45min', 'Daily'),
                      Container(width: 1, height: 24, color: Colors.white30),
                      _buildStatItem('18', 'Left'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFeatureCards(BuildContext context, String type) {
    return Column(
      children: [
        _buildPrimaryFeatureCard(
          context,
          title: 'AI Teacher Lab',
          subtitle: 'Interactive learning with AI guidance',
          icon: Icons.psychology_rounded,
          gradient: LinearGradient(
            colors: [AppColors.purple.withOpacity(0.8), AppColors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AITeacherScreen(skill: widget.skillName, skillType: type)),
          ),
          badge: 'POPULAR',
        ),
        const SizedBox(height: 16),

        // Secondary Features Row
        Row(
          children: [
            Expanded(
              child: _buildSecondaryFeatureCard(
                context,
                title: 'Quiz',
                subtitle: 'Test knowledge',
                icon: Icons.quiz_rounded,
                color: AppColors.amber,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SkillQuizScreen(skillName: widget.skillName, skillType: type)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryFeatureCard(
                context,
                title: 'Stats',
                subtitle: 'Track growth',
                icon: Icons.insights_rounded,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProgressStatsScreen(skillName: widget.skillName)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryFeatureCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap,
        String? badge,
      }) {
    return GlassCard(
      gradient: gradient,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.amber,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryFeatureCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GlassContainer(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChips(BuildContext context) {
    final actions = [
      {'icon': Icons.bookmark_outline_rounded, 'label': 'Saved', 'color': AppColors.teal},
      {'icon': Icons.history_rounded, 'label': 'Recent', 'color': AppColors.purple},
      {'icon': Icons.notes_rounded, 'label': 'Notes', 'color': AppColors.amber},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GlassContainer(
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${action['label']} - Coming soon!'),
                      duration: const Duration(milliseconds: 1500),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action['label'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedResourceCards(BuildContext context) {
    final skillType = _getSkillType();
    final List<Map<String, dynamic>> resources = _getResourcesForSkill(skillType);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final res = resources[index];
        return GlassContainer(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final url = res['url'] as String;
                // Show a dialog with the resource info
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Text(res['i']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            res['t']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res['desc']!,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (res['c'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: (res['c'] as Color).withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: res['c'] as Color, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${res['type']} • ${res['d']}',
                                  style: TextStyle(
                                    color: res['c'] as Color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This will open in your browser:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: AppColors.teal, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  url,
                                  style: const TextStyle(
                                    color: AppColors.teal,
                                    fontSize: 10,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE', style: TextStyle(color: Colors.white54)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);

                          // Launch URL
                          final uri = Uri.parse(url);
                          try {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text('Opening ${res['t']}...')),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: res['c'] as Color,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.white, size: 20),
                                        SizedBox(width: 12),
                                        Expanded(child: Text('Could not open URL')),
                                      ],
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text('Error: ${e.toString()}')),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('OPEN RESOURCE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: res['c'] as Color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (res['c'] as Color).withOpacity(0.3),
                                (res['c'] as Color).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              res['i']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                res['t']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                res['desc']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (res['c'] as Color).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: (res['c'] as Color).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      res['type']!,
                                      style: TextStyle(
                                        color: res['c'] as Color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                                  const SizedBox(width: 4),
                                  Text(
                                    res['d']!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (res['c'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () async {
                              // Quick launch without dialog
                              final url = res['url'] as String;
                              final uri = Uri.parse(url);

                              try {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(child: Text('Quick launching ${res['t']}!')),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: res['c'] as Color,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Could not open: ${e.toString()}'),
                                      backgroundColor: Colors.red.shade700,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 24,
                              color: res['c'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (res['progress'] > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: res['progress'],
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(res['c'] as Color),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
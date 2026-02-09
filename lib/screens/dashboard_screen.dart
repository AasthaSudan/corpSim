import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/services.dart';
import '../core/models.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_helper.dart';
import '../widgets/stat_card.dart';
import '../widgets/glass_card.dart';
import 'scenarios_screen.dart';
import 'analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout based on screen width
              if (constraints.maxWidth > 1200) {
                return _buildDesktopLayout();
              } else if (constraints.maxWidth > 600) {
                return _buildTabletLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: () => context.read<SessionProvider>().loadSessions(),
      color: AppColors.teal,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildStats(crossAxisCount: 2),
          _buildQuickAction(),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        if (!kIsWeb) _buildCompactSidebar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<SessionProvider>().loadSessions(),
            color: AppColors.teal,
            backgroundColor: AppColors.surface,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildStats(crossAxisCount: 3),
                _buildQuickAction(),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: RefreshIndicator(
                onRefresh: () => context.read<SessionProvider>().loadSessions(),
                color: AppColors.teal,
                backgroundColor: AppColors.surface,
                child: CustomScrollView(
                  slivers: [
                    _buildHeader(),
                    _buildStats(crossAxisCount: 4),
                    _buildQuickAction(),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.tealPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'NEGOTIUM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavItem(Icons.dashboard, 'Dashboard', true),
          _buildNavItem(Icons.school, 'Learn', false),
          _buildNavItem(Icons.psychology, 'Practice', false),
          _buildNavItem(Icons.insights, 'Analytics', false),
          _buildNavItem(Icons.emoji_events, 'Achievements', false),
          const Spacer(),
          // Settings at bottom
          _buildNavItem(Icons.settings, 'Settings', false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompactSidebar() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildCompactNavItem(Icons.dashboard, true),
          _buildCompactNavItem(Icons.school, false),
          _buildCompactNavItem(Icons.psychology, false),
          _buildCompactNavItem(Icons.insights, false),
          const Spacer(),
          _buildCompactNavItem(Icons.settings, false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: isActive ? AppGradients.teal : null,
        color: isActive ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildCompactNavItem(IconData icon, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isActive ? AppGradients.teal : null,
        color: isActive ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Command Center',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: context.isMobile ? 28 : 36,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, Agent',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (!context.isMobile)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppGradients.tealPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'TK',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats({required int crossAxisCount}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.responsivePadding),
      sliver: Consumer<SessionProvider>(
        builder: (context, provider, _) {
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: context.isMobile ? 1.3 : 1.2,
            ),
            delegate: SliverChildListDelegate([
              StatCard(
                title: 'Overall Score',
                value: '85%',
                icon: Icons.trending_up,
                color: AppColors.teal,
              ).animate().fadeIn(duration: 600.ms).scale(),
              StatCard(
                title: 'Sessions',
                value: provider.totalSessions.toString(),
                icon: Icons.tablet,
                color: AppColors.purple,
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms).scale(),
              StatCard(
                title: 'Hours',
                value: provider.hoursInvested,
                icon: Icons.access_time,
                color: AppColors.amber,
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(),
              StatCard(
                title: 'Scenarios',
                value: '6/8',
                icon: Icons.business,
                color: AppColors.cyan,
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale(),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePadding),
        child: GlassCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ScenariosScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: AppColors.teal,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'RECOMMENDED',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.teal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start New Simulation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Continue your training in the Salary Negotiation module.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: 0.2),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.responsivePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                Consumer<SessionProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.teal,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<SessionProvider>(
              builder: (context, provider, _) {
                if (provider.sessions.isEmpty && !provider.isLoading) {
                  return GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sessions found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start negotiating!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: provider.sessions.map((session) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActivityRow(session: session)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.2),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final SavedSession session;

  const _ActivityRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(sessionId: session.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: const Icon(
                Icons.list_alt,
                color: AppColors.teal,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.scenario,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Leverage: ${(session.leverage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(session.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary.withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return DateFormat('h:mm a').format(date);
      } else {
        return DateFormat('MMM d, h:mm a').format(date);
      }
    } catch (e) {
      return 'Just now';
    }
  }
}
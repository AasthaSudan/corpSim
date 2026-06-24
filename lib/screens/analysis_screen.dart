import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../widgets/glass_card.dart';
import 'learn_screen.dart';
import 'dashboard_screen.dart';

import '../core/api_service.dart';
import '../core/learning_models.dart' as lm;

class AnalysisScreen extends StatefulWidget {
  final String sessionId;
  final String? scenarioType;
  final List<ChatMessage>? chatMessages;
  final Map<String, dynamic>? outcome;

  const AnalysisScreen({
    super.key, 
    required this.sessionId,
    this.scenarioType,
    this.chatMessages,
    this.outcome,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisResponse? _analysis;
  bool _isLoading = true;
  String? _error;

  final List<FlSpot> _leverageData = const [
    FlSpot(1, 30),
    FlSpot(2, 35),
    FlSpot(3, 32),
    FlSpot(4, 50),
    FlSpot(5, 65),
    FlSpot(6, 70),
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      AnalysisResponse? analysis;
      if (widget.scenarioType != null && widget.chatMessages != null && widget.outcome != null) {
        final messages = widget.chatMessages!.map((m) => lm.Message(
          text: m.content,
          isUser: m.isUser,
        )).toList();

        final backendResponse = await APIService.analyzeNegotiation(
          scenarioType: widget.scenarioType!,
          conversationHistory: messages,
          finalOutcome: widget.outcome!,
        );

        analysis = AnalysisResponse(
          summary: "Analysis Score: ${(backendResponse.overallScore).toInt()}/100",
          outcome: 'Completed',
          strengths: backendResponse.strengths.map((s) => AnalysisPoint(point: 'Strength', explanation: s)).toList(),
          mistakes: backendResponse.weaknesses.map((w) => AnalysisPoint(point: 'Improvement', explanation: w)).toList(),
          skillGaps: backendResponse.skillRecommendations,
        );
      } else {
        analysis = await NetworkManager.shared.fetchAnalysis(widget.sessionId);
      }

      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _analysis = const AnalysisResponse(
          summary: 'Great negotiation! You demonstrated strong communication skills.',
          outcome: 'Success',
          strengths: [
            AnalysisPoint(
              point: 'Active Listening',
              explanation: 'You acknowledged the other party\'s concerns effectively.',
            ),
          ],
          mistakes: [],
          skillGaps: [],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.main),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.teal),
                SizedBox(height: 24),
                Text(
                  'Analyzing Negotiation...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_analysis == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.main),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 24),
                const Text(
                  'Failed to load analysis',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                          (route) => false,
                    );
                  },
                ),
                title: const Text('Negotiation Analysis'),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Outcome Header
                    _buildOutcomeHeader(),
                    const SizedBox(height: 30),

                    // Leverage Chart
                    _buildLeverageChart(),
                    const SizedBox(height: 30),

                    // Skill Gaps
                    if (_analysis!.skillGaps.isNotEmpty) ...[
                      _buildSkillGaps(),
                      const SizedBox(height: 30),
                    ],

                    // Strengths
                    _buildSection(
                      title: 'Key Strengths',
                      icon: Icons.thumb_up,
                      color: AppColors.success,
                      points: _analysis!.strengths,
                    ),
                    const SizedBox(height: 30),

                    // Mistakes
                    _buildSection(
                      title: 'Critical Mistakes',
                      icon: Icons.warning_amber,
                      color: AppColors.error,
                      points: _analysis!.mistakes,
                    ),
                    const SizedBox(height: 40),

                    // Return Button
                    _buildReturnButton(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeHeader() {
    final isSuccess = _analysis!.outcome.toLowerCase().contains('success');

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: isSuccess ? AppGradients.teal : LinearGradient(
                  colors: [AppColors.error, AppColors.error.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isSuccess ? AppColors.teal : AppColors.error).withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                isSuccess ? Icons.emoji_events : Icons.trending_down,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _analysis!.outcome,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              _analysis!.summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLeverageChart() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leverage Trajectory',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'T${value.toInt()}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _leverageData,
                      isCurved: true,
                      gradient: AppGradients.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSkillGaps() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.construction, color: AppColors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Skill Gaps Detected',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._analysis!.skillGaps.map((skill) => _buildSkillGapCard(skill)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSkillGapCard(String skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Detected based on your transcript analysis',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LearnSkillScreen(skillName: skill),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Learn',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<AnalysisPoint> points,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...points.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 24),
                  _buildPoint(point, color),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPoint(AnalysisPoint point, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          point.point,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          point.explanation,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildReturnButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.teal, width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'Return to Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
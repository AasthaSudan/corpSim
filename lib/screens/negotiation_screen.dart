import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/models.dart';
import '../core/services.dart';
import '../widgets/chat_row.dart';
import '../widgets/glass_card.dart';
import '../widgets/metrics_pill.dart';
import 'analysis_screen.dart';

class NegotiationScreen extends StatefulWidget {
  final Scenario scenario;

  const NegotiationScreen({super.key, required this.scenario});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _showCoachTip = true;
  bool _showDebugPanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NegotiationProvider>().startNewSession(widget.scenario.title);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      context.read<NegotiationProvider>().decrementTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<NegotiationProvider>();
    await provider.sendMessage(widget.scenario.title, text);
    _inputController.clear();
    _showCoachTip = true;

    // Auto scroll
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Auto terminate if patience runs out or mood is angry/terminated
    if (provider.patience <= 0.0 || 
        provider.mood.toLowerCase() == 'angry' || 
        provider.mood.toLowerCase() == 'terminated') {
      if (!mounted) return;
      provider.endSession(context.read<SessionProvider>(), widget.scenario.title);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            sessionId: provider.sessionID ?? "mock",
            scenarioType: widget.scenario.title,
            chatMessages: provider.messages,
            outcome: {'final_leverage': provider.leverage, 'mood': provider.mood},
          ),
        ),
      );
    }
  }

  void _endNegotiation() {
    final navProvider = context.read<NegotiationProvider>();
    final sessionProvider = context.read<SessionProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End Negotiation?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure? Your progress will be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // 1. Tell NegotiationProvider to push current data to SessionProvider
              navProvider.endSession(sessionProvider, widget.scenario.title);

              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalysisScreen(
                    sessionId: navProvider.sessionID ?? "mock",
                    scenarioType: widget.scenario.title,
                    chatMessages: navProvider.messages,
                    outcome: {'final_leverage': navProvider.leverage, 'mood': navProvider.mood},
                  ),
                ),
              );
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.teal.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).blur(
                begin: const Offset(100, 100),
                end: const Offset(100, 100),
              ),
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                // Top Bar with Mode Indicator
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.8),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                    ),
                    child: Consumer<NegotiationProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          children: [
                            // Main metrics row
                            Row(
                              children: [
                                MetricPill(
                                  label: 'Leverage',
                                  value: provider.leverage,
                                  color: AppColors.teal,
                                ),
                                const SizedBox(width: 16),
                                MetricPill(
                                  label: 'Patience',
                                  value: provider.patience,
                                  color: AppColors.purple,
                                ),
                                const Spacer(),
                                // Timer
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: provider.timeRemaining < 60
                                        ? AppColors.error.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: provider.timeRemaining < 60
                                            ? AppColors.error
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTime(provider.timeRemaining),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                          color: provider.timeRemaining < 60
                                              ? AppColors.error
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: _endNegotiation,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(
                                    'End',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Debug Mode Indicator
                            const SizedBox(height: 8),
                            _buildModeIndicator(),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                Consumer<NegotiationProvider>(
                  builder: (context, provider, _) {
                    if (provider.latestCoachTip == null || !_showCoachTip) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppGradients.purple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coach Tip',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.purple,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    provider.latestCoachTip!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              color: AppColors.textSecondary,
                              onPressed: () {
                                setState(() => _showCoachTip = false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms);
                  },
                ),

                Expanded(
                  child: Consumer<NegotiationProvider>(
                    builder: (context, provider, _) {
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final message = provider.messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ChatRow(message: message)
                                .animate()
                                .fadeIn(duration: 400.ms),
                          );
                        },
                      );
                    },
                  ),
                ),

                Consumer<NegotiationProvider>(
                  builder: (context, provider, _) {
                    if (provider.error == null) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            color: AppColors.error,
                            onPressed: () => provider.clearError(),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                if (_showDebugPanel) _buildQuickTestPanel(),

                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.95),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showDebugPanel ? Icons.bug_report : Icons.bug_report_outlined,
                            color: _showDebugPanel ? AppColors.teal : AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _showDebugPanel = !_showDebugPanel);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type your response...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppColors.teal, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            onChanged: (_) => setState(() {}), // Update send button
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Consumer<NegotiationProvider>(
                          builder: (context, provider, _) {
                            final isEmpty = _inputController.text.isEmpty;
                            return GestureDetector(
                              onTap: provider.isLoading ? null : _sendMessage,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: isEmpty ? null : AppGradients.teal,
                                  color: isEmpty ? Colors.white.withValues(alpha: 0.2) : null,
                                  shape: BoxShape.circle,
                                ),
                                child: provider.isLoading
                                    ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildModeIndicator() {
    final mode = NetworkManager.shared.getCurrentMode();
    Color modeColor;
    IconData modeIcon;

    if (mode == 'Real Backend') {
      modeColor = AppColors.success;
      modeIcon = Icons.cloud;
    } else if (mode == 'Enhanced Mock') {
      modeColor = AppColors.amber;
      modeIcon = Icons.science;
    } else {
      modeColor = AppColors.purple;
      modeIcon = Icons.speed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: modeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: modeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(modeIcon, size: 12, color: modeColor),
          const SizedBox(width: 6),
          Text(
            mode,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: modeColor,
            ),
          ),
        ],
      ),
    );
  }

  // Quick Test Panel
  Widget _buildQuickTestPanel() {
    final testMessages = [
      ('✅ High Leverage', 'Based on my 5 years delivering \$2M in revenue, I\'m looking at \$130k.'),
      ('❌ Aggressive', 'I demand \$150k immediately or I\'m leaving!'),
      ('🤝 Collaborative', 'I appreciate this opportunity. Let\'s explore a win-win solution.'),
      ('⚠️ Weak', 'Sorry to ask, but maybe we could possibly consider an increase?'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, size: 16, color: AppColors.teal),
              const SizedBox(width: 8),
              const Text(
                'Quick Test Messages',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _showDebugPanel = false);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: testMessages.map((msg) {
              return GestureDetector(
                onTap: () {
                  _inputController.text = msg.$2;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    msg.$1,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/services.dart';
import 'dashboard_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    StorageService.instance.setLoggedIn(true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: Stack(
          children: [
            // Animated Orbs
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _orbController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _orbController.value * 200 - 100,
                      _orbController.value * 200 - 100,
                    ),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.orb,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                      duration: 3000.ms,
                      color: Colors.white.withValues(alpha: 0.1),
                    )
                        .blur(begin: const Offset(60, 60), end: const Offset(60, 60)),
                  );
                },
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppGradients.tealPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                        .then()
                        .shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),

                    const SizedBox(height: 40),
                    Text(
                      'NEGOTIUM',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 16),

                    Text(
                      'Negotiate with Superhuman Intelligence',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms),

                    const Spacer(),

                    _buildPrimaryButton()
                        .animate()
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppGradients.tealPurple,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startSimulation,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Start Simulation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
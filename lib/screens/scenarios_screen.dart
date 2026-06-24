import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/models.dart';
import '../widgets/scenario_card.dart';
import 'negotiation_screen.dart';

class ScenariosScreen extends StatelessWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Scenario Library'),
              ),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scenario Library',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a simulation environment to practice.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
              ),

              // Scenarios Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final scenario = MockData.scenarios[index];
                      return ScenarioCard(
                        scenario: scenario,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NegotiationScreen(scenario: scenario),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 400.ms);
                    },
                    childCount: MockData.scenarios.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}
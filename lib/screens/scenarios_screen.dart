import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme/app_colors.dart';
import '../config/routes/app_routes.dart';
import '../models/scenario.dart';
import '../widgets/scenario_card.dart';

class ScenariosScreen extends StatelessWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarios = Scenario.getSampleScenarios();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Choose Your Challenge'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'History feature will be available soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryTeal,
                colorText: AppColors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to Practice?',
                          style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose a scenario and master negotiation',
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: scenarios.length,
                itemBuilder: (context, index) {
                  return ScenarioCard(
                    scenario: scenarios[index],
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.brief,
                        arguments: scenarios[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
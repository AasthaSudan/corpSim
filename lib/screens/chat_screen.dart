import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../models/scenario.dart';
import '../widgets/message_bubble.dart';
import '../widgets/metrics_bar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Scenario scenario = Get.arguments as Scenario;
    final controller = Get.put(ChatController(scenario: scenario));

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scenario.opponentName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              scenario.opponentRole,
              style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showScenarioInfo(context, scenario);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => MetricsBar(
            patience: controller.patience.value,
            leverage: controller.leverage.value,
            emotion: controller.emotion.value,
          )),

          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty && controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                    message: controller.messages[index],
                  );
                },
              );
            }),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${scenario.opponentName} is typing...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGray.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your response...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundGray,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (value) {
                        controller.sendMessage(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => FloatingActionButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                      controller.sendMessage(
                        controller.messageController.text,
                      );
                    },
                    backgroundColor: controller.isLoading.value
                        ? AppColors.lightGray
                        : AppColors.primaryTeal,
                    elevation: 2,
                    child: const Icon(
                      Icons.send,
                      color: AppColors.white,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScenarioInfo(BuildContext context, Scenario scenario) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    scenario.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      scenario.title,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '🎯 Your Goal',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scenario.goal,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
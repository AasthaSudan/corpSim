// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import '../models/message.dart';
// import '../models/scenario.dart';
// import '../services/claude_service.dart';
//
// class ChatController extends GetxController {
//   final Scenario scenario;
//
//   ChatController({required this.scenario});
//
//   // State
//   final messages = <Message>[].obs;
//   final isLoading = false.obs;
//   final patience = 10.0.obs;
//   final leverage = 3.obs;
//   final emotion = '😐'.obs;
//
//   final claudeService = ClaudeService();
//   final ScrollController scrollController = ScrollController();
//   final TextEditingController messageController = TextEditingController();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _startConversation();
//   }
//
//   @override
//   void onClose() {
//     scrollController.dispose();
//     messageController.dispose();
//     super.onClose();
//   }
//
//   /// Start the conversation with AI greeting
//   void _startConversation() async {
//     isLoading.value = true;
//
//     // Create initial greeting from AI
//     final greeting = await claudeService.sendMessage(
//       conversationHistory: [
//         {
//           'role': 'user',
//           'content': 'Start the conversation as ${scenario.opponentName}. Greet me and ask what I want to discuss. Keep it brief (1-2 sentences).',
//         }
//       ],
//       scenario: scenario,
//       patience: patience.value,
//       leverage: leverage.value,
//     );
//
//     final aiMessage = Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       content: greeting,
//       isUser: false,
//       timestamp: DateTime.now(),
//     );
//
//     messages.add(aiMessage);
//     isLoading.value = false;
//     _scrollToBottom();
//   }
//
//   /// Send user message
//   Future<void> sendMessage(String content) async {
//     if (content.trim().isEmpty || isLoading.value) return;
//
//     // Add user message
//     final userMessage = Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       content: content.trim(),
//       isUser: true,
//       timestamp: DateTime.now(),
//     );
//
//     messages.add(userMessage);
//     messageController.clear();
//     _scrollToBottom();
//
//     // Analyze message and update metrics
//     final analysis = claudeService.analyzeMessage(
//       userMessage: content,
//       currentPatience: patience.value,
//       currentLeverage: leverage.value,
//     );
//
//     patience.value = analysis['patience'];
//     leverage.value = analysis['leverage'];
//     emotion.value = claudeService.getEmotion(patience.value);
//
//     // Check if negotiation should end
//     if (patience.value <= 0) {
//       _endNegotiation(success: false);
//       return;
//     }
//
//     // Get AI response
//     isLoading.value = true;
//
//     try {
//       final response = await claudeService.sendMessage(
//         conversationHistory: _buildConversationHistory(),
//         scenario: scenario,
//         patience: patience.value,
//         leverage: leverage.value,
//       );
//
//       final aiMessage = Message(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         content: response,
//         isUser: false,
//         timestamp: DateTime.now(),
//       );
//
//       messages.add(aiMessage);
//       _scrollToBottom();
//
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to get response. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   /// Build conversation history for API
//   List<Map<String, String>> _buildConversationHistory() {
//     final history = <Map<String, String>>[];
//
//     for (var message in messages) {
//       history.add({
//         'role': message.isUser ? 'user' : 'assistant',
//         'content': message.content,
//       });
//     }
//
//     return history;
//   }
//
//   /// Scroll to bottom of chat
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   /// End negotiation
//   void _endNegotiation({required bool success}) {
//     Get.dialog(
//       AlertDialog(
//         title: Text(success ? '🎉 Success!' : '😔 Negotiation Ended'),
//         content: Text(
//           success
//               ? 'You successfully completed the negotiation!'
//               : 'The negotiation ended early. They lost patience.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back(); // Close dialog
//               Get.back(); // Go back to scenarios
//             },
//             child: const Text('Back to Scenarios'),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back(); // Close dialog
//               // TODO: Navigate to analysis screen
//             },
//             child: const Text('View Analysis'),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }
// }
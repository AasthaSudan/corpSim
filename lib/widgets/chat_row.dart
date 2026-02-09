import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/models.dart';

class ChatRow extends StatelessWidget {
  final ChatMessage message;

  const ChatRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!message.isUser) _buildAvatar(false),
        if (!message.isUser) const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: message.isUser ? AppGradients.teal : null,
              color: message.isUser ? null : const Color(0xFF1F2937),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: message.isUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (message.isUser) const SizedBox(width: 10),
        if (message.isUser) _buildAvatar(true),
      ],
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
          colors: [AppColors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isUser ? null : const Color(0xFF2D2D2D),
        shape: BoxShape.circle,
        border: Border.all(
          color: isUser ? AppColors.teal.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Center(
        child: isUser
            ? const Text(
          'TK',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.teal,
          ),
        )
            : const Icon(
          Icons.psychology,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
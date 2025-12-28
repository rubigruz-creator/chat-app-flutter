import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding,
        horizontal: AppConstants.defaultPadding,
      ),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isCurrentUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser 
                  ? AppConstants.primaryColor 
                  : Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : AppConstants.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.userName} • ${DateFormat('HH:mm').format(message.createdAt)}',
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTile({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lastMessageTime = chat.lastMessageTime;
    final timeStr = lastMessageTime != null 
      ? DateFormat('HH:mm').format(lastMessageTime)
      : '';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      title: Text(
        chat.title ?? 'Personal Chat',
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            chat.lastMessage ?? 'Нет сообщений',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${chat.lastMessageSender ?? ''} • ${chat.memberCount} участников',
            style: const TextStyle(
              fontSize: 11,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (chat.isGroup)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppConstants.accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'GROUP',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

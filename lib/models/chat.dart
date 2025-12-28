class Chat {
  final String id;
  final String? title;
  final bool isGroup;
  final DateTime createdAt;
  final int memberCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;

  Chat({
    required this.id,
    this.title,
    required this.isGroup,
    required this.createdAt,
    required this.memberCount,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      isGroup: json['is_group'] == true || 
               json['is_group'] == 1 || 
               json['is_group']?.toString() == '1' ||
               (json['is_group'] ?? false) == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      memberCount: int.tryParse(json['member_count']?.toString() ?? '0') ?? 0,
      lastMessage: json['last_message']?.toString(),
      lastMessageTime: json['last_message_time'] != null 
        ? DateTime.tryParse(json['last_message_time'].toString()) 
        : null,
      lastMessageSender: json['last_message_sender']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_group': isGroup,
    'created_at': createdAt.toIso8601String(),
    'member_count': memberCount,
    'last_message': lastMessage,
  };
}

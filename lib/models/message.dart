class Message {
  final String id;
  final String chatId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final String userName;

  Message({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.userName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      userId: json['user_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chat_id': chatId,
    'user_id': userId,
    'text': text,
    'created_at': createdAt.toIso8601String(),
    'user_name': userName,
  };
}

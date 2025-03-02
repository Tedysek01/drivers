// lib/models/chat.dart
class Chat {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;

  Chat({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

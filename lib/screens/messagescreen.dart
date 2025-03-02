import 'package:flutter/material.dart';
import 'package:drivers/style/barvy.dart';
import 'package:drivers/chat_user_class.dart'; // Používáme jedinou definici modelu Chat
import 'chat_detail.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Dummy data – v reálné implementaci načítáš chaty z databáze
  List<Chat> chats = [
    Chat(
      id: '1',
      title: 'John Doe',
      lastMessage: 'Ahoj, jak se máš?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      avatarUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxrd4dsitg-Rhwx0aUZsGjzqkZn34JbVC9-w&s',
      unreadCount: 2,
      isOnline: true,
    ),
    Chat(
      id: '2',
      title: 'Service Center',
      lastMessage: 'Váš termín je potvrzen.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      avatarUrl: 'https://avatar.iran.liara.run/public/15',
      unreadCount: 0,
      isOnline: false,
    ),
    Chat(
      id: '3',
      title: 'Marketplace Seller',
      lastMessage: 'Odeslal jsem zboží, děkuji.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      avatarUrl: 'https://avatar.iran.liara.run/public/7',
      unreadCount: 3,
      isOnline: true,
    ),
  ];

  String searchQuery = '';

  // Filtrace chatů podle vyhledávacího dotazu
  List<Chat> get filteredChats {
    if (searchQuery.isEmpty) return chats;
    return chats.where((chat) =>
        chat.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  // Funkce pro formátování času (např. "5m ago")
  String formatTimeAgo(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Hledat mezi chaty...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Seznam chatů
          Expanded(
            child: ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(chat.avatarUrl),
                      ),
                      if (chat.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    chat.title,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTimeAgo(chat.lastMessageTime),
                        style: TextStyle(
                          color: colorScheme.onPrimary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    // Navigace do detailu chatu s jednotnou definicí Chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(chat: chat),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

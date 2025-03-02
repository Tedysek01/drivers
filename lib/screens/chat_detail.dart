import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:drivers/style/barvy.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivers/chat_user_class.dart'; // Jediná definice třídy Chat

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      Map<String, dynamic> messageData = {
        'text': text,
        'senderId': 'currentUserId', // Nahraď skutečným ID aktuálního uživatele
        'senderName': 'Current User', // Nahraď údajem z tvého auth systému
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.id)
          .collection('messages')
          .add(messageData);

      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickImageAndSend() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child("chat_images").child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> messageData = {
        'imageUrl': downloadUrl,
        'senderId': 'currentUserId',
        'senderName': 'Current User',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chat.id)
          .collection('messages')
          .add(messageData);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime time = timestamp.toDate();
    return DateFormat('HH:mm').format(time);
  }

  void _openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.title),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chat.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Chyba při načítání zpráv.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;
                    bool isImageMessage = data.containsKey('imageUrl');
                    String? messageText = data['text'];
                    String? imageUrl = data['imageUrl'];
                    Timestamp? timestamp = data['timestamp'] as Timestamp?;
                    bool isCurrentUser = data['senderId'] == 'currentUserId';

                    if (isImageMessage) {
                      // Obrázek se zobrazuje bez dekorace, celý viditelný, s kliknutím na full-screen
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => _openFullScreenImage(imageUrl!),
                          child: Image.network(
                            imageUrl!,
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else {
                      // Textová zpráva s bublinou
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isCurrentUser ? colorScheme.primary : colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                messageText ?? '',
                                style: TextStyle(color: colorScheme.onPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo, color: colorScheme.onPrimary),
                      onPressed: _pickImageAndSend,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: colorScheme.onPrimary),
                        decoration: InputDecoration(
                          hintText: 'Napište zprávu...',
                          hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: colorScheme.onPrimary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(), // Kliknutím se vrátíš zpět
        child: Center(
          child: InteractiveViewer(
  clipBehavior: Clip.none, // Toto umožní, aby se obrázek nezobrazoval jen v rámci okrajů widgetu
  minScale: 0.5,
  maxScale: 4.0,
  child: Image.network(
    imageUrl,
    fit: BoxFit.contain,
  ),
),

        ),
      ),
    );
  }
}


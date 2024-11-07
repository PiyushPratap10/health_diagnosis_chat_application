import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/message_bubble.dart';
import '../api/chat_service.dart';
import '../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late ChatService _chatService;
  bool _isSending = false;  // Add this flag to track sending state

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  final userId = Provider.of<UserProvider>(context, listen: false).user?.userId;

  if (accessToken != null && userId != null) {
    _chatService = Provider.of<ChatService>(context, listen: false);

    // Remove any existing listener to prevent duplication
    _chatService.removeListener(_receiveMessage);
    
    // Connect WebSocket and add listener
    await _chatService.connect(userId, accessToken);
    _chatService.addListener(_receiveMessage);
  } else {
    print("Access token or user ID not found. Cannot connect to chat.");
  }
}

  void _receiveMessage() {
    setState(() {
      final newMessage = _chatService.messages.last;
      _messages.add({
        'text': newMessage['message'],
        'isUser': newMessage['sender'] == 'user',
      });
    });
  }

  void _sendMessage() {
  if (_isSending) return;

  setState(() {
    _isSending = true;
  });

  final messageText = _messageController.text.trim();
  if (messageText.isNotEmpty) {
    _chatService.sendMessage(messageText);
    setState(() {
      _messages.add({
        'text': messageText,
        'isUser': true,
      });
    });
    _messageController.clear();
  }

  // Add a small delay to reset the flag to prevent double triggering
  Future.delayed(Duration(milliseconds: 200), () {
    setState(() {
      _isSending = false;
    });
  });
}


  @override
  void dispose() {
    _chatService.removeListener(_receiveMessage);
    _chatService.disconnect();  // Disconnect WebSocket
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Bot"),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Additional actions like settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(
                  message: message['text'],
                  isUser: message['isUser'],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Message...',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

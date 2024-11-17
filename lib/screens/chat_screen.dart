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
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final userId =
        Provider.of<UserProvider>(context, listen: false).user?.userId;

    if (accessToken != null && userId != null) {
      _chatService = Provider.of<ChatService>(context, listen: false);
      _chatService.removeListener(_receiveMessage);
      await _chatService.connect(userId, accessToken);
      _chatService.addListener(_receiveMessage);
    } else {
      print("Access token or user ID not found. Cannot connect to chat.");
    }
  }

  void _sendMessage() {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      // Immediately add the message to the UI
      setState(() {
        _messages.add({
          'text': messageText,
          'isUser': true,
        });
      });

      _chatService.sendMessage(
          messageText); // This triggers _receiveMessage if a response comes back
      _messageController.clear();
    }

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _isSending = false;
      });
    });
  }

  void _receiveMessage() {
    final newMessage = _chatService.messages.last;

    // Only process the message if it's not a duplicate user message
    if (newMessage['sender'] != 'user') {
      setState(() {
        _messages.add({
          'text': newMessage['message'],
          'isUser': false, // Message is from bot
        });
      });
    }
  }

  Future<void> _logout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // Clear user info and WebSocket connection
    userProvider.clearUser();
    _chatService.disconnect();

    // Clear access token from shared preferences
    await prefs.remove('access_token');

    // Navigate to login screen, clearing navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void dispose() {
    _chatService.removeListener(_receiveMessage);
    _chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 980;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 39, 39, 39),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 255, 223, 0),
            title: const Text("HealthWise",
                style: TextStyle(color: const Color.fromARGB(255, 39, 39, 39))),
            actions: isLargeScreen
                ? null
                : [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/update");
                        },
                        child: Icon(Icons.person),
                      ),
                    ),
                  ],
          ),
          drawer: isLargeScreen ? null : _buildDrawer(),
          body: Row(
            children: [
              if (isLargeScreen)
                _buildDrawer(), // Show drawer as a side panel on large screens
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              _messages[_messages.length - 1 - index];
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 5,
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
            backgroundColor: Color.fromARGB(255, 255, 223, 0),
            child: IconButton(
              icon: Icon(Icons.send,
                  color: const Color.fromARGB(255, 39, 39, 39)),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 62, 62, 62),
      shape: LinearBorder(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.white,
            ),
            title: Text(
              'Your Profile',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // Navigate to Profile
              Navigator.pushNamed(context, "/profile");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.white,
            ),
            title: Text(
              'Image Analyzer',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // Navigate to Profile
              Navigator.pushNamed(context, "/image_analyzer");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
              color: Colors.white,
            ),
            title: Text('Chat History', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Chat History
              Navigator.pushNamed(context, '/chat_history');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            title: Text('Model Information',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Model Information
            },
          ),
          ListTile(
            leading: Icon(
              Icons.policy,
              color: Colors.white,
            ),
            title: Text('Usage Policy', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Usage Policy
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

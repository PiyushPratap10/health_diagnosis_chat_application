import 'package:flutter/material.dart';

class ChatHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chatHistory = [
    {'id': 1, 'preview': 'You mentioned headache...', 'timestamp': 'Today, 2:45 PM'},
    {'id': 2, 'preview': 'I have a fever...', 'timestamp': 'Yesterday, 5:12 PM'},
    {'id': 3, 'preview': 'Feeling dizzy...', 'timestamp': 'Nov 1, 11:30 AM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: chatHistory.length,
        itemBuilder: (context, index) {
          final chat = chatHistory[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(chat['preview']),
              subtitle: Text(chat['timestamp']),
              onTap: () {
                // Navigate to ChatScreen with chat ID or other context
                Navigator.pushNamed(context, '/chat', arguments: chat['id']);
              },
            ),
          );
        },
      ),
    );
  }
}

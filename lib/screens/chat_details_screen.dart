import 'package:flutter/material.dart';
import 'package:healthwise_ai/widgets/message_bubble.dart';

class ChatDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chatMessages;

  ChatDetailScreen({required this.chatMessages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color.fromARGB(255, 39, 39, 39),
      appBar: AppBar(title: Text("Chat Details",style: TextStyle(color: Color.fromARGB(255, 39, 39, 39)),),centerTitle: true,backgroundColor: Color.fromARGB(255, 255, 223, 0),),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        itemCount: chatMessages.length,
        itemBuilder: (context, index) {
          var userMessage = chatMessages[index]['user_message']['message'];
          var modelMessage = chatMessages[index]['model_response']['message'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 900), // Set max width to 900
                  child: MessageBubble(
                    message: userMessage,
                    isUser: true,
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 900), // Set max width to 900
                  child: MessageBubble(
                    message: modelMessage,
                    isUser: false,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

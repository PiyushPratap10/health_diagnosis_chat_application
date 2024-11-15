import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser; // true if the message is from the user, false if from the bot

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Color.fromARGB(255, 255, 223, 0) : const Color.fromARGB(255, 52, 52, 52),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isUser ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isUser ? Radius.circular(0) : Radius.circular(12),
          ),
        ),
        child: isUser? Text(
          message,
          style:const TextStyle(
            color: Color.fromARGB(255, 39, 39, 39),
            fontSize: 16,
          ),
        ):Text(
          message,
          style:const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

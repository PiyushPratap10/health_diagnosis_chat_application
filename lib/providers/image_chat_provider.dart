import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  void addMessage(String message, bool isUser) {
    _messages.add({"message": message, "isUser": isUser});
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
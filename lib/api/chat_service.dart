import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class ChatService with ChangeNotifier {
  late WebSocketChannel _channel;
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => _messages;

  void connect(String userId) {
    _channel = IOWebSocketChannel.connect('ws://your_backend_url_here/chat/$userId');
    _channel.stream.listen((message) {
      _messages.add({'sender': 'bot', 'message': message});
      notifyListeners();
    });
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
    _messages.add({'sender': 'user', 'message': message});
    notifyListeners();
  }

  void disconnect() {
    _channel.sink.close();
  }
}

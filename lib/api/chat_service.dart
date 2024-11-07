import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart' show IOWebSocketChannel;
import 'package:web_socket_channel/html.dart' show HtmlWebSocketChannel;
import 'package:flutter/material.dart';

class ChatService with ChangeNotifier {
  WebSocketChannel? _channel;
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => _messages;

  // Connect to WebSocket for chat with access token
  Future<void> connect(String userId, String accessToken) async {
    final url = 'ws://127.0.0.1:8000/ws/chat/$userId/$accessToken';

    // Check if running on web
    if (kIsWeb) {
      // Use HtmlWebSocketChannel for Flutter Web
      _channel = HtmlWebSocketChannel.connect(url);
    } else {
      // Use IOWebSocketChannel for mobile/desktop platforms
      _channel = IOWebSocketChannel.connect(url);
    }

    _channel!.stream.listen((message) {
      _messages.add({'sender': 'bot', 'message': message});
      notifyListeners();
    });
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
      _messages.add({'sender': 'user', 'message': message});
      notifyListeners();
    } else {
      print("WebSocket channel is not connected. Message not sent.");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;  // Reset the channel
  }
}

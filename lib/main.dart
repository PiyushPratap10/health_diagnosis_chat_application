import 'package:flutter/material.dart';
import 'package:healthwise_ai/api/chat_service.dart';
import 'package:healthwise_ai/providers/image_chat_provider.dart';
import 'package:healthwise_ai/screens/image_analysis_screen.dart';
import 'package:healthwise_ai/screens/profile_view_screen.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_history_screen.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (context)=> ChatService(),),
        ChangeNotifierProvider(create: (context)=> ChatProvider(),)
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Diagnosis Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        brightness: Brightness.light,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/chat': (context) => ChatScreen(),
        '/profile': (context) => ProfileViewScreen(),
        '/update': (context) => ProfileUpdateScreen(),
        '/chat_history': (context) => ChatListScreen(),
        '/image_analyzer': (context) => ImageAnalysisScreen(),
      },
    );
  }
}

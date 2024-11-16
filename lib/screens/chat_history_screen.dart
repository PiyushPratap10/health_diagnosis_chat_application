import 'package:flutter/material.dart';
import 'package:healthwise_ai/api/api_service.dart';
import 'package:healthwise_ai/providers/user_provider.dart';
import 'package:healthwise_ai/screens/chat_details_screen.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> nonEmptyChats = [];
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchUserChats();
  }

  Future<void> fetchUserChats() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.userId;
      if (userId == null) {
        return;
      }
      final response = await apiService.getUserChats(userId);
      if (response != null) {
        final List chatData = response['messages'];

        setState(() {
          nonEmptyChats = chatData.where((chat) => chat.isNotEmpty).toList();
        });
      }
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 39, 39, 39) ,
      appBar: AppBar(title: const Text('Chat History',style: TextStyle(color: Color.fromARGB(255, 39, 39, 39)),),centerTitle: true,backgroundColor: Color.fromARGB(255, 255, 223, 0),),
      body: nonEmptyChats.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 255, 223, 0),))
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding from top and bottom
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListView.builder(
                    itemCount: nonEmptyChats.length,
                    itemBuilder: (context, index) {
                      var firstModelMessage = nonEmptyChats[index][0]['model_response']['message'];
                      var firstModelTimestamp = nonEmptyChats[index][0]['model_response']['timestamp'];
                      var formattedDate = DateTime.parse(firstModelTimestamp).toLocal();

                      return Center(
                        child: ConstrainedBox(
                          constraints:const BoxConstraints(
                            maxWidth: 700, // Maximum width constraint
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                firstModelMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(formattedDate.toString()),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailScreen(
                                      chatMessages: List<Map<String, dynamic>>.from(nonEmptyChats[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

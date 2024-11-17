import 'package:flutter/material.dart';
import 'package:healthwise_ai/providers/image_chat_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:healthwise_ai/api/api_service.dart';
import 'package:healthwise_ai/widgets/message_bubble.dart';

class ImageAnalysisScreen extends StatefulWidget {
  @override
  _ImageAnalysisScreenState createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _pickAndAnalyzeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageName = pickedFile.name;

      // Add the image name as a user message
      Provider.of<ChatProvider>(context, listen: false).addMessage(imageName, true);

      // Call the API to analyze the image
      String? result = await _apiService.analyzeImage(pickedFile);

      // Add the model response as a bot message
      Provider.of<ChatProvider>(context, listen: false).addMessage(result ?? "No result", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      appBar: AppBar(
        title: const Text(
          'Image Analysis',
          style: TextStyle(color: Color.fromARGB(255, 39, 39, 39)),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 223, 0),
      ),
      body: Center(
        child: Container(
          width: 900,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    return ListView.builder(
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final messageData = chatProvider.messages[index];
                        return MessageBubble(
                          message: messageData["message"],
                          isUser: messageData["isUser"],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _pickAndAnalyzeImage,
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      width: 2,
                      color: Color.fromARGB(255, 255, 223, 0)
                    ),
                  ),
                  child: const Text(
                    "Upload Image for Analysis",
                    style: TextStyle(color: Color.fromARGB(255, 39, 39, 39)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

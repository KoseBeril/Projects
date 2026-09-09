import 'package:flutter/material.dart';
import 'api_service.dart';

// Api instance
final ApiService apiService = ApiService();

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: İleride Render'dan geçmiş sohbetleri çekmek için bir rota eklenebilir - iyileştirme.
    // Şimdilik boş.
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    final userText = text;
    setState(() {
      _messages.add({'text': userText, 'isUser': 1});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Flask API'den yanıtı al 
      String botResponse = await apiService.getChatReply(userText);
      
      setState(() {
        _messages.add({'text': botResponse, 'isUser': 0});
      });
    } catch (e) {
      setState(() {
        _messages.add({'text': "Cannot connect to server. Please try again.", 'isUser': 0});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plant AI Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                bool isUser = _messages[i]['isUser'] == 1;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Color(0xFF2D5A27) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[i]['text'],
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) LinearProgressIndicator(), // Yükleniyor barı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Ask a question..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF2D5A27)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
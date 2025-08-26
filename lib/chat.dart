import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LlmChatScreen extends StatefulWidget {
  const LlmChatScreen({super.key});

  @override
  _LlmChatScreenState createState() => _LlmChatScreenState();
}

class _LlmChatScreenState extends State<LlmChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {role: "user"/"ai", text: "message"}

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
    });
    _controller.clear();

    // Fake LLM response (replace with your API call)
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _messages.add({"role": "ai", "text": "This is a mock AI response to: $text"});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40,),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton(onPressed: (){
            FirebaseAuth.instance.signOut();
          }, child: Text("Logout")), SizedBox(width: 10,)]),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple.shade200 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg["text"] ?? ""),
                  ),
                );
              },
            ),
          ),

          // Input box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.grey.shade200),
              padding: EdgeInsets.fromLTRB(30, 6, 10, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask me anything...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

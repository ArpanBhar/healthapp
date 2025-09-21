import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LlmChatScreen extends StatefulWidget {
  const LlmChatScreen({super.key});

  @override
  _LlmChatScreenState createState() => _LlmChatScreenState();
}

class _LlmChatScreenState extends State<LlmChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<Map<String, dynamic>?> response(
    BuildContext context,
    String text,
  ) async {
    const apiKey = "AIzaSyAtKBs-tRVZZp4I42owbsnPg59kKX1Snjc";
    const url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

    final headers = {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey,
    };

    final body = jsonEncode({
      "system_instruction": {
    "parts": [
      {"text": "You are a healthcare assistant, your name is Erika, your job is to ask for relevant information like symptoms from a patient. Don't list out duplicate symptoms in the symptoms array. Probe the patient to extract details of further symptoms"}
    ]
  },
  "contents":  _messages.map((message) {
  return {
    'role': message['role'],
    'parts': [{'text': message['text']}]
  };
}).toList(),
  "generationConfig": {
    "responseMimeType": "application/json",
    "responseSchema": {
      "type": "OBJECT",
      "properties": {
        "response": {"type": "STRING"},
        "symptoms": {
          "type": "ARRAY",
          "items": {"type": "STRING"}
        }
      },
      "required": ["response", "symptoms"]
    }
  }
});

    try {
      final res = await http.post(Uri.parse(url), headers: headers, body: body);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return jsonDecode(data['candidates'][0]['content']['parts'][0]['text']);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${res.body}")));
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Request failed: $e")));
      return null;
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
    });
    _controller.clear();
    final msg = await response(context, text);

    if (msg != null) {
      FirebaseFirestore.instance
    .collection('userData')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .set({
      'symptoms': msg['symptoms']
    },SetOptions(merge: true));
      setState(() {
      _messages.add({
        "role": "model",
        "text": msg["response"].toString(),
      });
    });
    }
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
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Text("Logout"),
              ),
              SizedBox(width: 10),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.deepPurple.shade200
                          : Colors.grey.shade300,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey.shade200,
              ),
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

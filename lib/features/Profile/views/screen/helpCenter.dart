import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maasapp/core/widgets/AppBar/appBar.dart';
import 'package:maasapp/core/widgets/sideBar.dart';

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Arabni'),
      drawer: CommonSideBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'How can we help you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            FAQSection(),
            SizedBox(height: 32),
            ChatbotSection(),
          ],
        ),
      ),
    );
  }
}

class FAQSection extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How to use Arabni app?',
      'answer':
          'You can use Arabni app by signing up, searching for routes, and planning your trips with ease.',
    },
    {
      'question': 'How to reset my password?',
      'answer':
          'Go to the login screen, click on "Forgot Password" and follow the instructions to reset your password.',
    },
    {
      'question': 'How to contact customer support?',
      'answer':
          'You can contact customer support by emailing support@arabni.com.',
    },
    // Add more FAQs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...faqs.map((faq) {
          return ExpansionTile(
            title: Text(faq['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(faq['answer']!),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}

class ChatbotSection extends StatefulWidget {
  @override
  _ChatbotSectionState createState() => _ChatbotSectionState();
}

class _ChatbotSectionState extends State<ChatbotSection> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> messages = [];

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'message': message});
        messages.add({
          'sender': 'bot',
          'message': 'This is a bot response.'
        }); // Simulate bot response
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chat with us',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ListTile(
                title: Align(
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user'
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                          color: message['sender'] == 'user'
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HelpCenterScreen(),
  ));
}

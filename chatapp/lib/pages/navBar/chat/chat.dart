import 'dart:convert';

import 'package:chatapp/pages/navBar/chat/conversation.dart';
import 'package:chatapp/pages/navBar/chat/newDM.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<dynamic> conversations = [];

  Future<void> _getConversations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse('$serverURL/api/dm/getConversations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    print(response.body);

    if (response.statusCode == 200 && mounted) {
      setState(() {
        conversations = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Direct Message"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const NewDM()));
                },
                icon: const Icon(
                  Icons.add,
                  size: 32,
                ))
          ],
        ),
        body: ListView(
          children: conversations.map((conversation) {
            if (conversation['type'] == 'DM') {
              return ConversationTile(
                name: conversation['members'][0]['displayName'],
                image: conversation['members'][0]['profilePic'],
                convoId: conversation['_id'],
              );
            } else {
              return ConversationTile(
                name: conversation['name'],
                image: conversation['image'],
                convoId: conversation['_id'],
              );
            }
          }).toList(),
        ));
  }
}

class ConversationTile extends StatelessWidget {
  final String name;
  final String image;
  final String convoId;
  const ConversationTile(
      {super.key,
      required this.name,
      required this.image,
      required this.convoId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConversationPage(conversationId: convoId)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image(
                  image: NetworkImage('$serverURL/api/$image'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(name)
          ],
        ),
      ),
    );
  }
}

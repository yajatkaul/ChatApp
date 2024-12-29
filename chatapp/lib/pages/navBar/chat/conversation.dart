import 'dart:convert';

import 'package:chatapp/components/MessageBubbles.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConversationPage extends StatefulWidget {
  final String conversationId;
  const ConversationPage({super.key, required this.conversationId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<dynamic> messages = [];
  late String userId;

  final _messageController = TextEditingController();

  Future<void> _getMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final response = await http.get(
      Uri.parse(
          '$serverURL/api/dm/getMessages?conversationId=${widget.conversationId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    if (response.statusCode == 200 && mounted) {
      setState(() {
        messages = jsonDecode(response.body)['messages'];
        userId = jsonDecode(response.body)['userId'];
      });
    }
  }

  Future<void> _sendMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final response = await http.post(
        Uri.parse(
            '$serverURL/api/dm/sendMessage?conversationId=${widget.conversationId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': sessionCookie!,
        },
        body: jsonEncode({"message": _messageController.text}));

    if (response.statusCode == 200) {
      _messageController.text = '';
    }
  }

  Future<void> _socketConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionCookie = prefs.getString('session_cookie');

    final id = await http.get(
      Uri.parse('$serverURL/api/user/getId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': sessionCookie!,
      },
    );

    String userId = id.body; // Extract the raw response body

// Check if the response contains quotes and remove them
    if (userId.startsWith('"') && userId.endsWith('"')) {
      userId = userId.substring(1, userId.length - 1);
    }

    IO.Socket socket = IO.io(
        serverURL,
        IO.OptionBuilder()
            .setTransports(['websocket']).setQuery({'userId': userId}).build());

    socket.connect();

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.on("newMessage", (message) {
      print(message);
      setState(() {
        messages.add(message);
      });
    });

    // Connection error
    socket.onConnectError((data) {
      print('Connection error: $data');
    });

    // Disconnect
    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  @override
  void initState() {
    super.initState();
    _getMessages();
    _socketConnection();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              children: messages.map((message) {
                if (message['_id'] == userId) {
                  return MessageSent(
                    message: message['message'],
                  );
                } else {
                  return MessageRecieved(
                    message: message['message'],
                  );
                }
              }).toList(),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type a message',
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: _sendMessage, child: const Text("Click"))
              ],
            ),
          )
        ],
      ),
    );
  }
}

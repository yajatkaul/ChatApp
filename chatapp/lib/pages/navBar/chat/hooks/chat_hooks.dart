import 'dart:convert';

import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChatHooks {
  Future<List<dynamic>> getMessages(
      BuildContext context, String convoId) async {
    final response = await http.get(
      Uri.parse('$serverURL/api/dm/getMessages?conversationId=$convoId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie':
            Provider.of<UserProvider>(context, listen: false).sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['messages'];
    } else {
      return [];
    }
  }

  Future<void> sendMessages(BuildContext context, String convoId,
      TextEditingController _messageController) async {
    final response = await http.post(
        Uri.parse('$serverURL/api/dm/sendMessage?conversationId=$convoId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie':
              Provider.of<UserProvider>(context, listen: false).sessionCookie!,
        },
        body: jsonEncode({"message": _messageController.text}));

    if (response.statusCode == 200) {
      _messageController.text = '';
    }
  }
}

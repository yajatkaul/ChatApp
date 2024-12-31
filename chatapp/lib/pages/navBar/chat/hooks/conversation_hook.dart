import 'dart:convert';

import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ConversationHook {
  Future<List<dynamic>> getConversations(BuildContext context) async {
    final response = await http.get(
      Uri.parse('$serverURL/api/dm/getConversations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie':
            Provider.of<UserProvider>(context, listen: false).sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}

import 'dart:convert';

import 'package:chatapp/pages/navBar/chat/conversation.dart';
import 'package:chatapp/providers/dm_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NewDM extends StatefulWidget {
  const NewDM({super.key});

  @override
  State<NewDM> createState() => _NewDMState();
}

class _NewDMState extends State<NewDM> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<DmProvider>(context, listen: false).getAllUsers(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
      ),
      body: ListView(
        children: Provider.of<DmProvider>(context).all_users.map((user) {
          return SizedBox(
            height: 80,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? sessionCookie = prefs.getString('session_cookie');

                final response = await http.get(
                  Uri.parse(
                      "$serverURL/api/dm/createConversation?userId=${user['_id']}"),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Cookie': sessionCookie!,
                  },
                );

                if (response.statusCode == 200) {
                  final responseBody = jsonDecode(response.body);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ConversationPage(
                                conversationId: responseBody['id'],
                              )));
                } else {
                  print(response.body);
                }
              },
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: Image(
                          image: NetworkImage(user['profilePic'] == null
                              ? 'https://play-lh.googleusercontent.com/z-ppwF62-FuXHMO7q20rrBMZeOnHfx1t9UPkUqtyouuGW7WbeUZECmyeNHAus2Jcxw=w526-h296-rw'
                              : '$serverURL/api/${user['profilePic']}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      user['displayName'],
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

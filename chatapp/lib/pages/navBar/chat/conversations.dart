import 'dart:convert';

import 'package:chatapp/pages/navBar/chat/chat.dart';
import 'package:chatapp/pages/navBar/chat/hooks/conversationHook.dart';
import 'package:chatapp/pages/navBar/chat/newDM.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<dynamic> conversations = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    conversations = await ConversationHook().getConversations(context);
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
          children: [
            ...conversations.map((conversation) {
              if (conversation['type'] == 'DM') {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ConversationTile(
                    name: conversation['members'][0]['displayName'],
                    image: conversation['members'][0]['profilePic'],
                    convoId: conversation['_id'],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ConversationTile(
                    name: conversation['name'],
                    image: conversation['image'],
                    convoId: conversation['_id'],
                  ),
                );
              }
            }),
          ],
        ));
  }
}

class ConversationTile extends StatelessWidget {
  final String name;
  final String? image;
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
                  image: NetworkImage(image == null
                      ? 'https://play-lh.googleusercontent.com/z-ppwF62-FuXHMO7q20rrBMZeOnHfx1t9UPkUqtyouuGW7WbeUZECmyeNHAus2Jcxw=w526-h296-rw'
                      : '$serverURL/api/$image'),
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

import 'package:chatapp/pages/navBar/chat/newDM.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

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
        body: const Text("Chat"));
  }
}

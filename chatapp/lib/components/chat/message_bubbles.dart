import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageSent extends StatelessWidget {
  final String message;
  const MessageSent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatBubble(
          clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(top: 20),
          backGroundColor: Colors.blue,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image.network(
                Provider.of<UserProvider>(context).profilePic == null
                    ? defaultImage
                    : Provider.of<UserProvider>(context).profilePic!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )),
      ],
    );
  }
}

class MessageRecieved extends StatelessWidget {
  final String message;
  final String? profilePic;
  const MessageRecieved(
      {super.key, required this.message, required this.profilePic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image.network(
                profilePic == null ? defaultImage : profilePic!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )),
        ChatBubble(
          clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
          backGroundColor: const Color(0xffE7E7ED),
          margin: const EdgeInsets.only(top: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}

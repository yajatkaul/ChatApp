import 'package:chatapp/utils/env.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MessageRecieved extends StatelessWidget {
  final String message;
  const MessageRecieved({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
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
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Image(
              image: NetworkImage('https://i.sstatic.net/DHtN3m.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class MessageSent extends StatelessWidget {
  final String message;
  const MessageSent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Image(
              image: NetworkImage('https://i.sstatic.net/DHtN3m.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
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

class ImageSent extends StatelessWidget {
  final String image;
  const ImageSent({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Image(
              image: NetworkImage('https://i.sstatic.net/DHtN3m.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        ChatBubble(
          clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
          backGroundColor: const Color(0xffE7E7ED),
          margin: const EdgeInsets.only(top: 20),
          child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Image(image: NetworkImage("$serverURL/api/$image"))),
        ),
      ],
    );
  }
}

class ImageRecieved extends StatelessWidget {
  final String image;
  const ImageRecieved({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Image(image: NetworkImage("$serverURL/api/$image"))),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Image(
              image: NetworkImage('https://i.sstatic.net/DHtN3m.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class VideoSent extends StatefulWidget {
  final String video;
  const VideoSent({super.key, required this.video});

  @override
  State<VideoSent> createState() => _VideoSentState();
}

class _VideoSentState extends State<VideoSent> {
  late final player = Player();
  late final _controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(
      '$serverURL/api/${widget.video}',
      httpHeaders: {
        'Foo': 'Bar',
        'Accept': '*/*',
      },
    ));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Image(
              image: NetworkImage('https://i.sstatic.net/DHtN3m.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        ChatBubble(
            clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
            backGroundColor: const Color(0xffE7E7ED),
            margin: const EdgeInsets.only(top: 20),
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: SizedBox(child: Video(controller: _controller))))
      ],
    );
  }
}

class VideoRecieved extends StatelessWidget {
  final String image;
  const VideoRecieved({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Image(image: NetworkImage("$serverURL/api/$image"))),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: const SizedBox(
            height: 50,
            width: 50,
            child: Image(
              image: NetworkImage('https://i.sstatic.net/DHtN3m.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

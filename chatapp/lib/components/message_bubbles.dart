import 'package:chatapp/utils/env.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

class MessageRecieved extends StatelessWidget {
  final String message;
  const MessageRecieved({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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

class ImageRecieved extends StatelessWidget {
  final String image;
  const ImageRecieved({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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

class ImageSent extends StatelessWidget {
  final String image;
  const ImageSent({super.key, required this.image});

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

class VideoRecieved extends StatefulWidget {
  final String video;
  const VideoRecieved({super.key, required this.video});

  @override
  State<VideoRecieved> createState() => _VideoRecievedState();
}

class _VideoRecievedState extends State<VideoRecieved> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('$serverURL/api/${widget.video}'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
                          onTap: () {
                            _controller.play();
                          },
                          child: VideoPlayer(_controller)),
                    )
                  : Container(),
            ))
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
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('$serverURL/api/${widget.video}'))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: GestureDetector(
                        onTap: () {
                          _controller.play();
                        },
                        child: VideoPlayer(_controller)),
                  )
                : Container(),
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

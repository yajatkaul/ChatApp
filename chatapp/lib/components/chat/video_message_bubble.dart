import 'dart:async';

import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoSent extends StatefulWidget {
  final String video;
  final String convoId;
  final String messageId;
  const VideoSent(
      {super.key,
      required this.video,
      required this.convoId,
      required this.messageId});

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

  void _showVideoOverlay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => VideoFullscreenPage(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              height: 200,
              width: 200,
              child: _controller.value.isInitialized
                  ? SizedBox(
                      height: 200,
                      width: 200,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Message Options"),
                                  content: SizedBox(
                                    height: 50,
                                    child: Column(
                                      children: [
                                        TextButton(
                                            onPressed: () async {
                                              await ChatHooks().deleteMessage(
                                                  context,
                                                  widget.messageId,
                                                  widget.convoId);
                                              Navigator.of(context).pop();
                                            },
                                            child:
                                                const Text("Unsend Message")),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          onTap: _showVideoOverlay,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller),
                              Icon(
                                Icons.play_circle_outline,
                                size: 50,
                                color: Colors.white.withValues(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image.network(
                Provider.of<UserProvider>(context).profilePic ?? defaultImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoRecieved extends StatefulWidget {
  final String video;
  final String? profilePic;
  const VideoRecieved(
      {super.key, required this.video, required this.profilePic});

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
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showVideoOverlay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => VideoFullscreenPage(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                height: 40,
                width: 40,
                child: Image.network(
                  widget.profilePic == null ? defaultImage : widget.profilePic!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )),
          const SizedBox(
            width: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              width: 200,
              height: 200,
              child: _controller.value.isInitialized
                  ? SizedBox(
                      height: 200,
                      width: 200,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: GestureDetector(
                          onTap: () {
                            _showVideoOverlay();
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller),
                              Icon(
                                Icons.play_circle_outline,
                                size: 50,
                                color: Colors.white.withValues(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          )
        ],
      ),
    );
  }
}

class VideoFullscreenPage extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoFullscreenPage({
    super.key,
    required this.controller,
  });

  @override
  State<VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<VideoFullscreenPage> {
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
    // Enable full screen
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    // Reset to portrait orientation when leaving fullscreen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Restore system UI
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (!_isDragging) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_isDragging) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          if (_showControls) {
            _startHideControlsTimer();
          }
        },
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            if (_showControls)
              Container(
                color: Colors.black26,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              widget.controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                widget.controller.value.isPlaying
                                    ? widget.controller.pause()
                                    : widget.controller.play();
                              });
                              _startHideControlsTimer();
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ValueListenableBuilder(
                          valueListenable: widget.controller,
                          builder: (context, VideoPlayerValue value, child) {
                            return Row(
                              children: [
                                Text(
                                  _formatDuration(value.position),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: value.position.inMilliseconds
                                        .toDouble(),
                                    min: 0.0,
                                    max: value.duration.inMilliseconds
                                        .toDouble(),
                                    onChanged: (double position) {
                                      widget.controller.seekTo(Duration(
                                          milliseconds: position.toInt()));
                                    },
                                    onChangeStart: (_) {
                                      _isDragging = true;
                                      setState(() {
                                        _showControls = true;
                                      });
                                    },
                                    onChangeEnd: (_) {
                                      _isDragging = false;
                                      _startHideControlsTimer();
                                    },
                                  ),
                                ),
                                Text(
                                  _formatDuration(value.duration),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:voice_message_package/voice_message_package.dart';

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
              height: 50,
              width: 50,
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

class VMSent extends StatelessWidget {
  final String vm;
  const VMSent({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: VoiceMessageView(
                circlesColor: Colors.blue,
                activeSliderColor: Colors.blue,
                controller: VoiceController(
                  audioSrc: '$serverURL/api/$vm',
                  onComplete: () {
                    /// do something on complete
                  },
                  onPause: () {
                    /// do something on pause
                  },
                  onPlaying: () {
                    /// do something on playing
                  },
                  onError: (err) {
                    /// do somethin on error
                  },
                  maxDuration: const Duration(seconds: 5000),
                  isFile: false,
                ),
                innerPadding: 12,
                cornerRadius: 20,
              )),
          const SizedBox(
            width: 10,
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                height: 50,
                width: 50,
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
      ),
    );
  }
}

class VMRecieved extends StatelessWidget {
  final String vm;
  final String? profilePic;
  const VMRecieved({super.key, required this.vm, required this.profilePic});

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
                height: 50,
                width: 50,
                child: Image.network(
                  profilePic == null ? defaultImage : profilePic!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )),
          const SizedBox(
            width: 10,
          ),
          Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: VoiceMessageView(
                circlesColor: Colors.black,
                activeSliderColor: Colors.black,
                controller: VoiceController(
                  audioSrc: '$serverURL/api/$vm',
                  onComplete: () {
                    /// do something on complete
                  },
                  onPause: () {
                    /// do something on pause
                  },
                  onPlaying: () {
                    /// do something on playing
                  },
                  onError: (err) {
                    /// do somethin on error
                  },
                  maxDuration: const Duration(seconds: 5000),
                  isFile: false,
                ),
                innerPadding: 12,
                cornerRadius: 20,
              )),
        ],
      ),
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
              height: 50,
              width: 50,
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

class ImageReceived extends StatelessWidget {
  final String image;
  final String? profilePic;
  const ImageReceived(
      {super.key, required this.image, required this.profilePic});

  void _showFullscreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullscreenImageViewer(
          imageUrl: "$serverURL/api/$image",
        ),
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
              height: 50,
              width: 50,
              child: Image.network(
                profilePic ?? defaultImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showFullscreenImage(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Image(image: NetworkImage("$serverURL/api/$image")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
    // Enable full screen and hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      // If zoomed in, zoom out
      _controller.value = Matrix4.identity();
    } else {
      // If zoomed out, zoom in
      final position = _doubleTapDetails!.localPosition;
      const double scale = 3.0;
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);
      final zoomed = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
      _controller.value = zoomed;
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image with zoom
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Close button
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ImageSent extends StatelessWidget {
  final String image;
  const ImageSent({super.key, required this.image});

  void _showFullscreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullscreenImageViewer(
          imageUrl: "$serverURL/api/$image",
        ),
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
          GestureDetector(
            onTap: () => _showFullscreenImage(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Image(image: NetworkImage("$serverURL/api/$image")),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 50,
              width: 50,
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
                height: 50,
                width: 50,
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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: _controller.value.isInitialized
                  ? AspectRatio(
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
                    )
                  : Container(),
            ),
          )
        ],
      ),
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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
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
                    )
                  : Container(),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 50,
              width: 50,
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    // Reset to portrait orientation when leaving fullscreen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

import 'dart:async';

import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:provider/provider.dart';

class ImageSent extends StatelessWidget {
  final String image;
  final String convoId;
  final String messageId;
  const ImageSent(
      {super.key,
      required this.image,
      required this.convoId,
      required this.messageId});

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
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Message Options"),
                    content: SizedBox(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton(
                              onPressed: () async {
                                await ChatHooks()
                                    .deleteMessage(context, messageId, convoId);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Unsend Message")),
                          TextButton(
                              onPressed: () async {
                                final url = '$serverURL/api/$image';
                                final dl = DownloadManager();
                                dl.addDownload(url,
                                    "$androidDownloadLocation/${dl.getFileNameFromUrl(url)}");

                                DownloadTask? task = dl.getDownload(url);

                                await task?.whenDownloadComplete();

                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Downloaded")));

                                Navigator.of(context).pop();
                              },
                              child: const Text("Download")),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image(
                  image: NetworkImage("$serverURL/api/$image"),
                  fit: BoxFit.cover,
                ),
              ),
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
              height: 40,
              width: 40,
              child: Image.network(
                profilePic != null
                    ? '$serverURL/api/$profilePic'
                    : defaultImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 200,
            height: 200,
            child: GestureDetector(
              onTap: () => _showFullscreenImage(context),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Message Options"),
                      content: SizedBox(
                        height: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  final url = '$serverURL/api/$image';
                                  final dl = DownloadManager();
                                  dl.addDownload(url,
                                      "$androidDownloadLocation/${dl.getFileNameFromUrl(url)}");

                                  DownloadTask? task = dl.getDownload(url);

                                  await task?.whenDownloadComplete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Downloaded")));

                                  Navigator.of(context).pop();
                                },
                                child: const Text("Download")),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image(
                    image: NetworkImage("$serverURL/api/$image"),
                    fit: BoxFit.cover,
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
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    // Restore system UI
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

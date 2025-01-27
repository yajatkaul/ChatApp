import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:provider/provider.dart';
import 'package:voice_message_package/voice_message_package.dart';

class VMSent extends StatelessWidget {
  final String vm;
  final String convoId;
  final String messageId;
  const VMSent(
      {super.key,
      required this.vm,
      required this.convoId,
      required this.messageId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
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
                                final url = '$serverURL/api/$vm';
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
            child: Container(
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
          ),
          const SizedBox(
            width: 10,
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
                height: 40,
                width: 40,
                child: Image.network(
                  profilePic == null
                      ? defaultImage
                      : '$serverURL/api/$profilePic',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
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
                                final url = '$serverURL/api/$vm';
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
            child: Container(
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
          ),
        ],
      ),
    );
  }
}

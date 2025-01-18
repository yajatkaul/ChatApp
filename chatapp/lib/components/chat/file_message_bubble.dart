import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:provider/provider.dart';

class FileSent extends StatelessWidget {
  final String file;
  final String convoId;
  final String messageId;
  const FileSent(
      {super.key,
      required this.file,
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
                                final url = '$serverURL/api/$file';
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
            child: ChatBubble(
              clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(top: 10),
              backGroundColor: Colors.blue,
              child: Container(
                  height: 60,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_copy),
                      Text(DownloadManager()
                          .getFileNameFromUrl('$serverURL/api/$file'))
                    ],
                  )),
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
      ),
    );
  }
}

class FileReceived extends StatelessWidget {
  final String file;
  final String messageId;
  const FileReceived({super.key, required this.file, required this.messageId});

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
                  Provider.of<UserProvider>(context).profilePic == null
                      ? defaultImage
                      : Provider.of<UserProvider>(context).profilePic!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )),
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
                                final url = '$serverURL/api/$file';
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
            child: ChatBubble(
              clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
              backGroundColor: const Color(0xffE7E7ED),
              margin: const EdgeInsets.only(top: 10),
              child: Container(
                  height: 60,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_copy),
                      Text(DownloadManager()
                          .getFileNameFromUrl('$serverURL/api/$file'))
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

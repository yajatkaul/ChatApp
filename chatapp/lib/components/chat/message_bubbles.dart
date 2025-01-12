import 'package:any_link_preview/any_link_preview.dart';
import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

class MessageSent extends StatelessWidget {
  final String convoId;
  final String messageId;
  final String message;
  const MessageSent(
      {super.key,
      required this.message,
      required this.messageId,
      required this.convoId});

  @override
  Widget build(BuildContext context) {
    // Regular expression to find links in the message
    final RegExp linkRegExp = RegExp(
      r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
    );
    final String? link = linkRegExp.firstMatch(message)?.group(0);
    if (link != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Message Options"),
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          TextButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: message));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied Message"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text("Copy Message")),
                          TextButton(
                              onPressed: () {},
                              child: const Text("Edit Message")),
                          TextButton(
                              onPressed: () async {
                                await ChatHooks()
                                    .deleteMessage(context, messageId, convoId);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Unsend Message")),
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
              margin: const EdgeInsets.only(top: 20),
              backGroundColor: Colors.blue,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (AnyLinkPreview.isValidLink(link))
                          AnyLinkPreview(
                            link: link,
                            displayDirection: UIDirection.uiDirectionVertical,
                            showMultimedia: true,
                            bodyMaxLines: 5,
                            bodyTextOverflow: TextOverflow.ellipsis,
                            titleStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            bodyStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            errorBody: 'Could not load preview',
                            errorTitle: 'Error',
                            errorWidget: Container(
                              color: Colors.grey[300],
                              child: const Text('Oops!'),
                            ),
                            cache: const Duration(days: 7),
                            backgroundColor: Colors.grey[300],
                            borderRadius: 12,
                            removeElevation: false,
                            onTap: () => launchUrl(Uri.parse(link)),
                          ),
                        MarkdownBody(
                          data: message,
                          onTapLink: (text, href, title) =>
                              launchUrl(Uri.parse(href!)),
                          styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.white),
                              a: const TextStyle(
                                  color: Color.fromARGB(255, 179, 202, 243))),
                          builders: {
                            "code": CodeBuilder(context),
                          },
                        ),
                      ]),
                ),
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
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Message Options"),
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          TextButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: message));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied Message"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text("Copy Message")),
                          TextButton(
                              onPressed: () {},
                              child: const Text("Edit Message")),
                          TextButton(
                              onPressed: () async {
                                await ChatHooks()
                                    .deleteMessage(context, messageId, convoId);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Unsend Message")),
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
              margin: const EdgeInsets.only(top: 20),
              backGroundColor: Colors.blue,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: MarkdownBody(
                    data: message,
                    onTapLink: (text, href, title) =>
                        launchUrl(Uri.parse(href!)),
                    styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.white),
                        a: const TextStyle(
                            color: Color.fromARGB(255, 179, 202, 243))),
                    builders: {
                      "code": CodeBuilder(context),
                    },
                  ),
                ),
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
}

class CodeBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Material(
      // Wrap with Material to handle tap properly
      color: Colors.transparent,
      child: InkWell(
        // Using InkWell instead of GestureDetector
        onTap: () {
          final String codeText = element.textContent;
          Clipboard.setData(ClipboardData(text: codeText)).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code copied to clipboard')),
            );
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            element.textContent,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
        ),
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
    // Regular expression to find links in the message
    final RegExp linkRegExp = RegExp(
      r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
    );
    final String? link = linkRegExp.firstMatch(message)?.group(0);

    if (link != null) {
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
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
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: message));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied Message"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text("Copy Message")),
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
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (AnyLinkPreview.isValidLink(link))
                        AnyLinkPreview(
                          link: link,
                          displayDirection: UIDirection.uiDirectionVertical,
                          showMultimedia: true,
                          bodyMaxLines: 5,
                          bodyTextOverflow: TextOverflow.ellipsis,
                          titleStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          bodyStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          errorBody: 'Could not load preview',
                          errorTitle: 'Error',
                          errorWidget: Container(
                            color: Colors.grey[300],
                            child: const Text('Oops!'),
                          ),
                          cache: const Duration(days: 7),
                          backgroundColor: Colors.grey[300],
                          borderRadius: 12,
                          removeElevation: false,
                          onTap: () => launchUrl(Uri.parse(link)),
                        ),
                      MarkdownBody(
                        data: message,
                        builders: {
                          "code": CodeBuilder(context),
                        },
                        onTapLink: (text, href, title) =>
                            launchUrl(Uri.parse(href!)),
                        styleSheet: MarkdownStyleSheet(
                            a: const TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
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
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: message));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied Message"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text("Copy Message")),
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
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: MarkdownBody(
                    data: message,
                    builders: {
                      "code": CodeBuilder(context),
                    },
                    styleSheet: MarkdownStyleSheet(
                        a: const TextStyle(
                            color: Color.fromARGB(255, 179, 202, 243))),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

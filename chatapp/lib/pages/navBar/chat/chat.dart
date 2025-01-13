import 'dart:async';

import 'package:chatapp/components/chat/image_message_bubble.dart';
import 'package:chatapp/components/chat/map_message_bubble.dart';
import 'package:chatapp/components/chat/message_bubbles.dart';
import 'package:chatapp/components/chat/video_message_bubble.dart';
import 'package:chatapp/components/chat/vm_message_bubbles.dart';
import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:provider/provider.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String? profilePic;
  const ConversationPage(
      {super.key,
      required this.conversationId,
      required this.profilePic,
      required this.userName});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<dynamic> messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Map<String, dynamic> _replyMessage = {};
  final FocusNode _focusNode = FocusNode();
  io.Socket? socket;

  Future<void> _socketConnection() async {
    socket = io.io(
        serverURL,
        io.OptionBuilder().setTransports(['websocket']).setQuery({
          'userId': Provider.of<UserProvider>(context, listen: false).id
        }).build());

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint('Connected to server');
    });

    socket!.on("newMessage", (message) {
      if (message['conversationId'] == widget.conversationId) {
        setState(() {
          messages.add(message);
        });
        _scrollToBottom();
      }
    });

    socket!.on("deleteMessage", (message) {
      if (message['convoId'] == widget.conversationId) {
        int indexToRemove = messages.indexWhere(
            (chatMessage) => chatMessage['_id'] == message['messageId']);

        if (indexToRemove != -1) {
          setState(() {
            messages.removeAt(indexToRemove);
          });
        }
      }
    });

    // Connection error
    socket!.onConnectError((data) {
      _socketConnection();
      debugPrint('Connection error: $data');
    });

    // Disconnect
    socket!.onDisconnect((_) {
      socket!.dispose();
      debugPrint('Disconnected from server');
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _socketConnection();
    messages = await ChatHooks().getMessages(context, widget.conversationId);
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    socket?.dispose();
    super.dispose();
  }

  Future<void> _sendAsset() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(context);

    if (result != null) {
      try {
        ChatHooks().sendAsset(context, result, widget.conversationId);
      } catch (e) {
        debugPrint('Error occurred while uploading assets: $e');
      }
    }
  }

  final _waveController = WaveformRecorderController();
  bool _isCanceled = false;

  _toggleRecording() async {
    if (_waveController.isRecording) {
      await _waveController.stopRecording();
    } else {
      await _waveController.startRecording();
    }
    setState(() {
      _isCanceled = false;
    });
  }

  _onRecordingStopped() async {
    if (_isCanceled) {
      debugPrint("Recording canceled");
    } else {
      final file = _waveController.file;
      if (file == null) return;
      ChatHooks().sendVM(context, file, widget.conversationId);
    }
  }

  _onRecodingCanceled() async {
    setState(() {
      _isCanceled = true;
    });
    await _waveController.stopRecording();
    setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        double targetPosition = _scrollController.position.extentTotal;
        if (_scrollController.position.pixels != targetPosition) {
          _scrollController.animateTo(
            targetPosition,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.profilePic == null
                    ? defaultImage
                    : "$serverURL/api/${widget.profilePic}",
              ),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 1, left: 8.0),
            child: ListView(
              controller: _scrollController,
              children: messages.map((message) {
                if (message['type'] == "MESSAGE") {
                  Map<String, dynamic>? replyMessage;
                  if (message['replied'] == true) {
                    replyMessage = messages.firstWhere(
                      (replyMessage) =>
                          replyMessage['_id'] == message['replyId'],
                      orElse: () => null,
                    );
                  }
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        setState(() {
                          _replyMessage = message;
                        });
                        await Future.delayed(const Duration(milliseconds: 50));
                        _focusNode.requestFocus();
                        return false;
                      },
                      child: MessageSent(
                        convoId: widget.conversationId,
                        messageId: message['_id'],
                        message: message['message'],
                        replyMessage: replyMessage,
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        setState(() {
                          _replyMessage = message;
                        });
                        await Future.delayed(const Duration(milliseconds: 50));
                        _focusNode.requestFocus();
                        return false;
                      },
                      child: MessageRecieved(
                        profilePic: message['userId']['profilePic'],
                        message: message['message'],
                        replyMessage: replyMessage,
                      ),
                    );
                  }
                } else if (message['type'] == "IMAGE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return ImageSent(
                      messageId: message['_id'],
                      convoId: widget.conversationId,
                      image: message['message'],
                    );
                  } else {
                    return ImageReceived(
                      profilePic: message['userId']['profilePic'],
                      image: message['message'],
                    );
                  }
                } else if (message['type'] == "VIDEO") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return VideoSent(
                      convoId: widget.conversationId,
                      messageId: message['_id'],
                      video: message['message'],
                    );
                  } else {
                    return VideoRecieved(
                      profilePic: message['userId']['profilePic'],
                      video: message['message'],
                    );
                  }
                } else if (message['type'] == "VOICE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return VMSent(
                      vm: message["message"],
                      messageId: message['_id'],
                      convoId: widget.conversationId,
                    );
                  } else {
                    return VMRecieved(
                      profilePic: message['userId']['profilePic'],
                      vm: message['message'],
                    );
                  }
                } else if (message['type'] == "MAP") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return LocationSent(
                      location: message["message"],
                      messageId: message['_id'],
                      convoId: widget.conversationId,
                    );
                  } else {
                    return LocationReceived(
                      profilePic: message['userId']['profilePic'],
                      location: message['message'],
                    );
                  }
                } else {
                  return const SizedBox();
                }
              }).toList(),
            ),
          )),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4, right: 8),
              child: _waveController.isRecording
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: 52,
                            child: WaveformRecorder(
                              height: 48,
                              controller: _waveController,
                              onRecordingStopped: _onRecordingStopped,
                            ),
                          ),
                          IconButton(
                              onPressed: _onRecodingCanceled,
                              icon: const Icon(Icons.delete)),
                          IconButton(
                              onPressed: _toggleRecording,
                              icon: const Icon(Icons.send_rounded)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        if (_replyMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Replying to ${_replyMessage["userId"]['displayName']}",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      child: Text(_replyMessage['message']),
                                    ),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _replyMessage = {};
                                      });
                                    },
                                    icon: const Icon(Icons.close))
                              ],
                            ),
                          ),
                        TextField(
                          minLines: 1,
                          maxLines: 5,
                          controller: _messageController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25)),
                            hintText: 'Type a message',
                            prefixIcon: IconButton(
                              onPressed: () {
                                bottomBar();
                              },
                              icon: const Icon(CupertinoIcons.plus),
                              color: Colors.blue,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _toggleRecording,
                                  icon: const Icon(CupertinoIcons.mic),
                                  color: Colors.blue,
                                  iconSize: 24,
                                ),
                                IconButton(
                                  onPressed: _sendAsset,
                                  icon: const Icon(Icons.image_rounded),
                                  color: Colors.blue,
                                  iconSize: 24,
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_messageController.text == "") {
                                      return;
                                    }
                                    ChatHooks().sendMessages(
                                        context,
                                        widget.conversationId,
                                        _messageController,
                                        _replyMessage['_id']);
                                    if (_replyMessage.isNotEmpty) {
                                      setState(() {
                                        _replyMessage = {};
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.send_rounded),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

  Future<dynamic> bottomBar() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 300,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                children: [
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.file_open)),
                  IconButton(
                      onPressed: () {
                        ChatHooks()
                            .sendLocation(context, widget.conversationId);
                      },
                      icon: const Icon(Icons.map))
                ],
              ));
        });
  }
}

import 'dart:async';

import 'package:chatapp/components/chat/file_message_bubble.dart';
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
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:video_player/video_player.dart';
import 'package:voice_message_package/voice_message_package.dart';
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
  late VideoPlayerController _controller;

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

  Future<bool> _selectMessageToReply(Map<String, dynamic> message) async {
    setState(() {
      _replyMessage = message;
    });
    if (message['type'] == "VIDEO") {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse('$serverURL/api/${message['message']}'))
        ..initialize().then((_) {
          setState(() {});
        });
    }

    await Future.delayed(const Duration(milliseconds: 50));
    _focusNode.requestFocus();
    return false;
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
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: MessageSent(
                        convoId: widget.conversationId,
                        messageId: message['_id'],
                        message: message['message'],
                        replyMessage: message['replyId'],
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: MessageRecieved(
                        profilePic: message['userId']['profilePic'],
                        message: message['message'],
                        replyMessage: message['replyId'],
                      ),
                    );
                  }
                } else if (message['type'] == "IMAGE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: ImageSent(
                        messageId: message['_id'],
                        convoId: widget.conversationId,
                        image: message['message'],
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: ImageReceived(
                        profilePic: message['userId']['profilePic'],
                        image: message['message'],
                      ),
                    );
                  }
                } else if (message['type'] == "VIDEO") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: VideoSent(
                        convoId: widget.conversationId,
                        messageId: message['_id'],
                        video: message['message'],
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: VideoRecieved(
                        profilePic: message['userId']['profilePic'],
                        video: message['message'],
                      ),
                    );
                  }
                } else if (message['type'] == "VOICE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: VMSent(
                        vm: message["message"],
                        messageId: message['_id'],
                        convoId: widget.conversationId,
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: VMRecieved(
                        profilePic: message['userId']['profilePic'],
                        vm: message['message'],
                      ),
                    );
                  }
                } else if (message['type'] == "MAP") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: LocationSent(
                        location: message["message"],
                        messageId: message['_id'],
                        convoId: widget.conversationId,
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: LocationReceived(
                        profilePic: message['userId']['profilePic'],
                        location: message['message'],
                      ),
                    );
                  }
                } else if (message['type'] == "FILE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: FileSent(
                        file: message["message"],
                        messageId: message['_id'],
                        convoId: widget.conversationId,
                      ),
                    );
                  } else {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: UniqueKey(),
                      confirmDismiss: (e) async {
                        await _selectMessageToReply(message);
                        return;
                      },
                      child: FileReceived(
                        messageId: message['_id'],
                        file: message['message'],
                      ),
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
                                    if (_replyMessage['type'] == "MESSAGE")
                                      SizedBox(
                                        child: Text(_replyMessage['message']),
                                      ),
                                    if (_replyMessage['type'] == "IMAGE")
                                      SizedBox(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: Image(
                                            image: NetworkImage(
                                                '$serverURL/api/${_replyMessage['message']}'),
                                            fit: BoxFit.cover,
                                            width: 70,
                                            height: 70,
                                          ),
                                        ),
                                      ),
                                    if (_replyMessage['type'] == "VOICE")
                                      Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          child: VoiceMessageView(
                                            circlesColor: Colors.blue,
                                            activeSliderColor: Colors.blue,
                                            controller: VoiceController(
                                              audioSrc:
                                                  '$serverURL/api/${_replyMessage['message']}',
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
                                              maxDuration:
                                                  const Duration(seconds: 5000),
                                              isFile: false,
                                            ),
                                            innerPadding: 12,
                                            cornerRadius: 20,
                                          )),
                                    if (_replyMessage['type'] == "MAP")
                                      const SizedBox(
                                        child: Row(children: [
                                          Icon(Icons.map),
                                          Text("Map Location")
                                        ]),
                                      ),
                                    if (_replyMessage['type'] == "VIDEO")
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              VideoPlayer(_controller),
                                              Icon(
                                                Icons.play_circle_outline,
                                                size: 50,
                                                color:
                                                    Colors.white.withValues(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (_replyMessage['type'] == "FILE")
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: SizedBox(
                                          height: 70,
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.file_download,
                                                size: 20,
                                              ),
                                              Text(DownloadManager()
                                                  .getFileNameFromUrl(
                                                      '$serverURL/api/${_replyMessage['message']}')),
                                            ],
                                          ),
                                        ),
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
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 10),
                  children: [
                    ClipOval(
                      child: Container(
                        color: Colors.blue,
                        child: IconButton(
                            onPressed: () {
                              ChatHooks()
                                  .sendFiles(context, widget.conversationId);
                            },
                            icon: const Icon(
                              Icons.file_open,
                              size: 50,
                            )),
                      ),
                    ),
                    ClipOval(
                      child: Container(
                        color: Colors.green,
                        child: IconButton(
                            onPressed: () {
                              ChatHooks()
                                  .sendLocation(context, widget.conversationId);
                            },
                            icon: const Icon(
                              Icons.map,
                              size: 50,
                            )),
                      ),
                    )
                  ],
                ),
              ));
        });
  }
}

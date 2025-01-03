import 'dart:async';

import 'package:chatapp/components/chat/image_message_bubble.dart';
import 'package:chatapp/components/chat/message_bubbles.dart';
import 'package:chatapp/components/chat/video_message_bubble.dart';
import 'package:chatapp/components/chat/vm_message_bubbles.dart';
import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:provider/provider.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  const ConversationPage({super.key, required this.conversationId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<dynamic> messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  Future<void> _socketConnection() async {
    IO.Socket socket = IO.io(
        serverURL,
        IO.OptionBuilder().setTransports(['websocket']).setQuery({
          'userId': Provider.of<UserProvider>(context, listen: false).id
        }).build());

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Connected to server');
    });

    socket.on("newMessage", (message) {
      _scrollToBottom();
      setState(() {
        messages.add(message);
      });
    });

    // Connection error
    socket.onConnectError((data) {
      debugPrint('Connection error: $data');
    });

    // Disconnect
    socket.onDisconnect((_) {
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
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              controller: _scrollController,
              children: messages.map((message) {
                if (message['type'] == "MESSAGE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return MessageSent(
                      message: message['message'],
                    );
                  } else {
                    return MessageRecieved(
                      profilePic: message['userId']['profilePic'],
                      message: message['message'],
                    );
                  }
                } else if (message['type'] == "IMAGE") {
                  if (message['userId']['_id'] ==
                      Provider.of<UserProvider>(context).id) {
                    return ImageSent(
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
                    return VMSent(vm: message["message"]);
                  } else {
                    return VMRecieved(
                      profilePic: message['userId']['profilePic'],
                      vm: message['message'],
                    );
                  }
                } else {
                  return const SizedBox();
                }
              }).toList(),
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
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
                : TextField(
                    controller: _messageController,
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          final bottomOffset =
                              _scrollController.position.maxScrollExtent -
                                  MediaQuery.of(context).viewInsets.bottom;
                          _scrollController.animateTo(
                            bottomOffset,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      hintText: 'Type a message',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _toggleRecording,
                            icon: const Icon(Icons.mic),
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
                              ChatHooks().sendMessages(context,
                                  widget.conversationId, _messageController);
                            },
                            icon: const Icon(Icons.send_rounded),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

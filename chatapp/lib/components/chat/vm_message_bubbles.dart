import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_message_package/voice_message_package.dart';

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

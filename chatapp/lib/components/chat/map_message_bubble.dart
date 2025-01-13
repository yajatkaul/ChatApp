import 'package:chatapp/pages/navBar/chat/hooks/chat_hooks.dart';
import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LocationSent extends StatelessWidget {
  final String location;
  final String convoId;
  final String messageId;
  const LocationSent(
      {super.key,
      required this.location,
      required this.convoId,
      required this.messageId});

  double get latitude => double.parse(location.split(",")[0]);
  double get longitude => double.parse(location.split(",")[1]);

  @override
  Widget build(BuildContext context) {
    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: ChatBubble(
              clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(top: 20),
              backGroundColor: Colors.blue,
              child: SizedBox(
                width: 300,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: GestureDetector(
                    onTap: () async {
                      await launchUrlString(
                          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
                    },
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
                                        await ChatHooks().deleteMessage(
                                            context, messageId, convoId);
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
                    child: AbsorbPointer(
                      absorbing: true,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: cameraPosition,
                        markers: {
                          Marker(
                              markerId: const MarkerId("Location"),
                              position: LatLng(latitude, longitude))
                        },
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                    ),
                  ),
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

class LocationReceived extends StatelessWidget {
  final String location;
  final String? profilePic;
  const LocationReceived(
      {super.key, required this.location, required this.profilePic});

  double get latitude => double.parse(location.split(",")[0]);
  double get longitude => double.parse(location.split(",")[1]);

  @override
  Widget build(BuildContext context) {
    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );

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
          ChatBubble(
            clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
            backGroundColor: const Color(0xffE7E7ED),
            margin: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 300,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: GestureDetector(
                  onTap: () async {
                    await launchUrlString(
                        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
                  },
                  child: AbsorbPointer(
                    absorbing: true,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: cameraPosition,
                      markers: {
                        Marker(
                            markerId: const MarkerId("Location"),
                            position: LatLng(latitude, longitude))
                      },
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                    ),
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

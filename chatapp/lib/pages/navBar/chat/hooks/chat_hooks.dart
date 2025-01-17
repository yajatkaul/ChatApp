import 'dart:convert';
import 'dart:io';

import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';

class ChatHooks {
  Future<List<dynamic>> getMessages(
      BuildContext context, String convoId) async {
    final response = await http.get(
      Uri.parse('$serverURL/api/dm/getMessages?conversationId=$convoId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie':
            Provider.of<UserProvider>(context, listen: false).sessionCookie!,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<void> sendMessages(BuildContext context, String convoId,
      TextEditingController messageController, String? replyId) async {
    final response = await http.post(
        Uri.parse('$serverURL/api/dm/sendMessage?conversationId=$convoId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie':
              Provider.of<UserProvider>(context, listen: false).sessionCookie!,
        },
        body: jsonEncode(
            {"message": messageController.text, "replyId": replyId}));

    if (response.statusCode == 200) {
      messageController.text = '';
    }
  }

  Future<void> sendAsset(
      BuildContext context, List<AssetEntity> result, String convoId) async {
    try {
      final Uri url =
          Uri.parse('$serverURL/api/dm/sendAsset?conversationId=$convoId');

      var request = http.MultipartRequest('POST', url);

      request.headers['Cookie'] =
          Provider.of<UserProvider>(context, listen: false).sessionCookie!;

      for (var asset in result) {
        final File? file = await asset.file;

        var mimeTypeData = lookupMimeType(file!.path);
        var type = mimeTypeData!.split("/");

        var value = await http.MultipartFile.fromPath('assets', file.path,
            filename: path.basename(file.path),
            contentType: MediaType(type[0], type[1]));
        request.files.add(value);
      }

      await request.send();
    } catch (e) {
      debugPrint('Error occurred while uploading assets: $e');
    }
  }

  Future<void> sendVM(BuildContext context, XFile file, String convoId) async {
    try {
      final Uri url =
          Uri.parse('$serverURL/api/dm/sendVM?conversationId=$convoId');

      var request = http.MultipartRequest('POST', url);

      request.headers['Cookie'] =
          Provider.of<UserProvider>(context, listen: false).sessionCookie!;

      var mimeTypeData = lookupMimeType(file.path);
      var type = mimeTypeData!.split("/");

      var value = await http.MultipartFile.fromPath('vm', file.path,
          filename: path.basename(file.path),
          contentType: MediaType(type[0], type[1]));
      request.files.add(value);

      await request.send();
    } catch (e) {
      debugPrint('Error occurred while uploading assets: $e');
    }
  }

  Future<void> deleteMessage(
      BuildContext context, String messageId, String convoId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$serverURL/api/dm/deleteMessage?messageId=$messageId&convoId=$convoId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie':
              Provider.of<UserProvider>(context, listen: false).sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Message Deleted"),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error occurred while uploading assets: $e');
    }
  }

  Future<void> sendLocation(BuildContext context, String convoId) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }

    Position location = await Geolocator.getCurrentPosition();

    final response = await http.post(
        Uri.parse('$serverURL/api/dm/sendLocation?conversationId=$convoId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie':
              Provider.of<UserProvider>(context, listen: false).sessionCookie!,
        },
        body: jsonEncode(
            {"message": '${location.latitude},${location.longitude}'}));

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  Future<void> sendFiles(BuildContext context, String convoId) async {
    try {
      final Uri url =
          Uri.parse('$serverURL/api/dm/sendFiles?conversationId=$convoId');

      var request = http.MultipartRequest('POST', url);

      request.headers['Cookie'] =
          Provider.of<UserProvider>(context, listen: false).sessionCookie!;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();

        for (var fileRaw in files) {
          var mimeTypeData = lookupMimeType(fileRaw.path);
          var type = mimeTypeData!.split("/");

          var value = await http.MultipartFile.fromPath('files', fileRaw.path,
              filename: path.basename(fileRaw.path),
              contentType: MediaType(type[0], type[1]));
          request.files.add(value);
        }

        final response = await request.send();

        if (response.statusCode == 200) {
          Navigator.pop(context);
        }
      } else {
        return;
      }
    } catch (e) {
      debugPrint('Error occurred while uploading assets: $e');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:chatapp/providers/user_provider.dart';
import 'package:chatapp/utils/env.dart';
import 'package:chatapp/utils/showToast.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UpdateUser {
  updateDetails(BuildContext context, String displayName, File? galleryPic,
      XFile? image) async {
    if (galleryPic != null) {
      _uploadImage(File(image!.path),
          Provider.of<UserProvider>(context, listen: false).sessionCookie);
    }

    final response = await http.post(
      Uri.parse('$serverURL/api/user/updateUsername'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie':
            Provider.of<UserProvider>(context, listen: false).sessionCookie!,
      },
      body: jsonEncode(<String, String>{
        'displayName': displayName,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['result'], true, context);
      Provider.of<UserProvider>(context, listen: false).getDetails(context);
      Navigator.pop(context);
    } else {
      final responseBody = jsonDecode(response.body);
      showToast(responseBody['error'], false, context);
    }
  }

  _uploadImage(File image, String? cookie) async {
    final url = Uri.parse('$serverURL/api/user/updatePFP');

    var request = http.MultipartRequest('POST', url);

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    request.headers['Cookie'] = cookie!;

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      ),
    );

    try {
      await request.send();
    } catch (e) {
      print('Error occurred while uploading image: $e');
    }
  }
}

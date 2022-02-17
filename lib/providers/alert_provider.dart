import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:muniapp/models/models.dart';
import 'package:muniapp/utils/shared_preferences.dart';
import 'package:muniapp/utils/url.dart';
import 'package:muniapp/utils/utils.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';


class AlertProvider {

  final String _url   = Environment.API_APP;
  final String _api   = Environment.API_USERS;
  final String _alert = Environment.API_ALERT;

  BuildContext ?context;
  //Para utilizar la info del user y la sesión
  User ?sessionUser;

  void init(BuildContext context, {User ?sessionUser}) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<Stream?> sendWithImage(Munialert alert, File image) async {
    try {
      Uri url = Uri.http(_url, '$_alert/create');
      final request = http.MultipartRequest('POST', url);

      String path = image.path;
      bool directoryExists = await Directory(path).exists();
      bool fileExists = await File(path).exists();

      if(directoryExists || fileExists) {
        //}if (image != null) {
        request.files.add(http.MultipartFile(
            'archivo',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }

      request.fields['alert'] = json.encode(alert);
      final response = await request.send(); // ENVIARA LA PETICION
      return response.stream.transform(utf8.decoder);
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }



}
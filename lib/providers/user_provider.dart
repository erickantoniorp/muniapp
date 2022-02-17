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


class UsersProvider {

  final String _url = Environment.API_APP;
  final String _api = Environment.API_USERS;
  final String _auth = Environment.API_AUTH;

  BuildContext ?context;
  User ?sessionUser;

  void init(BuildContext context, {User ?sessionUser}) {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<User?> getById(String id) async {
    try {
      Uri url = Uri.http(_url, '$_api/findById/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) { // NO AUTORIZADO
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
        new SharedPref().logout(context!, sessionUser!.id!);
      }

      final data = json.decode(res.body);
      User user = User.fromJson(data);
      return user;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  int getCurrentUserId(){
    int userid = -1;

    try {
      //User user = User.fromJson(await _sharedPref.read('user') ?? {});
      if( sessionUser!= null) {
        userid = int.parse(sessionUser!.id!);
      }
    }catch(error){
      print("Error al obtener id del usuario desde sharedPref en Home Controller");
      userid = -1;
    }
    return userid;
  }

  /*Future<List<User>?> getDeliveryMen() async {
    try {
      Uri url = Uri.http(_url, '$_api/findDeliveryMen');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) { // NO AUTORIZADO
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
        new SharedPref().logout(context!, sessionUser!.id);
      }

      final data = json.decode(res.body);
      User user = User.fromJsonList(data);
      return user.toList;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }*/


  Future<List<String>?> getAdminsNotificationTokens() async {
    try {
      Uri url = Uri.http(_url, '$_api/getAdminsNotificationTokens');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) { // NO AUTORIZADO
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
        new SharedPref().logout(context!, sessionUser!.id!);
      }

      final data = json.decode(res.body);
      final tokens = List<String>.from(data);

      print('TOKENS DE ADMIN ${tokens}');
      return tokens;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Stream?> createWithImage(User user, File image) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
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

      request.fields['user'] = json.encode(user);
      final response = await request.send(); // ENVIARA LA PETICION
      return response.stream.transform(utf8.decoder);
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Stream?> update(User user, File image) async {
    try {
      Uri url = Uri.http(_url, '$_api/update');
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = sessionUser!.sessionToken!;

      if (image != null) {
        request.files.add(http.MultipartFile(
            'archivo',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }

      request.fields['user'] = json.encode(user);
      final response = await request.send(); // ENVIARA LA PETICION

      if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Tu sesion expiro');
        new SharedPref().logout(context!, sessionUser!.id!);
      }

      return response.stream.transform(utf8.decoder);
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> create(User user) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(user);
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> updateNotificationToken(String idUser, String token) async {
    try {
      Uri url = Uri.http(_url, '$_api/updateNotificationToken');
      String bodyParams = json.encode({
        'id': idUser,
        'notification_token': token
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
      };
      final res = await http.put(url, headers: headers, body: bodyParams);

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> logout(String idUser) async {
    try {
      Uri url = Uri.http(_url, '$_api/logout');
      String bodyParams = json.encode({
        'id' : idUser
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final Map<String, dynamic> decodedResp = json.decode( res.body );
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponseApi?> login(String email, String password) async {
    try {
      Uri url = Uri.http(_url, '$_auth/login');
      String bodyParams = json.encode({
        'email': email,
        'password': password
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final Map<String, dynamic> decodedResp = json.decode( res.body );

      //final data = json.decode(decodedResp["data"]);
      ResponseApi responseApi = ResponseApi.fromJson(res.body);
      return responseApi;
    }
    catch(e) {
      print('Error: $e');
      return null;
    }
  }

}
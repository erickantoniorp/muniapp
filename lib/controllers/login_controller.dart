import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:muniapp/models/api_response.dart';
import 'package:muniapp/models/user.dart';
//import 'package:muniapp/providers/push_notifications_provider.dart';
import 'package:muniapp/providers/user_provider.dart';
import 'package:muniapp/utils/my_snackbar.dart';
import 'package:muniapp/utils/shared_preferences.dart';

class LoginController {

  late BuildContext context;
  TextEditingController emailController     = TextEditingController(text: "erickantoniorp@outlook.com");
  TextEditingController passwordController  = TextEditingController(text: "12345678");

  UsersProvider usersProvider               = UsersProvider();
  //PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();
  final SharedPref _sharedPref              = SharedPref();

  Future init(BuildContext context) async {
    this.context = context;

    usersProvider.init(context);

    String? userFromSharedPref = await _sharedPref.read('user');
    if( userFromSharedPref != null ) {
      User user = User.fromJson(userFromSharedPref);

      print('Login Init - Usuario: ${user.toJson()}');

      /*if (user?.sessionToken != null) {

      //if (user.roles!.length > 1) {
      if (user.roles!.length > 0 && user.roles![0].name == "oper") {
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      }
      else {
        Navigator.pushNamedAndRemoveUntil(context, user.roles![0].name, (route) => false);
      }
    }*/
    }
  }

  void goToRegisterPage() {
    Navigator.pushNamed(context, 'register');
  }

  void login() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    ResponseApi? responseApi = await usersProvider.login(email, password);

    if( responseApi!= null) {
      print('Respuesta object: ${responseApi}');
      print('Respuesta: ${responseApi.toJson()}');

      if (responseApi.success == "true") {
        //User user = User.fromJson(json.decode( responseApi.data! ));
        String tmp = json.encode(responseApi.data!);
        User user = User.fromJson(tmp);
        _sharedPref.save('user', user.toJson());

        //pushNotificationsProvider.saveToken(user.id);

        print('USUARIO LOGEADO: ${user.toJson()}');

        //TODO: Revisar como cambiar esto
        if (user.roles!.length > 0 && user.roles![0].name == "oper") {
          Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
        }
        else {
          Navigator.pushNamedAndRemoveUntil(
              context, user.roles![0].name, (route) => false);
        }
      }
      else {
        MySnackbar.show(context, responseApi.message);
      }
    }else {
      MySnackbar.show(context, "Ocurrió un Error al Intentar Iniciar Sesión");
    }

  }

}
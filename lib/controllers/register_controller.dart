import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:muniapp/models/models.dart';
import 'package:muniapp/providers/user_provider.dart';
import 'package:muniapp/utils/constant.dart';
import 'package:muniapp/utils/my_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muniapp/utils/shared_preferences.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class RegisterController {

  BuildContext ?context;
  TextEditingController emailController             = TextEditingController(text: "erickantoniorp@outlook.com");
  TextEditingController nameController              = TextEditingController(text: "Erick");
  TextEditingController lastnameController          = TextEditingController(text: "Rodriguez");
  TextEditingController lastnameController2         = TextEditingController(text: "Plaza");
  TextEditingController phoneController             = TextEditingController(text: "989344678");
  TextEditingController numDocController            = TextEditingController(text: "40527034");
  TextEditingController passwordController          = TextEditingController(text: "12345678");
  TextEditingController confirmPassswordController  = TextEditingController(text: "12345678");
  final docTypeItems                                = ["DNI", "C.E.", "Pasaporte", "Otro"];
  String currentDocTypeValue                        = "DNI";

  UsersProvider usersProvider                       = UsersProvider();
  late File imageFile                               = File('assets/images/user_profile_2.png');
  PickedFile? pickedFile;
  Function? refresh;

  ProgressDialog ?_progressDialog;

  bool isEnable = true;

  void init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
  }

  void register() async {
    String email            = emailController.text.trim();
    String name             = nameController.text;
    String lastname         = lastnameController.text;
    String lastname2        = lastnameController2.text;
    String docType          = currentDocTypeValue;
    String numDoc           = numDocController.text;
    String phone            = phoneController.text.trim();
    String password         = passwordController.text.trim();
    String confirmPassword  = confirmPassswordController.text.trim();


    if (email.isEmpty || name.isEmpty || lastname.isEmpty || phone.isEmpty || password.isEmpty ||
        confirmPassword.isEmpty || docType.isEmpty || numDoc.isEmpty) {
      MySnackbar.show(context!, Constant.all_fields);
      return;
    }

    if (confirmPassword != password) {
      MySnackbar.show(context!, Constant.different_passwords);
      return;
    }

    if (password.length < 6) {
      MySnackbar.show(context!, Constant.password_size);
      return;
    }

    if (imageFile == null) {
      MySnackbar.show(context!, Constant.choose_image);
      return;
    }

    _progressDialog!.show(max: 100, msg: Constant.wait);
    isEnable = false;

    User user = User(
        email:      email,
        firstname:  name,
        lastname:   lastname,
        lastname2:  lastname2,
        phone:      phone,
        password:   password,
        doctype:    docTypeId(currentDocTypeValue),
        numdoc:     numDoc,
        image:      "-",
        sessionToken: "-",
        roles: []
    );

    Stream? stream = await usersProvider.createWithImage(user, imageFile);
    if ( stream != null) {
      stream.listen((res) {
        _progressDialog!.close();

        try {
          ResponseApi responseApi = ResponseApi.fromJson( res );
          //ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

          print('RESPUESTA: ${responseApi.toJson()}');
          MySnackbar.show(context!, responseApi.message);

        if (responseApi.success == "true") {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pushReplacementNamed(context!, 'login');
          });
        }
        else {
          isEnable = true;
        }
        }on Exception catch (exception) {
          print(exception.toString());
        } catch (error) {
          print(error.toString());
        }

      });
    }
  }

  String docTypeId(String selectedDocType){
    //TODO: hay que ver si se trae de la BD
    switch( selectedDocType){
      case "DNI": return "1";break;
      case "C.E.": return "2";break;
      case "Pasaporte": return "3";break;
      case "Otro": return "4";break;
    }
    return "-1";
  }

  Future selectImage(ImageSource imageSource) async {
    pickedFile = await ImagePicker().getImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
    }
    Navigator.pop(context!);
    refresh!();
  }

  void showAlertDialog() {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.gallery);
        },
        child: Text('GALERIA')
    );

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.camera);
        },
        child: Text('CAMARA')
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );

    showDialog(
        context: context!,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  void back() {
    Navigator.pop(context!);
  }


}
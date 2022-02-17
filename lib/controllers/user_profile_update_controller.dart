import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muniapp/models/api_response.dart';
import 'package:muniapp/models/user.dart';
import 'package:muniapp/providers/user_provider.dart';
import 'package:muniapp/utils/my_snackbar.dart';
import 'package:muniapp/utils/shared_preferences.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class UserProfileUpdateController {
  BuildContext? context;
  TextEditingController nameController      = TextEditingController();
  TextEditingController lastnameController  = TextEditingController();
  TextEditingController phoneController     = TextEditingController();
  TextEditingController lastnameController2 = TextEditingController();
  TextEditingController numDocController    = TextEditingController();
  final docTypeItems                        = ["DNI", "C.E.", "Pasaporte", "Otro"];
  String currentDocTypeValue                = "DNI";

  UsersProvider usersProvider = new UsersProvider();

  PickedFile? pickedFile;
  File? imageFile;
  Function? refresh;

  ProgressDialog? _progressDialog;

  bool isEnable = true;
  User? user;
  SharedPref _sharedPref = new SharedPref();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _progressDialog = ProgressDialog(context: context);
    user = User.fromJson(await _sharedPref.read('user'));

    print('TOKEN ENVIADO: ${user!.sessionToken}');
    usersProvider.init(context, sessionUser: user);

    nameController.text       = user!.firstname;
    lastnameController.text   = user!.lastname;
    lastnameController2.text  = user!.lastname2;
    phoneController.text      = user!.phone;
    numDocController.text     = user!.numdoc;
    refresh();
  }

  void update() async {
    String name = nameController.text;
    String lastname = lastnameController.text;
    String phone = phoneController.text.trim();

    if (name.isEmpty || lastname.isEmpty || phone.isEmpty) {
      MySnackbar.show(context!, 'Debes ingresar todos los campos');
      return;
    }

    _progressDialog!.show(max: 100, msg: 'Espere un momento...');
    isEnable = false;

    User myUser = new User(
        id: user!.id,
        firstname: name,
        lastname: lastname,
        lastname2: user!.lastname2,
        phone: phone,
        image: user!.image,
        numdoc: user!.numdoc,
        doctype: '',
        email: '',

    );

    Stream? stream = await usersProvider.update(myUser, imageFile!);
    if( stream!= null) {
      stream!.listen((res) async {
        _progressDialog!.close();

        // ResponseApi responseApi = await usersProvider.create(user);
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        Fluttertoast.showToast(msg: responseApi.message);

        if (responseApi.success == "true") {
          user = await usersProvider.getById( myUser.id! );
          // OBTENIENDO EL USUARIO DE LA DB
          print('Usuario obtenido: ${user!.toJson()}');
          _sharedPref.save('user', user!.toJson());
          Navigator.pushNamedAndRemoveUntil(
              context!, 'home', (route) => false);
        }
        else {
          isEnable = true;
        }
      });
    }
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
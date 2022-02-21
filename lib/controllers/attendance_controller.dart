import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:camera/camera.dart';

import '../models/user.dart';
import '../providers/providers.dart';
import '../utils/shared_preferences.dart';

class AttendanceController {

    BuildContext? context;
    UsersProvider usersProvider                       = UsersProvider();
    AlertProvider alertProvider                       = AlertProvider();
    MarkProvider markProvider                         = MarkProvider();
    SharedPref _sharedPref                            = SharedPref();
    Function? refresh;
    ProgressDialog? _progressDialog;

    bool cameraWasUsed = false;
    User? user;
    List<CameraDescription>? cameras;
    CameraController? controller;
    CameraDescription? firstCamera;
    List? cams;
    Future<void>? _initializeControllerFuture;
    String imageFilePath = "";

    void init(BuildContext context, Function refresh) async{
        this.context = context;
        this.refresh = refresh;
        _progressDialog = ProgressDialog(context: context);

        //Se supone ya existe la sesión del usuario por el login
        user = User.fromJson(await _sharedPref.read('user'));
        usersProvider.init(context, sessionUser: user);
        startCameras();
    }

    void startCameras() async {
        try {
            //TODO: probar quitando esto WidgetsFlutterBinding.ensureInitialized();
            //WidgetsFlutterBinding.ensureInitialized();
            //cameras = await availableCameras();
            //TODO: chequear que todo esté bien y el 1 sea la cámara frontal
            firstCamera = cameras![1];
        } on CameraException catch (e) {
            print("Error en startCameras: Codigo $e.code, Desc: $e.description");
        }

        controller = CameraController(
            // Get a specific camera from the list of available cameras.
            firstCamera!,
            // Define the resolution to use.
            ResolutionPreset.medium,
        );

        _initializeControllerFuture = controller!.initialize().then((_) {
            /*if (!mounted) {
                return;
            }
            setState(() {});*/
        });

        await _initializeControllerFuture;
    }

    void takePic() async {
        // Toma la foto en un bloque try / catch . Si algo sale mal, atrapo el error
        String imagePath = "";
        try {
            // Se asegura que el Controlador haya sido inicializado
            await _initializeControllerFuture;

            // Intenta tomar la foto y la coloca en el archivo `image`
            // donde sera grabado.
            final image = await controller!.takePicture();

            // Si la foto fue tomada, guardamos la ruta.
            imagePath = image.path;
            //setState(() {
                imageFilePath = imagePath;
                cameraWasUsed = true;
            //});
            print("Archivo: $imagePath");
        } catch (e) {
            // Si ocurriera un error, lo mostramos
            print(e);
        }
        //return imagePath;
    }

    //Si se tomo la foto, y fue grabada, se muestra en el mismo widget donde aparecia la camara
    Widget showPicture() {
        Widget tmp = Image.file(File(imageFilePath));
        //setState(() {
            cameraWasUsed = false;
            imageFilePath = "";
        //});
        return tmp;
    }
}
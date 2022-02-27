import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart' as location;

import '../models/api_response.dart';
import '../models/mark.dart';
import '../models/user.dart';
import '../providers/providers.dart';
import '../utils/constant.dart';
import '../utils/globals.dart';
import '../utils/my_snackbar.dart';
import '../utils/shared_preferences.dart';

class AttendanceController {

    BuildContext? context;
    UsersProvider usersProvider                       = UsersProvider();
    AlertProvider alertProvider                       = AlertProvider();
    MarkProvider markProvider                         = MarkProvider();
    SharedPref _sharedPref                            = SharedPref();
    Function? refresh;
    ProgressDialog? _progressDialog;
    File? markImageFile;

    bool cameraWasUsed = false;
    bool isCameraInitialized = false;
    bool isEnable = true;

    User? user;
    List<CameraDescription>? cameras;
    CameraController? controller;
    CameraDescription? firstCamera;
    List? cams;
    Future<void>? _initializeControllerFuture;
    String imageFilePath = "";

    int batteryLevel = 0;

    //Para geolocalizacion
    Position? _currentPosition;

    void init(BuildContext context, Function refresh) async{
        this.context = context;
        this.refresh = refresh;
        _progressDialog = ProgressDialog(context: context);

        //Se supone ya existe la sesión del usuario por el login
        user = User.fromJson(await _sharedPref.read('user'));
        usersProvider.init(context, sessionUser: user);
        cameras = globalCameras;
        await startCameras();
        checkGps();
        refresh();
    }

    Future<void> startCameras() async {
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

    Future<void> takePic() async {
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

    Future<void> takePicAndSendMark({ int fromBiometric : 0, int markType:1 }) async{
        await takePic();
        await sendMark(fromBiometric: fromBiometric, markType: markType);
    }

    //Enviará Alerta de Marcación
    Future<void> sendMark({ int fromBiometric : 0, int markType:1 }) async {
        ResponseApi? responseApi;
        _progressDialog!.show(max: 100, msg: Constant.wait);
        isEnable = false;

        DateTime now = DateTime.now();
        final String cur_register_date = DateFormat('dd-MM-yyyy kk:mm:ss').format(now);

        int userid = usersProvider.getCurrentUserId();
        await getBatteryLevel();

        Mark newMark = Mark(
            type          : markType,
            state         : 1,
            lon           : _currentPosition!.longitude.toString(),
            lat           : _currentPosition!.latitude.toString(),
            register_date : cur_register_date,
            biometric     : fromBiometric.toString()
        );

        try {
            if (markImageFile == null) {
                responseApi = await markProvider.send(newMark);
                print('Respuesta object: ${responseApi}');
                print('Respuesta: ${responseApi!.toJson()}');

                if (responseApi.success == "true") {
                    _progressDialog!.close();

                    try {
                        String tmp = json.encode(responseApi.data!);
                        User user = User.fromJson(tmp);
                        //ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

                        print('RESPUESTA: ${responseApi.toJson()}');
                        MySnackbar.show(context!, responseApi.message);
                    } on Exception catch (exception) {
                        print(exception.toString());
                    } catch (error) {
                        print(error.toString());
                    }
                }
                else {
                    isEnable = true;
                    MySnackbar.show(context!, responseApi.message);
                }
            }
            else {
                Stream? stream = await markProvider.sendWithImage(newMark, markImageFile!);
                if (stream != null) {
                    stream.listen((res) {
                        _progressDialog!.close();

                        try {
                            ResponseApi responseApi = ResponseApi.fromJson(res);
                            //ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

                            print('RESPUESTA: ${responseApi.toJson()}');
                            MySnackbar.show(context!, responseApi.message);

                            if (responseApi.success == "true") {
                                /*Future.delayed(Duration(seconds: 3), () {
                    Navigator.pushReplacementNamed(context!, 'login');
                  });*/

                            }
                            else {
                                isEnable = true;
                            }
                        } on Exception catch (exception) {
                            print(exception.toString());
                        } catch (error) {
                            print(error.toString());
                        }
                    });
                }
            }
        }on Exception catch (exception) {
            print(exception.toString());
            _progressDialog!.close();
        } catch (error) {
            print(error.toString());
            _progressDialog!.close();
        }
    }

    void checkGps() async {
        bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

        if (isLocationEnabled) {
            updateLocation();
        }
        else {
            bool locationGPS = await location.Location().requestService();
            if (locationGPS) {
                updateLocation();
            }
        }
    }

    void updateLocation() async {
        try {

            _currentPosition = await _determinePosition(); // OBTENER LA POSICION ACTUAL Y TAMBIEN SOLICITAR LOS PERMISOS

            //emitPosition();

            refresh!();

        } catch(e) {
            print('Error: $e');
        }
    }

    Future<Position> _determinePosition() async {
        bool serviceEnabled;
        LocationPermission permission;

        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
            return Future.error('Los servicios de Ubicación están desactivados');
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
                return Future.error('Los permisos de Ubicación fueron denegados');
            }
        }

        if (permission == LocationPermission.deniedForever) {
            return Future.error('Los Permisos de Ubicación están denegados permanentemente. No se pueden requerir.');
        }

        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true);
    }

    Future<void> getBatteryLevel() async{
        batteryLevel = AndroidBatteryInfo().batteryLevel!;
    }
}
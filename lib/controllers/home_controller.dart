import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:muniapp/models/models.dart';
import 'package:muniapp/providers/alert_provider.dart';
import 'package:muniapp/providers/mark_provider.dart';
import 'package:muniapp/providers/user_provider.dart';
import 'package:muniapp/utils/constant.dart';
import 'package:muniapp/utils/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:muniapp/utils/url.dart';
import 'package:muniapp/utils/my_snackbar.dart';


class HomeController {

    BuildContext? context;
    GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

    UsersProvider usersProvider                       = UsersProvider();
    AlertProvider alertProvider                       = AlertProvider();
    MarkProvider markProvider                         = MarkProvider();
    final SharedPref _sharedPref                      = SharedPref();

    PickedFile? pickedFile;
    Function? refresh;
    ProgressDialog? _progressDialog;

    File? imageFile;
    File? markImageFile;

    bool isEnable = true;
    bool isClose = false;

    late IO.Socket socket;

    //Para geolocalizacion
    late Position _currentPosition;
    late String _currentAddress;
    User? user;

    bool isEmitting = false;

    Timer? timerObj;
    int frec = 3;

    //Para biometrico
    LocalAuthentication? localAuth;
    bool isBiomtricAvailable = false;
    bool biometricSent = false;

    int batteryLevel = 0;

    //SignatureController? signController;

    void init(BuildContext context, Function refresh) async{
        this.context = context;
        this.refresh = refresh;
        usersProvider.init(context);
        _progressDialog = ProgressDialog(context: context);

        user = User.fromJson(await _sharedPref.read('user'));

        //Para la firma
        /*signController = SignatureController(
            penColor: Colors.blue,
            penStrokeWidth: 3
        );*/

        initSocket();
        checkGps();
        initBiometrics();
    }

  void initBiometrics(){
      localAuth = LocalAuthentication();
      localAuth!.canCheckBiometrics.then((b){
          isBiomtricAvailable = b;
      });
  }

  void initSocket(){
    //socket = IO.io('http://${Environment.API_APP}/orders/delivery', <String, dynamic> {
    socket = IO.io(Environment.SOCKET_SEND_ALERT, <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket.connect();
    //Asignamos evento cuando ocurra un error
    socket.onConnectError((data) => print('Error de Conexion de Socket: $data'));
  }

  void openDrawer() {
    key.currentState?.openDrawer();
  }

  Future<void> sendAlert() async {
    showAlertDialog();
  }

  /*int getCurrentUserId(){
    int userid = -1;

    try {
      //User user = User.fromJson(await _sharedPref.read('user') ?? {});
      if( user!= null) {
        userid = int.parse(user!.id!);
      }
    }catch(error){
      print("Error al obtener id del usuario desde sharedPref en Home Controller");
      userid = -1;
    }
    return userid;
  }*/

  Future<void> sendAllData() async {
    print('Enviara Alerta: ');
    checkGps();
    print("LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}");

    if (imageFile == null) {
      MySnackbar.show(context!, Constant.choose_image);
      return;
    }

    _progressDialog!.show(max: 100, msg: Constant.wait);
    isEnable = false;

    DateTime now = DateTime.now();
    final String cur_register_date = DateFormat('dd-MM-yyyy kk:mm:ss').format(now);

    int userid = usersProvider.getCurrentUserId();
    /*int userid = -1;

    try {
      //User user = User.fromJson(await _sharedPref.read('user') ?? {});
      if( user!= null) {
        userid = int.parse(user!.id!);
      }
    }catch(error){
      print("Error al obtener id del usuario desde sharedPref en Home Controller");
      userid = -1;
    }*/

    Munialert newAlert = Munialert(
        type: 1,
        state: 1,
        userid: userid,
        long: _currentPosition.longitude.toString(),
        lat: _currentPosition.latitude.toString(),
        register_date: cur_register_date
    );

    Stream? stream = await alertProvider.sendWithImage(newAlert, imageFile!);
    if ( stream != null) {
      stream!.listen((res) {
        _progressDialog!.close();

        try {
          ResponseApi responseApi = ResponseApi.fromJson( res );
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
        }on Exception catch (exception) {
          print(exception.toString());
        } catch (error) {
          print(error.toString());
        }

      });
    }

  }

  Future selectImage(ImageSource imageSource) async {
    pickedFile = await ImagePicker().getImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      sendAllData();
    }
    Navigator.pop(context!);
    refresh!();
  }

  void showAlertDialog(){
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

  void emitPosition() {
    print("Emitira Posicion: ");
    //Actualizo el Gps antes
    checkGps();
    socket.emit('position', {
      'userid': user!.id,
      'lat': _currentPosition.latitude,
      'lon': _currentPosition.longitude,
    });
  }

  void goToUpdatePage() {
    Navigator.pushNamed(context!, 'user/update');
  }

  void logout() {
    _sharedPref.logout(context!, user!.id!);
  }

  void dispose(){
    socket?.disconnect();
  }

  //Inicia la emisión de la posición cada n segundos, especificados en la variable frec
  void initEmit() {
    timerObj = Timer.periodic(Duration(seconds: frec), (timer) async {
      emitPosition();
    });
  }

  void finishEmit(){
    timerObj?.cancel();
  }

    Future<void> getBatteryLevel() async{
      batteryLevel = AndroidBatteryInfo().batteryLevel!;
    }

  //Enviará Alerta de Marcación
  Future<void> sendMark({int fromBiometric : 0}) async {
    ResponseApi? responseApi;
    _progressDialog!.show(max: 100, msg: Constant.wait);
    isEnable = false;

    DateTime now = DateTime.now();
    final String cur_register_date = DateFormat('dd-MM-yyyy kk:mm:ss').format(now);

    int userid = usersProvider.getCurrentUserId();
    await getBatteryLevel();

    Mark newMark = Mark(
        type          : 1,
        state         : 1,
        lon           : _currentPosition.longitude.toString(),
        lat           : _currentPosition.latitude.toString(),
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
          stream!.listen((res) {
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

  Future<void> sendMarkWithImage() async{
    Navigator.pushNamed(context!, 'signature');
  }

  Future<void> sendBiometrics() async{
    if( isBiomtricAvailable) {
      final bool didAuthentication = await localAuth!.authenticate(
        biometricOnly: true,
        localizedReason: 'Marcar con Huella',
        useErrorDialogs: true,);
      if (didAuthentication) {
        MySnackbar.show(context!, 'Se autenticó correctamente');
        await sendMark(fromBiometric: 1);
        //Navigator.pushReplacementNamed(context, 'home');
      } else {
        MySnackbar.show(context!, 'Falló al autenticar');
      }
      Navigator.pop(context!);
    }
  }

  /*
  Future<void> getSign() async{
      if(signController!.isNotEmpty){
          final signature = await exportSignature();

          /*await Navigator.of(context!).push( MaterialPageRoute(
            builder: ( context ) => SignaturePreviewPage( signature: signature!, key: null),
          ));*/

          final status = await Permission.storage.status;
          if (!status.isGranted) {
            await Permission.storage.request();
          }

          final time = DateTime.now().toIso8601String().replaceAll('.', ':');
          final name = 'signature_$time.png';

          final result = await ImageGallerySaver.saveImage(signature!, name: name);
          print( result );
          final isSuccess = result['isSuccess'];

          if (isSuccess) {

              MySnackbar.show(context!, 'Firma Guardada');
              //markImageFile.path
              //Navigator.pop(context);
              Navigator.pushReplacementNamed(context!, 'home');
          } else {
              MySnackbar.show(context!, 'Falló al guardar la firma');
          }
      }

      signController!.clear();


  }


  Future <Uint8List?> exportSignature() async{

      final exportController = SignatureController(
        penStrokeWidth: 2,
        penColor: Colors.black,
        exportBackgroundColor: Colors.white,
        points: signController!.points,
      );

      final signature = await exportController.toPngBytes();
      exportController.dispose();
      return signature;
  }

  Future<void> signClear() async{
      signController!.clear();
  }
  */
}
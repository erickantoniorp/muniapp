import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muniapp/utils/mycolors.dart';

import '../controllers/attendance_controller.dart';
import '../utils/my_snackbar.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage( {Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {

    final AttendanceController _con = AttendanceController();

    @override
    void initState() {
      // TODO: implement initState
      super.initState();

      SchedulerBinding.instance?.addPostFrameCallback((timeStamp)  {
        _con.init(context, refresh);
      });

      print("Termino initState");
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
          title: Text('Módulo de Asistencia'),
            backgroundColor: MyColors.primaryColor,

          ),
        body: Column(
          children: [
            Center(
              child: Container(
                //width: double.infinity,
                width: 230,
                height: 230,
                color: Colors.blue[50],
                child: (!_con.cameraWasUsed)
                    ? CamContainer()
                    : Image.file(File(_con.imageFilePath)),
              ),
            ),
            Container(
              height: 320,
              child: GridView.count(
                //childAspectRatio: (itemWidth / itemHeight),
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        child: const Text("Marcar Entrada"),
                        padding: const EdgeInsets.all(6),
                        color: Colors.blue[800],
                        alignment: Alignment.center,
                      ),
                      onTap: () {
                        print("Marcar Entrada");
                        _con.sendMark(markType: 1);
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: const Text('Inicio Almuerzo'),
                        padding: const EdgeInsets.all(6),
                        color: Colors.lightBlue[700],
                        alignment: Alignment.center,
                      ),
                      onTap: () {
                        print("Inicio Almuerzo");
                        _con.sendMark(markType: 2);
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: const Text('Fin de Almuerzo'),
                        padding: const EdgeInsets.all(6),
                        color: Colors.lightBlue[500],
                        alignment: Alignment.center,
                      ),
                      onTap: () {
                        print("Fin Almuerzo");
                        _con.sendMark(markType: 3);
                      },
                    ),
                    InkWell(
                      child: Container(
                        child: const Text('Marcar Salida'),
                        padding: const EdgeInsets.all(6),
                        color: Colors.lightBlue[100],
                        alignment: Alignment.center,
                      ),
                      onTap: () {
                        print("Marcar Salida");
                        _con.sendMark(markType: 4);
                      },
                    ),
                  ]),
            ),
          ],
        ),
      );
    }

    Widget CamContainer() {
      //final CameraController? cameraController = controller;
      print("Entra a CamContainer");
      if (_con.controller == null || !_con.controller!.value.isInitialized) {
        print("camcontroller is null");
        return Center(
            child: CircularProgressIndicator(
              color: Colors.indigo,
            )
          /*child: const Text(
          'Seleccione una camara',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        ),*/
        );
      } else {
        print("mostrara el campreview");
        return Listener(
          child: CameraPreview(
              _con.controller! /*,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                );
              }),*/
          ),
        );
      }
    }


    void refresh() {
      setState(() {

      });
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      final CameraController? cameraController = _con.controller;

      // App state changed before we got the chance to initialize.
      if (cameraController == null || !cameraController.value.isInitialized) {
        return;
      }

      if (state == AppLifecycleState.inactive) {
        cameraController.dispose();
      } else if (state == AppLifecycleState.resumed) {
        onNewCameraSelected(cameraController.description);
      }
    }

    Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
        final previousCameraController =_con.controller;

        if (_con.controller != null) {
            await _con.controller!.dispose();
        }

        final CameraController cameraController = CameraController(
            cameraDescription,
            ResolutionPreset.medium,
            //imageFormatGroup: ImageFormatGroup.jpeg,
        );

        _con.controller = cameraController;

        // If the controller is updated then update the UI.
        if (mounted) {
          setState(() {
            _con.controller = cameraController;
          });
        }

        cameraController.addListener(() {
          if (mounted) setState(() {});
        });

        // Initialize controller
        try {
          await cameraController.initialize();
        } on CameraException catch (e) {
          print('Error initializing camera: $e');
        }

        // Update the Boolean
        if (mounted) {
          setState(() {
            _con.isCameraInitialized = _con.controller!.value.isInitialized;
          });
        }

        if (cameraController.value.hasError) {
          MySnackbar.show(context, 'Camera error ${cameraController.value.errorDescription}');
        }

    }

    @override
    void dispose() {
      _con.controller?.dispose();
      super.dispose();
    }
}

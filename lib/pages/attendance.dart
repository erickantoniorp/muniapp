import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muniapp/utils/mycolors.dart';

import '../controllers/attendance_controller.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {

    final AttendanceController _con = AttendanceController();

    @override
    void initState() {
      // TODO: implement initState
      super.initState();

      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        _con.init(context, refresh);
      });
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
                        //sendAlert(alertType: 1);
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
                        //sendAlert(alertType: 2);
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
                        //sendAlert(alertType: 3);
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
                        //sendAlert(alertType: 1);
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

      if (_con.controller == null || !_con.controller!.value.isInitialized) {
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
}

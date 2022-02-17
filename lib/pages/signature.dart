import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muniapp/controllers/sign_controller.dart';
import 'package:muniapp/pages/signature_preview.dart';
import 'package:muniapp/utils/mycolors.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  //late SignatureController signController;
  final SignController _con = SignController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  void refresh() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            //onPressed: () => Navigator.pushNamed(context, 'home'),
            //onPressed: () => Navigator.pushReplacementNamed(context, 'home'),
          ),
          title: Text('Ingrese Firma'),
          backgroundColor: MyColors.primaryColor,
        ),
        body: Column(
            children: <Widget>[
              Signature(
                controller: (_con.signController!= null)?(_con.signController!): SignatureController(
                    penColor: Colors.blue,
                    penStrokeWidth: 3
                ),
                backgroundColor: Colors.white,
                height: MediaQuery.of(context).size.height-AppBar().preferredSize.height-143,
                width: MediaQuery.of(context).size.width,
              ),
              Spacer(),
              buildButtons(context)
            ]
        )
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _con.signController!.dispose();
    super.dispose();
  }

  Widget buildButtons(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          buildCheck(context),
          buildClear(),
        ],
      ),
    );
  }

  Widget buildCheck(BuildContext context) {
    return IconButton(
      iconSize: 36,
      icon: Icon(Icons.check, color: Colors.green),
      onPressed: _con.getSign
    );
  }

  Widget buildClear() {
    return IconButton(
      iconSize: 36,
      icon: Icon(Icons.clear, color: Colors.red),
      onPressed: () => _con.signClear,
    );
  }




}



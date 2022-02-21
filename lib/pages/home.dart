import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:muniapp/controllers/home_controller.dart';
import 'package:muniapp/utils/constant.dart';
import 'package:muniapp/utils/mycolors.dart';
import 'package:muniapp/utils/url.dart';
import 'package:muniapp/utils/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HomeController _con = HomeController();

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
    return SafeArea(
      child: Scaffold(
        key: _con.key,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
              title: const Text(Constant.main_title),
            backgroundColor: MyColors.primaryColor,
            /*flexibleSpace: Column(
                children: [
                  SizedBox(height: 40),
                  _menuDrawer(),
                  SizedBox(height: 20),
                  //_textFieldSearch()
                ],
              ),*/
          ),
          /*PreferredSize(
            preferredSize: Size.fromHeight(170),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              actions: [
                //_shoppingBag()
              ],
              flexibleSpace: Column(
                children: [
                  SizedBox(height: 40),
                  _menuDrawer(),
                  SizedBox(height: 20),
                  //_textFieldSearch()
                ],
              ),
              /*bottom: TabBar(
                indicatorColor: MyColors.primaryColor,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[400],
                isScrollable: true,
                tabs: List<Widget>.generate(_con.categories.length, (index) {
                  return Tab(
                    child: Text(_con.categories[index].name ?? ''),
                  );
                }),
              ),*///
            ),
          ),*/
        drawer: _drawer(),
          body: Container(
                  width: double.infinity,
                  child: Stack(
                      children: [
                        Positioned(
                            top: -80,
                            left: -100,
                            child: _circle()
                        ),
                        Positioned(
                            child: _textRegister(),
                            top: 65,
                            left: 27,
                        ),
                        Positioned(
                            child: _iconBack(),
                            top: 51,
                            left: -5,
                        ),
                        Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 150),
                            child: SingleChildScrollView(
                                child: Column(
                                    children: [
                                      _lottieAnimation(),
                                    ]
                                ),
                            ),
                        ),
                  ]
                  ),
              ),
          ),
    );
  }

  Widget _lottieAnimation() {
      return Container(
          margin: EdgeInsets.only(
                  top: 150,
                  bottom: MediaQuery.of(context).size.height * 0.17
              ),
          child: GestureDetector(
              onTap: () => {
                _con.sendAlert()
              },
              child: Center(
                  child: Lottie.asset(
                      'assets/json/alert8.json',
                      width: 350,
                      height: 200,
                      fit: BoxFit.fill
                  ),
              ),
          ),
      );
  }

  Widget _circle() {
    return Container(
      width: 240,
      height: 230,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: MyColors.primaryColor
      ),
    );
  }

  Widget _iconBack() {
    return IconButton(
        onPressed: ()=>{},//_con.back,
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white)
    );
  }

  Widget _textRegister() {
    return const Text(
        Constant.alert_title,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'NimbusSans'
        )
    );
  }

  Widget _menuDrawer() {
    return GestureDetector(
      onTap: _con.openDrawer,
      child: Container(
        margin: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Image.asset('assets/images/menu.png', width: 20, height: 20),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  color: MyColors.primaryColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_con.user?.firstname ?? ''} ${_con.user?.lastname ?? ''}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.email ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.phone ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                  ),
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 10),
                    child: FadeInImage(
                      image:
                            _con.user?.image != null && _con.user?.image != "-" ?
                            NetworkImage(Environment.API_FILES + '/' + _con.user!.image!):
                            Image.asset('assets/images/no-image.png').image,
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/images/no-image.png'),
                    ),
                  )

                ],
              )
          ),
          ListTile(
            onTap: _con.goToUpdatePage,
            title: Text('Editar perfil'),
            trailing: Icon(Icons.account_box),
          ),
          ListTile(
            onTap: _con.goToAttendance,
            title: Text('Asistencia'),
            trailing: Icon(Icons.access_alarm),
          ),
          ListTile(
            onTap: _con.emitPosition,
            title: Text('Emitir Posición'),
            trailing: Icon(Icons.add_location),
          ),
          ListTile(
            onTap: _con.initEmit,
            title: Text('Emitir Frecuentemente'),
            trailing: Icon(Icons.access_alarm),
          ),
          ListTile(
            onTap: _con.finishEmit,
            title: Text('Terminar Emision'),
            trailing: Icon(Icons.alarm_off_sharp),
          ),
          ListTile(
            onTap: _con.sendMark,
            title: Text('Enviar Marcación'),
            trailing: Icon(Icons.assignment_turned_in),
          ),
          ListTile(
            onTap: _con.sendMarkWithImage,
            title: Text('Enviar Marcación Con Firma'),
            trailing: Icon(Icons.assignment_ind),
          ),
          ListTile(
            onTap: _con.sendBiometrics,
            title: Text('Marcación Con Biometrico'),
            trailing: Icon(Icons.fingerprint_outlined),
          ),
          /*_con.user != null ?
          _con.user.roles.length > 1 ?
          ListTile(
            onTap: ()=>{},//_con.goToRoles,
            title: Text('Seleccionar rol'),
            trailing: Icon(Icons.person_outline),
          ) : Container() : Container(),*/
          ListTile(
            onTap: _con.logout,
            title: Text('Cerrar sesion'),
            trailing: Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {

    });
  }

  getCurrentLocation(){
    //_con.getCurrentLocation();
  }

}

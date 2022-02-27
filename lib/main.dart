import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muniapp/utils/globals.dart';
import 'package:muniapp/utils/utils.dart';
import 'package:muniapp/pages/pages.dart';


Future<void> main() async{
  try {
    WidgetsFlutterBinding.ensureInitialized();
    globalCameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error al intentar cargar camaras en Main: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //pushNotificationsProvider.onMessageListener();
  }

  @override
  Widget build(BuildContext context) {
    //Para forzar que siempre esté vertical

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: Constant.main_title,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: 'login',
      routes: {
        'login'       : (BuildContext context) => MyLoginPage(),
        'register'    : (BuildContext context) => RegisterPage(),
        'home'        : (BuildContext context) => MyHomePage(),
        'user/update' : (BuildContext context) => UserProfileUpdatePage(),
        'signature'   : (BuildContext context) => SignaturePage(),
        'attendance'  : (BuildContext context) => AttendancePage(),
/*        'roles' : (BuildContext context) => RolesPage(),
        'client/products/list' : (BuildContext context) => ClientProductsListPage(),
        'client/update' : (BuildContext context) => ClientUpdatePage(),
        'client/orders/create' : (BuildContext context) => ClientOrdersCreatePage(),
        'client/address/list' : (BuildContext context) => ClientAddressListPage(),
        'client/address/create' : (BuildContext context) => ClientAddressCreatePage(),
        'client/address/map' : (BuildContext context) => ClientAddressMapPage(),
        'client/orders/list' : (BuildContext context) => ClientOrdersListPage(),
        'client/orders/map' : (BuildContext context) => ClientOrdersMapPage(),
        'client/payments/create' : (BuildContext context) => ClientPaymentsCreatePage(),
        'client/payments/installments' : (BuildContext context) => ClientPaymentsInstallmentsPage(),
        'client/payments/status' : (BuildContext context) => ClientPaymentsStatusPage(),
        'restaurant/orders/list' : (BuildContext context) => RestaurantOrdersListPage(),
        'restaurant/categories/create' : (BuildContext context) => RestaurantCategoriesCreatePage(),
        'restaurant/products/create' : (BuildContext context) => RestaurantProductsCreatePage(),
        'delivery/orders/list' : (BuildContext context) => DeliveryOrdersListPage(),
        'delivery/orders/map' : (BuildContext context) => DeliveryOrdersMapPage(),

 */
      },
      theme: ThemeData(
        // fontFamily: 'NimbusSans',
          primaryColor: MyColors.primaryColor,
          appBarTheme: AppBarTheme(elevation: 0)
      ),
    );
  }
}


/*class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: Constant.main_title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyLoginPage(),
    );
  }
}

*/
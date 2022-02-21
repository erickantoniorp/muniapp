import 'package:flutter/material.dart';

class Environment {
//static const String API_APP         = "localhost:5000";
  //static const String API_APP           = "192.168.0.200:5000";
  static const String API_APP           = "3.217.146.100:5000";
  static const String API_USERS         = "/api/user";
  static const String API_AUTH          = "/api/auth";
  static const String API_ALERT         = "/api/alert";
  static const String API_MARK          = "/api/mark";
  static const String API_FILES         = "http://" + API_APP + "/api/uploads/";
  static const String SOCKET_SEND_ALERT = "http://" + API_APP + "/alert/send" ;
  /// SharedPreferences data key.
  static const EVENTS_KEY               = "fetch_events";

}
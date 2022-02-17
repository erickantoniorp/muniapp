import 'dart:convert';
//Clase para manejar la información de la marcación, similar a una alerta

class Mark{
  Mark({
    //this.userid,
    this.id,
    required this.type,
    required this.state,
    this.register_date,
    required this.lon,
    required this.lat,
    this.sign,
    this.biometric,
    this.batterylevel
  });

  //int ?userid;
  int ?id;
  int type;
  int state;
  String? register_date;
  String lon;
  String lat;
  String? sign;
  String? biometric;
  String? batterylevel;

  factory Mark.fromJson(String str) => Mark.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Mark.fromMap(Map<String, dynamic> json) => Mark(
    //userid: json["userid"],
    id              : json["id"],
    type            : json["type"],
    state           : json["state"],
    register_date   : json["register_date"],
    lat             : json["lat"],
    lon             : json["lon"],
    sign            : json["sign"],
    biometric       : json["biometric"],
    batterylevel    : json["batterylevel"],
  );

  Map<String, dynamic> toMap() => {
    //"userid": userid,
    "id"            : id,
    "type"          : type,
    "state"         : state,
    "register_date" : register_date,
    "lat"           : lat,
    "lon"           : lon,
    "sign"          : sign,
    "biometric"     : biometric,
    "batterylevel"  : batterylevel
  };
}


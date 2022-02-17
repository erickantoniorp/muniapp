import 'dart:convert';

class Munialert{
  Munialert({
    this.id,
    this.userid,
    required this.type,
    required this.state,
    this.register_date,
    required this.long,
    required this.lat,
    this.image,
    this.audio
  });

  int ?id;
  int ?userid;
  int type;
  int state;
  String? register_date;
  String long;
  String lat;
  String? image;
  String? audio;

  factory Munialert.fromJson(String str) => Munialert.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Munialert.fromMap(Map<String, dynamic> json) => Munialert(
    id: json["id"],
    userid: json["userid"],
    type: json["type"],
    state: json["state"],
    register_date: json["register_date"],
    lat: json["lat"],
    long: json["long"],
    image: json["image"],
    audio: json["audio"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "userid": userid,
    "type": type,
    "state": state,
    "register_date": register_date,
    "lat": lat,
    "long": long,
    "image": image,
    "audio": audio
  };
}


import 'dart:convert';

class Role {
  Role({
    required this.id,
    required this.name,
    required this.image,
    this.descr,
  });

  String id;
  String name;
  String image;
  String ?descr;

  factory Role.fromJson(String str) => Role.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Role.fromMap(Map<String, dynamic> json) => Role(
    id: json["id"].toString(),
    name: json["name"],
    image: json["image"],
    descr: json["descr"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "image": image,
    "descr": descr,
  };
}

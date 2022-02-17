import 'dart:convert';

import 'package:muniapp/models/role.dart';

class User {

  String ?id;
  String firstname;
  String lastname;
  String lastname2;
  String email;
  String phone;
  String doctype;
  String numdoc;
  String ?password;
  String ?is_available;
  String ?sessionToken;
  String ?image;
  List<Role>? roles = [];
  List<User>? toList = [];

  User({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.lastname2,
    required this.email,
    required this.phone,
    required this.doctype,
    required this.numdoc,
    this.password,
    this.sessionToken,
    this.image,
    this.roles,
    this.is_available
  });

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  fromJsonList(List<dynamic>? jsonList) {
    if (jsonList == null) return;
    jsonList.forEach((item) {
      User user = User.fromJson(item);
      toList?.add(user);
    });
  }

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    email: json["email"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    lastname2: json["lastname2"],
    phone: json["phone"],
    doctype: json["doctype"].toString(),
    numdoc: json["numdoc"],
    password: json["password"],
    image: json["image"],
    sessionToken: json["sessionToken"],
    is_available: json["is_available"].toString(),
    //createdAt: DateTime.parse(json["created_at"]),
    //updatedAt: DateTime.parse(json["updated_at"]),
    roles: List<Role>.from(json["roles"].map((x) => Role.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "email": email,
    "firstname": firstname,
    "lastname": lastname,
    "lastname2": lastname2,
    "phone": phone,
    "doctype": doctype,
    "numdoc": numdoc,
    "password": password,
    "image": image == null ? null : image,
    "sessionToken": sessionToken == null ? null :sessionToken,
    "is_available": is_available == null ? null :is_available,
    //"created_at": createdAt.toIso8601String(),
    //"updated_at": updatedAt.toIso8601String(),
    "roles": roles == null ? null : List<dynamic>.from(roles!.map((x) => x.toMap())),
  };

}

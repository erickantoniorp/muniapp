import 'dart:convert';

ResponseApi responseApiFromJson(String str) => ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {

  String message;
  String success;
  String ?error;
  dynamic data;

  ResponseApi({
    required this.message,
    required this.success,
    this.error,
    this.data
  });

  /*ResponseApi.fromJson(Map<String, dynamic> json) {

    message = json["message"];
    error = json["error"];
    success = json["success"];

    try {
      data = json['data'];
    } catch(e) {
      print('Exception data $e');
    }

  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "error": error,
    "success": success,
    "data": data,
  };
*/


  factory ResponseApi.fromJson(String str) => ResponseApi.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResponseApi.fromMap(Map<String, dynamic> json) => ResponseApi(
    message: json["message"],
    error: json["error"],
    success: json["success"],
    data: json["data"]
  );

  Map<String, dynamic> toMap() => {
    "message": message,
    "error": error,
    "success": success,
    "data": data
  };
}

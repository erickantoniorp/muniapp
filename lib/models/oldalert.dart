import 'dart:convert';

class Oldalert{
  Oldalert({
    required this.id,
    required this.tipo,
    this.fecha,
    this.hora,
    this.idusuario,
    required this.gps,
    this.foto,
    required this.nivelbateria,
    required this.estado,
    this.fotourl,
    this.fechamovil,
    this.horamovil
  });

  int id;
  int tipo;
  String? fecha;
  String? hora;
  int? idusuario;
  String gps;
  String? foto;
  int nivelbateria;
  int estado=1;
  String? fotourl;
  String? fechamovil;
  String? horamovil;

  factory Oldalert.fromJson(String str) => Oldalert.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Oldalert.fromMap(Map<String, dynamic> json) => Oldalert(
    id: json["id"],
    tipo: json["tipo"],
    fecha: json["fecha"],
    hora: json["hora"],
    idusuario: json["idusuario"],
    gps: json["gps"],
    foto: json["foto"],
    nivelbateria: json["nivelbateria"],
    estado: json["estado"],
    fotourl: json["fotourl"],
    fechamovil: json["fechamovil"],
    horamovil: json["horamovil"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "tipo": tipo,
    "fecha": fecha,
    "hora": hora,
    "idusuario": idusuario,
    "gps": gps,
    "foto": foto,
    "nivelbateria": nivelbateria,
    "estado": estado,
    "fotourl": fotourl,
    "fechamovil": fechamovil,
    "horamovil": horamovil,
  };
}


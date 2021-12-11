import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class ObjetNom extends JsonObject {
  ObjetNom({
    this.name,
    this.id,
  });

  final String? name;
  final String? id;

  factory ObjetNom.fromRawJson(String str) => ObjetNom.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ObjetNom.fromJson(Map<String, dynamic> json) => ObjetNom(
    name: json["L"],
    id: json["N"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "L": name,
    "N": id,
  };
}

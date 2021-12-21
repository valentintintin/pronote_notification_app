import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class NameObject extends JsonObject {
  NameObject({
    this.name,
    this.id,
  });

  final String? name; // L
  final String? id; // N

  factory NameObject.fromRawJson(String str) => NameObject.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory NameObject.fromJson(Map<String, dynamic> json) => NameObject(
    name: json["L"],
    id: json["N"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "L": name,
    "N": id,
  };
}

import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesParams implements JsonObject {
  DonneesParams({
    this.uuid,
    this.identifiantNav,
  });

  final String? uuid;
  final String? identifiantNav;

  factory DonneesParams.fromRawJson(String str) => DonneesParams.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesParams.fromJson(Map<String, dynamic> json) => DonneesParams(
    uuid: json["Uuid"],
    identifiantNav: json["identifiantNav"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "Uuid": uuid,
    "identifiantNav": identifiantNav,
  };
}
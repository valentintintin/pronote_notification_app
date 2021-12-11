import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesNavigation implements JsonObject {
  DonneesNavigation({
    this.onglet,
    this.ongletPrec,
  });

  final int? onglet;
  final int? ongletPrec;

  factory DonneesNavigation.fromRawJson(String str) => DonneesNavigation.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesNavigation.fromJson(Map<String, dynamic> json) => DonneesNavigation(
    onglet: json["onglet"],
    ongletPrec: json["ongletPrec"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "onglet": onglet,
    "ongletPrec": ongletPrec,
  };
}
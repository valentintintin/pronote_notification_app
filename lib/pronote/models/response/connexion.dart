import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesConnexion extends JsonObject {
  DonneesConnexion({
    this.libelleUtil,
    this.modeSecurisationParDefaut,
    this.cle,
    this.derniereConnexion,
  });

  final String? libelleUtil;
  final int? modeSecurisationParDefaut;
  final String? cle;
  final DerniereConnexion? derniereConnexion;

  factory DonneesConnexion.fromRawJson(String str) => DonneesConnexion.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesConnexion.fromJson(Map<String, dynamic> json) => DonneesConnexion(
    libelleUtil: json["libelleUtil"],
    modeSecurisationParDefaut: json["modeSecurisationParDefaut"],
    cle: json["cle"],
    derniereConnexion: json["derniereConnexion"] == null ? null : DerniereConnexion.fromJson(json["derniereConnexion"]),
  );

  Map<String, dynamic> toJson() => {
    "libelleUtil": libelleUtil,
    "modeSecurisationParDefaut": modeSecurisationParDefaut,
    "cle": cle,
    "derniereConnexion": derniereConnexion?.toJson(),
  };
}

class DerniereConnexion extends JsonObject {
  DerniereConnexion({
    this.t,
    this.v,
  });

  final int? t;
  final String? v;

  factory DerniereConnexion.fromRawJson(String str) => DerniereConnexion.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DerniereConnexion.fromJson(Map<String, dynamic> json) => DerniereConnexion(
    t: json["_T"],
    v: json["V"],
  );

  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v,
  };
}

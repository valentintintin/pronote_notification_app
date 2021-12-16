import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';
import 'package:pronote_notification/pronote/models/response/name_object.dart';

class DonneesParamsUser extends JsonObject {
  DonneesParamsUser({
    this.ressource,
  });

  final ParamsUserRessource? ressource;

  factory DonneesParamsUser.fromRawJson(String str) => DonneesParamsUser.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesParamsUser.fromJson(Map<String, dynamic> json) => DonneesParamsUser(
    ressource: json["ressource"] == null ? null : ParamsUserRessource.fromJson(json["ressource"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "ressource": ressource == null ? null : ressource!.toJson(),
  };
}

class ParamsUserRessource extends JsonObject {
  ParamsUserRessource({
    this.userFullName,
    this.ine,
    this.g,
    this.p,
    this.classeDEleve,
    this.school,
    this.listeOngletsPourPeriodes,
  });

  final String? userFullName;
  final String? ine;
  final int? g;
  final int? p;
  final NameObject? classeDEleve;
  final Etablissement? school;
  final ListeOngletsPourPeriodes? listeOngletsPourPeriodes;

  factory ParamsUserRessource.fromRawJson(String str) => ParamsUserRessource.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ParamsUserRessource.fromJson(Map<String, dynamic> json) => ParamsUserRessource(
    userFullName: json["L"],
    ine: json["N"],
    g: json["G"],
    p: json["P"],
    classeDEleve: json["classeDEleve"] == null ? null : NameObject.fromJson(json["classeDEleve"]),
    school: json["Etablissement"] == null ? null : Etablissement.fromJson(json["Etablissement"]),
    listeOngletsPourPeriodes: json["listeOngletsPourPeriodes"] == null ? null : ListeOngletsPourPeriodes.fromJson(json["listeOngletsPourPeriodes"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "L": userFullName,
    "N": ine,
    "G": g,
    "P": p,
    "classeDEleve": classeDEleve == null ? null : classeDEleve!.toJson(),
    "Etablissement": school == null ? null : school!.toJson(),
    "listeOngletsPourPeriodes": listeOngletsPourPeriodes == null ? null : listeOngletsPourPeriodes!.toJson(),
  };
}

class Etablissement extends JsonObject {
  Etablissement({
    this.t,
    this.nameValue,
  });

  final int? t;
  final NameObject? nameValue;

  factory Etablissement.fromRawJson(String str) => Etablissement.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Etablissement.fromJson(Map<String, dynamic> json) => Etablissement(
    t: json["_T"],
    nameValue: json["V"] == null ? null : NameObject.fromJson(json["V"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": nameValue == null ? null : nameValue!.toJson(),
  };
}

class ListeOngletsPourPeriodes extends JsonObject {
  ListeOngletsPourPeriodes({
    this.t,
    this.periodes,
  });

  final int? t;
  final List<PeriodeV>? periodes;

  factory ListeOngletsPourPeriodes.fromRawJson(String str) => ListeOngletsPourPeriodes.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListeOngletsPourPeriodes.fromJson(Map<String, dynamic> json) => ListeOngletsPourPeriodes(
    t: json["_T"],
    periodes: json["V"] == null ? null : List<PeriodeV>.from(json["V"].map((x) => PeriodeV.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": periodes == null ? null : List<dynamic>.from(periodes!.map((x) => x.toJson())),
  };
}

class PeriodeV extends JsonObject {
  PeriodeV({
    this.g,
    this.listePeriodes,
    this.periodeParDefaut,
  });

  final int? g;
  final ListePeriodes? listePeriodes;
  final Etablissement? periodeParDefaut;

  factory PeriodeV.fromRawJson(String str) => PeriodeV.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory PeriodeV.fromJson(Map<String, dynamic> json) => PeriodeV(
    g: json["G"],
    listePeriodes: json["listePeriodes"] == null ? null : ListePeriodes.fromJson(json["listePeriodes"]),
    periodeParDefaut: json["periodeParDefaut"] == null ? null : Etablissement.fromJson(json["periodeParDefaut"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "G": g,
    "listePeriodes": listePeriodes == null ? null : listePeriodes!.toJson(),
    "periodeParDefaut": periodeParDefaut == null ? null : periodeParDefaut!.toJson(),
  };
}

class ListePeriodes extends JsonObject {
  ListePeriodes({
    this.t,
    this.periodes,
  });

  final int? t;
  final List<NameObject>? periodes;

  factory ListePeriodes.fromRawJson(String str) => ListePeriodes.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListePeriodes.fromJson(Map<String, dynamic> json) => ListePeriodes(
    t: json["_T"],
    periodes: json["V"] == null ? null : List<NameObject>.from(json["V"].map((x) => NameObject.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": periodes == null ? null : List<dynamic>.from(periodes!.map((x) => x.toJson())),
  };
}

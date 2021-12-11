import 'dart:convert';

import '../request_data.dart';

class DonneesIdentification implements JsonObject {
  DonneesIdentification({
    this.genreConnexion,
    this.genreEspace,
    this.identifiant,
    this.pourEnt,
    this.enConnexionAuto,
    this.demandeConnexionAuto,
    this.demandeConnexionAppliMobile,
    this.demandeConnexionAppliMobileJeton,
    this.uuidAppliMobile,
    this.loginTokenSav,
  });

  final int? genreConnexion;
  final int? genreEspace;
  final String? identifiant;
  final bool? pourEnt;
  final bool? enConnexionAuto;
  final bool? demandeConnexionAuto;
  final bool? demandeConnexionAppliMobile;
  final bool? demandeConnexionAppliMobileJeton;
  final String? uuidAppliMobile;
  final String? loginTokenSav;

  @override
  String toRawJson() => json.encode(toJson());

  @override
  Map<String, dynamic> toJson() => {
    "genreConnexion": genreConnexion,
    "genreEspace": genreEspace,
    "identifiant": identifiant,
    "pourENT": pourEnt,
    "enConnexionAuto": enConnexionAuto,
    "demandeConnexionAuto": demandeConnexionAuto,
    "demandeConnexionAppliMobile": demandeConnexionAppliMobile,
    "demandeConnexionAppliMobileJeton": demandeConnexionAppliMobileJeton,
    "uuidAppliMobile": uuidAppliMobile,
    "loginTokenSAV": loginTokenSav,
  };
}
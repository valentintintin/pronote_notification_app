import 'dart:convert';
import 'dart:core';

import 'package:pronote_notification/pronote/models/request_data.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';

class DonneesInfo extends JsonObject {
  DonneesInfo({
    this.identifiantNav,
    this.avecMembre,
    this.pourNouvelleCaledonie,
    this.genreImageConnexion,
    this.urlImageConnexion,
    this.logoProduitCss,
    this.theme,
    this.nomEtablissement,
    this.nomEtablissementConnexion,
    this.anneeScolaire,
    this.urlSiteIndexEducation,
    this.urlSiteInfosHebergement,
    this.version,
    this.versionPn,
    this.millesime,
    this.langue,
    this.langId,
    this.lienMentions,
    this.espaces,
  });

  final String? identifiantNav;
  final bool? avecMembre;
  final bool? pourNouvelleCaledonie;
  final int? genreImageConnexion;
  final String? urlImageConnexion;
  final String? logoProduitCss;
  final int? theme;
  final String? nomEtablissement;
  final String? nomEtablissementConnexion;
  final String? anneeScolaire;
  final ValueObject? urlSiteIndexEducation;
  final ValueObject? urlSiteInfosHebergement;
  final String? version;
  final String? versionPn;
  final String? millesime;
  final String? langue;
  final int? langId;
  final String? lienMentions;
  final ListeEspace? espaces;

  factory DonneesInfo.fromRawJson(String str) => DonneesInfo.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesInfo.fromJson(Map<String, dynamic> json) => DonneesInfo(
    identifiantNav: json["identifiantNav"],
    avecMembre: json["avecMembre"],
    pourNouvelleCaledonie: json["pourNouvelleCaledonie"],
    genreImageConnexion: json["genreImageConnexion"],
    urlImageConnexion: json["urlImageConnexion"],
    logoProduitCss: json["logoProduitCss"],
    theme: json["Theme"],
    nomEtablissement: json["NomEtablissement"],
    nomEtablissementConnexion: json["NomEtablissementConnexion"],
    anneeScolaire: json["anneeScolaire"],
    urlSiteIndexEducation: json["urlSiteIndexEducation"] == null ? null : ValueObject.fromJson(json["urlSiteIndexEducation"]),
    urlSiteInfosHebergement: json["urlSiteInfosHebergement"] == null ? null : ValueObject.fromJson(json["urlSiteInfosHebergement"]),
    version: json["version"],
    versionPn: json["versionPN"],
    millesime: json["millesime"],
    langue: json["langue"],
    langId: json["langID"],
    lienMentions: json["lienMentions"],
    espaces: json["espaces"] == null ? null : ListeEspace.fromJson(json["espaces"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "identifiantNav": identifiantNav,
    "avecMembre": avecMembre,
    "pourNouvelleCaledonie": pourNouvelleCaledonie,
    "genreImageConnexion": genreImageConnexion,
    "urlImageConnexion": urlImageConnexion,
    "logoProduitCss": logoProduitCss,
    "Theme": theme,
    "NomEtablissement": nomEtablissement,
    "NomEtablissementConnexion": nomEtablissementConnexion,
    "anneeScolaire": anneeScolaire,
    "urlSiteIndexEducation": urlSiteIndexEducation?.toJson(),
    "urlSiteInfosHebergement": urlSiteInfosHebergement?.toJson(),
    "version": version,
    "versionPN": versionPn,
    "millesime": millesime,
    "langue": langue,
    "langID": langId,
    "lienMentions": lienMentions,
    "espaces": espaces?.toJson(),
  };
}

class ListeEspace extends JsonObject {
  ListeEspace({
    this.t,
    this.v,
  });

  final int? t;
  final List<Espace>? v;

  factory ListeEspace.fromRawJson(String str) => ListeEspace.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListeEspace.fromJson(Map<String, dynamic> json) => ListeEspace(
    t: json["_T"],
    v: json["V"] == null ? null : List<Espace>.from(json["V"].map((x) => Espace.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v == null ? null : List<dynamic>.from(v!.map((x) => x.toJson())),
  };
}

class Espace extends JsonObject {
  Espace({
    this.g,
    this.l,
    this.url,
  });

  final int? g;
  final String? l;
  final String? url;

  factory Espace.fromRawJson(String str) => Espace.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Espace.fromJson(Map<String, dynamic> json) => Espace(
    g: json["G"],
    l: json["L"],
    url: json["url"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "G": g,
    "L": l,
    "url": url,
  };
}

import 'dart:convert';
import 'dart:core';
import 'dart:core';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesInfo extends JsonObject {
  DonneesInfo({
    this.identifiantNav,
    this.listePolices,
    this.avecMembre,
    this.pourNouvelleCaledonie,
    this.genreImageConnexion,
    this.urlImageConnexion,
    this.logoProduitCss,
    this.theme,
    this.mentionsPagesPubliques,
    this.nomEtablissement,
    this.nomEtablissementConnexion,
    this.logo,
    this.anneeScolaire,
    this.urlSiteIndexEducation,
    this.urlSiteInfosHebergement,
    this.version,
    this.versionPn,
    this.millesime,
    this.langue,
    this.langId,
    this.listeLangues,
    this.lienMentions,
    this.espaces,
  });

  final String? identifiantNav;
  final ListePolices? listePolices;
  final bool? avecMembre;
  final bool? pourNouvelleCaledonie;
  final int? genreImageConnexion;
  final String? urlImageConnexion;
  final String? logoProduitCss;
  final int? theme;
  final MentionsPagesPubliques? mentionsPagesPubliques;
  final String? nomEtablissement;
  final String? nomEtablissementConnexion;
  final Logo? logo;
  final String? anneeScolaire;
  final UrlSiteIndexEducation? urlSiteIndexEducation;
  final UrlSiteIndexEducation? urlSiteInfosHebergement;
  final String? version;
  final String? versionPn;
  final String? millesime;
  final String? langue;
  final int? langId;
  final ListeLangues? listeLangues;
  final String? lienMentions;
  final Espaces? espaces;

  factory DonneesInfo.fromRawJson(String str) => DonneesInfo.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesInfo.fromJson(Map<String, dynamic> json) => DonneesInfo(
    identifiantNav: json["identifiantNav"],
    listePolices: json["listePolices"] == null ? null : ListePolices.fromJson(json["listePolices"]),
    avecMembre: json["avecMembre"],
    pourNouvelleCaledonie: json["pourNouvelleCaledonie"],
    genreImageConnexion: json["genreImageConnexion"],
    urlImageConnexion: json["urlImageConnexion"],
    logoProduitCss: json["logoProduitCss"],
    theme: json["Theme"],
    mentionsPagesPubliques: json["mentionsPagesPubliques"] == null ? null : MentionsPagesPubliques.fromJson(json["mentionsPagesPubliques"]),
    nomEtablissement: json["NomEtablissement"],
    nomEtablissementConnexion: json["NomEtablissementConnexion"],
    logo: json["logo"] == null ? null : Logo.fromJson(json["logo"]),
    anneeScolaire: json["anneeScolaire"],
    urlSiteIndexEducation: json["urlSiteIndexEducation"] == null ? null : UrlSiteIndexEducation.fromJson(json["urlSiteIndexEducation"]),
    urlSiteInfosHebergement: json["urlSiteInfosHebergement"] == null ? null : UrlSiteIndexEducation.fromJson(json["urlSiteInfosHebergement"]),
    version: json["version"],
    versionPn: json["versionPN"],
    millesime: json["millesime"],
    langue: json["langue"],
    langId: json["langID"],
    listeLangues: json["listeLangues"] == null ? null : ListeLangues.fromJson(json["listeLangues"]),
    lienMentions: json["lienMentions"],
    espaces: json["espaces"] == null ? null : Espaces.fromJson(json["espaces"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "identifiantNav": identifiantNav,
    "listePolices": listePolices?.toJson(),
    "avecMembre": avecMembre,
    "pourNouvelleCaledonie": pourNouvelleCaledonie,
    "genreImageConnexion": genreImageConnexion,
    "urlImageConnexion": urlImageConnexion,
    "logoProduitCss": logoProduitCss,
    "Theme": theme,
    "mentionsPagesPubliques": mentionsPagesPubliques?.toJson(),
    "NomEtablissement": nomEtablissement,
    "NomEtablissementConnexion": nomEtablissementConnexion,
    "logo": logo?.toJson(),
    "anneeScolaire": anneeScolaire,
    "urlSiteIndexEducation": urlSiteIndexEducation?.toJson(),
    "urlSiteInfosHebergement": urlSiteInfosHebergement?.toJson(),
    "version": version,
    "versionPN": versionPn,
    "millesime": millesime,
    "langue": langue,
    "langID": langId,
    "listeLangues": listeLangues?.toJson(),
    "lienMentions": lienMentions,
    "espaces": espaces?.toJson(),
  };
}

class Espaces extends JsonObject {
  Espaces({
    this.t,
    this.v,
  });

  final int? t;
  final List<EspacesV>? v;

  factory Espaces.fromRawJson(String str) => Espaces.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Espaces.fromJson(Map<String, dynamic> json) => Espaces(
    t: json["_T"],
    v: json["V"] == null ? null : List<EspacesV>.from(json["V"].map((x) => EspacesV.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v == null ? null : List<dynamic>.from(v!.map((x) => x.toJson())),
  };
}

class EspacesV extends JsonObject {
  EspacesV({
    this.g,
    this.l,
    this.url,
  });

  final int? g;
  final String? l;
  final String? url;

  factory EspacesV.fromRawJson(String str) => EspacesV.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory EspacesV.fromJson(Map<String, dynamic> json) => EspacesV(
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

class ListeLangues extends JsonObject {
  ListeLangues({
    this.t,
    this.v,
  });

  final int? t;
  final List<ListeLanguesV>? v;

  factory ListeLangues.fromRawJson(String str) => ListeLangues.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListeLangues.fromJson(Map<String, dynamic> json) => ListeLangues(
    t: json["_T"],
    v: json["V"] == null ? null : List<ListeLanguesV>.from(json["V"].map((x) => ListeLanguesV.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v == null ? null : List<dynamic>.from(v!.map((x) => x.toJson())),
  };
}

class ListeLanguesV extends JsonObject {
  ListeLanguesV({
    this.langId,
    this.description,
  });

  final int? langId;
  final String? description;

  factory ListeLanguesV.fromRawJson(String str) => ListeLanguesV.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListeLanguesV.fromJson(Map<String, dynamic> json) => ListeLanguesV(
    langId: json["langID"],
    description: json["description"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "langID": langId,
    "description": description,
  };
}

class ListePolices extends JsonObject {
  ListePolices({
    this.t,
    this.v,
  });

  final int? t;
  final List<ListePolicesV>? v;

  factory ListePolices.fromRawJson(String str) => ListePolices.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListePolices.fromJson(Map<String, dynamic> json) => ListePolices(
    t: json["_T"],
    v: json["V"] == null ? null : List<ListePolicesV>.from(json["V"].map((x) => ListePolicesV.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v == null ? null : List<dynamic>.from(v!.map((x) => x.toJson())),
  };
}

class ListePolicesV extends JsonObject {
  ListePolicesV({
    this.l,
  });

  final String? l;

  factory ListePolicesV.fromRawJson(String str) => ListePolicesV.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListePolicesV.fromJson(Map<String, dynamic> json) => ListePolicesV(
    l: json["L"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "L": l,
  };
}

class Logo extends JsonObject {
  Logo({
    this.t,
    this.v,
  });

  final int? t;
  final int? v;

  factory Logo.fromRawJson(String str) => Logo.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Logo.fromJson(Map<String, dynamic> json) => Logo(
    t: json["_T"],
    v: json["V"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v,
  };
}

class MentionsPagesPubliques extends JsonObject {
  MentionsPagesPubliques({
    this.lien,
  });

  final UrlSiteIndexEducation? lien;

  factory MentionsPagesPubliques.fromRawJson(String str) => MentionsPagesPubliques.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory MentionsPagesPubliques.fromJson(Map<String, dynamic> json) => MentionsPagesPubliques(
    lien: json["lien"] == null ? null : UrlSiteIndexEducation.fromJson(json["lien"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "lien": lien?.toJson(),
  };
}

class UrlSiteIndexEducation extends JsonObject {
  UrlSiteIndexEducation({
    this.t,
    this.v,
  });

  final int? t;
  final String? v;

  factory UrlSiteIndexEducation.fromRawJson(String str) => UrlSiteIndexEducation.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory UrlSiteIndexEducation.fromJson(Map<String, dynamic> json) => UrlSiteIndexEducation(
    t: json["_T"],
    v: json["V"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": v,
  };
}

class Signature extends JsonObject {
  Signature({
    this.modeExclusif,
  });

  final bool? modeExclusif;

  factory Signature.fromRawJson(String str) => Signature.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Signature.fromJson(Map<String, dynamic> json) => Signature(
    modeExclusif: json["ModeExclusif"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "ModeExclusif": modeExclusif,
  };
}

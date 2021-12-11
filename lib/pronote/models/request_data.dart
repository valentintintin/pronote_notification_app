import 'dart:convert';

abstract class JsonObject {
  String toRawJson();
  Map<String, dynamic> toJson();
}

class RequestData<T extends JsonObject> {
  RequestData({
    this.session,
    this.numeroOrdre,
    this.nom,
    this.donneesSec,
  });

  final int? session;
  final String? numeroOrdre;
  final String? nom;
  final RequestDonneesSec<T>? donneesSec;

  factory RequestData.fromRawJson(String str, Function fromJsonModel) => RequestData.fromJson(json.decode(str), fromJsonModel);

  String toRawJson() => json.encode(toJson());

  factory RequestData.fromJson(Map<String, dynamic> json, Function fromJsonModel) => RequestData(
    session: json["session"],
    numeroOrdre: json["numeroOrdre"],
    nom: json["nom"],
    donneesSec: RequestDonneesSec.fromJson(json["donneesSec"], fromJsonModel),
  );

  Map<String, dynamic> toJson() => {
    "session": session,
    "numeroOrdre": numeroOrdre,
    "nom": nom,
    "donneesSec": donneesSec?.toJson(),
  };
}

class RequestDonneesSec<T extends JsonObject> {
  RequestDonneesSec({
    this.donnees,
    this.nom,
    this.signature,
  });

  final T? donnees;
  final String? nom;
  final RequestDonneesSignature? signature;

  factory RequestDonneesSec.fromRawJson(String str, Function fromJsonModel) => RequestDonneesSec.fromJson(json.decode(str), fromJsonModel);

  String toRawJson() => json.encode(toJson());

  factory RequestDonneesSec.fromJson(Map<String, dynamic> json, Function fromJsonModel) => RequestDonneesSec(
    donnees: fromJsonModel(json["donnees"]),
    nom: json["nom"],
  );

  Map<String, dynamic> toJson() => {
    "donnees": donnees?.toJson(),
    "nom": nom,
    "_Signature_": signature?.toJson()
  };
}

class RequestDonneesSignature extends JsonObject {
  RequestDonneesSignature({
    this.onglet,
  });

  final int? onglet;

  factory RequestDonneesSignature.fromRawJson(String str) => RequestDonneesSignature.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory RequestDonneesSignature.fromJson(Map<String, dynamic> json) => RequestDonneesSignature(
    onglet: json["onglet"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "onglet": onglet,
  };
}

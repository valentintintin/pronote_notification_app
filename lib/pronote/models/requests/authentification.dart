import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesAuthentification extends JsonObject {
  DonneesAuthentification({
    this.connexion,
    this.challenge,
    this.espace,
  });

  final int? connexion;
  final String? challenge;
  final int? espace;

  factory DonneesAuthentification.fromRawJson(String str) => DonneesAuthentification.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesAuthentification.fromJson(Map<String, dynamic> json) => DonneesAuthentification(
    connexion: json["connexion"],
    challenge: json["challenge"],
    espace: json["espace"],
  );

  Map<String, dynamic> toJson() => {
    "connexion": connexion,
    "challenge": challenge,
    "espace": espace,
  };
}
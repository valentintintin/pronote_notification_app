import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesChallenge extends JsonObject {
  DonneesChallenge({
    this.alea, // scramble
    this.modeCompMdp,
    this.modeCompLog,
    this.challenge,
  });

  final String? alea;
  final int? modeCompMdp;
  final int? modeCompLog;
  final String? challenge;

  factory DonneesChallenge.fromRawJson(String str) => DonneesChallenge.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesChallenge.fromJson(Map<String, dynamic> json) => DonneesChallenge(
    alea: json["alea"],
    modeCompMdp: json["modeCompMdp"],
    modeCompLog: json["modeCompLog"],
    challenge: json["challenge"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "alea": alea,
    "modeCompMdp": modeCompMdp,
    "modeCompLog": modeCompLog,
    "challenge": challenge,
  };
}
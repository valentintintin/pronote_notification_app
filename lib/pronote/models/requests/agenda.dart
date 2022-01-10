import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';

class DonneesAgendaRequest implements JsonObject {
  DonneesAgendaRequest({
    this.numeroSemaine,
    this.NumeroSemaine,
  });

  final int? numeroSemaine;
  final int? NumeroSemaine;

  factory DonneesAgendaRequest.fromRawJson(String str) => DonneesAgendaRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesAgendaRequest.fromJson(Map<String, dynamic> json) => DonneesAgendaRequest(
    numeroSemaine: json["numeroSemaine"],
    NumeroSemaine: json["NumeroSemaine"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "numeroSemaine": numeroSemaine,
    "NumeroSemaine": NumeroSemaine,
  };
}
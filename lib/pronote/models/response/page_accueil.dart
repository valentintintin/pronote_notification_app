import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';
import 'package:pronote_notification/pronote/models/response/objet_nom.dart';

class DonneesPageAccueil extends JsonObject {
  DonneesPageAccueil({
    this.notes,
  });

  final Notes? notes;

  factory DonneesPageAccueil.fromRawJson(String str) => DonneesPageAccueil.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesPageAccueil.fromJson(Map<String, dynamic> json) => DonneesPageAccueil(
    notes: json["notes"] == null ? null : Notes.fromJson(json["notes"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "notes": notes == null ? null : notes!.toJson(),
  };
}

class Notes extends JsonObject {
  Notes({
    this.listeDevoirs,
  });

  final ListeDevoirs? listeDevoirs;

  factory Notes.fromRawJson(String str) => Notes.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
    listeDevoirs: json["listeDevoirs"] == null ? null : ListeDevoirs.fromJson(json["listeDevoirs"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "listeDevoirs": listeDevoirs == null ? null : listeDevoirs!.toJson(),
  };
}

class ListeDevoirs extends JsonObject {
  ListeDevoirs({
    this.t,
    this.devoirs,
  });

  final int? t;
  final List<Devoir>? devoirs;

  factory ListeDevoirs.fromRawJson(String str) => ListeDevoirs.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ListeDevoirs.fromJson(Map<String, dynamic> json) => ListeDevoirs(
    t: json["_T"],
    devoirs: json["V"] == null ? null : List<Devoir>.from(json["V"].map((x) => Devoir.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": devoirs == null ? null : List<dynamic>.from(devoirs!.map((x) => x.toJson())),
  };
}

class Devoir extends JsonObject {
  Devoir({
    this.id,
    this.g,
    this.note,
    this.bareme,
    this.baremeParDefaut,
    this.date,
    this.cours,
    this.periode,
  });

  final String? id;
  final int? g;
  final ObjetValeur? note;
  final ObjetValeur? bareme;
  final ObjetValeur? baremeParDefaut;
  final ObjetValeur? date;
  final Service? cours;
  final Periode? periode;

  factory Devoir.fromRawJson(String str) => Devoir.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Devoir.fromJson(Map<String, dynamic> json) => Devoir(
    id: json["N"],
    g: json["G"],
    note: json["note"] == null ? null : ObjetValeur.fromJson(json["note"]),
    bareme: json["bareme"] == null ? null : ObjetValeur.fromJson(json["bareme"]),
    baremeParDefaut: json["baremeParDefaut"] == null ? null : ObjetValeur.fromJson(json["baremeParDefaut"]),
    date: json["date"] == null ? null : ObjetValeur.fromJson(json["date"]),
    cours: json["service"] == null ? null : Service.fromJson(json["service"]),
    periode: json["periode"] == null ? null : Periode.fromJson(json["periode"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "N": id,
    "G": g,
    "note": note == null ? null : note!.toJson(),
    "bareme": bareme == null ? null : bareme!.toJson(),
    "baremeParDefaut": baremeParDefaut == null ? null : baremeParDefaut!.toJson(),
    "date": date == null ? null : date!.toJson(),
    "service": cours == null ? null : cours!.toJson(),
    "periode": periode == null ? null : periode!.toJson(),
  };

  @override
  String toString() {
    String result = '';
    
    String? noteValue = note?.valeur;
    
    if (noteValue == '|1') {
      result += 'absent';
    } else if (noteValue != null) {
      result += noteValue;

      if (bareme?.valeur != null) {
        result += '/' + bareme!.valeur!;
      }
    } else {
      throw Exception('Données incorrects pour le devoir');
    }
    
    if (cours?.service?.name != null) {
      result += ' en ' + cours!.service!.name!;
    }
    
    if (date?.valeur != null) {
      result += ' le ' + date!.valeur!;
    }
    
    return result;
  }
}

class ObjetValeur extends JsonObject {
  ObjetValeur({
    this.id,
    this.valeur,
  });

  final int? id;
  final String? valeur;

  factory ObjetValeur.fromRawJson(String str) => ObjetValeur.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ObjetValeur.fromJson(Map<String, dynamic> json) => ObjetValeur(
    id: json["_T"],
    valeur: json["V"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": valeur,
  };
}

class Periode extends JsonObject {
  Periode({
    this.id,
    this.periode,
  });

  final int? id;
  final ObjetNom? periode;

  factory Periode.fromRawJson(String str) => Periode.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Periode.fromJson(Map<String, dynamic> json) => Periode(
    id: json["_T"],
    periode: json["V"] == null ? null : ObjetNom.fromJson(json["V"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": periode == null ? null : periode!.toJson(),
  };
}

class Service extends JsonObject {
  Service({
    this.id,
    this.service,
  });

  final int? id;
  final ObjetNom? service;

  factory Service.fromRawJson(String str) => Service.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["_T"],
    service: json["V"] == null ? null : ObjetNom.fromJson(json["V"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": service == null ? null : service!.toJson(),
  };
}

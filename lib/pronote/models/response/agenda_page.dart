import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';
import 'package:pronote_notification/pronote/models/response/home_page.dart';
import 'package:pronote_notification/pronote/models/response/name_object.dart';

class DonneesAgenda extends JsonObject {
  DonneesAgenda({
    this.avecCoursAnnule,
    this.classes,
    this.absences,
  });

  final bool? avecCoursAnnule;
  final List<Class>? classes;
  final Absences? absences;

  factory DonneesAgenda.fromRawJson(String str) => DonneesAgenda.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DonneesAgenda.fromJson(Map<String, dynamic> json) => DonneesAgenda(
    avecCoursAnnule: json["avecCoursAnnule"],
    classes: json["ListeCours"] == null ? null : List<Class>.from(json["ListeCours"].map((x) => Class.fromJson(x))),
    absences: Absences.fromJson(json["absences"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "avecCoursAnnule": avecCoursAnnule,
    "ListeCours": classes == null ? null : List<dynamic>.from(classes!.map((x) => x.toJson())),
    "absences": absences?.toJson(),
  };
}

class Class extends JsonObject {
  Class({
    this.id,
    this.duration,
    this.date,
    this.color,
    this.contentsList,
    this.status,
    this.isCanceled,
  });

  final String? id;
  final int? duration;
  final ValueObject? date;
  final String? color;
  final ClassContentList? contentsList;
  final String? status;
  final bool? isCanceled;

  factory Class.fromRawJson(String str) => Class.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Class.fromJson(Map<String, dynamic> json) => Class(
    id: json["N"],
    duration: json["duree"],
    date: json["DateDuCours"] == null ? null : ValueObject.fromJson(json["DateDuCours"]),
    color: json["CouleurFond"],
    contentsList: json["ListeContenus"] == null ? null : ClassContentList.fromJson(json["ListeContenus"]),
    status: json["Statut"],
    isCanceled: json["estAnnule"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "N": id,
    "duree": duration,
    "DateDuCours": date == null ? null : date!.toJson(),
    "CouleurFond": color,
    "ListeContenus": contentsList == null ? null : contentsList!.toJson(),
    "Statut": status,
    "estAnnule": isCanceled,
  };

  @override
  String toString() {
    String result = getCourse();
    
    if (date?.value?.isNotEmpty == true) {
      result += ' le ' + date!.value!;
    }
    
    return result;
  }
  
  String getCourse() {
    if (contentsList?.contents?.isNotEmpty == true) {
      return contentsList!.contents!.first.name!;
    }
    
    return 'Matière inconnue';
  }
  
  String getTeacher() {
    if ((contentsList?.contents?.length ?? 0) >= 2) {
      return contentsList!.contents![1].name!;
    }
    
    return 'Enseignant inconnu';
  }
  
  String getRoom() {
    if ((contentsList?.contents?.length ?? 0) >= 3) {
      return contentsList!.contents!.last.name!;
    }
    
    return 'Salle inconnue';
  }
}

class ClassContentList extends JsonObject {
  ClassContentList({
    this.id,
    this.contents,
  });

  final int? id;
  final List<NameObject>? contents;

  factory ClassContentList.fromRawJson(String str) => ClassContentList.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ClassContentList.fromJson(Map<String, dynamic> json) => ClassContentList(
    id: json["_T"],
    contents: json["V"] == null ? null : List<NameObject>.from(json["V"].map((x) => NameObject.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": contents == null ? null : List<dynamic>.from(contents!.map((x) => x.toJson())),
  };
}

class Absences extends JsonObject {
  Absences({
    this.joursCycle,
  });

  final JoursCycle? joursCycle;

  factory Absences.fromRawJson(String str) => Absences.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Absences.fromJson(Map<String, dynamic> json) => Absences(
    joursCycle: JoursCycle.fromJson(json["joursCycle"]),
  );

  Map<String, dynamic> toJson() => {
    "joursCycle": joursCycle != null ? joursCycle!.toJson() : null,
  };
}

class JoursCycle extends JsonObject {
  JoursCycle({
    this.t,
    this.jourCycle,
  });

  final int? t;
  final List<JoursCycleV>? jourCycle;

  factory JoursCycle.fromRawJson(String str) => JoursCycle.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JoursCycle.fromJson(Map<String, dynamic> json) => JoursCycle(
    t: json["_T"],
    jourCycle: List<JoursCycleV>.from(json["V"].map((x) => JoursCycleV.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": jourCycle != null ? List<dynamic>.from(jourCycle!.map((x) => x.toJson())) : null,
  };
}

class JoursCycleV extends JsonObject {
  JoursCycleV({
    this.jourCycle,
    this.numeroSemaine,
  });

  final int? jourCycle;
  final int? numeroSemaine;

  factory JoursCycleV.fromRawJson(String str) => JoursCycleV.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JoursCycleV.fromJson(Map<String, dynamic> json) => JoursCycleV(
    jourCycle: json["jourCycle"],
    numeroSemaine: json["numeroSemaine"],
  );

  Map<String, dynamic> toJson() => {
    "jourCycle": jourCycle,
    "numeroSemaine": numeroSemaine,
  };
}
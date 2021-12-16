import 'dart:convert';

import 'package:pronote_notification/pronote/models/request_data.dart';
import 'package:pronote_notification/pronote/models/response/name_object.dart';

class HomePage extends JsonObject {
  HomePage({
    this.exams,
  });

  final Exams? exams;

  factory HomePage.fromRawJson(String str) => HomePage.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory HomePage.fromJson(Map<String, dynamic> json) => HomePage(
    exams: json["notes"] == null ? null : Exams.fromJson(json["notes"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "notes": exams == null ? null : exams!.toJson(),
  };
}

class Exams extends JsonObject {
  Exams({
    this.examsList,
  });

  final ExamsList? examsList;

  factory Exams.fromRawJson(String str) => Exams.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Exams.fromJson(Map<String, dynamic> json) => Exams(
    examsList: json["listeDevoirs"] == null ? null : ExamsList.fromJson(json["listeDevoirs"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "listeDevoirs": examsList == null ? null : examsList!.toJson(),
  };
}

class ExamsList extends JsonObject {
  ExamsList({
    this.t,
    this.exams,
  });

  final int? t;
  final List<Exam>? exams;

  factory ExamsList.fromRawJson(String str) => ExamsList.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ExamsList.fromJson(Map<String, dynamic> json) => ExamsList(
    t: json["_T"],
    exams: json["V"] == null ? null : List<Exam>.from(json["V"].map((x) => Exam.fromJson(x))),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": exams == null ? null : List<dynamic>.from(exams!.map((x) => x.toJson())),
  };
}

class Exam extends JsonObject {
  Exam({
    this.id,
    this.g,
    this.mark,
    this.scale,
    this.defaultScale,
    this.date,
    this.Course,
    this.period,
  });

  final String? id;
  final int? g;
  final ValueObject? mark;
  final ValueObject? scale;
  final ValueObject? defaultScale;
  final ValueObject? date;
  final Service? Course;
  final Period? period;

  factory Exam.fromRawJson(String str) => Exam.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
    id: json["N"],
    g: json["G"],
    mark: json["note"] == null ? null : ValueObject.fromJson(json["note"]),
    scale: json["bareme"] == null ? null : ValueObject.fromJson(json["bareme"]),
    defaultScale: json["baremeParDefaut"] == null ? null : ValueObject.fromJson(json["baremeParDefaut"]),
    date: json["date"] == null ? null : ValueObject.fromJson(json["date"]),
    Course: json["service"] == null ? null : Service.fromJson(json["service"]),
    period: json["periode"] == null ? null : Period.fromJson(json["periode"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "N": id,
    "G": g,
    "note": mark == null ? null : mark!.toJson(),
    "bareme": scale == null ? null : scale!.toJson(),
    "baremeParDefaut": defaultScale == null ? null : defaultScale!.toJson(),
    "date": date == null ? null : date!.toJson(),
    "service": Course == null ? null : Course!.toJson(),
    "periode": period == null ? null : period!.toJson(),
  };

  @override
  String toString() {
    String result = '';
    
    String? noteValue = mark?.valeur;
    
    if (noteValue == '|1') {
      result += 'absent';
    } else if (noteValue != null) {
      result += noteValue;

      if (scale?.valeur != null) {
        result += '/' + scale!.valeur!;
      }
    } else {
      throw Exception('Données incorrects pour le devoir');
    }
    
    if (Course?.service?.name != null) {
      result += ' en ' + Course!.service!.name!;
    }
    
    if (date?.valeur != null) {
      result += ' le ' + date!.valeur!;
    }
    
    return result;
  }
}

class ValueObject extends JsonObject {
  ValueObject({
    this.id,
    this.valeur,
  });

  final int? id;
  final String? valeur;

  factory ValueObject.fromRawJson(String str) => ValueObject.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ValueObject.fromJson(Map<String, dynamic> json) => ValueObject(
    id: json["_T"],
    valeur: json["V"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": valeur,
  };
}

class Period extends JsonObject {
  Period({
    this.id,
    this.periode,
  });

  final int? id;
  final NameObject? periode;

  factory Period.fromRawJson(String str) => Period.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Period.fromJson(Map<String, dynamic> json) => Period(
    id: json["_T"],
    periode: json["V"] == null ? null : NameObject.fromJson(json["V"]),
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
  final NameObject? service;

  factory Service.fromRawJson(String str) => Service.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["_T"],
    service: json["V"] == null ? null : NameObject.fromJson(json["V"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": service == null ? null : service!.toJson(),
  };
}

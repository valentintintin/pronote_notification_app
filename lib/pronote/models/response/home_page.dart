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
    exams: json["V"] == null ? null : List<Exam>.from(json["V"].map((x) => Exam.fromJson(x))).reversed.toList(),
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": t,
    "V": exams == null ? null : List<dynamic>.from(exams!.map((x) => x.toJson())),
  };

  @override
  String toString() {
    return exams == null ? '' : exams!.map((e) => e.toString()).join('\n');
  }
}

class Exam extends JsonObject {
  Exam({
    this.id,
    this.g,
    this.mark,
    this.scale,
    this.defaultScale,
    this.date,
    this.course,
    this.period,
  });

  final String? id;
  final int? g;
  final ValueObject? mark;
  final ValueObject? scale;
  final ValueObject? defaultScale;
  final ValueObject? date;
  final Service? course;
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
    course: json["service"] == null ? null : Service.fromJson(json["service"]),
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
    "service": course == null ? null : course!.toJson(),
    "periode": period == null ? null : period!.toJson(),
  };

  String getMarkValue() {
    String? markString = mark?.value?.replaceAll(',', '.');
    
    if (markString == '|1') {
      return 'absent';
    }
    
    try {
      double? markValue = double.parse(markString!);
      
      if (scale?.value != null && defaultScale?.value != null && scale!.value != defaultScale!.value) {
        try {
          double scaleValue = double.parse(scale!.value!);
          double defaultScaleValue = double.parse(defaultScale!.value!);
          
          return (markValue * defaultScaleValue / scaleValue).toStringAsFixed(2) + '/' + defaultScale!.value! + ' (' + markValue.toString() + '/' + scale!.value! + ')';
        } catch(e) {
          return markValue.toString() + '/' + scale!.value!;  
        }
      } else if (scale?.value != null) {
        return markValue.toString() + '/' + scale!.value!;
      } else if (defaultScale?.value != null) {
        return markValue.toString() + '/' + defaultScale!.value!;
      }
      
      return markValue.toString();
    } catch(e) {
      throw Exception('Note incorrect pour le devoir. ' + e.toString());
    }
  }
  
  @override
  String toString() {
    String result = getMarkValue();
    
    if (course?.service?.name != null) {
      result += ' en ' + course!.service!.name!;
    }
    
    if (date?.value != null) {
      result += ' le ' + date!.value!;
    }
    
    return result;
  }
}

class ValueObject extends JsonObject {
  ValueObject({
    this.id,
    this.value,
  });

  final int? id; // _T
  final String? value; // V

  factory ValueObject.fromRawJson(String str) => ValueObject.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory ValueObject.fromJson(Map<String, dynamic> json) => ValueObject(
    id: json["_T"],
    value: json["V"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "_T": id,
    "V": value,
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

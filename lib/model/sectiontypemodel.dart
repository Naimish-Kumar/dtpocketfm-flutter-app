// To parse this JSON data, do
// final sectionTypeModel = sectionTypeModelFromJson(jsonString);

import 'dart:convert';

SectionTypeModel sectionTypeModelFromJson(String str) =>
    SectionTypeModel.fromJson(json.decode(str));

String sectionTypeModelToJson(SectionTypeModel data) =>
    json.encode(data.toJson());

class SectionTypeModel {
  SectionTypeModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  List<Result>? result;

  factory SectionTypeModel.fromJson(Map<String, dynamic> json) =>
      SectionTypeModel(
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result != null
            ? List<dynamic>.from(result?.map((x) => x.toJson()) ?? [])
            : [],
      };
}

class Result {
  Result({
    this.id,
    this.name,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  int? type;
  String? createdAt;
  String? updatedAt;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

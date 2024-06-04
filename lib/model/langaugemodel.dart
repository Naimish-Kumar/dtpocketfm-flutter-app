// To parse this JSON data, do
// final langaugeModel = langaugeModelFromJson(jsonString);

import 'dart:convert';

LangaugeModel langaugeModelFromJson(String str) =>
    LangaugeModel.fromJson(json.decode(str));

String langaugeModelToJson(LangaugeModel data) => json.encode(data.toJson());

class LangaugeModel {
  LangaugeModel({
    this.code,
    this.status,
    this.message,
    this.result,
  });

  int? code;
  int? status;
  String? message;
  List<Result>? result;

  factory LangaugeModel.fromJson(Map<String, dynamic> json) => LangaugeModel(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  Result({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

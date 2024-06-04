// To parse this JSON data, do
// final generalSettingModel = generalSettingModelFromJson(jsonString);

import 'dart:convert';

GeneralSettingModel generalSettingModelFromJson(String str) =>
    GeneralSettingModel.fromJson(json.decode(str));

String generalSettingModelToJson(GeneralSettingModel data) =>
    json.encode(data.toJson());

class GeneralSettingModel {
  GeneralSettingModel({
    this.code,
    this.status,
    this.message,
    this.result,
  });

  int? code;
  int? status;
  String? message;
  List<Result>? result;

  factory GeneralSettingModel.fromJson(Map<String, dynamic> json) =>
      GeneralSettingModel(
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
        "result": List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    this.id,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        key: json["key"],
        value: json["value"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

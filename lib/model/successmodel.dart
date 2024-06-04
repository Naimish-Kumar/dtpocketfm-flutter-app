// To parse this JSON data, do
//
//     final successModel = successModelFromJson(jsonString);

import 'dart:convert';

SuccessModel successModelFromJson(String str) =>
    SuccessModel.fromJson(json.decode(str));

String successModelToJson(SuccessModel data) => json.encode(data.toJson());

class SuccessModel {
  int? status;
  String? message;
  String? success;
  List<dynamic>? result;

  SuccessModel({
    this.status,
    this.message,
    this.result,
    this.success,
  });

  factory SuccessModel.fromJson(Map<String, dynamic> json) => SuccessModel(
        status: json["status"],
        message: json["message"],
        success: json["success"],
        result: json["result"] == null
            ? null
            : List<dynamic>.from(json["result"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "success": success,
        "result": List<dynamic>.from(result?.map((x) => x) ?? []),
      };
}

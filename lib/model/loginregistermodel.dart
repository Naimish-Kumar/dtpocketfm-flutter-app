// To parse this JSON data, do
// final loginRegisterModel = loginRegisterModelFromJson(jsonString);

import 'dart:convert';

LoginRegisterModel profileModelFromJson(String str) =>
    LoginRegisterModel.fromJson(json.decode(str));

String profileModelToJson(LoginRegisterModel data) =>
    json.encode(data.toJson());

class LoginRegisterModel {
  int? status;
  String? message;
  List<Result>? result;

  LoginRegisterModel({
    this.status,
    this.message,
    this.result,
  });

  factory LoginRegisterModel.fromJson(Map<String, dynamic> json) =>
      LoginRegisterModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  String? name;
  String? userName;
  String? mobile;
  String? email;
  String? password;
  String? gender;
  String? image;
  int? status;
  int? type;
  String? expiryDate;
  String? apiToken;
  String? emailVerifyToken;
  String? isEmailVerify;
  String? createdAt;
  String? updatedAt;
  int? isBuy;

  Result({
    this.id,
    this.userName,
    this.name,
    this.mobile,
    this.email,
    this.image,
    this.type,
    this.status,
    this.expiryDate,
    this.apiToken,
    this.emailVerifyToken,
    this.isEmailVerify,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userName: json["user_name"],
        name: json["full_name"],
        mobile: json["mobile_number"],
        email: json["email"],
        image: json["image"],
        type: json["type"],
        status: json["status"],
        expiryDate: json["expiry_date"],
        apiToken: json["api_token"],
        emailVerifyToken: json["email_verify_token"],
        isEmailVerify: json["is_email_verify"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_name": userName,
        "full_name": name,
        "mobile_number": mobile,
        "email": email,
        "image": image,
        "type": type,
        "status": status,
        "expiry_date": expiryDate,
        "api_token": apiToken,
        "email_verify_token": emailVerifyToken,
        "is_email_verify": isEmailVerify,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
      };
}

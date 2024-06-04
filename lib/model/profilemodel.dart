// To parse this JSON data, do
// final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int? status;
  String? message;
  List<Result>? result;

  ProfileModel({
    this.status,
    this.message,
    this.result,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
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
  String? fullName;
  String? mobile;
  String? email;
  String? password;
  String? gender;
  String? image;
  int? status;
  int? type;
  int? walletCoin;
  String? expiryDate;
  String? apiToken;
  String? emailVerifyToken;
  String? isEmailVerify;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  String? bio;

  Result(
      {this.id,
      this.name,
      this.userName,
      this.fullName,
      this.mobile,
      this.email,
      this.password,
      this.gender,
      this.image,
      this.status,
      this.type,
      this.walletCoin,
      this.expiryDate,
      this.apiToken,
      this.emailVerifyToken,
      this.isEmailVerify,
      this.createdAt,
      this.updatedAt,
      this.isBuy,
      this.bio});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      id: json["id"],
      name: json["name"],
      userName: json["user_name"],
      fullName: json["full_name"],
      mobile: json["mobile_number"],
      email: json["email"],
      password: json["password"],
      gender: json["gender"],
      image: json["image"],
      status: json["status"],
      type: json["type"],
      walletCoin: json["wallet_coin"],
      expiryDate: json["expiry_date"],
      apiToken: json["api_token"],
      emailVerifyToken: json["email_verify_token"],
      isEmailVerify: json["is_email_verify"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      isBuy: json["is_buy"],
      bio: json["bio"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "user_name": userName,
        "full_name": fullName,
        "mobile_number": mobile,
        "email": email,
        "password": password,
        "gender": gender,
        "image": image,
        "status": status,
        "type": type,
        "wallet_coin": walletCoin,
        "expiry_date": expiryDate,
        "api_token": apiToken,
        "email_verify_token": emailVerifyToken,
        "is_email_verify": isEmailVerify,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "bio": bio
      };
}

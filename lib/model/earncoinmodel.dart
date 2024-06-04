// To parse this JSON data, do
//
//     final earncoinmodel = earncoinmodelFromJson(jsonString);

import 'dart:convert';

Earncoinmodel earncoinmodelFromJson(String str) =>
    Earncoinmodel.fromJson(json.decode(str));

String earncoinmodelToJson(Earncoinmodel data) => json.encode(data.toJson());

class Earncoinmodel {
  int? status;
  String? message;
  List<DailyLogin>? spinWheel;
  List<DailyLogin>? dailyLogin;
  List<DailyLogin>? freeCoin;

  Earncoinmodel({
    this.status,
    this.message,
    this.spinWheel,
    this.dailyLogin,
    this.freeCoin,
  });

  factory Earncoinmodel.fromJson(Map<String, dynamic> json) => Earncoinmodel(
        status: json["status"],
        message: json["message"],
        spinWheel: List<DailyLogin>.from(
            json["spin_wheel"].map((x) => DailyLogin.fromJson(x))),
        dailyLogin: List<DailyLogin>.from(
            json["daily_login"].map((x) => DailyLogin.fromJson(x))),
        freeCoin: List<DailyLogin>.from(
            json["free_coin"].map((x) => DailyLogin.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "spin_wheel":
            List<dynamic>.from(spinWheel?.map((x) => x.toJson()) ?? []),
        "daily_login":
            List<dynamic>.from(dailyLogin?.map((x) => x.toJson()) ?? []),
        "free_coin": List<dynamic>.from(freeCoin?.map((x) => x.toJson()) ?? []),
      };
}

class DailyLogin {
  int? id;
  String? key;
  String? value;
  int? type;

  DailyLogin({
    this.id,
    this.key,
    this.value,
    this.type,
  });

  factory DailyLogin.fromJson(Map<String, dynamic> json) => DailyLogin(
        id: json["id"],
        key: json["key"],
        value: json["value"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
        "type": type,
      };
}

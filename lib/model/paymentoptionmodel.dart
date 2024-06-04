// To parse this JSON data, do
//
//     final paymentOptionModel = paymentOptionModelFromJson(jsonString);

import 'dart:convert';

PaymentOptionModel paymentOptionModelFromJson(String str) =>
    PaymentOptionModel.fromJson(json.decode(str));

String paymentOptionModelToJson(PaymentOptionModel data) =>
    json.encode(data.toJson());

class PaymentOptionModel {
  int? status;
  String? message;
  Result? result;

  PaymentOptionModel({
    this.status,
    this.message,
    this.result,
  });

  factory PaymentOptionModel.fromJson(Map<String, dynamic> json) =>
      PaymentOptionModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson(),
      };
}

class Result {
  Flutterwave? inapppurchage;
  Flutterwave? paypal;
  Flutterwave? razorpay;
  Flutterwave? flutterwave;
  Flutterwave? payumoney;
  Flutterwave? paytm;
  Flutterwave? stripe;

  Result({
    this.inapppurchage,
    this.paypal,
    this.razorpay,
    this.flutterwave,
    this.payumoney,
    this.paytm,
    this.stripe,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        inapppurchage: Flutterwave.fromJson(json["inapppurchage"]),
        paypal: Flutterwave.fromJson(json["paypal"]),
        razorpay: Flutterwave.fromJson(json["razorpay"]),
        flutterwave: Flutterwave.fromJson(json["flutterwave"]),
        payumoney: Flutterwave.fromJson(json["payumoney"]),
        paytm: Flutterwave.fromJson(json["paytm"]),
        stripe: Flutterwave.fromJson(json["stripe"]),
      );

  Map<String, dynamic> toJson() => {
        "inapppurchage": inapppurchage?.toJson(),
        "paypal": paypal?.toJson(),
        "razorpay": razorpay?.toJson(),
        "flutterwave": flutterwave?.toJson(),
        "payumoney": payumoney?.toJson(),
        "paytm": paytm?.toJson(),
        "stripe": stripe?.toJson(),
      };
}

class Flutterwave {
  int? id;
  String? name;
  String? visibility;
  String? isLive;
  String? key1;
  String? key2;
  String? key3;
  String? createdAt;
  String? updatedAt;

  Flutterwave({
    this.id,
    this.name,
    this.visibility,
    this.isLive,
    this.key1,
    this.key2,
    this.key3,
    this.createdAt,
    this.updatedAt,
  });

  factory Flutterwave.fromJson(Map<String, dynamic> json) => Flutterwave(
        id: json["id"],
        name: json["name"],
        visibility: json["visibility"],
        isLive: json["is_live"],
        key1: json["key_1"],
        key2: json["key_2"],
        key3: json["key_3"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "visibility": visibility,
        "is_live": isLive,
        "key_1": key1,
        "key_2": key2,
        "key_3": key3,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

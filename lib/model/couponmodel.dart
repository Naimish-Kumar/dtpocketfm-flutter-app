// To parse this JSON data, do
// final couponModel = couponModelFromJson(jsonString);

import 'dart:convert';

CouponModel couponModelFromJson(String str) =>
    CouponModel.fromJson(json.decode(str));

String couponModelToJson(CouponModel data) => json.encode(data.toJson());

class CouponModel {
  CouponModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  Result? result;

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson() ?? {},
      };
}

class Result {
  Result({
    this.id,
    this.uniqueId,
    this.totalAmount,
    this.discountAmount,
  });

  int? id;
  String? uniqueId;
  int? totalAmount;
  int? discountAmount;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        uniqueId: json["unique_id"],
        totalAmount: json["total_amount"],
        discountAmount: json["discount_amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "unique_id": uniqueId,
        "total_amount": totalAmount,
        "discount_amount": discountAmount,
      };
}

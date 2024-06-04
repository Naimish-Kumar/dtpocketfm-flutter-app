// To parse this JSON data, do
// final historyModel = historyModelFromJson(jsonString);

import 'dart:convert';

HistoryModel historyModelFromJson(String str) =>
    HistoryModel.fromJson(json.decode(str));

String historyModelToJson(HistoryModel data) => json.encode(data.toJson());

class HistoryModel {
  HistoryModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  List<Result>? result;

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  Result({
    this.id,
    this.userId,
    this.uniqueId,
    this.packageId,
    this.description,
    this.amount,
    this.paymentId,
    this.currencyCode,
    this.expiryDate,
    this.status,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.packageName,
    this.packagePrice,
  });

  int? id;
  int? userId;
  String? uniqueId;
  int? packageId;
  String? description;
  String? amount;
  String? paymentId;
  String? currencyCode;
  String? expiryDate;
  int? status;
  dynamic date;
  String? createdAt;
  String? updatedAt;
  int? isDelete;
  String? packageName;
  int? packagePrice;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        uniqueId: json["unique_id"],
        packageId: json["package_id"],
        description: json["description"],
        amount: json["amount"],
        paymentId: json["payment_id"],
        currencyCode: json["currency_code"],
        expiryDate: json["expiry_date"],
        status: json["status"],
        date: json["date"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isDelete: json["is_delete"],
        packageName: json["package_name"],
        packagePrice: json["package_price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "unique_id": uniqueId,
        "package_id": packageId,
        "description": description,
        "amount": amount,
        "payment_id": paymentId,
        "currency_code": currencyCode,
        "expiry_date": expiryDate,
        "status": status,
        "date": date,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_delete": isDelete,
        "package_name": packageName,
        "package_price": packagePrice,
      };
}

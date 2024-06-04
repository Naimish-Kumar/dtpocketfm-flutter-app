// // To parse this JSON data, do
// // final subscriptionModel = subscriptionModelFromJson(jsonString);

// import 'dart:convert';

// SubscriptionModel subscriptionModelFromJson(String str) =>
//     SubscriptionModel.fromJson(json.decode(str));

// String subscriptionModelToJson(SubscriptionModel data) =>
//     json.encode(data.toJson());

// class SubscriptionModel {
//   int? status;
//   String? message;
//   List<Result>? result;

//   SubscriptionModel({
//     this.status,
//     this.message,
//     this.result,
//   });

//   factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
//       SubscriptionModel(
//         status: json["status"],
//         message: json["message"],
//         result: List<Result>.from(
//             json["result"]?.map((x) => Result.fromJson(x)) ?? []),
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "result": result == null
//             ? []
//             : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
//       };
// }

// class Result {
//   int? id;
//   String? name;
//   int? price;
//   String? time;
//   String? type;
//   String? typeId;
//   String? androidProductPackage;
//   String? iosProductPackage;
//   List<Datum>? data;
//   int? isBuy;

//   Result({
//     this.id,
//     this.name,
//     this.price,
//     this.time,
//     this.type,
//     this.typeId,
//     this.androidProductPackage,
//     this.iosProductPackage,
//     this.data,
//     this.isBuy,
//   });

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         id: json["id"],
//         name: json["name"],
//         price: json["price"],
//         time: json["time"],
//         type: json["type"],
//         typeId: json["type_id"],
//         androidProductPackage: json["android_product_package"],
//         iosProductPackage: json["ios_product_package"],
//         data:
//             List<Datum>.from(json["data"]?.map((x) => Datum.fromJson(x)) ?? []),
//         isBuy: json["is_buy"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "price": price,
//         "time": time,
//         "type": type,
//         "type_id": typeId,
//         "android_product_package": androidProductPackage,
//         "ios_product_package": iosProductPackage,
//         "data": data == null
//             ? []
//             : List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
//         "is_buy": isBuy,
//       };
// }

// class Datum {
//   int? id;
//   int? packageId;
//   String? packageKey;
//   String? packageValue;
//   String? createdAt;
//   String? updatedAt;

//   Datum({
//     this.id,
//     this.packageId,
//     this.packageKey,
//     this.packageValue,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         id: json["id"],
//         packageId: json["package_id"],
//         packageKey: json["package_key"],
//         packageValue: json["package_value"],
//         createdAt: json["created_at"],
//         updatedAt: json["updated_at"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "package_id": packageId,
//         "package_key": packageKey,
//         "package_value": packageValue,
//         "created_at": createdAt,
//         "updated_at": updatedAt,
//       };
// }
// To parse this JSON data, do
//
//     final subscriptionModel = subscriptionModelFromJson(jsonString);

import 'dart:convert';

SubscriptionModel subscriptionModelFromJson(String str) =>
    SubscriptionModel.fromJson(json.decode(str));

String subscriptionModelToJson(SubscriptionModel data) =>
    json.encode(data.toJson());

class SubscriptionModel {
  int? status;
  String? message;
  List<Result>? result;

  SubscriptionModel({
    this.status,
    this.message,
    this.result,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        status: json["status"],
        message: json["message"],
        result: json['result'] == null
            ? null
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  String? name;
  String? image;
  int? price;
  int? coin;
  String? androidProductPackage;
  String? iosProductPackage;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;

  Result(
      {this.id,
      this.name,
      this.image,
      this.price,
      this.coin,
      this.androidProductPackage,
      this.iosProductPackage,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.isBuy});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      price: json["price"],
      coin: json["coin"],
      androidProductPackage: json["android_product_package"],
      iosProductPackage: json["ios_product_package"],
      status: json["status"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      isBuy: json["is_buy"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "price": price,
        "coin": coin,
        "android_product_package": androidProductPackage,
        "ios_product_package": iosProductPackage,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        'is_buy': isBuy
      };
}

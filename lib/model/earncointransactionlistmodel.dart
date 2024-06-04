// To parse this JSON data, do
//
//     final earnCoindTransactionListModel = earnCoindTransactionListModelFromJson(jsonString);

import 'dart:convert';

EarnCoindTransactionListModel earnCoindTransactionListModelFromJson(
        String str) =>
    EarnCoindTransactionListModel.fromJson(json.decode(str));

String earnCoindTransactionListModelToJson(
        EarnCoindTransactionListModel data) =>
    json.encode(data.toJson());

class EarnCoindTransactionListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  EarnCoindTransactionListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory EarnCoindTransactionListModel.fromJson(Map<String, dynamic> json) =>
      EarnCoindTransactionListModel(
        status: json["status"],
        message: json["message"],
        result: json['result'] == null
            ? null
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  int? userId;
  int? coin;
  int? type;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? fullName;
  String? userImage;

  Result({
    this.id,
    this.userId,
    this.coin,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.fullName,
    this.userImage,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        coin: json["coin"],
        type: json["type"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userName: json["user_name"],
        fullName: json["full_name"],
        userImage: json["user_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "coin": coin,
        "type": type,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "full_name": fullName,
        "user_image": userImage,
      };
}

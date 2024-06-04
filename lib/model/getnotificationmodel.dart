// To parse this JSON data, do
//
//     final getNotificationModel = getNotificationModelFromJson(jsonString);

import 'dart:convert';

GetNotificationModel getNotificationModelFromJson(String str) =>
    GetNotificationModel.fromJson(json.decode(str));

String getNotificationModelToJson(GetNotificationModel data) =>
    json.encode(data.toJson());

class GetNotificationModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetNotificationModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetNotificationModel.fromJson(Map<String, dynamic> json) =>
      GetNotificationModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
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
  int? type;
  String? title;
  String? message;
  String? image;
  int? userId;
  int? fromUserId;
  int? contentId;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? userImage;
  String? contentName;
  String? contentImage;

  Result({
    this.id,
    this.type,
    this.title,
    this.message,
    this.image,
    this.userId,
    this.fromUserId,
    this.contentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userImage,
    this.contentName,
    this.contentImage,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        type: json["type"],
        title: json["title"],
        message: json["message"],
        image: json["image"],
        userId: json["user_id"],
        fromUserId: json["from_user_id"],
        contentId: json["content_id"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userName: json["user_name"],
        userImage: json["user_image"],
        contentName: json["content_name"],
        contentImage: json["content_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "title": title,
        "message": message,
        "image": image,
        "user_id": userId,
        "from_user_id": fromUserId,
        "content_id": contentId,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "user_image": userImage,
        "content_name": contentName,
        "content_image": contentImage,
      };
}

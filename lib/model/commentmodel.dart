// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);

import 'dart:convert';

CommentModel commentModelFromJson(String str) =>
    CommentModel.fromJson(json.decode(str));

String commentModelToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  CommentModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
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
  int? contentType;
  int? contentId;
  int? threadsId;
  String? comment;
  int? rating;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? fullName;
  String? image;
  int? isReply;
  int? totalReply;

  Result({
    this.id,
    this.userId,
    this.contentType,
    this.contentId,
    this.threadsId,
    this.comment,
    this.rating,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.fullName,
    this.image,
    this.isReply,
    this.totalReply,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        contentType: json["content_type"],
        contentId: json["content_id"],
        threadsId: json["threads_id"],
        comment: json["comment"],
        rating: json["rating"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userName: json["user_name"],
        fullName: json["full_name"],
        image: json["image"],
        isReply: json["is_reply"],
        totalReply: json["total_reply"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "content_type": contentType,
        "content_id": contentId,
        "threads_id": threadsId,
        "comment": comment,
        "rating": rating,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "full_name": fullName,
        "image": image,
        "is_reply": isReply,
        "total_reply": totalReply,
      };
}

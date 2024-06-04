// To parse this JSON data, do
//
//     final threadsListModel = threadsListModelFromJson(jsonString);

import 'dart:convert';

ThreadsListModel threadsListModelFromJson(String str) =>
    ThreadsListModel.fromJson(json.decode(str));

String threadsListModelToJson(ThreadsListModel data) =>
    json.encode(data.toJson());

class ThreadsListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  ThreadsListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory ThreadsListModel.fromJson(Map<String, dynamic> json) =>
      ThreadsListModel(
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
  int? userType;
  int? userId;
  String? description;
  String? image;
  int? totalLike;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? fullName;
  String? userImage;
  int? isArtist;
  int? totalComment;
  int? isLike;
  List<String>? images;

  Result({
    this.id,
    this.userType,
    this.userId,
    this.description,
    this.image,
    this.totalLike,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.fullName,
    this.userImage,
    this.isArtist,
    this.totalComment,
    this.isLike,
    this.images,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userType: json["user_type"],
        userId: json["user_id"],
        description: json["description"],
        image: json["image"],
        totalLike: json["total_like"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userName: json["user_name"],
        fullName: json["full_name"],
        userImage: json["user_image"],
        isArtist: json["is_artist"],
        totalComment: json["total_comment"],
        isLike: json["is_like"],
        images: json["images"] == null
            ? null
            : List<String>.from(json["images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "user_id": userId,
        "description": description,
        "image": image,
        "total_like": totalLike,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "full_name": fullName,
        "user_image": userImage,
        "is_artist": isArtist,
        "total_comment": totalComment,
        "is_like": isLike,
        "images": List<dynamic>.from(images?.map((x) => x) ?? []),
      };
}

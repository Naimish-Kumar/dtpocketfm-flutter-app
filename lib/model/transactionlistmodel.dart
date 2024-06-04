// To parse this JSON data, do
//
//     final transactionListModel = transactionListModelFromJson(jsonString);

import 'dart:convert';

TransactionListModel transactionListModelFromJson(String str) =>
    TransactionListModel.fromJson(json.decode(str));

String transactionListModelToJson(TransactionListModel data) =>
    json.encode(data.toJson());

class TransactionListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  TransactionListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) =>
      TransactionListModel(
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
  int? packageId;
  String? description;
  String? price;
  int? coin;
  String? transactionId;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? fullName;
  String? image;
  String? packageName;
  int? contentType;
  int? audiobookType;
  int? contentId;
  int? contentEpisodeId;
  String? userImage;
  String? contentTitle;
  String? contentPortraitImg;
  String? episodeName;
  String? episodeImage;

  Result({
    this.id,
    this.userId,
    this.packageId,
    this.description,
    this.price,
    this.coin,
    this.transactionId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.fullName,
    this.image,
    this.packageName,
    this.contentType,
    this.audiobookType,
    this.contentId,
    this.contentEpisodeId,
    this.userImage,
    this.contentTitle,
    this.contentPortraitImg,
    this.episodeName,
    this.episodeImage,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userId: json["user_id"],
        packageId: json["package_id"],
        description: json["description"],
        price: json["price"],
        coin: json["coin"],
        transactionId: json["transaction_id"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userName: json["user_name"],
        fullName: json["full_name"],
        image: json["image"],
        packageName: json["package_name"],
        contentType: json["content_type"],
        audiobookType: json["audiobook_type"],
        contentId: json["content_id"],
        contentEpisodeId: json["content_episode_id"],
        userImage: json["user_image"],
        contentTitle: json["content_title"],
        contentPortraitImg: json["content_portrait_img"],
        episodeName: json["episode_name"],
        episodeImage: json["episode_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "package_id": packageId,
        "description": description,
        "price": price,
        "coin": coin,
        "transaction_id": transactionId,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "full_name": fullName,
        "image": image,
        "package_name": packageName,
        "content_type": contentType,
        "audiobook_type": audiobookType,
        "content_id": contentId,
        "content_episode_id": contentEpisodeId,
        "user_image": userImage,
        "content_title": contentTitle,
        "content_portrait_img": contentPortraitImg,
        "episode_name": episodeName,
        "episode_image": episodeImage,
      };
}

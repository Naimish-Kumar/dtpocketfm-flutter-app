// To parse this JSON data, do
//
//     final sectionBannerModel = sectionBannerModelFromJson(jsonString);

import 'dart:convert';

SectionBannerModel sectionBannerModelFromJson(String str) =>
    SectionBannerModel.fromJson(json.decode(str));

String sectionBannerModelToJson(SectionBannerModel data) =>
    json.encode(data.toJson());

class SectionBannerModel {
  int? status;
  String? message;
  List<Result>? result;

  SectionBannerModel({
    this.status,
    this.message,
    this.result,
  });

  factory SectionBannerModel.fromJson(Map<String, dynamic> json) =>
      SectionBannerModel(
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
  int? contentType;
  int? artistId;
  int? categoryId;
  int? languageId;
  String? title;
  String? portraitImg;
  String? landscapeImg;
  String? webBannerImage;
  String? description;
  String? fullNovel;
  int? isPaidNovel;
  int? novelCoin;
  int? totalPlayed;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? categoryName;
  String? artistName;
  String? languageName;
  String? avgRating;
  int? totalEpisode;
  int? totalReviews;
  int? totalUserPlay;

  Result({
    this.id,
    this.contentType,
    this.artistId,
    this.categoryId,
    this.languageId,
    this.title,
    this.portraitImg,
    this.landscapeImg,
    this.webBannerImage,
    this.description,
    this.fullNovel,
    this.isPaidNovel,
    this.novelCoin,
    this.totalPlayed,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.artistName,
    this.languageName,
    this.avgRating,
    this.totalEpisode,
    this.totalReviews,
    this.totalUserPlay,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        contentType: json["content_type"],
        artistId: json["artist_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        title: json["title"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        webBannerImage: json["web_banner_img"],
        description: json["description"],
        fullNovel: json["full_novel"],
        isPaidNovel: json["is_paid_novel"],
        novelCoin: json["novel_coin"],
        totalPlayed: json["total_played"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        categoryName: json["category_name"],
        artistName: json["artist_name"],
        languageName: json["language_name"],
        avgRating: json["avg_rating"],
        totalEpisode: json["total_episode"],
        totalReviews: json["total_reviews"],
        totalUserPlay: json["total_user_play"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "artist_id": artistId,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "description": description,
        "full_novel": fullNovel,
        "web_banner_img": webBannerImage,
        "is_paid_novel": isPaidNovel,
        "novel_coin": novelCoin,
        "total_played": totalPlayed,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "category_name": categoryName,
        "artist_name": artistName,
        "language_name": languageName,
        "avg_rating": avgRating,
        "total_episode": totalEpisode,
        "total_reviews": totalReviews,
        "total_user_play": totalUserPlay,
      };
}

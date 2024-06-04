// To parse this JSON data, do
//
//     final contentDetailsModel = contentDetailsModelFromJson(jsonString);

import 'dart:convert';

ContentDetailsModel contentDetailsModelFromJson(String str) =>
    ContentDetailsModel.fromJson(json.decode(str));

String contentDetailsModelToJson(ContentDetailsModel data) =>
    json.encode(data.toJson());

class ContentDetailsModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  ContentDetailsModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory ContentDetailsModel.fromJson(Map<String, dynamic> json) =>
      ContentDetailsModel(
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
  int? contentType;
  int? artistId;
  int? categoryId;
  int? languageId;
  String? title;
  String? portraitImg;
  String? landscapeImg;
  String? description;
  String? fullNovel;
  int? isPaidNovel;
  int? novelCoin;
  int? totalPlayed;
  int? status;
  String? createdAt;
  String? webBannerImg;
  String? updatedAt;
  String? categoryName;
  String? languageName;
  String? artistName;
  String? artistImage;
  int? isFollow;
  int? artistFollowers;
  String? avgRating;
  int? totalEpisode;
  int? totalReviews;
  String? book;
  int? isBookPaid;
  int? isBookCoin;
  int? totalBookPlayed;
  int? isBuy;
  int? totalUserPlay;
  int? isBookMark;

  Result(
      {this.id,
      this.contentType,
      this.artistId,
      this.categoryId,
      this.languageId,
      this.title,
      this.portraitImg,
      this.landscapeImg,
      this.description,
      this.fullNovel,
      this.webBannerImg,
      this.isPaidNovel,
      this.novelCoin,
      this.totalPlayed,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.categoryName,
      this.languageName,
      this.artistName,
      this.artistImage,
      this.isFollow,
      this.book,
      this.isBookPaid,
      this.isBookCoin,
      this.totalBookPlayed,
      this.artistFollowers,
      this.avgRating,
      this.totalEpisode,
      this.totalReviews,
      this.isBuy,
      this.totalUserPlay,
      this.isBookMark});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      id: json["id"],
      contentType: json["content_type"],
      artistId: json["artist_id"],
      categoryId: json["category_id"],
      languageId: json["language_id"],
      title: json["title"],
      portraitImg: json["portrait_img"],
      landscapeImg: json["landscape_img"],
      webBannerImg: json["web_banner_img"],
      description: json["description"],
      fullNovel: json["full_novel"],
      isPaidNovel: json["is_paid_novel"],
      novelCoin: json["novel_coin"],
      totalPlayed: json["total_played"],
      status: json["status"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      book: json["book"],
      isBookPaid: json["is_book_paid"],
      isBookCoin: json["is_book_coin"],
      totalBookPlayed: json["total_book_played"],
      categoryName: json["category_name"],
      languageName: json["language_name"],
      artistName: json["artist_name"],
      artistImage: json["artist_image"],
      isFollow: json["is_follow"],
      artistFollowers: json["artist_followers"],
      avgRating: json["avg_rating"],
      totalEpisode: json["total_episode"],
      totalReviews: json["total_reviews"],
      isBuy: json['is_buy'],
      totalUserPlay: json["total_user_play"],
      isBookMark: json["is_bookmark"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "artist_id": artistId,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "web_banner_img": webBannerImg,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "description": description,
        "full_novel": fullNovel,
        "is_paid_novel": isPaidNovel,
        "novel_coin": novelCoin,
        "total_played": totalPlayed,
        "status": status,
        "created_at": createdAt,
        "book": book,
        "is_book_paid": isBookPaid,
        "is_book_coin": isBookCoin,
        "total_book_played": totalBookPlayed,
        "updated_at": updatedAt,
        "category_name": categoryName,
        "language_name": languageName,
        "artist_name": artistName,
        "artist_image": artistImage,
        "is_follow": isFollow,
        "artist_followers": artistFollowers,
        "avg_rating": avgRating,
        "total_episode": totalEpisode,
        "total_reviews": totalReviews,
        'is_buy': isBuy,
        "total_user_play": totalUserPlay,
        "is_bookmark": isBookMark
      };
}

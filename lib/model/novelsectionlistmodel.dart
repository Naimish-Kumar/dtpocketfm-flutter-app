// To parse this JSON data, do
//
//     final novelSectionListModel = novelSectionListModelFromJson(jsonString);

import 'dart:convert';

NovelSectionListModel novelSectionListModelFromJson(String str) =>
    NovelSectionListModel.fromJson(json.decode(str));

String novelSectionListModelToJson(NovelSectionListModel data) =>
    json.encode(data.toJson());

class NovelSectionListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  NovelSectionListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory NovelSectionListModel.fromJson(Map<String, dynamic> json) =>
      NovelSectionListModel(
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
  int? sectionType;
  int? isHomeScreen;
  int? topCategoryId;
  int? contentType;
  String? title;
  String? shortTitle;
  int? categoryId;
  int? languageId;
  int? artistId;
  int? orderByPlay;
  int? orderByUpload;
  String? screenLayout;
  int? noOfContent;
  int? viewAll;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<Datum>? data;

  Result({
    this.id,
    this.sectionType,
    this.isHomeScreen,
    this.topCategoryId,
    this.contentType,
    this.title,
    this.shortTitle,
    this.categoryId,
    this.languageId,
    this.artistId,
    this.orderByPlay,
    this.orderByUpload,
    this.screenLayout,
    this.noOfContent,
    this.viewAll,
    this.sortable,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        sectionType: json["section_type"],
        isHomeScreen: json["is_home_screen"],
        topCategoryId: json["top_category_id"],
        contentType: json["content_type"],
        title: json["title"],
        shortTitle: json["short_title"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        artistId: json["artist_id"],
        orderByPlay: json["order_by_play"],
        orderByUpload: json["order_by_upload"],
        screenLayout: json["screen_layout"],
        noOfContent: json["no_of_content"],
        viewAll: json["view_all"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "section_type": sectionType,
        "is_home_screen": isHomeScreen,
        "top_category_id": topCategoryId,
        "content_type": contentType,
        "title": title,
        "short_title": shortTitle,
        "category_id": categoryId,
        "language_id": languageId,
        "artist_id": artistId,
        "order_by_play": orderByPlay,
        "order_by_upload": orderByUpload,
        "screen_layout": screenLayout,
        "no_of_content": noOfContent,
        "view_all": viewAll,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class Datum {
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
  String? updatedAt;
  String? categoryName;
  String? artistName;
  String? languageName;
  String? avgRating;
  int? totalEpisode;
  int? totalReviews;
  String? userName;
  String? image;
  String? bio;
  String? instagramUrl;
  String? facebookUrl;
  String? name;
  int? totalUserPlay;

  Datum(
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
      this.userName,
      this.image,
      this.bio,
      this.instagramUrl,
      this.facebookUrl,
      this.name,
      this.totalUserPlay});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
      id: json["id"],
      contentType: json["content_type"],
      artistId: json["artist_id"],
      categoryId: json["category_id"],
      languageId: json["language_id"],
      title: json["title"],
      portraitImg: json["portrait_img"],
      landscapeImg: json["landscape_img"],
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
      userName: json["user_name"],
      image: json["image"],
      bio: json["bio"],
      instagramUrl: json["instagram_url"],
      facebookUrl: json["facebook_url"],
      name: json["name"],
      totalUserPlay: json["total_user_play"]);

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
        "user_name": userName,
        "image": image,
        "bio": bio,
        "instagram_url": instagramUrl,
        "facebook_url": facebookUrl,
        "name": name,
        "total_user_play": totalUserPlay
      };
}

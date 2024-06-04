// To parse this JSON data, do
//
//     final episodeByContentModel = episodeByContentModelFromJson(jsonString);

import 'dart:convert';

GetContentByArtistMdel episodeByContentModelFromJson(String str) =>
    GetContentByArtistMdel.fromJson(json.decode(str));

String episodeByContentModelToJson(GetContentByArtistMdel data) =>
    json.encode(data.toJson());

class GetContentByArtistMdel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetContentByArtistMdel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetContentByArtistMdel.fromJson(Map<String, dynamic> json) =>
      GetContentByArtistMdel(
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
  String? musicUploadType;
  String? music;
  int? musicDuration;
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

  Result(
      {this.id,
      this.contentType,
      this.artistId,
      this.categoryId,
      this.languageId,
      this.title,
      this.portraitImg,
      this.landscapeImg,
      this.musicUploadType,
      this.music,
      this.musicDuration,
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
      this.totalUserPlay});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      id: json["id"],
      contentType: json["content_type"],
      artistId: json["artist_id"],
      categoryId: json["category_id"],
      languageId: json["language_id"],
      title: json["title"],
      portraitImg: json["portrait_img"],
      landscapeImg: json["landscape_img"],
      musicUploadType: json["music_upload_type"],
      music: json["music"],
      musicDuration: json["music_duration"],
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
      totalUserPlay: json['total_user_play']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_type": contentType,
        "artist_id": artistId,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "music_upload_type": musicUploadType,
        "music": music,
        "music_duration": musicDuration,
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
        'total_user_play': totalUserPlay
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "content_type": contentType,
      "artist_id": artistId,
      "category_id": categoryId,
      "language_id": languageId,
      "title": title,
      "portrait_img": portraitImg,
      "landscape_img": landscapeImg,
      "music_upload_type": musicUploadType,
      "music": music,
      "music_duration": musicDuration,
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
      'total_user_play': totalUserPlay
    };
  }
}

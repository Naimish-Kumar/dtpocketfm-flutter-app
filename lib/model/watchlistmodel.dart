// To parse this JSON data, do
// final watchlistModel = watchlistModelFromJson(jsonString);

import 'dart:convert';

WatchlistModel watchlistModelFromJson(String str) =>
    WatchlistModel.fromJson(json.decode(str));

String watchlistModelToJson(WatchlistModel data) => json.encode(data.toJson());

class WatchlistModel {
  WatchlistModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  List<Result>? result;

  factory WatchlistModel.fromJson(Map<String, dynamic> json) => WatchlistModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  String? categoryId;
  String? languageId;
  String? castId;
  int? channelId;
  String? directorId;
  String? starringId;
  String? supportingCastId;
  String? networks;
  String? maturityRating;
  String? name;
  String? thumbnail;
  String? landscape;
  String? videoUploadType;
  String? trailerType;
  String? trailerUrl;
  String? releaseYear;
  String? ageRestriction;
  String? maxVideoQuality;
  String? releaseTag;
  int? typeId;
  int? videoType;
  String? videoExtension;
  String? releaseDate;
  int? isPremium;
  String? description;
  int? videoDuration;
  int? videoSize;
  int? view;
  dynamic imdbRating;
  int? download;
  int? status;
  String? isTitle;
  String? video320;
  String? video480;
  String? video720;
  String? video1080;
  String? subtitleType;
  String? subtitleLang1;
  String? subtitleLang2;
  String? subtitleLang3;
  String? subtitle1;
  String? subtitle2;
  String? subtitle3;
  String? createdAt;
  String? updatedAt;
  int? stopTime;
  int? isDownloaded;
  int? isBookmark;
  int? rentBuy;
  int? isRent;
  int? rentPrice;
  int? isBuy;
  String? categoryName;
  String? sessionId;
  int? upcomingType;
  String? studios;
  String? contentAdvisory;
  String? viewingRights;

  Result({
    this.id,
    this.channelId,
    this.categoryId,
    this.languageId,
    this.castId,
    this.typeId,
    this.videoType,
    this.name,
    this.thumbnail,
    this.landscape,
    this.trailerType,
    this.trailerUrl,
    this.description,
    this.isPremium,
    this.isTitle,
    this.releaseDate,
    this.view,
    this.imdbRating,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.directorId,
    this.starringId,
    this.supportingCastId,
    this.networks,
    this.maturityRating,
    this.studios,
    this.contentAdvisory,
    this.viewingRights,
    this.stopTime,
    this.isDownloaded,
    this.isBookmark,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.isBuy,
    this.categoryName,
    this.sessionId,
    this.upcomingType,
    this.download,
    this.videoUploadType,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.videoExtension,
    this.videoDuration,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitle1,
    this.subtitleLang2,
    this.subtitle2,
    this.subtitleLang3,
    this.subtitle3,
    this.releaseYear,
    this.ageRestriction,
    this.maxVideoQuality,
    this.releaseTag,
    this.videoSize,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        channelId: json["channel_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        castId: json["cast_id"],
        typeId: json["type_id"],
        videoType: json["video_type"],
        name: json["name"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        trailerType: json["trailer_type"],
        trailerUrl: json["trailer_url"],
        description: json["description"],
        isPremium: json["is_premium"],
        isTitle: json["is_title"],
        releaseDate: json["release_date"],
        view: json["view"],
        imdbRating: json["imdb_rating"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        directorId: json["director_id"],
        starringId: json["starring_id"],
        supportingCastId: json["supporting_cast_id"],
        networks: json["networks"],
        maturityRating: json["maturity_rating"],
        studios: json["studios"],
        contentAdvisory: json["content_advisory"],
        viewingRights: json["viewing_rights"],
        stopTime: json["stop_time"],
        isDownloaded: json["is_downloaded"],
        isBookmark: json["is_bookmark"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
        categoryName: json["category_name"],
        sessionId: json["session_id"],
        upcomingType: json["upcoming_type"],
        download: json["download"],
        videoUploadType: json["video_upload_type"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        videoExtension: json["video_extension"],
        videoDuration: json["video_duration"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitle1: json["subtitle_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitle2: json["subtitle_2"],
        subtitleLang3: json["subtitle_lang_3"],
        subtitle3: json["subtitle_3"],
        releaseYear: json["release_year"],
        ageRestriction: json["age_restriction"],
        maxVideoQuality: json["max_video_quality"],
        releaseTag: json["release_tag"],
        videoSize: json["video_size"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_id": channelId,
        "category_id": categoryId,
        "language_id": languageId,
        "cast_id": castId,
        "type_id": typeId,
        "video_type": videoType,
        "name": name,
        "thumbnail": thumbnail,
        "landscape": landscape,
        "trailer_type": trailerType,
        "trailer_url": trailerUrl,
        "description": description,
        "is_premium": isPremium,
        "is_title": isTitle,
        "release_date": releaseDate,
        "view": view,
        "imdb_rating": imdbRating,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "director_id": directorId,
        "starring_id": starringId,
        "supporting_cast_id": supportingCastId,
        "networks": networks,
        "maturity_rating": maturityRating,
        "studios": studios,
        "content_advisory": contentAdvisory,
        "viewing_rights": viewingRights,
        "stop_time": stopTime,
        "is_downloaded": isDownloaded,
        "is_bookmark": isBookmark,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
        "category_name": categoryName,
        "session_id": sessionId,
        "upcoming_type": upcomingType,
        "download": download,
        "video_upload_type": videoUploadType,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "video_extension": videoExtension,
        "video_duration": videoDuration,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_1": subtitle1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_2": subtitle2,
        "subtitle_lang_3": subtitleLang3,
        "subtitle_3": subtitle3,
        "release_year": releaseYear,
        "age_restriction": ageRestriction,
        "max_video_quality": maxVideoQuality,
        "release_tag": releaseTag,
        "video_size": videoSize,
      };
}

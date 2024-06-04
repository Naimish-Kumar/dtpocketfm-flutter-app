// To parse this JSON data, do
// final episodeBySeasonModel = episodeBySeasonModelFromJson(jsonString);

import 'dart:convert';

EpisodeBySeasonModel epiBySeasonModelFromJson(String str) =>
    EpisodeBySeasonModel.fromJson(json.decode(str));

String epiBySeasonModelToJson(EpisodeBySeasonModel data) =>
    json.encode(data.toJson());

class EpisodeBySeasonModel {
  EpisodeBySeasonModel({
    this.code,
    this.status,
    this.message,
    this.result,
  });

  int? code;
  int? status;
  String? message;
  List<Result>? result;

  factory EpisodeBySeasonModel.fromJson(Map<String, dynamic> json) =>
      EpisodeBySeasonModel(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  Result({
    this.id,
    this.showId,
    this.sessionId,
    this.thumbnail,
    this.landscape,
    this.videoUploadType,
    this.videoType,
    this.videoExtension,
    this.videoDuration,
    this.isPremium,
    this.name,
    this.description,
    this.view,
    this.download,
    this.status,
    this.isTitle,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitleLang2,
    this.subtitleLang3,
    this.subtitle1,
    this.subtitle2,
    this.subtitle3,
    this.createdAt,
    this.updatedAt,
    this.stopTime,
    this.isDownloaded,
    this.isBookmark,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.isBuy,
    this.categoryName,
    this.upcomingType,
  });

  int? id;
  int? showId;
  int? sessionId;
  String? thumbnail;
  String? landscape;
  String? videoUploadType;
  int? videoType;
  String? videoExtension;
  int? videoDuration;
  int? isPremium;
  String? name;
  String? description;
  int? view;
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
  int? upcomingType;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        showId: json["show_id"],
        sessionId: json["session_id"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        videoUploadType: json["video_upload_type"],
        videoType: json["video_type"],
        videoExtension: json["video_extension"],
        videoDuration: json["video_duration"],
        isPremium: json["is_premium"],
        name: json["name"],
        description: json["description"],
        view: json["view"],
        download: json["download"],
        status: json["status"],
        isTitle: json["is_title"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitleLang3: json["subtitle_lang_3"],
        subtitle1: json["subtitle_1"],
        subtitle2: json["subtitle_2"],
        subtitle3: json["subtitle_3"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        stopTime: json["stop_time"],
        isDownloaded: json["is_downloaded"],
        isBookmark: json["is_bookmark"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
        categoryName: json["category_name"],
        upcomingType: json["upcoming_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "show_id": showId,
        "session_id": sessionId,
        "thumbnail": thumbnail,
        "landscape": landscape,
        "video_upload_type": videoUploadType,
        "video_type": videoType,
        "video_extension": videoExtension,
        "video_duration": videoDuration,
        "is_premium": isPremium,
        "name": name,
        "description": description,
        "view": view,
        "download": download,
        "status": status,
        "is_title": isTitle,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_lang_3": subtitleLang3,
        "subtitle_1": subtitle1,
        "subtitle_2": subtitle2,
        "subtitle_3": subtitle3,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "stop_time": stopTime,
        "is_downloaded": isDownloaded,
        "is_bookmark": isBookmark,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
        "category_name": categoryName,
        "upcoming_type": upcomingType,
      };
}

// To parse this JSON data, do
// final channelSectionModel = channelSectionModelFromJson(jsonString);

import 'dart:convert';

ChannelSectionModel channelSectionModelFromJson(String str) =>
    ChannelSectionModel.fromJson(json.decode(str));

String channelSectionModelToJson(ChannelSectionModel data) =>
    json.encode(data.toJson());

class ChannelSectionModel {
  ChannelSectionModel({
    this.code,
    this.status,
    this.message,
    this.result,
    this.liveUrl,
  });

  int? code;
  int? status;
  String? message;
  List<Result>? result;
  List<LiveUrl>? liveUrl;

  factory ChannelSectionModel.fromJson(Map<String, dynamic> json) =>
      ChannelSectionModel(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
        liveUrl: json["live_url"] != null
            ? List<LiveUrl>.from(
                json["live_url"].map((x) => LiveUrl.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "live_url": liveUrl != null
            ? List<dynamic>.from(liveUrl?.map((x) => x.toJson()) ?? [])
            : [],
      };
}

class LiveUrl {
  LiveUrl({
    this.id,
    this.name,
    this.image,
    this.link,
    this.status,
    this.orderNo,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
  });

  int? id;
  String? name;
  String? image;
  String? link;
  int? status;
  int? orderNo;
  String? createdAt;
  String? updatedAt;
  int? isBuy;

  factory LiveUrl.fromJson(Map<String, dynamic> json) => LiveUrl(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        link: json["link"],
        status: json["status"],
        orderNo: json["order_no"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "link": link,
        "status": status,
        "order_no": orderNo,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
      };
}

class Result {
  Result({
    this.id,
    this.typeId,
    this.categoryId,
    this.channelId,
    this.videoId,
    this.tvShowId,
    this.languageId,
    this.categoryIds,
    this.title,
    this.videoType,
    this.sectionType,
    this.screenLayout,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.channelName,
    this.data,
  });

  int? id;
  int? typeId;
  int? categoryId;
  String? channelId;
  String? videoId;
  String? tvShowId;
  String? languageId;
  String? categoryIds;
  String? title;
  int? videoType;
  int? sectionType;
  String? screenLayout;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? channelName;
  List<Datum>? data;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        typeId: json["type_id"],
        categoryId: json["category_id"],
        channelId: json["channel_id"],
        videoId: json["video_id"],
        tvShowId: json["tv_show_id"],
        languageId: json["language_id"],
        categoryIds: json["category_ids"],
        title: json["title"],
        videoType: json["video_type"],
        sectionType: json["section_type"],
        screenLayout: json["screen_layout"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        channelName: json["channel_name"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type_id": typeId,
        "category_id": categoryId,
        "channel_id": channelId,
        "video_id": videoId,
        "tv_show_id": tvShowId,
        "language_id": languageId,
        "category_ids": categoryIds,
        "title": title,
        "video_type": videoType,
        "section_type": sectionType,
        "screen_layout": screenLayout,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "channel_name": channelName,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class Datum {
  Datum({
    this.id,
    this.categoryId,
    this.languageId,
    this.castId,
    this.channelId,
    this.directorId,
    this.starringId,
    this.supportingCastId,
    this.networks,
    this.maturityRating,
    this.name,
    this.thumbnail,
    this.landscape,
    this.videoUploadType,
    this.trailerType,
    this.trailerUrl,
    this.releaseYear,
    this.ageRestriction,
    this.maxVideoQuality,
    this.releaseTag,
    this.typeId,
    this.videoType,
    this.videoExtension,
    this.isPremium,
    this.description,
    this.videoDuration,
    this.videoSize,
    this.view,
    this.imdbRating,
    this.download,
    this.status,
    this.isTitle,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.subtitleType,
    this.subtitle,
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
    this.sessionId,
    this.studios,
    this.contentAdvisory,
    this.viewingRights,
  });

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
  String? subtitle;
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
  String? studios;
  String? contentAdvisory;
  String? viewingRights;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        castId: json["cast_id"],
        channelId: json["channel_id"],
        directorId: json["director_id"],
        starringId: json["starring_id"],
        supportingCastId: json["supporting_cast_id"],
        networks: json["networks"],
        maturityRating: json["maturity_rating"],
        name: json["name"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        videoUploadType: json["video_upload_type"],
        trailerType: json["trailer_type"],
        trailerUrl: json["trailer_url"],
        releaseYear: json["release_year"],
        ageRestriction: json["age_restriction"],
        maxVideoQuality: json["max_video_quality"],
        releaseTag: json["release_tag"],
        typeId: json["type_id"],
        videoType: json["video_type"],
        videoExtension: json["video_extension"],
        isPremium: json["is_premium"],
        description: json["description"],
        videoDuration: json["video_duration"],
        videoSize: json["video_size"],
        view: json["view"],
        imdbRating: json["imdb_rating"],
        download: json["download"],
        status: json["status"],
        isTitle: json["is_title"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        subtitleType: json["subtitle_type"],
        subtitle: json["subtitle"],
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
        sessionId: json["session_id"],
        studios: json["studios"],
        contentAdvisory: json["content_advisory"],
        viewingRights: json["viewing_rights"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "language_id": languageId,
        "cast_id": castId,
        "channel_id": channelId,
        "director_id": directorId,
        "starring_id": starringId,
        "supporting_cast_id": supportingCastId,
        "networks": networks,
        "maturity_rating": maturityRating,
        "name": name,
        "thumbnail": thumbnail,
        "landscape": landscape,
        "video_upload_type": videoUploadType,
        "trailer_type": trailerType,
        "trailer_url": trailerUrl,
        "release_year": releaseYear,
        "age_restriction": ageRestriction,
        "max_video_quality": maxVideoQuality,
        "release_tag": releaseTag,
        "type_id": typeId,
        "video_type": videoType,
        "video_extension": videoExtension,
        "is_premium": isPremium,
        "description": description,
        "video_duration": videoDuration,
        "video_size": videoSize,
        "view": view,
        "imdb_rating": imdbRating,
        "download": download,
        "status": status,
        "is_title": isTitle,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "subtitle_type": subtitleType,
        "subtitle": subtitle,
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
        "session_id": sessionId,
        "studios": studios,
        "content_advisory": contentAdvisory,
        "viewing_rights": viewingRights,
      };
}

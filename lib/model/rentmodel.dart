// To parse this JSON data, do
// final rentModel = rentModelFromJson(jsonString);

import 'dart:convert';

RentModel rentModelFromJson(String str) => RentModel.fromJson(json.decode(str));

String rentModelToJson(RentModel data) => json.encode(data.toJson());

class RentModel {
  RentModel({
    this.status,
    this.message,
    this.result,
    this.video,
    this.tvshow,
  });

  int? status;
  String? message;
  List<dynamic>? result;
  List<Video>? video;
  List<Tvshow>? tvshow;

  factory RentModel.fromJson(Map<String, dynamic> json) => RentModel(
        status: json["status"],
        message: json["message"],
        result: List<dynamic>.from(json["result"]?.map((x) => x) ?? []),
        video: List<Video>.from(
            json["video"]?.map((x) => Video.fromJson(x)) ?? []),
        tvshow: List<Tvshow>.from(
            json["tvshow"]?.map((x) => Tvshow.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x) ?? []),
        "video": video == null
            ? []
            : List<dynamic>.from(video?.map((x) => x.toJson()) ?? []),
        "tvshow": tvshow == null
            ? []
            : List<dynamic>.from(tvshow?.map((x) => x.toJson()) ?? []),
      };
}

class Tvshow {
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
  String? studios;
  String? contentAdvisory;
  String? viewingRights;
  int? typeId;
  int? videoType;
  String? name;
  String? description;
  String? trailerType;
  String? trailerUrl;
  String? thumbnail;
  String? landscape;
  int? view;
  dynamic imdbRating;
  int? status;
  String? isTitle;
  String? releaseDate;
  int? isPremium;
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
  String? rentTime;
  String? rentType;

  Tvshow({
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
    this.rentTime,
    this.rentType,
  });

  factory Tvshow.fromJson(Map<String, dynamic> json) => Tvshow(
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
        rentTime: json["rent_time"],
        rentType: json["rent_type"],
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
        "rent_time": rentTime,
        "rent_type": rentType,
      };
}

class Video {
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
  String? releaseDate;
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
  String? rentTime;
  String? rentType;

  Video({
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
    this.description,
    this.isPremium,
    this.isTitle,
    this.download,
    this.videoUploadType,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.videoExtension,
    this.videoDuration,
    this.trailerType,
    this.trailerUrl,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitle1,
    this.subtitleLang2,
    this.subtitle2,
    this.subtitleLang3,
    this.subtitle3,
    this.releaseDate,
    this.releaseYear,
    this.imdbRating,
    this.view,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.directorId,
    this.starringId,
    this.supportingCastId,
    this.networks,
    this.maturityRating,
    this.ageRestriction,
    this.maxVideoQuality,
    this.releaseTag,
    this.videoSize,
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
    this.rentTime,
    this.rentType,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
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
        description: json["description"],
        isPremium: json["is_premium"],
        isTitle: json["is_title"],
        download: json["download"],
        videoUploadType: json["video_upload_type"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        videoExtension: json["video_extension"],
        videoDuration: json["video_duration"],
        trailerType: json["trailer_type"],
        trailerUrl: json["trailer_url"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitle1: json["subtitle_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitle2: json["subtitle_2"],
        subtitleLang3: json["subtitle_lang_3"],
        subtitle3: json["subtitle_3"],
        releaseDate: json["release_date"],
        releaseYear: json["release_year"],
        imdbRating: json["imdb_rating"],
        view: json["view"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        directorId: json["director_id"],
        starringId: json["starring_id"],
        supportingCastId: json["supporting_cast_id"],
        networks: json["networks"],
        maturityRating: json["maturity_rating"],
        ageRestriction: json["age_restriction"],
        maxVideoQuality: json["max_video_quality"],
        releaseTag: json["release_tag"],
        videoSize: json["video_size"],
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
        rentTime: json["rent_time"],
        rentType: json["rent_type"],
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
        "description": description,
        "is_premium": isPremium,
        "is_title": isTitle,
        "download": download,
        "video_upload_type": videoUploadType,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "video_extension": videoExtension,
        "video_duration": videoDuration,
        "trailer_type": trailerType,
        "trailer_url": trailerUrl,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_1": subtitle1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_2": subtitle2,
        "subtitle_lang_3": subtitleLang3,
        "subtitle_3": subtitle3,
        "release_date": releaseDate,
        "release_year": releaseYear,
        "imdb_rating": imdbRating,
        "view": view,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "director_id": directorId,
        "starring_id": starringId,
        "supporting_cast_id": supportingCastId,
        "networks": networks,
        "maturity_rating": maturityRating,
        "age_restriction": ageRestriction,
        "max_video_quality": maxVideoQuality,
        "release_tag": releaseTag,
        "video_size": videoSize,
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
        "rent_time": rentTime,
        "rent_type": rentType,
      };
}

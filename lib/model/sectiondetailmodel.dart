// To parse this JSON data, do
// final sectionDetailModel = sectionDetailModelFromJson(jsonString);

import 'dart:convert';

SectionDetailModel sectionDetailModelFromJson(String str) =>
    SectionDetailModel.fromJson(json.decode(str));

String sectionDetailModelToJson(SectionDetailModel data) =>
    json.encode(data.toJson());

class SectionDetailModel {
  SectionDetailModel({
    this.status,
    this.message,
    this.result,
    this.cast,
    this.session,
    this.getRelatedVideo,
    this.language,
    this.moreDetails,
  });

  int? status;
  String? message;
  Result? result;
  List<Cast>? cast;
  List<Session>? session;
  List<GetRelatedVideo>? getRelatedVideo;
  List<Language>? language;
  List<MoreDetail>? moreDetails;

  factory SectionDetailModel.fromJson(Map<String, dynamic> json) =>
      SectionDetailModel(
        status: json["status"],
        message: json["message"],
        result: Result.fromJson(json["result"]),
        cast: List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x))),
        session:
            List<Session>.from(json["session"].map((x) => Session.fromJson(x))),
        getRelatedVideo: List<GetRelatedVideo>.from(
            json["get_related_video"].map((x) => GetRelatedVideo.fromJson(x))),
        language: List<Language>.from(
            json["language"].map((x) => Language.fromJson(x))),
        moreDetails: List<MoreDetail>.from(
            json["more_details"].map((x) => MoreDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? {} : result?.toJson(),
        "cast": cast == null
            ? []
            : List<dynamic>.from(cast?.map((x) => x.toJson()) ?? []),
        "session": session == null
            ? []
            : List<dynamic>.from(session?.map((x) => x.toJson()) ?? []),
        "get_related_video": getRelatedVideo == null
            ? []
            : List<dynamic>.from(getRelatedVideo?.map((x) => x.toJson()) ?? []),
        "language": language == null
            ? []
            : List<dynamic>.from(language?.map((x) => x.toJson()) ?? []),
        "more_details": moreDetails == null
            ? []
            : List<dynamic>.from(moreDetails?.map((x) => x.toJson()) ?? []),
      };
}

class Cast {
  Cast({
    this.id,
    this.name,
    this.image,
    this.type,
    this.personalInfo,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  String? image;
  String? type;
  String? personalInfo;
  int? status;
  String? createdAt;
  String? updatedAt;

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        type: json["type"],
        personalInfo: json["personal_info"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "type": type,
        "personal_info": personalInfo,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Language {
  Language({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? name;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Result {
  Result(
      {this.id,
      this.categoryId,
      this.languageId,
      this.castId,
      this.channelId,
      this.directorId,
      this.starringId,
      this.supportingCastId,
      this.networks,
      this.maturityRating,
      this.studios,
      this.contentAdvisory,
      this.viewingRights,
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
      this.releaseDate,
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
      this.sessionId,
      this.totalUserPlay});

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
  String? thumbnail;
  String? landscape;
  String? videoUploadType;
  String? trailerType;
  String? trailerUrl;
  String? releaseYear;
  String? ageRestriction;
  String? maxVideoQuality;
  String? releaseTag;
  String? videoExtension;
  int? videoDuration;
  int? videoSize;
  int? download;
  int? view;
  dynamic imdbRating;
  int? status;
  String? isTitle;
  String? releaseDate;
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
  int? totalUserPlay;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
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
      studios: json["studios"],
      contentAdvisory: json["content_advisory"],
      viewingRights: json["viewing_rights"],
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
      releaseDate: json["release_date"],
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
      sessionId: json["session_id"],
      totalUserPlay: json["total_user_play"]);

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
        "studios": studios,
        "content_advisory": contentAdvisory,
        "viewing_rights": viewingRights,
        "type_id": typeId,
        "video_type": videoType,
        "name": name,
        "description": description,
        "thumbnail": thumbnail,
        "landscape": landscape,
        "video_upload_type": videoUploadType,
        "trailer_url": trailerUrl,
        "release_year": releaseYear,
        "age_restriction": ageRestriction,
        "max_video_quality": maxVideoQuality,
        "release_tag": releaseTag,
        "video_extension": videoExtension,
        "is_premium": isPremium,
        "video_duration": videoDuration,
        "video_size": videoSize,
        "view": view,
        "imdb_rating": imdbRating,
        "status": status,
        "is_title": isTitle,
        "release_date": releaseDate,
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
        "session_id": sessionId,
        "total_user_play": totalUserPlay
      };
}

class GetRelatedVideo {
  int? id;
  int? channelId;
  String? categoryId;
  String? languageId;
  String? castId;
  int? typeId;
  int? videoType;
  String? name;
  String? thumbnail;
  String? landscape;
  String? trailerType;
  String? trailerUrl;
  String? description;
  int? isPremium;
  String? isTitle;
  String? releaseDate;
  int? view;
  dynamic imdbRating;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? directorId;
  String? starringId;
  String? supportingCastId;
  String? networks;
  String? maturityRating;
  String? studios;
  String? contentAdvisory;
  String? viewingRights;
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
  int? download;
  String? videoUploadType;
  String? video320;
  String? video480;
  String? video720;
  String? video1080;
  String? videoExtension;
  int? videoDuration;
  String? subtitleType;
  String? subtitleLang1;
  String? subtitle1;
  String? subtitleLang2;
  String? subtitle2;
  String? subtitleLang3;
  String? subtitle3;
  String? releaseYear;
  String? ageRestriction;
  String? maxVideoQuality;
  String? releaseTag;
  int? videoSize;

  GetRelatedVideo({
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

  factory GetRelatedVideo.fromJson(Map<String, dynamic> json) =>
      GetRelatedVideo(
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

class MoreDetail {
  MoreDetail({
    this.title,
    this.description,
  });

  String? title;
  String? description;

  factory MoreDetail.fromJson(Map<String, dynamic> json) => MoreDetail(
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}

class Session {
  Session({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isDownloaded,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.isBuy,
  });

  int? id;
  String? name;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isDownloaded;
  int? rentBuy;
  int? isRent;
  int? rentPrice;
  int? isBuy;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isDownloaded: json["is_downloaded"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_downloaded": isDownloaded,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
      };
}

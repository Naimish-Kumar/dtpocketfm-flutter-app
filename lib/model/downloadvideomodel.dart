// import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadVideoModel {
  String? taskId;
  int? progress = 0;
  // DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  DownloadVideoModel({
    this.id,
    this.taskId,
    this.name,
    this.description,
    this.videoUrl,
    this.savedDir,
    this.savedFile,
    this.videoType,
    this.typeId,
    this.isPremium,
    this.isBuy,
    this.isRent,
    this.rentBuy,
    this.rentPrice,
    this.isDownload,
    this.videoDuration,
    this.videoUploadType,
    this.trailerUploadType,
    this.trailerUrl,
    this.releaseYear,
    this.landscapeImg,
    this.thumbnailImg,
    this.session,
  });

  final int? id;
  final String? name;
  final String? description;
  final String? videoUrl;
  final String? savedDir;
  final String? savedFile;
  final int? videoType;
  final int? typeId;
  final int? isPremium;
  final int? isBuy;
  final int? isRent;
  final int? rentBuy;
  final int? rentPrice;
  final int? isDownload;
  final int? videoDuration;
  final String? videoUploadType;
  final String? trailerUploadType;
  final String? trailerUrl;
  final String? releaseYear;
  final String? landscapeImg;
  final String? thumbnailImg;
  List<SessionItem>? session = [];

  factory DownloadVideoModel.fromJson(Map<String, dynamic> json) =>
      DownloadVideoModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        videoUrl: json["videoUrl"],
        savedDir: json["savedDir"],
        savedFile: json["savedFile"],
        videoType: json["videoType"],
        typeId: json["typeId"],
        isPremium: json["isPremium"],
        isBuy: json["isBuy"],
        isRent: json["isRent"],
        rentBuy: json["rentBuy"],
        rentPrice: json["rentPrice"],
        isDownload: json["isDownload"],
        videoDuration: json["videoDuration"],
        videoUploadType: json["videoUploadType"],
        trailerUploadType: json["trailerUploadType"],
        trailerUrl: json["trailerUrl"],
        releaseYear: json["releaseYear"],
        landscapeImg: json["landscapeImg"],
        thumbnailImg: json["thumbnailImg"],
        session: List<SessionItem>.from(
            json["session"].map((x) => SessionItem.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "videoUrl": videoUrl,
        "savedDir": savedDir,
        "savedFile": savedFile,
        "videoType": videoType,
        "typeId": typeId,
        "isPremium": isPremium,
        "isBuy": isBuy,
        "isRent": isRent,
        "rentBuy": rentBuy,
        "rentPrice": rentPrice,
        "isDownload": isDownload,
        "videoDuration": videoDuration,
        "videoUploadType": videoUploadType,
        "trailerUploadType": trailerUploadType,
        "trailerUrl": trailerUrl,
        "releaseYear": releaseYear,
        "landscapeImg": landscapeImg,
        "thumbnailImg": thumbnailImg,
        "session": List<dynamic>.from(session?.map((x) => x.toJson()) ?? []),
      };
}

class SessionItem {
  SessionItem({
    this.id,
    this.showId,
    this.sessionPosition,
    this.name,
    this.status,
    this.isDownloaded,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.isBuy,
    this.episode,
  });

  final int? id;
  final int? showId;
  final int? sessionPosition;
  final String? name;
  final int? status;
  final int? isDownloaded;
  final int? rentBuy;
  final int? isRent;
  final int? rentPrice;
  final int? isBuy;
  List<EpisodeItem>? episode;

  factory SessionItem.fromJson(Map<String, dynamic> json) => SessionItem(
        id: json["id"],
        showId: json["show_id"],
        sessionPosition: json["sessionPosition"],
        name: json["name"],
        status: json["status"],
        isDownloaded: json["is_downloaded"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
        episode: List<EpisodeItem>.from(
            json["episode"]?.map((x) => EpisodeItem.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "show_id": showId,
        "sessionPosition": sessionPosition,
        "name": name,
        "status": status,
        "is_downloaded": isDownloaded,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
        "episode": List<dynamic>.from(episode?.map((x) => x.toJson()) ?? []),
      };
}

class EpisodeItem {
  EpisodeItem({
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
    this.description,
    this.status,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.savedDir,
    this.savedFile,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitleLang2,
    this.subtitleLang3,
    this.subtitle1,
    this.subtitle2,
    this.subtitle3,
    this.isDownloaded,
    this.isBookmark,
    this.rentBuy,
    this.isRent,
    this.rentPrice,
    this.isBuy,
    this.categoryName,
  });

  final int? id;
  final int? showId;
  final int? sessionId;
  final String? thumbnail;
  final String? landscape;
  final String? videoUploadType;
  final dynamic videoType;
  final String? videoExtension;
  final int? videoDuration;
  final int? isPremium;
  final String? description;
  final int? status;
  final String? video320;
  final String? video480;
  final String? video720;
  final String? video1080;
  final String? savedDir;
  final String? savedFile;
  final String? subtitleType;
  final String? subtitleLang1;
  final String? subtitleLang2;
  final String? subtitleLang3;
  final String? subtitle1;
  final String? subtitle2;
  final String? subtitle3;
  final int? isDownloaded;
  final int? isBookmark;
  final int? rentBuy;
  final int? isRent;
  final int? rentPrice;
  final int? isBuy;
  final String? categoryName;

  factory EpisodeItem.fromJson(Map<String, dynamic> json) => EpisodeItem(
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
        description: json["description"],
        status: json["status"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        savedDir: json["savedDir"],
        savedFile: json["savedFile"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitleLang3: json["subtitle_lang_3"],
        subtitle1: json["subtitle_1"],
        subtitle2: json["subtitle_2"],
        subtitle3: json["subtitle_3"],
        isDownloaded: json["is_downloaded"],
        isBookmark: json["is_bookmark"],
        rentBuy: json["rent_buy"],
        isRent: json["is_rent"],
        rentPrice: json["rent_price"],
        isBuy: json["is_buy"],
        categoryName: json["category_name"],
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
        "description": description,
        "status": status,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "savedDir": savedDir,
        "savedFile": savedFile,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_lang_3": subtitleLang3,
        "subtitle_1": subtitle1,
        "subtitle_2": subtitle2,
        "subtitle_3": subtitle3,
        "is_downloaded": isDownloaded,
        "is_bookmark": isBookmark,
        "rent_buy": rentBuy,
        "is_rent": isRent,
        "rent_price": rentPrice,
        "is_buy": isBuy,
        "category_name": categoryName,
      };
}

// To parse this JSON data, do
//
//     final episodeByContentModel = episodeByContentModelFromJson(jsonString);

import 'dart:convert';

VideoByIdModel episodeByContentModelFromJson(String str) =>
    VideoByIdModel.fromJson(json.decode(str));

String episodeByContentModelToJson(VideoByIdModel data) =>
    json.encode(data.toJson());

class VideoByIdModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  VideoByIdModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory VideoByIdModel.fromJson(Map<String, dynamic> json) => VideoByIdModel(
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
  int? contentId;
  int? contentType;
  int? categoryId;
  int? languageId;
  int? artistId;
  String? name;
  String? title;
  String? image;
  String? portraitImg;
  String? landscapeImg;
  String? description;
  int? audioType;
  String? audio;
  String? music;
  int? audioDuration;
  int? isAudioPaid;
  int? isAudioCoin;
  int? totalAudioPlayed;
  int? videoType;
  String? video;
  int? videoDuration;
  int? totalEpisode;
  int? totalReviews;
  int? isVideoPaid;
  int? isVideoCoin;
  int? totalVideoPlayed;
  String? book;
  int? totalPlayed;
  int? isBookPaid;
  int? isBookCoin;
  int? totalBookPlayed;
  String? fullNovel;
  int? isPaidNovel;
  int? novelCoin;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? stopTime;
  int? isBuy;
  String? avgRating;
  int? totalUserPlay;

  Result(
      {this.id,
      this.contentId,
      this.contentType,
      this.artistId,
      this.categoryId,
      this.novelCoin,
      this.totalPlayed,
      this.totalReviews,
      this.languageId,
      this.fullNovel,
      this.isPaidNovel,
      this.name,
      this.title,
      this.music,
      this.portraitImg,
      this.image,
      this.description,
      this.audioType,
      this.avgRating,
      this.audio,
      this.audioDuration,
      this.isAudioPaid,
      this.isAudioCoin,
      this.totalAudioPlayed,
      this.videoType,
      this.video,
      this.videoDuration,
      this.landscapeImg,
      this.isVideoPaid,
      this.isVideoCoin,
      this.totalVideoPlayed,
      this.book,
      this.isBookPaid,
      this.totalEpisode,
      this.isBookCoin,
      this.totalBookPlayed,
      this.sortable,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.stopTime,
      this.isBuy,
      this.totalUserPlay});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
      id: json["id"],
      contentId: json["content_id"],
      contentType: json["content_type"],
      name: json["name"],
      artistId: json["artist_id"],
      title: json["title"],
      categoryId: json["category_id"],
      languageId: json["language_id"],
      totalPlayed: json["total_played"],
      fullNovel: json["full_novel"],
      isPaidNovel: json["is_paid_novel"],
      landscapeImg: json["landscape_img"],
      novelCoin: json["novel_coin"],
      music: json["music"],
      portraitImg: json["portrait_img"],
      image: json["image"],
      description: json["description"],
      totalEpisode: json["total_episode"],
      audioType: json["audio_type"],
      audio: json["audio"],
      totalReviews: json["total_reviews"],
      audioDuration: json["audio_duration"],
      isAudioPaid: json["is_audio_paid"],
      isAudioCoin: json["is_audio_coin"],
      totalAudioPlayed: json["total_audio_played"],
      videoType: json["video_type"],
      video: json["video"],
      videoDuration: json["video_duration"],
      isVideoPaid: json["is_video_paid"],
      isVideoCoin: json["is_video_coin"],
      totalVideoPlayed: json["total_video_played"],
      book: json["book"],
      isBookPaid: json["is_book_paid"],
      isBookCoin: json["is_book_coin"],
      totalBookPlayed: json["total_book_played"],
      sortable: json["sortable"],
      status: json["status"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      stopTime: json["stop_time"],
      isBuy: json["is_buy"],
      avgRating: json["avg_rating"],
      totalUserPlay: json['total_user_play']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_id": contentId,
        "content_type": contentType,
        "artist_id": artistId,
        "landscape_img": landscapeImg,
        "name": name,
        "image": image,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "music": music,
        'total_reviews': totalReviews,
        "portrait_img": portraitImg,
        "total_played": totalPlayed,
        "description": description,
        "audio_type": audioType,
        "audio": audio,
        "full_novel": fullNovel,
        "is_paid_novel": isPaidNovel,
        "avg_rating": avgRating,
        "novel_coin": novelCoin,
        "audio_duration": audioDuration,
        "is_audio_paid": isAudioPaid,
        "is_audio_coin": isAudioCoin,
        "total_audio_played": totalAudioPlayed,
        "total_episode": totalEpisode,
        "video_type": videoType,
        "video": video,
        "video_duration": videoDuration,
        "is_video_paid": isVideoPaid,
        "is_video_coin": isVideoCoin,
        "total_video_played": totalVideoPlayed,
        "book": book,
        "is_book_paid": isBookPaid,
        "is_book_coin": isBookCoin,
        "total_book_played": totalBookPlayed,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "stop_time": stopTime,
        "is_buy": isBuy,
        'total_user_play': totalUserPlay
      };

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "content_id": contentId,
      "artist_id": artistId,
      "content_type": contentType,
      "name": name,
      "category_id": categoryId,
      "language_id": languageId,
      "total_played": totalPlayed,
      "total_episode": totalEpisode,
      "avg_rating": avgRating,
      'total_reviews': totalReviews,
      "image": image,
      "title": title,
      "music": music,
      "landscape_img": landscapeImg,
      "portrait_img": portraitImg,
      "description": description,
      "audio_type": audioType,
      "audio": audio,
      "audio_duration": audioDuration,
      "is_audio_paid": isAudioPaid,
      "is_audio_coin": isAudioCoin,
      "total_audio_played": totalAudioPlayed,
      "video_type": videoType,
      "video": video,
      "video_duration": videoDuration,
      "is_video_paid": isVideoPaid,
      "is_video_coin": isVideoCoin,
      "total_video_played": totalVideoPlayed,
      "book": book,
      "is_book_paid": isBookPaid,
      "is_book_coin": isBookCoin,
      "total_book_played": totalBookPlayed,
      "sortable": sortable,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "stop_time": stopTime,
      "is_buy": isBuy,
      'total_user_play': totalUserPlay
    };
  }
}

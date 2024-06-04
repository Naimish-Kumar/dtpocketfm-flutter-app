// To parse this JSON data, do
//
//     final audioByContentModel = audioByContentModelFromJson(jsonString);

import 'dart:convert';

AudioByContentModel audioByContentModelFromJson(String str) =>
    AudioByContentModel.fromJson(json.decode(str));

String audioByContentModelToJson(AudioByContentModel data) =>
    json.encode(data.toJson());

class AudioByContentModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  AudioByContentModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory AudioByContentModel.fromJson(Map<String, dynamic> json) =>
      AudioByContentModel(
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
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
  String? name;
  String? image;
  String? description;
  int? audioType;
  String? audio;
  int? audioDuration;
  int? isAudioPaid;
  int? isAudioCoin;
  int? totalAudioPlayed;
  int? videoType;
  String? video;
  int? videoDuration;
  int? isVideoPaid;
  int? isVideoCoin;
  int? totalVideoPlayed;
  String? book;
  int? isBookPaid;
  int? isBookCoin;
  int? totalBookPlayed;
  int? sortable;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? stopTime;
  int? isBuy;

  Result({
    this.id,
    this.contentId,
    this.name,
    this.image,
    this.description,
    this.audioType,
    this.audio,
    this.audioDuration,
    this.isAudioPaid,
    this.isAudioCoin,
    this.totalAudioPlayed,
    this.videoType,
    this.video,
    this.videoDuration,
    this.isVideoPaid,
    this.isVideoCoin,
    this.totalVideoPlayed,
    this.book,
    this.isBookPaid,
    this.isBookCoin,
    this.totalBookPlayed,
    this.sortable,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.stopTime,
    this.isBuy,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        contentId: json["content_id"],
        name: json["name"],
        image: json["image"],
        description: json["description"],
        audioType: json["audio_type"],
        audio: json["audio"],
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
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content_id": contentId,
        "name": name,
        "image": image,
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
      };
}

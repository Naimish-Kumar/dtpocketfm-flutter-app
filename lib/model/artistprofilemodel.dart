// To parse this JSON data, do
//
//     final artistProfileModel = artistProfileModelFromJson(jsonString);

import 'dart:convert';

ArtistProfileModel artistProfileModelFromJson(String str) =>
    ArtistProfileModel.fromJson(json.decode(str));

String artistProfileModelToJson(ArtistProfileModel data) =>
    json.encode(data.toJson());

class ArtistProfileModel {
  int? status;
  String? message;
  List<Result>? result;

  ArtistProfileModel({
    this.status,
    this.message,
    this.result,
  });

  factory ArtistProfileModel.fromJson(Map<String, dynamic> json) =>
      ArtistProfileModel(
        status: json["status"],
        message: json["message"],
        result: json['result'] == null
            ? null
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  String? userName;
  String? image;
  String? bio;
  String? instagramUrl;
  String? facebookUrl;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? followes;
  int? isFollow;

  Result({
    this.id,
    this.userName,
    this.image,
    this.bio,
    this.instagramUrl,
    this.facebookUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.followes,
    this.isFollow,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userName: json["user_name"],
        image: json["image"],
        bio: json["bio"],
        instagramUrl: json["instagram_url"],
        facebookUrl: json["facebook_url"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        followes: json["followes"],
        isFollow: json["is_follow"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_name": userName,
        "image": image,
        "bio": bio,
        "instagram_url": instagramUrl,
        "facebook_url": facebookUrl,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "followes": followes,
        "is_follow": isFollow,
      };
}

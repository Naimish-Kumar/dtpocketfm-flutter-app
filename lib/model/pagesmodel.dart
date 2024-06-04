// To parse this JSON data, do
//
//     final pagesModel = pagesModelFromJson(jsonString);

import 'dart:convert';

PagesModel pagesModelFromJson(String str) =>
    PagesModel.fromJson(json.decode(str));

String pagesModelToJson(PagesModel data) => json.encode(data.toJson());

class PagesModel {
  int? status;
  String? message;
  List<Result>? result;

  PagesModel({
    this.status,
    this.message,
    this.result,
  });

  factory PagesModel.fromJson(Map<String, dynamic> json) => PagesModel(
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  String? pageName;
  String? title;
  String? url;
  String? icon;

  Result({
    this.pageName,
    this.title,
    this.url,
    this.icon,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        pageName: json["page_name"],
        title: json["title"],
        url: json["url"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "page_name": pageName,
        "title": title,
        "url": url,
        "icon": icon,
      };
}

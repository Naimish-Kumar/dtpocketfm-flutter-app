import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyImage extends StatelessWidget {
  double? height;
  double? width;
  String? imagePath;
  Color? color;
  dynamic fit;

  MyImage(
      {super.key,
      this.width,
      this.height,
      required this.imagePath,
      this.color,
      this.fit});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/$imagePath",
      height: height,
      color: color,
      width: width,
      fit: fit,
      errorBuilder: (context, url, error) {
        return Image.asset(
          "assets/images/no_image_port.png",
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

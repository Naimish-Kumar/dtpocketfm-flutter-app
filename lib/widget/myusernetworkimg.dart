import 'package:cached_network_image/cached_network_image.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyUserNetworkImage extends StatelessWidget {
  String imageUrl;
  double? imgHeight, imgWidth;
  dynamic fit;

  MyUserNetworkImage(
      {super.key,
      required this.imageUrl,
      required this.fit,
      this.imgHeight,
      this.imgWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imgHeight,
      width: imgWidth,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) {
          return MyImage(
            width: imgWidth,
            height: imgHeight,
            imagePath: "no_user.png",
            fit: BoxFit.cover,
          );
        },
        errorWidget: (context, url, error) {
          return MyImage(
            width: imgWidth,
            height: imgHeight,
            imagePath: "no_user.png",
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}

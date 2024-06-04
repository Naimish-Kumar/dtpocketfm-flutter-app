import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String? title, subTitle;
  const NoData({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: transparentColor,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyImage(
              height: 130,
              fit: BoxFit.contain,
              imagePath: "nodata.png",
            ),
            const SizedBox(height: 20),
            (title ?? "") != ""
                ? MyText(
                    color: white,
                    text: title ?? "",
                    fontsizeNormal: 16,
                    fontsizeWeb: 12,
                    maxline: 2,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 8),
            (subTitle ?? "") != ""
                ? MyText(
                    color: otherColor,
                    // text: subTitle ?? "",
                    text: "datawillappear",
                    fontsizeNormal: 14,
                    fontsizeWeb: 10,
                    maxline: 5,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w500,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

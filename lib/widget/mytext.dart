// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:math';

import 'package:dtpocketfm/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class MyText extends StatelessWidget {
  String text;
  double? fontsizeNormal, fontsizeWeb;
  var maxline, fontstyle, fontweight, textalign, multilanguage;
  Color color;
  var overflow;

  MyText({
    super.key,
    required this.color,
    required this.text,
    this.fontsizeNormal,
    this.fontsizeWeb,
    this.maxline,
    this.multilanguage,
    this.overflow,
    this.textalign,
    this.fontweight,
    this.fontstyle,
  });

  static getAdaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    if (kIsWeb || Constant.isTV) {
      return (value / 650) *
          min(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width);
    } else {
      return (value / 720 * MediaQuery.of(context).size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (multilanguage == true) {
      return LocaleText(
        text,
        // textAlign: textalign,
        overflow: overflow,
        // maxLines: maxline,
        style: GoogleFonts.montserrat(
          fontSize: getAdaptiveTextSize(context,
              (kIsWeb || Constant.isTV) ? fontsizeWeb : fontsizeNormal),
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontweight,
        ),
      );
    } else {
      return Text(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: GoogleFonts.montserrat(
          fontSize: getAdaptiveTextSize(context,
              (kIsWeb || Constant.isTV) ? fontsizeWeb : fontsizeNormal),
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontweight,
        ),
      );
    }
  }
}

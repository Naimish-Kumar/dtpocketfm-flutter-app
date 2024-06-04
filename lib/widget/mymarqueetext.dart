import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

// ignore: must_be_immutable
class MyMarqueeText extends StatelessWidget {
  String? text;
  double fontsize;
  dynamic fontstyle, fontweight, color;

  MyMarqueeText({
    super.key,
    this.color,
    required this.text,
    required this.fontsize,
    this.fontweight,
    this.fontstyle,
  });

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text ?? "",
      style: GoogleFonts.inter(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color: color,
        fontWeight: fontweight,
      ),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: MediaQuery.of(context).size.width * 0.5,
      velocity: 50,
      pauseAfterRound: const Duration(milliseconds: 500),
      showFadingOnlyWhenScrolling: true,
      fadingEdgeStartFraction: 0.1,
      fadingEdgeEndFraction: 0.1,
      startPadding: 10,
      accelerationDuration: const Duration(milliseconds: 500),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}

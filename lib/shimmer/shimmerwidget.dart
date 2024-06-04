import 'package:dtpocketfm/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final Color shimmerBgColor;

// Rectangular
  const ShimmerWidget.rectangular(
      {super.key,
      this.width = double.infinity,
      this.shimmerBgColor = shimmerItemColor,
      required this.height})
      : shapeBorder = const RoundedRectangleBorder();

// Circle
  const ShimmerWidget.circular({
    super.key,
    this.width = double.infinity,
    this.shimmerBgColor = shimmerItemColor,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

// Round corner Container
  const ShimmerWidget.roundcorner({
    super.key,
    this.width = double.infinity,
    this.shimmerBgColor = shimmerItemColor,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8))),
  });

// for line / text
  const ShimmerWidget.roundrectborder({
    super.key,
    this.width = double.infinity,
    this.shimmerBgColor = shimmerItemColor,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4))),
  });

  @override
  Widget build(BuildContext context) => Shimmer(
        duration: const Duration(milliseconds: 800),
        interval: const Duration(milliseconds: 800),
        color: shimmerColor,
        colorOpacity: 0.3,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: shimmerBgColor,
            shape: shapeBorder,
          ),
        ),
      );
}

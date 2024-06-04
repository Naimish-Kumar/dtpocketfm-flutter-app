import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InteractiveIcon extends StatefulWidget {
  final String imagePath;
  dynamic iconColor, iconColorHover, bgColor, bgHoverColor;
  final double? bgRadius, height, width;
  final bool? withBG;

  InteractiveIcon({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.iconColor,
    this.iconColorHover,
    this.withBG,
    this.bgRadius,
    this.bgColor,
    this.bgHoverColor,
  });

  @override
  InteractiveIconState createState() => InteractiveIconState();
}

class InteractiveIconState extends State<InteractiveIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => _hovered(true),
      onExit: (_) => _hovered(false),
      child: (widget.withBG ?? true)
          ? Container(
              decoration: Utils.setBackground(
                  _hovering ? widget.bgHoverColor : widget.bgColor,
                  widget.bgRadius ?? 0),
              padding: const EdgeInsets.all(6),
              child: MyImage(
                imagePath: widget.imagePath,
                width: widget.width,
                height: widget.height,
                color: _hovering ? widget.iconColorHover : widget.iconColor,
              ),
            )
          : MyImage(
              imagePath: widget.imagePath,
              width: widget.width,
              height: widget.height,
              color: _hovering ? widget.iconColorHover : widget.iconColor,
            ),
    );
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}

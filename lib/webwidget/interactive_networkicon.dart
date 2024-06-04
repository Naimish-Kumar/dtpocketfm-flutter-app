import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InteractiveNetworkIcon extends StatefulWidget {
  final String imagePath;
  dynamic iconFit, bgColor, bgHoverColor;
  final double? bgRadius, height, width;
  final bool? withBG;

  InteractiveNetworkIcon({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.iconFit,
    this.withBG,
    this.bgRadius,
    this.bgColor,
    this.bgHoverColor,
  });

  @override
  InteractiveNetworkIconState createState() => InteractiveNetworkIconState();
}

class InteractiveNetworkIconState extends State<InteractiveNetworkIcon> {
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
              child: MyNetworkImage(
                imageUrl: widget.imagePath,
                imgWidth: widget.width,
                imgHeight: widget.height,
                fit: widget.iconFit,
              ),
            )
          : MyNetworkImage(
              imageUrl: widget.imagePath,
              imgWidth: widget.width,
              imgHeight: widget.height,
              fit: widget.iconFit,
            ),
    );
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}

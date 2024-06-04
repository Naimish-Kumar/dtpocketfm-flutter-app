import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/material.dart';

class InteractiveText extends StatefulWidget {
  final String text;
  final double? fontsizeWeb;
  final dynamic maxline,
      fontstyle,
      fontweight,
      textalign,
      multilanguage,
      overflow;

  const InteractiveText({
    super.key,
    required this.text,
    this.fontsizeWeb,
    this.maxline,
    this.multilanguage,
    this.overflow,
    this.textalign,
    this.fontweight,
    this.fontstyle,
  });

  @override
  InteractiveTextState createState() => InteractiveTextState();
}

class InteractiveTextState extends State<InteractiveText> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => _hovered(true),
      onExit: (_) => _hovered(false),
      child: MyText(
        multilanguage: widget.multilanguage,
        color: _hovering ? colorPrimary : white,
        text: widget.text,
        maxline: widget.maxline,
        textalign: widget.textalign,
        fontstyle: widget.fontstyle,
        fontsizeWeb: widget.fontsizeWeb,
        fontsizeNormal: widget.fontsizeWeb,
        fontweight: widget.fontweight,
      ),
    );
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}

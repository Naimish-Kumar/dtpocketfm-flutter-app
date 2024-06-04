import 'package:flutter/material.dart';

class TranslateOnHover extends StatefulWidget {
  final Widget child;
  // You can also pass the translation in here if you want to
  const TranslateOnHover({super.key, required this.child});

  @override
  State<TranslateOnHover> createState() => _TranslateOnHoverState();
}

class _TranslateOnHoverState extends State<TranslateOnHover> {
  double elevation = 0;
  double scale = 1.0;
  Offset translate = const Offset(0, 0);
  final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
  final hoverTransform = Matrix4.identity()..translate(0, -10, 0);

  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _mouseEnter(true),
      onExit: (e) => _mouseEnter(false),
      child: Transform.translate(
        offset: translate,
        child: Transform.scale(
          scale: scale,
          child: widget.child,
        ),
      ),
    );
  }

  void _mouseEnter(bool hover) {
    debugPrint("_hovering ====> $_hovering");
    if (hover) {
      setState(() {
        elevation = 5;
        scale = 1.1;
        translate = const Offset(3, 3);
        _hovering = true;
      });
    } else {
      setState(() {
        elevation = 4;
        scale = 1.0;
        translate = const Offset(0, 0);
        _hovering = false;
      });
    }
  }
}

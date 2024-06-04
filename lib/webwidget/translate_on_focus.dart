import 'package:flutter/material.dart';

class TranslateOnFocus extends StatefulWidget {
  final Widget child;
  // You can also pass the translation in here if you want to
  const TranslateOnFocus({super.key, required this.child});

  @override
  State<TranslateOnFocus> createState() => _TranslateOnFocusState();
}

class _TranslateOnFocusState extends State<TranslateOnFocus> {
  double elevation = 0;
  double scale = 1.0;
  Offset translate = const Offset(0, 0);
  final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
  final hoverTransform = Matrix4.identity()..translate(0, -10, 0);

  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onFocusChange: (e) => _mouseEnter(!_hovering),
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

import 'package:dtpocketfm/webwidget/translate_on_focus.dart';
import 'package:flutter/material.dart';

extension FocusExtensions on Widget {
  // Get a regerence to the body of the view
  Widget get moveUpOnFocus {
    return TranslateOnFocus(
      child: this,
    );
  }
}

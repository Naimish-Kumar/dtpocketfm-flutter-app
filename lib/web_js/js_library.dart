@JS()
library script.js;

import 'package:js/js.dart';

// This function will open new popup window for given URL.
@JS()
external dynamic jsOpenTab(String url, String target);

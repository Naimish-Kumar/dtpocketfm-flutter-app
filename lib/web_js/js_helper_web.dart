import 'package:js/js_util.dart';

import 'js_library.dart';

class JSHelper {
  Future<String> callOpenTab(String url, String target) async {
    return await promiseToFuture(jsOpenTab(url, target));
  }
}

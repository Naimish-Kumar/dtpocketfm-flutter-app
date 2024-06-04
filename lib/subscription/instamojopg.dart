import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InstamojoPG extends StatefulWidget {
  final String? paymentId;
  final String? paymentUrl;

  const InstamojoPG({
    super.key,
    required this.paymentId,
    required this.paymentUrl,
  });

  @override
  State<InstamojoPG> createState() => _InstamojoPGState();
}

class _InstamojoPGState extends State<InstamojoPG> {
  InAppWebViewController? webViewController;
  String finalPaymentId = "";

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return PopScope(
      onPopInvoked: (didPop) {
        debugPrint("finalPaymentId =========> $finalPaymentId");
        if (finalPaymentId != "") {
          Navigator.pop(context, true);
          return;
        } else {
          Navigator.pop(context, false);
          return;
        }
      },
      child: Scaffold(
        backgroundColor: appBgColor,
        appBar: Utils.myAppBarWithBack(context, "Instamojo", true, false),
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest:
                URLRequest(url: Uri.parse(widget.paymentUrl ?? "")),
            onWebViewCreated: (controller) async {
              webViewController = controller;
            },
            onLoadStart: (controller, url) async {},
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              debugPrint("onLoadStop url =========> $url");
              if (url.toString().contains('instamojo.com/order/status')) {
                finalPaymentId = widget.paymentId ?? "";
                debugPrint(
                    "onLoadStop finalPaymentId =========> $finalPaymentId");
                Navigator.pop(context, true);
              } else {
                finalPaymentId = "";
              }
            },
            onProgressChanged: (controller, progress) {},
            onUpdateVisitedHistory: (controller, url, isReload) {
              debugPrint("onUpdateVisitedHistory url =========> $url");
            },
            onConsoleMessage: (controller, consoleMessage) {},
          ),
        ),
      ),
    );
  }
}

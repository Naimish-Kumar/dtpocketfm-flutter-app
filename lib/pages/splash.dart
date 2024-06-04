import 'package:dtpocketfm/pages/bottombar.dart';
import 'package:dtpocketfm/pages/intro.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/tvpages/webhome.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> {
  String? seen;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      if (!mounted) return;
      isFirstCheck();
    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        color: appBgColor,
        child: MyImage(
          imagePath: (kIsWeb || Constant.isTV) ? "appicon.png" : "splash.png",
          fit: (kIsWeb || Constant.isTV) ? BoxFit.contain : BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> isFirstCheck() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.setLoading(true);

    seen = await sharedPre.read('seen') ?? "0";
    Constant.userID = await sharedPre.read('userid');
    debugPrint('seen ==> $seen');
    debugPrint('Constant userID ==> ${Constant.userID}');
    if (!mounted) return;
    if (kIsWeb || Constant.isTV) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const WebHome(pageName: "home");
          },
        ),
      );
    } else {
      if (seen == "1") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Intro();
            },
          ),
        );
      }
    }
  }
}

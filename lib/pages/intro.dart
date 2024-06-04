import 'package:dtpocketfm/pages/bottombar.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => IntroState();
}

class IntroState extends State<Intro> {
  PageController pageController = PageController();
  final currentPageNotifier = ValueNotifier<int>(0);
  int position = 0;

  List<String> introBigtext = <String>[
    "intro1title",
    "intro2title",
    "intro3title",
    // "intro4title",
  ];
  List<String> introSmalltext = <String>[
    "intro1smalltitle",
    "intro2smalltitle",
    "intro3smalltitle",
    // "intro4title",
  ];

  List<String> introPager = <String>[
    "intro1.png",
    "intro2.png",
    "intro3.png",
    // "intro4.png",
  ];

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/introbg.png"))),
            alignment: Alignment.center,
            child: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 6,
                      child: Padding(
                        padding: EdgeInsets.all(18),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 0),
                              child: SmoothPageIndicator(
                                controller: pageController,
                                count: introPager.length,
                                axisDirection: Axis.horizontal,
                                effect: const ExpandingDotsEffect(
                                  spacing: 6,
                                  radius: 5,
                                  dotWidth: 10,
                                  expansionFactor: 4,
                                  dotHeight: 10,
                                  dotColor: grayDark,
                                  activeDotColor: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PageView.builder(
            itemCount: introPager.length,
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return SafeArea(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: MyImage(
                            imagePath: introPager[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              MyText(
                                color: white,
                                maxline: 4,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                text: introBigtext[index],
                                textalign: TextAlign.center,
                                fontsizeNormal: 20,
                                fontsizeWeb: 25,
                                fontweight: FontWeight.w600,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              MyText(
                                color: white,
                                maxline: 7,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                text: introSmalltext[index],
                                textalign: TextAlign.center,
                                fontsizeNormal: 14,
                                fontsizeWeb: 25,
                                fontweight: FontWeight.w500,
                                fontstyle: FontStyle.normal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onPageChanged: (index) {
              position = index;
              currentPageNotifier.value = index;
              debugPrint("position :==> $position");
              setState(() {});
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 80),
              child: InkWell(
                onTap: () {
                  debugPrint("nextPage pos :==> $position");
                  if (position == introPager.length - 1) {
                    Utils.setFirstTime("1");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Bottombar();
                        },
                      ),
                    );
                  }
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 0,
                    maxHeight: 45,
                    minWidth: 0,
                    maxWidth: 200,
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryDark,
                    borderRadius: BorderRadius.circular(5),
                    shape: BoxShape.rectangle,
                  ),
                  child: MyText(
                    color: white,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    multilanguage: true,
                    text: (position == introPager.length - 1)
                        ? "getstarted"
                        : "next",
                    textalign: TextAlign.center,
                    fontsizeNormal: 16,
                    fontsizeWeb: 18,
                    fontweight: FontWeight.w700,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
          (position != introPager.length - 1)
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      debugPrint("pos :==> $position");
                      Utils.setFirstTime("1");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Bottombar();
                          },
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                      padding: const EdgeInsets.all(15),
                      child: MyText(
                        color: white,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        text: "skip",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 14,
                        fontsizeWeb: 16,
                        fontweight: FontWeight.w600,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/web_js/js_helper.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:dtpocketfm/webwidget/interactive_icon.dart';
import 'package:dtpocketfm/webwidget/interactive_text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class FooterWeb extends StatefulWidget {
  const FooterWeb({super.key});

  @override
  State<FooterWeb> createState() => _FooterWebState();
}

class _FooterWebState extends State<FooterWeb> {
  final JSHelper _jsHelper = JSHelper();
  SharedPre sharedPref = SharedPre();
  late GeneralProvider generalProvider;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _redirectToUrl(loadingUrl) async {
    debugPrint("loadingUrl -----------> $loadingUrl");
    /*
      _blank => open new Tab
      _self => open in current Tab
    */
    String dataFromJS = await _jsHelper.callOpenTab(loadingUrl, '_blank');
    debugPrint("dataFromJS -----------> $dataFromJS");
  }

  _getData() async {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    await generalProvider.getPages();
    // await generalProvider.getSocialLinks();

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
      child: (MediaQuery.of(context).size.width < 800)
          ? _buildColumnFooter()
          : _buildRowFooter(),
    );
  }

  Widget _buildRowFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* App Icon & Desc. */
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyImage(
                width: 200,
                height: 60,
                fit: BoxFit.fill,
                imagePath: "appicon.png",
              ),
              const SizedBox(height: 8),
              Consumer<GeneralProvider>(
                builder: (context, generalProvider, child) {
                  return MyText(
                    color: otherColor,
                    multilanguage: false,
                    text: generalProvider.appDescription ?? "",
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 13,
                    fontsizeNormal: 13,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                    maxline: 5,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),

        /* Quick Links */
        Expanded(
          child: _buildPages(),
        ),
        const SizedBox(width: 30),

        /* Contact With us & Available On */
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Social Icons */
              // _buildSocialLink(),
              // const SizedBox(height: 20),

              /* Available On */
              MyText(
                color: white,
                multilanguage: false,
                text: "${Constant.appName} Available On",
                fontweight: FontWeight.w600,
                fontsizeWeb: 13,
                fontsizeNormal: 13,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              /* Store Icons */
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _redirectToUrl(Constant.androidAppUrl);
                    },
                    borderRadius: BorderRadius.circular(3),
                    child: InteractiveIcon(
                      imagePath: "playstore.png",
                      height: 25,
                      width: 25,
                      withBG: true,
                      bgRadius: 3,
                      bgColor: transparentColor,
                      bgHoverColor: colorPrimary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      _redirectToUrl(Constant.iosAppUrl);
                    },
                    borderRadius: BorderRadius.circular(3),
                    child: InteractiveIcon(
                      height: 25,
                      width: 25,
                      imagePath: "applestore.png",
                      iconColor: white,
                      withBG: true,
                      bgRadius: 3,
                      bgColor: transparentColor,
                      bgHoverColor: colorPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumnFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* App Icon & Desc. */
        Container(
          width: 160,
          height: 120,
          alignment: Alignment.centerLeft,
          child: MyImage(
            fit: BoxFit.fill,
            imagePath: "appicon.png",
          ),
        ),
        const SizedBox(height: 8),
        Consumer<GeneralProvider>(
          builder: (context, generalProvider, child) {
            return MyText(
              color: otherColor,
              multilanguage: false,
              text: generalProvider.appDescription ?? "",
              fontweight: FontWeight.w500,
              fontsizeWeb: 13,
              fontsizeNormal: 13,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
              maxline: 5,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        const SizedBox(height: 30),

        /* Quick Links */
        _buildPages(),
        // const SizedBox(height: 30),

        /* Contact With us & Store Icons */
        /* Social Icons */
        // _buildSocialLink(),
        const SizedBox(height: 20),

        /* Available On */
        MyText(
          color: white,
          multilanguage: false,
          text: "${Constant.appName} Available On",
          fontweight: FontWeight.w600,
          fontsizeWeb: 13,
          fontsizeNormal: 13,
          textalign: TextAlign.start,
          fontstyle: FontStyle.normal,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        /* Store Icons */
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _redirectToUrl(Constant.androidAppUrl);
              },
              borderRadius: BorderRadius.circular(3),
              child: InteractiveIcon(
                imagePath: "playstore.png",
                height: 25,
                width: 25,
                withBG: true,
                bgRadius: 3,
                bgColor: transparentColor,
                bgHoverColor: colorPrimary,
              ),
            ),
            const SizedBox(width: 5),
            InkWell(
              onTap: () {
                _redirectToUrl(Constant.iosAppUrl);
              },
              borderRadius: BorderRadius.circular(3),
              child: InteractiveIcon(
                height: 25,
                width: 25,
                imagePath: "applestore.png",
                iconColor: white,
                withBG: true,
                bgRadius: 3,
                bgColor: transparentColor,
                bgHoverColor: colorPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPages() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount: (generalProvider.pagesModel.result?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return _buildPageItem(
              pageName:
                  generalProvider.pagesModel.result?[position].title ?? "",
              onClick: () {
                _redirectToUrl(
                    generalProvider.pagesModel.result?[position].url ?? "");
              },
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildPageItem({
    required String pageName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: InteractiveText(
        text: pageName,
        multilanguage: false,
        maxline: 2,
        textalign: TextAlign.justify,
        fontstyle: FontStyle.normal,
        fontsizeWeb: 14,
        fontweight: FontWeight.w600,
      ),
    );
  }

  // Widget _buildSocialLink() {
  //   if (generalProvider.loading) {
  //     return const SizedBox.shrink();
  //   } else {
  //     if (generalProvider.socialLinkModel.status == 200 &&
  //         generalProvider.socialLinkModel.result != null) {
  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           MyText(
  //             color: white,
  //             multilanguage: false,
  //             text: "Connect With Us",
  //             fontweight: FontWeight.w600,
  //             fontsizeWeb: 13,
  //             fontsizeNormal: 13,
  //             textalign: TextAlign.start,
  //             fontstyle: FontStyle.normal,
  //             maxline: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           AlignedGridView.count(
  //             shrinkWrap: true,
  //             crossAxisCount: 6,
  //             crossAxisSpacing: 8,
  //             mainAxisSpacing: 8,
  //             itemCount: (generalProvider.socialLinkModel.result?.length ?? 0),
  //             padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemBuilder: (BuildContext context, int position) {
  //               return Wrap(
  //                 children: [
  //                   _buildSocialIcon(
  //                     iconUrl: generalProvider
  //                             .socialLinkModel.result?[position].image ??
  //                         "",
  //                     onClick: () {
  //                       _redirectToUrl(generalProvider
  //                               .socialLinkModel.result?[position].url ??
  //                           "");
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     } else {
  //       return const SizedBox.shrink();
  //     }
  //   }
  // }

  // Widget _buildSocialIcon({
  //   required String iconUrl,
  //   required Function() onClick,
  // }) {
  //   return SizedBox(
  //     height: Dimens.heightSocialBtn,
  //     width: Dimens.widthSocialBtn,
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(3.0),
  //       onTap: onClick,
  //       child: InteractiveNetworkIcon(
  //         height: 20,
  //         width: 20,
  //         iconFit: BoxFit.contain,
  //         imagePath: iconUrl,
  //         withBG: true,
  //         bgRadius: 3.0,
  //         bgColor: lightBlack,
  //         bgHoverColor: colorPrimary,
  //       ),
  //     ),
  //   );
  // }
}

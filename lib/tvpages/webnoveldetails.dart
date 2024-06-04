import 'dart:io';

import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/pages/pdfviewpage.dart';
import 'package:dtpocketfm/provider/novelsectiondataprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/moredetails.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:social_share/social_share.dart';

class WebNovelDetails extends StatefulWidget {
  final int videoId, videoType;
  const WebNovelDetails(this.videoId, this.videoType, {super.key});

  @override
  State<WebNovelDetails> createState() => WebNovelDetailsState();
}

class WebNovelDetailsState extends State<WebNovelDetails> {
  String? audioLanguages;
  late NovelSectionDataProvider showDetailsProvider;
  late NovelSectionDataProvider episodeProvider;
  late ScrollController _scrollController;
  double? ratingGiven;
  late ProgressDialog prDialog;
  final commentController = TextEditingController();
  late ProfileProvider profileProvider;
  String? userName, userEmail, userMobileNo;
  late SubscriptionProvider subscriptionProvider;
  SharedPre sharedPre = SharedPre();
  @override
  void initState() {
    showDetailsProvider =
        Provider.of<NovelSectionDataProvider>(context, listen: false);
    episodeProvider =
        Provider.of<NovelSectionDataProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    super.initState();
    prDialog = ProgressDialog(context);
    debugPrint("initState videoId ==> ${widget.videoId}");
    debugPrint("initState videoType ==> ${widget.videoType}");
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    showDetailsProvider.setLoading(true);
    _getData();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (showDetailsProvider.tabNovelClickedOn == "chapters") {
        if ((showDetailsProvider.novelcurrentPage ?? 0) <
            (showDetailsProvider.noveltotalPage ?? 0)) {
          showDetailsProvider.setLoadMore(true);
          _fetchData(
            showDetailsProvider.novelcurrentPage ?? 0,
          );
        }
      } else {
        if ((showDetailsProvider.reviewcurrentPage ?? 0) <
            (showDetailsProvider.reviewtotalPage ?? 0)) {
          showDetailsProvider.setLoadMore(true);
          await fetchComments((showDetailsProvider.reviewcurrentPage ?? 0));
        }
      }
    }
  }

  bool checkIsBuyOrNot() {
    for (var item in episodeProvider.novelList ?? []) {
      if (item.isBuy == 1) {
        episodeProvider.checkIsBuy(true);
        return true;
      } else {
        episodeProvider.checkIsBuy(false);
      }
    }
    return false;
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await showDetailsProvider.getNovelChapterdetails(
        widget.videoId, (nextPage ?? 0) + 1);
    if (nextPage == 0) {
      checkIsBuyOrNot();
    }
  }

  Future<void> fetchComments(int? nextPage) async {
    await showDetailsProvider.getReviews(
        widget.videoId, widget.videoType, (nextPage ?? 0) + 1);
  }

  Future<void> _getData() async {
    Utils.getCurrencySymbol();
    await profileProvider.getProfile(context);
    await showDetailsProvider.getContentDetails(
      widget.videoId,
      widget.videoType,
    );
    await subscriptionProvider.getPackages();
    await _fetchData(0);
    await fetchComments(0);
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {
        debugPrint(
            "setState videoId ======================> ${widget.videoId}");
      });
    });
  }

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');
  }

  @override
  void dispose() {
    super.dispose();
    showDetailsProvider.clearProvider();
    episodeProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        key: widget.key,
        backgroundColor: appBgColor,
        body: SafeArea(
          child: _buildUIWithAppBar(),
        ),
      ),
      Utils.buildMusicPanel(context),
    ]);
  }

  Widget _buildUIWithAppBar() {
    if (showDetailsProvider.loading) {
      return SingleChildScrollView(
        child: ((kIsWeb || Constant.isTV) &&
                MediaQuery.of(context).size.width > 720)
            ? ShimmerUtils.buildDetailWebShimmer(context, "video")
            : ShimmerUtils.buildDetailMobileShimmer(context, "video"),
      );
    } else {
      if (showDetailsProvider.contentdetailsModel.status == 200 &&
          showDetailsProvider.contentdetailsModel.result != null) {
        if ((kIsWeb || Constant.isTV) &&
            MediaQuery.of(context).size.width > 720) {
          return _buildTVWebData();
        } else {
          return _buildMobileData();
        }
      } else {
        return const NoData(title: 'nodata', subTitle: '');
      }
    }
  }

  Widget _buildTVWebData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              /* Poster */
              Container(
                constraints: BoxConstraints(
                  minHeight: Dimens.detailWebPoster,
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  children: [
                    /* Poster */
                    Stack(children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        height: Dimens.detailWebPoster,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              red,
                              red.withOpacity(0.8),
                              red.withOpacity(0.6),
                              red.withOpacity(0.4),
                              red.withOpacity(0.2),
                              white.withOpacity(0.5),
                              white,
                              appBgColor.withOpacity(0.5),
                              appBgColor
                            ])),
                        child: Column(
                          children: [
                            Expanded(
                              child: MyNetworkImage(
                                imgWidth:
                                    MediaQuery.of(context).size.width * 0.3,
                                fit: BoxFit.fill,
                                imageUrl: (showDetailsProvider
                                                .contentdetailsModel
                                                .result?[0]
                                                .webBannerImg ??
                                            "")
                                        .isEmpty
                                    ? (showDetailsProvider.contentdetailsModel
                                            .result?[0].landscapeImg
                                            .toString() ??
                                        "")
                                    : (showDetailsProvider.contentdetailsModel
                                            .result?[0].webBannerImg
                                            .toString() ??
                                        ""),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () {
                                if (Constant.userID != null) {
                                  if ((showDetailsProvider.contentdetailsModel
                                              .result?[0].fullNovel ??
                                          "")
                                      .isNotEmpty) {
                                    if (showDetailsProvider.contentdetailsModel
                                            .result?[0].isPaidNovel ==
                                        1) {
                                      if (showDetailsProvider
                                              .contentdetailsModel
                                              .result?[0]
                                              .isBuy ==
                                          1) {
                                        if ((showDetailsProvider
                                                    .contentdetailsModel
                                                    .result?[0]
                                                    .fullNovel ??
                                                "")
                                            .isNotEmpty) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PdfViewPage(
                                                        pdfLink: showDetailsProvider
                                                            .contentdetailsModel
                                                            .result?[0]
                                                            .fullNovel,
                                                        title: showDetailsProvider
                                                                .contentdetailsModel
                                                                .result?[0]
                                                                .title
                                                                .toString() ??
                                                            "",
                                                        contentID:
                                                            showDetailsProvider
                                                                .contentdetailsModel
                                                                .result?[0]
                                                                .id,
                                                        novelChapterID: 0,
                                                      )));
                                        }
                                      } else {
                                        openSubscriptionDialog(
                                            0,
                                            showDetailsProvider
                                                .contentdetailsModel
                                                .result?[0]
                                                .isBookCoin,
                                            showDetailsProvider
                                                .contentdetailsModel
                                                .result?[0]
                                                .title,
                                            0,
                                            showDetailsProvider
                                                .contentdetailsModel
                                                .result?[0]
                                                .id);
                                      }
                                    } else {
                                      if ((showDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .fullNovel ??
                                              "")
                                          .isNotEmpty) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewPage(
                                                      pdfLink: showDetailsProvider
                                                          .contentdetailsModel
                                                          .result?[0]
                                                          .fullNovel,
                                                      title: showDetailsProvider
                                                              .contentdetailsModel
                                                              .result?[0]
                                                              .title
                                                              .toString() ??
                                                          "",
                                                      contentID:
                                                          showDetailsProvider
                                                              .contentdetailsModel
                                                              .result?[0]
                                                              .id,
                                                      novelChapterID: 0,
                                                    )));
                                      }
                                    }
                                  } else {
                                    if (showDetailsProvider.novelchaptermodel
                                            .result?[0].isBookPaid ==
                                        1) {
                                      if (showDetailsProvider.novelchaptermodel
                                              .result?[0].isBuy ==
                                          1) {
                                        if ((showDetailsProvider
                                                    .novelchaptermodel
                                                    .result?[0]
                                                    .book ??
                                                "")
                                            .isNotEmpty) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PdfViewPage(
                                                        pdfLink:
                                                            showDetailsProvider
                                                                .novelchaptermodel
                                                                .result?[0]
                                                                .book,
                                                        title: showDetailsProvider
                                                                .novelchaptermodel
                                                                .result?[0]
                                                                .name
                                                                .toString() ??
                                                            "",
                                                        contentID:
                                                            showDetailsProvider
                                                                .novelchaptermodel
                                                                .result?[0]
                                                                .contentId,
                                                        novelChapterID:
                                                            showDetailsProvider
                                                                .novelchaptermodel
                                                                .result?[0]
                                                                .id,
                                                      )));
                                        }
                                      } else {
                                        openSubscriptionDialog(
                                            0,
                                            showDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .isBookCoin,
                                            showDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .name,
                                            showDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .id,
                                            showDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .contentId);
                                      }
                                    } else {
                                      if ((showDetailsProvider.novelchaptermodel
                                                  .result?[0].book ??
                                              "")
                                          .isNotEmpty) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewPage(
                                                      pdfLink:
                                                          showDetailsProvider
                                                              .novelchaptermodel
                                                              .result?[0]
                                                              .book,
                                                      title: showDetailsProvider
                                                              .novelchaptermodel
                                                              .result?[0]
                                                              .name
                                                              .toString() ??
                                                          "",
                                                      contentID:
                                                          showDetailsProvider
                                                              .novelchaptermodel
                                                              .result?[0]
                                                              .contentId,
                                                      novelChapterID:
                                                          showDetailsProvider
                                                              .novelchaptermodel
                                                              .result?[0]
                                                              .id,
                                                    )));
                                      }
                                    }
                                  }
                                } else {
                                  Utils.buildWebAlertDialog(
                                      context, "login", "");
                                }
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 0,
                                  maxHeight: 45,
                                  minWidth: 0,
                                  maxWidth: 160,
                                ),
                                padding: const EdgeInsets.all(10),
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
                                  text: "readnow",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 16,
                                  fontsizeWeb: 16,
                                  fontweight: FontWeight.w700,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 25,
                        left: 25,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: InkWell(
                            autofocus: true,
                            focusColor: gray.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              child: MyImage(
                                fit: BoxFit.fill,
                                imagePath: "backwith_bg.png",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    /* Details */
                    Container(
                      // height: Dimens.detailWebPoster,
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!kIsWeb)
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: InkWell(
                                autofocus: true,
                                focusColor: gray.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  child: MyImage(
                                    fit: BoxFit.contain,
                                    imagePath: "backwith_bg.png",
                                  ),
                                ),
                              ),
                            ),

                          /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                          Container(
                            width: MediaQuery.of(context).size.width,
                            constraints: const BoxConstraints(minHeight: 0),
                            padding: const EdgeInsets.fromLTRB(
                                0, kIsWeb ? 20 : 0, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                MyText(
                                  color: white,
                                  text: showDetailsProvider.contentdetailsModel
                                          .result?[0].title ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 20,
                                  fontsizeWeb: 24,
                                  fontweight: FontWeight.w800,
                                  maxline: 2,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 0),
                                  // child: _buildRentBtn(),
                                  child: _reviewAndPlay(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                /* Category */
                                if (showDetailsProvider.contentdetailsModel
                                            .result?[0].categoryName !=
                                        null &&
                                    showDetailsProvider.contentdetailsModel
                                            .result?[0].categoryName !=
                                        "")
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        MyText(
                                          color: whiteLight,
                                          text: "category",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w600,
                                          fontsizeWeb: 13,
                                          maxline: 1,
                                          multilanguage: true,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(width: 5),
                                        MyText(
                                          color: whiteLight,
                                          text: ":",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w600,
                                          fontsizeWeb: 13,
                                          maxline: 1,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: MyText(
                                            color: white,
                                            text: showDetailsProvider
                                                    .contentdetailsModel
                                                    .result?[0]
                                                    .categoryName ??
                                                "",
                                            textalign: TextAlign.start,
                                            fontsizeNormal: 13,
                                            fontsizeWeb: 13,
                                            fontweight: FontWeight.w600,
                                            multilanguage: false,
                                            maxline: 5,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                                /* Language */
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 0),
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        color: whiteLight,
                                        text: "language_",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 13,
                                        maxline: 1,
                                        multilanguage: true,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: whiteLight,
                                        text: ":",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 13,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: MyText(
                                          color: whiteLight,
                                          text: showDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .languageName
                                                  .toString() ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w600,
                                          fontsizeWeb: 13,
                                          multilanguage: false,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                /* Description */
                                ExpandableText(
                                  showDetailsProvider.contentdetailsModel
                                          .result?[0].description ??
                                      "",
                                  animation: true,
                                  textAlign: TextAlign.start,
                                  expandOnTextTap: true,
                                  collapseOnTextTap: true,
                                  expandText: "",
                                  maxLines: 10,
                                  linkColor: colorAccent,
                                  style: TextStyle(
                                    fontSize:
                                        (kIsWeb || Constant.isTV) ? 13 : 13,
                                    fontStyle: FontStyle.normal,
                                    color: white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /* Other Details */
              /* Related ~ More Details */
              Consumer<NovelSectionDataProvider>(
                builder: (context, showDetailsProvider, child) {
                  return _buildTabs();
                },
              ),
              const SizedBox(height: 20),

              /* Web Footer */
              (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Poster */
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  height: (kIsWeb || Constant.isTV)
                      ? Dimens.detailWebPoster
                      : Dimens.detailPoster,
                  child: Stack(children: [
                    MyNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: (showDetailsProvider.contentdetailsModel
                                      .result?[0].webBannerImg ??
                                  "")
                              .isEmpty
                          ? (showDetailsProvider
                                  .contentdetailsModel.result?[0].landscapeImg
                                  .toString() ??
                              "")
                          : (showDetailsProvider
                                  .contentdetailsModel.result?[0].webBannerImg
                                  .toString() ??
                              ""),
                    ),
                    Container(
                      height: Dimens.detailWebPoster,
                      width: MediaQuery.of(context).size.width,
                      color: black.withOpacity(0.65),
                    ),
                    Positioned.fill(
                      bottom: 60,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            if (Constant.userID != null) {
                              if ((showDetailsProvider.contentdetailsModel
                                          .result?[0].fullNovel ??
                                      "")
                                  .isNotEmpty) {
                                if (showDetailsProvider.contentdetailsModel
                                        .result?[0].isPaidNovel ==
                                    1) {
                                  if (showDetailsProvider.contentdetailsModel
                                          .result?[0].isBuy ==
                                      1) {
                                    if ((showDetailsProvider.contentdetailsModel
                                                .result?[0].fullNovel ??
                                            "")
                                        .isNotEmpty) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PdfViewPage(
                                                    pdfLink: showDetailsProvider
                                                        .contentdetailsModel
                                                        .result?[0]
                                                        .fullNovel,
                                                    title: showDetailsProvider
                                                            .contentdetailsModel
                                                            .result?[0]
                                                            .title
                                                            .toString() ??
                                                        "",
                                                    contentID:
                                                        showDetailsProvider
                                                            .contentdetailsModel
                                                            .result?[0]
                                                            .id,
                                                    novelChapterID: 0,
                                                  )));
                                    }
                                  } else {
                                    openSubscriptionDialog(
                                        0,
                                        showDetailsProvider.contentdetailsModel
                                            .result?[0].isBookCoin,
                                        showDetailsProvider.contentdetailsModel
                                            .result?[0].title,
                                        0,
                                        showDetailsProvider
                                            .contentdetailsModel.result?[0].id);
                                  }
                                } else {
                                  if ((showDetailsProvider.contentdetailsModel
                                              .result?[0].fullNovel ??
                                          "")
                                      .isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PdfViewPage(
                                                  pdfLink: showDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .fullNovel,
                                                  title: showDetailsProvider
                                                          .contentdetailsModel
                                                          .result?[0]
                                                          .title
                                                          .toString() ??
                                                      "",
                                                  contentID: showDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .id,
                                                  novelChapterID: 0,
                                                )));
                                  }
                                }
                              } else {
                                if (showDetailsProvider.novelchaptermodel
                                        .result?[0].isBookPaid ==
                                    1) {
                                  if (showDetailsProvider
                                          .novelchaptermodel.result?[0].isBuy ==
                                      1) {
                                    if ((showDetailsProvider.novelchaptermodel
                                                .result?[0].book ??
                                            "")
                                        .isNotEmpty) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PdfViewPage(
                                                    pdfLink: showDetailsProvider
                                                        .novelchaptermodel
                                                        .result?[0]
                                                        .book,
                                                    title: showDetailsProvider
                                                            .novelchaptermodel
                                                            .result?[0]
                                                            .name
                                                            .toString() ??
                                                        "",
                                                    contentID:
                                                        showDetailsProvider
                                                            .novelchaptermodel
                                                            .result?[0]
                                                            .contentId,
                                                    novelChapterID:
                                                        showDetailsProvider
                                                            .novelchaptermodel
                                                            .result?[0]
                                                            .id,
                                                  )));
                                    }
                                  } else {
                                    openSubscriptionDialog(
                                        0,
                                        showDetailsProvider.novelchaptermodel
                                            .result?[0].isBookCoin,
                                        showDetailsProvider
                                            .novelchaptermodel.result?[0].name,
                                        showDetailsProvider
                                            .novelchaptermodel.result?[0].id,
                                        showDetailsProvider.novelchaptermodel
                                            .result?[0].contentId);
                                  }
                                } else {
                                  if ((showDetailsProvider.novelchaptermodel
                                              .result?[0].book ??
                                          "")
                                      .isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PdfViewPage(
                                                  pdfLink: showDetailsProvider
                                                      .novelchaptermodel
                                                      .result?[0]
                                                      .book,
                                                  title: showDetailsProvider
                                                          .novelchaptermodel
                                                          .result?[0]
                                                          .name
                                                          .toString() ??
                                                      "",
                                                  contentID: showDetailsProvider
                                                      .novelchaptermodel
                                                      .result?[0]
                                                      .contentId,
                                                  novelChapterID:
                                                      showDetailsProvider
                                                          .novelchaptermodel
                                                          .result?[0]
                                                          .id,
                                                )));
                                  }
                                }
                              }
                            } else {
                              Utils.buildWebAlertDialog(context, "login", "");
                            }
                          },
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 0,
                              maxHeight: 45,
                              minWidth: 0,
                              maxWidth: 160,
                            ),
                            padding: const EdgeInsets.all(10),
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
                              text: "readnow",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontsizeWeb: 16,
                              fontweight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Positioned(
                  top: 25,
                  left: 25,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: InkWell(
                      autofocus: true,
                      focusColor: gray.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          fit: BoxFit.fill,
                          imagePath: "backwith_bg.png",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /* Other Details */
            Container(
              transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
              child: Column(
                children: [
                  /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(minHeight: 85),
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 65,
                          height: 85,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: MyNetworkImage(
                              fit: BoxFit.fill,
                              imgHeight: 85,
                              imgWidth: 65,
                              imageUrl: showDetailsProvider.contentdetailsModel
                                          .result?[0].portraitImg !=
                                      ""
                                  ? (showDetailsProvider.contentdetailsModel
                                          .result?[0].portraitImg ??
                                      "")
                                  : "",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              MyText(
                                color: white,
                                text: showDetailsProvider
                                        .contentdetailsModel.result?[0].title ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.start,
                                fontsizeNormal: 20,
                                fontsizeWeb: 24,
                                fontweight: FontWeight.w800,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(minWidth: 0),
                    // child: _buildRentBtn(),
                    child: _reviewAndPlay(),
                  ),
                  const SizedBox(height: 10),
                  /* Description, IMDb, Languages & Subtitles */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 0),
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: "category",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w500,
                                fontsizeWeb: 15,
                                maxline: 1,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color: white,
                                text: ":",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w500,
                                fontsizeWeb: 15,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: MyText(
                                  color: white,
                                  text: showDetailsProvider.contentdetailsModel
                                          .result?[0].categoryName ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  maxline: 5,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minHeight: 0),
                          margin: const EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: whiteLight,
                                text: "language_",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w600,
                                fontsizeWeb: 13,
                                maxline: 1,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color: whiteLight,
                                text: ":",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w600,
                                fontsizeWeb: 13,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: MyText(
                                  color: whiteLight,
                                  text: showDetailsProvider.contentdetailsModel
                                          .result?[0].languageName
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w600,
                                  fontsizeWeb: 13,
                                  multilanguage: false,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          constraints: const BoxConstraints(minHeight: 0),
                          alignment: Alignment.centerLeft,
                          child: ExpandableText(
                            showDetailsProvider.contentdetailsModel.result?[0]
                                    .description ??
                                "",
                            expandText: more,
                            collapseText: less_,
                            maxLines: 3,
                            linkColor: colorAccent,
                            expandOnTextTap: true,
                            collapseOnTextTap: true,
                            style: TextStyle(
                              fontSize: (kIsWeb || Constant.isTV) ? 13 : 14,
                              fontStyle: FontStyle.normal,
                              color: white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // /* Related ~ More Details */
                  Consumer<NovelSectionDataProvider>(
                    builder: (context, showDetailsProvider, child) {
                      return _buildTabs();
                    },
                  ),
                  const SizedBox(height: 20),

                  /* Web Footer */
                  (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: BoxConstraints(
              maxWidth: (kIsWeb || Constant.isTV)
                  ? (MediaQuery.of(context).size.width * 0.5)
                  : MediaQuery.of(context).size.width,
            ),
            height: (kIsWeb || Constant.isTV) ? 35 : Dimens.detailTabs,
            child: Row(
              children: [
                /* Related */
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await showDetailsProvider.setNovelTabClick("chapters");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: showDetailsProvider.tabNovelClickedOn !=
                                      "chapters"
                                  ? otherColor
                                  : primaryDark,
                              text: "chapters",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showDetailsProvider.tabNovelClickedOn ==
                              "chapters",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /* More Details */
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await showDetailsProvider.setNovelTabClick("details");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: showDetailsProvider.tabNovelClickedOn !=
                                      "details"
                                  ? otherColor
                                  : primaryDark,
                              text: "review",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showDetailsProvider.tabNovelClickedOn ==
                              "details",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /* Data */
          (showDetailsProvider.tabNovelClickedOn == "chapters")
              ? Container(
                  padding: ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720)
                      ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                      : const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      /* Episodes */
                      if (widget.videoType != 5)
                        (showDetailsProvider.novelchaptermodel.result != null &&
                                (showDetailsProvider.novelList?.length ?? 0) >
                                    0)
                            ? Column(
                                children: [
                                  Container(
                                    padding: ((kIsWeb || Constant.isTV) &&
                                            MediaQuery.of(context).size.width >
                                                720)
                                        ? const EdgeInsets.fromLTRB(
                                            20, 0, 20, 0)
                                        : const EdgeInsets.all(0),
                                    width: MediaQuery.of(context).size.width,
                                    constraints:
                                        const BoxConstraints(minHeight: 50),
                                    child: _buildUINovelOther(),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                height: 250,
                                child: NoData(title: 'nodata', subTitle: '')),
                    ],
                  ),
                )
              : MoreDetails(
                  type: 2,
                  contentid:
                      showDetailsProvider.contentdetailsModel.result?[0].id ??
                          0,
                  contentype: showDetailsProvider
                          .contentdetailsModel.result?[0].contentType ??
                      0,
                )
        ],
      ),
    );
  }

  Widget _buildUINovelOther() {
    return Consumer<NovelSectionDataProvider>(
        builder: (BuildContext context, episodeProvider, Widget? child) {
      return (episodeProvider.novelchaptermodel.status == 200 &&
              (episodeProvider.novelList?.length ?? 0) > 0)
          ? Column(
              children: [
                ResponsiveGridList(
                  minItemWidth: 60,
                  verticalGridSpacing: 8,
                  horizontalGridSpacing: 8,
                  minItemsPerRow: 1,
                  maxItemsPerRow:
                      (kIsWeb && MediaQuery.of(context).size.width > 720)
                          ? 2
                          : 1,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: List.generate(
                    (showDetailsProvider.novelList?.length ?? 0),
                    (index) {
                      return Container(
                        color: appBgColor,
                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                        constraints: const BoxConstraints(minHeight: 60),
                        child: InkWell(
                          onTap: () {
                            if (Constant.userID != null) {
                              if (showDetailsProvider
                                      .novelList?[index].isBookPaid ==
                                  1) {
                                if (showDetailsProvider
                                        .novelList?[index].isBuy ==
                                    1) {
                                  if ((showDetailsProvider
                                              .novelList?[index].book ??
                                          "")
                                      .isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PdfViewPage(
                                                  pdfLink: showDetailsProvider
                                                      .novelList?[index].book,
                                                  title: showDetailsProvider
                                                          .novelList?[index]
                                                          .name
                                                          .toString() ??
                                                      "",
                                                  contentID: showDetailsProvider
                                                      .novelList?[index]
                                                      .contentId,
                                                  novelChapterID:
                                                      showDetailsProvider
                                                          .novelList?[index].id,
                                                )));
                                  }
                                } else {
                                  openSubscriptionDialog(
                                      index,
                                      showDetailsProvider
                                          .novelList?[index].isBookCoin,
                                      showDetailsProvider
                                          .novelList?[index].name,
                                      showDetailsProvider.novelList?[index].id,
                                      showDetailsProvider
                                          .novelList?[index].contentId);
                                }
                              } else {
                                if ((showDetailsProvider.novelList?[0].book ??
                                        "")
                                    .isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PdfViewPage(
                                                pdfLink: showDetailsProvider
                                                    .novelList?[index].book,
                                                title: showDetailsProvider
                                                        .novelList?[index].name
                                                        .toString() ??
                                                    "",
                                                contentID: showDetailsProvider
                                                    .novelList?[index]
                                                    .contentId,
                                                novelChapterID:
                                                    showDetailsProvider
                                                        .novelList?[index].id,
                                              )));
                                }
                              }
                            } else {
                              Utils.buildWebAlertDialog(context, "login", "");
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyText(
                                color: white,
                                text: (index + 1).toString(),
                                multilanguage: false,
                                textalign: TextAlign.center,
                                fontsizeNormal: 15,
                                fontsizeWeb: 16,
                                maxline: 1,
                                fontweight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: MyNetworkImage(
                                        fit: BoxFit.fill,
                                        imgHeight: 50,
                                        imgWidth: 50,
                                        imageUrl: showDetailsProvider
                                                .novelList?[index].image
                                                .toString() ??
                                            "",
                                      ),
                                    ),
                                  ),
                                  (showDetailsProvider.novelList?[index]
                                                  .videoDuration !=
                                              null &&
                                          (showDetailsProvider.novelList?[index]
                                                      .stopTime ??
                                                  0) >
                                              0)
                                      ? Container(
                                          height: 2,
                                          width: 32,
                                          margin: const EdgeInsets.only(top: 8),
                                          child: LinearPercentIndicator(
                                            padding: const EdgeInsets.all(0),
                                            barRadius: const Radius.circular(2),
                                            lineHeight: 2,
                                            percent: Utils.getPercentage(
                                                showDetailsProvider
                                                        .novelList?[index]
                                                        .videoDuration ??
                                                    0,
                                                showDetailsProvider
                                                        .novelList?[index]
                                                        .stopTime ??
                                                    0),
                                            backgroundColor: secProgressColor,
                                            progressColor: colorPrimary,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    MyText(
                                      color: white,
                                      text: showDetailsProvider
                                              .novelList?[index].name ??
                                          "",
                                      textalign: TextAlign.start,
                                      fontstyle: FontStyle.normal,
                                      fontsizeNormal: 14,
                                      fontsizeWeb: 14,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontweight: FontWeight.w600,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 20,
                                            color: white,
                                          ),
                                        ),
                                        MyText(
                                          color: white,
                                          text: formatNumber(
                                            showDetailsProvider
                                                    .novelList?[index]
                                                    .totalBookPlayed ??
                                                0,
                                          ),
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 11,
                                          fontsizeWeb: 12,
                                          fontweight: FontWeight.w600,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          height: 4,
                                          width: 4,
                                          decoration: BoxDecoration(
                                              color: white,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: MyText(
                                            color: white,
                                            text: formatDate(showDetailsProvider
                                                    .novelList?[index].createdAt
                                                    .toString() ??
                                                ""),
                                            textalign: TextAlign.start,
                                            fontsizeNormal: 11,
                                            fontsizeWeb: 12,
                                            fontweight: FontWeight.w600,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              MyImage(
                                imagePath: (showDetailsProvider
                                                .novelList?[index].isBookPaid ??
                                            "") ==
                                        1
                                    ? (showDetailsProvider
                                                    .novelList?[index].isBuy ??
                                                "") ==
                                            1
                                        ? "download.png"
                                        : "ic_lock.png"
                                    : "download.png",
                                height: 14,
                                width: 14,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Consumer<NovelSectionDataProvider>(
                  builder: (context, showDetailsProvider, child) {
                    if (showDetailsProvider.loadmore) {
                      return Container(
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                        child: Utils.pageLoader(),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            )
          : const SizedBox(
              height: 250, child: NoData(title: 'nodata', subTitle: ''));
    });
  }

  Widget _reviewAndPlay() {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                  fontsizeWeb: 13,
                  fontsizeNormal: 13,
                  fontweight: FontWeight.w600,
                  color: white,
                  text: formatNumber(showDetailsProvider
                          .contentdetailsModel.result?[0].totalUserPlay ??
                      0)),
              const SizedBox(
                height: 5,
              ),
              MyText(
                  fontsizeWeb: 11,
                  fontsizeNormal: 11,
                  fontweight: FontWeight.w500,
                  color: edtBG,
                  text: "Play")
            ],
          ),
          const VerticalDivider(
            color: white,
            width: 50,
            thickness: 1,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(14)),
                    child: MyText(
                        fontsizeWeb: 15,
                        fontsizeNormal: 15,
                        fontweight: FontWeight.w600,
                        color: white,
                        text: showDetailsProvider
                                .contentdetailsModel.result?[0].avgRating
                                .toString() ??
                            "")),
              ),
              const SizedBox(
                height: 5,
              ),
              MyText(
                  fontsizeWeb: 11,
                  fontsizeNormal: 11,
                  fontweight: FontWeight.w500,
                  color: edtBG,
                  text:
                      "${formatNumber(showDetailsProvider.contentdetailsModel.result?[0].totalReviews ?? 0)} Reviews")
            ],
          ),
          const VerticalDivider(
            color: white,
            width: 50,
            thickness: 1,
          ),
          InkWell(
            focusColor: gray.withOpacity(0.5),
            onTap: () async {
              if (Constant.userID != null) {
                await showDetailsProvider.setBookMark(
                  context,
                  widget.videoType,
                  widget.videoId,
                );
              } else {
                if ((kIsWeb || Constant.isTV)) {
                  Utils.buildWebAlertDialog(context, "login", "");
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginSocial(
                        ishome: false,
                      );
                    },
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(5),
            child: Consumer<NovelSectionDataProvider>(
              builder: (context, showDetailsProvider, child) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                            width: 35,
                            height: 35,
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryDark,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              color: (showDetailsProvider.contentdetailsModel
                                              .result?[0].isBookMark ??
                                          0) ==
                                      0
                                  ? white
                                  : red,
                              Icons.favorite,
                              size: 25,
                            )),
                      ),
                      MyText(
                        color: white,
                        text: "favourite",
                        multilanguage: true,
                        fontsizeNormal: 10,
                        fontsizeWeb: 14,
                        fontweight: FontWeight.w500,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      )
                    ]);
              },
            ),
          ),
          const VerticalDivider(
            color: white,
            width: 50,
            thickness: 1,
          ),
          MyText(
              maxline: 3,
              fontsizeNormal: 15,
              fontweight: FontWeight.w600,
              color: white,
              fontsizeWeb: 15,
              text: showDetailsProvider
                      .contentdetailsModel.result?[0].languageName
                      .toString() ??
                  ""),
          const VerticalDivider(
            color: white,
            width: 50,
            thickness: 1,
          ),
          InkWell(
              onTap: () {
                // openReviewRatingDialog();
                _buildShareWithDialog();
              },
              child: MyImage(
                  imagePath: "ic_sharedetails.png", height: 32, width: 32))
        ],
      ),
    );
  }

  openReviewRatingDialog() {
    showGeneralDialog<void>(
      barrierColor: black.withOpacity(0.9),
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Dialog(
            insetPadding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            backgroundColor: white,
            alignment: Alignment.center,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Wrap(
              children: [
                _buildCommentDialog(),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {});
  }

  Widget _buildCommentDialog() {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            /* Close Button */
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: MyText(
                      fontsizeWeb: 17,
                      color: primaryDark,
                      text: "reviewandrating",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: 17,
                      maxline: 1,
                      fontweight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        debugPrint("Clicked on Close!");
                        commentController.clear();
                        ratingGiven = null;
                        // detailprovider.resetCommentData();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: black,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.2, decoration: Utils.setBackground(gray, 1)),

            // /* Add Rating */
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                    fontsizeWeb: 16,
                    color: primaryDark,
                    text: "give_ratings",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: 16,
                    maxline: 1,
                    fontweight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RatingBar(
                      initialRating: 0.0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: 30,
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                        full: const Icon(
                          Icons.star,
                          color: primaryDark,
                        ),
                        half: const Icon(
                          Icons.star_half,
                          color: primaryDark,
                        ),
                        empty: const Icon(
                          Icons.star_border,
                          color: gray,
                        ),
                      ),
                      onRatingUpdate: (double value) {
                        ratingGiven = value;
                        debugPrint("ratingGiven => $ratingGiven");
                      },
                    ),
                  ),
                ],
              ),
            ),

            /* Add Review */
            Container(
              height: 150,
              decoration: Utils.setBGWithBorder(
                  colorPrimary.withOpacity(0.2), gray.withOpacity(0.5), 8, 0.5),
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
              child: TextFormField(
                controller: commentController,
                scrollPhysics: const AlwaysScrollableScrollPhysics(),
                textAlign: TextAlign.start,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                onChanged: (value) async {},
                decoration: InputDecoration(
                  filled: true,
                  fillColor: transparentColor,
                  border: InputBorder.none,
                  hintText: "Add comments...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: gray,
                  ),
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                ),
                obscureText: false,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: colorPrimaryDark,
                ),
              ),
            ),

            /* Submit button */
            FittedBox(
              child: Container(
                height: 35,
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
                decoration: Utils.setBGWithBorder(colorAccent, gray, 5, 0.5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Constant.userID != null) {
                      debugPrint("Submit ratingGiven ===> $ratingGiven");
                      debugPrint(
                          "Submit comment =======> ${commentController.text}");
                      final commentprovider =
                          Provider.of<NovelSectionDataProvider>(context,
                              listen: false);

                      if (commentController.text.isNotEmpty &&
                          commentController.text != "") {
                        Utils.showProgress(context, prDialog);
                        await commentprovider.getAddReviews(
                            showDetailsProvider
                                .contentdetailsModel.result?[0].id,
                            commentController.text,
                            showDetailsProvider
                                .contentdetailsModel.result?[0].contentType,
                            ratingGiven ?? 0);
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        commentController.clear();
                        Navigator.pop(context);
                        setState(() {});
                      } else {
                        Utils.showToast("please_add_comment");
                      }
                    } else {
                      Utils.showToast(pleaselogin);
                      Utils.buildWebAlertDialog(context, "login", "")
                          .then((value) => _getData());
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Consumer<NovelSectionDataProvider>(
                      builder: (context, homeProvider, child) {
                        return MyText(
                          color: (commentController.text.toString().isEmpty)
                              ? white
                              : white,
                          text: "submit",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          maxline: 1,
                          fontsizeWeb: 14,
                          fontweight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /* Add Review - Reating END */

  openBottomSheet(int index, coins, episodeName, episodeID, contentID) {
    showModalBottomSheet(
        backgroundColor: black,
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                SizedBox(
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.3
                      : MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    child: MyImage(
                      fit: BoxFit.cover,
                      imagePath: 'coinsBanner.png',
                      height: 120,
                      width: kIsWeb
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Icon(
                      Icons.lock_open_rounded,
                      color: bottmsheetTextColor,
                      size: 40,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    MyText(
                      color: white,
                      text: episodeName.toString(),
                      textalign: TextAlign.start,
                      fontsizeNormal: 15,
                      fontsizeWeb: 14,
                      multilanguage: false,
                      fontweight: FontWeight.w600,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<SubscriptionProvider>(
                  builder: (context, subscriptionProvider, child) {
                    if (subscriptionProvider.loading) {
                      debugPrint("Shimmer Calling");
                      return Container();
                    } else {
                      if (subscriptionProvider.subscriptionModel.status ==
                              200 &&
                          subscriptionProvider.subscriptionModel.result !=
                              null) {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subscriptionProvider
                              .subscriptionModel.result?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () async {
                                /* Update Required data for payment */
                                if ((userName ?? "").isEmpty ||
                                    (userEmail ?? "").isEmpty ||
                                    (userMobileNo ?? "").isEmpty) {
                                  await updateDataDialog(
                                    isNameReq: (userName ?? "").isEmpty,
                                    isEmailReq: (userEmail ?? "").isEmpty,
                                    isMobileReq: (userMobileNo ?? "").isEmpty,
                                  );
                                  return;
                                } else {
                                  await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AllPayment(
                                          payType: 'Package',
                                          itemId: subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .id
                                                  .toString() ??
                                              '',
                                          price: subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .price
                                                  .toString() ??
                                              '',
                                          itemTitle: subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .name
                                                  .toString() ??
                                              '',
                                          coin: subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .coin
                                                  .toString() ??
                                              "",
                                          typeId: '',
                                          videoType: '',
                                          productPackage: (!kIsWeb)
                                              ? (Platform.isIOS
                                                  ? (subscriptionProvider
                                                          .subscriptionModel
                                                          .result?[index]
                                                          .iosProductPackage
                                                          .toString() ??
                                                      '')
                                                  : (subscriptionProvider
                                                          .subscriptionModel
                                                          .result?[index]
                                                          .androidProductPackage
                                                          .toString() ??
                                                      ''))
                                              : '',
                                          currency: '',
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 3,
                                color: subscriptionBG,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  color: black1,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                      left: 18, right: 18),
                                  constraints:
                                      const BoxConstraints(minHeight: 55),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .name ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 15,
                                          fontsizeWeb: 24,
                                          maxline: 1,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontweight: FontWeight.w600,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: white,
                                        text:
                                            "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 22,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontweight: FontWeight.w500,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: black1,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: bottmsheetTextColor,
                              text: "Need To Unlock",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyImage(
                                  imagePath: 'coin.png',
                                  height: 18,
                                  width: 18,
                                ),
                                MyText(
                                  color: white,
                                  text: "${coins.toString()} Coins",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 5,
                        thickness: 1,
                        indent: 15,
                        endIndent: 15,
                        color: white,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: bottmsheetTextColor,
                              text: "Current Balance",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyImage(
                                  imagePath: 'coin.png',
                                  height: 18,
                                  width: 18,
                                ),
                                MyText(
                                  color: white,
                                  text:
                                      "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if ((profileProvider
                                      .profileModel.result?[0].walletCoin ??
                                  0) >
                              coins) {
                            final episodebuyprovider =
                                Provider.of<NovelSectionDataProvider>(context,
                                    listen: false);
                            Utils.showProgress(context, prDialog);
                            await episodebuyprovider.getEpisodeBuy(
                                2, episodeID, 0, contentID, coins);
                            if (episodebuyprovider.episodeBuyModel.status ==
                                200) {
                              Utils.showToast("Succesfully Buy");
                              if (!context.mounted) return;
                              Utils().hideProgress(context);
                              setState(() {
                                showDetailsProvider.getNovelChapterdetails(
                                    widget.videoId,
                                    (showDetailsProvider.novelcurrentPage ??
                                            0) +
                                        1);
                                _getData();
                              });
                              Navigator.pop(context);
                            } else {
                              Utils.showToast("Something Went Wrong");
                              if (!context.mounted) return;
                              Utils().hideProgress(context);
                            }
                          } else {
                            Utils.showToast(
                                "Please Add The Coin In Your Account");
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: MyText(
                            color: white,
                            text: "buythisepisode",
                            textalign: TextAlign.start,
                            fontsizeNormal: 14,
                            fontsizeWeb: 14,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Subscription();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: MyText(
                            color: white,
                            text: "getmorecoin",
                            textalign: TextAlign.start,
                            fontsizeNormal: 15,
                            fontsizeWeb: 14,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  updateDataDialog({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      constraints: BoxConstraints(
          maxWidth: kIsWeb
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width),
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  _buildShareWithDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text: showDetailsProvider
                            .contentdetailsModel.result?[0].title ??
                        "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 18,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  const SizedBox(height: 12),

                  /* SMS */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      if (Platform.isAndroid) {
                        Utils.redirectToUrl(
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
                      }
                    },
                    child: _buildDialogItems(
                      icon: "ic_sms.png",
                      title: "sms",
                      isMultilang: true,
                    ),
                  ),

                  /* Instgram Stories */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                    },
                    child: _buildDialogItems(
                      icon: "ic_insta.png",
                      title: "instagram_stories",
                      isMultilang: true,
                    ),
                  ),

                  /* Copy Link */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      SocialShare.copyToClipboard(
                        text: Platform.isIOS
                            ? "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                            : "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                      ).then((data) {
                        debugPrint(data);
                        Utils.showSnackbar(
                            context, "success", "link_copied", true);
                      });
                    },
                    child: _buildDialogItems(
                      icon: "ic_link.png",
                      title: "copy_link",
                      isMultilang: true,
                    ),
                  ),

                  /* More */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                    },
                    child: _buildDialogItems(
                      icon: "ic_dots_h.png",
                      title: "more",
                      isMultilang: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogItems({
    required String icon,
    required String title,
    required bool isMultilang,
  }) {
    return Container(
      height: Dimens.minHtDialogContent,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyImage(
            width: Dimens.dialogIconSize,
            height: Dimens.dialogIconSize,
            imagePath: icon,
            fit: BoxFit.contain,
            color: otherColor,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: MyText(
              text: title,
              multilanguage: isMultilang,
              fontsizeNormal: 14,
              fontsizeWeb: 15,
              color: white,
              fontstyle: FontStyle.normal,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  openSubscriptionDialog(int index, coins, episodeName, episodeID, contentID) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: lightBlack,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        height: 30,
                        width: 30,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: white),
                        child: MyImage(
                          imagePath: "ic_close.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    child: MyImage(
                      fit: BoxFit.cover,
                      imagePath: 'coinsBanner.png',
                      height: 120,
                      width: kIsWeb
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width,
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const Icon(
                        Icons.lock_open_rounded,
                        color: bottmsheetTextColor,
                        size: 40,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      MyText(
                        color: white,
                        text: episodeName.toString(),
                        textalign: TextAlign.start,
                        fontsizeNormal: 15,
                        fontsizeWeb: 14,
                        multilanguage: false,
                        fontweight: FontWeight.w600,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer<SubscriptionProvider>(
                    builder: (context, subscriptionProvider, child) {
                      if (subscriptionProvider.loading) {
                        debugPrint("Shimmer Calling");
                        return Container();
                      } else {
                        if (subscriptionProvider.subscriptionModel.status ==
                                200 &&
                            subscriptionProvider.subscriptionModel.result !=
                                null) {
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subscriptionProvider
                                .subscriptionModel.result?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () async {
                                  /* Update Required data for payment */
                                  if ((userName ?? "").isEmpty ||
                                      (userEmail ?? "").isEmpty ||
                                      (userMobileNo ?? "").isEmpty) {
                                    await updateDataDialog(
                                      isNameReq: (userName ?? "").isEmpty,
                                      isEmailReq: (userEmail ?? "").isEmpty,
                                      isMobileReq: (userMobileNo ?? "").isEmpty,
                                    );
                                    return;
                                  } else {
                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AllPayment(
                                            payType: 'Package',
                                            itemId: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .id
                                                    .toString() ??
                                                '',
                                            price: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .price
                                                    .toString() ??
                                                '',
                                            itemTitle: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .name
                                                    .toString() ??
                                                '',
                                            coin: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .coin
                                                    .toString() ??
                                                "",
                                            typeId: '',
                                            videoType: '',
                                            productPackage: (!kIsWeb)
                                                ? (Platform.isIOS
                                                    ? (subscriptionProvider
                                                            .subscriptionModel
                                                            .result?[index]
                                                            .iosProductPackage
                                                            .toString() ??
                                                        '')
                                                    : (subscriptionProvider
                                                            .subscriptionModel
                                                            .result?[index]
                                                            .androidProductPackage
                                                            .toString() ??
                                                        ''))
                                                : '',
                                            currency: '',
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 3,
                                  color: subscriptionBG,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    color: black1,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        left: 18, right: 18),
                                    constraints:
                                        const BoxConstraints(minHeight: 55),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: MyText(
                                            color: white,
                                            text: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .name ??
                                                "",
                                            textalign: TextAlign.start,
                                            fontsizeNormal: 15,
                                            fontsizeWeb: 24,
                                            maxline: 1,
                                            multilanguage: false,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.w600,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        MyText(
                                          color: white,
                                          text:
                                              "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 14,
                                          fontsizeWeb: 22,
                                          maxline: 1,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontweight: FontWeight.w500,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: black1,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyText(
                                color: bottmsheetTextColor,
                                text: "Need To Unlock",
                                textalign: TextAlign.start,
                                fontsizeNormal: 15,
                                fontsizeWeb: 14,
                                multilanguage: false,
                                fontweight: FontWeight.w600,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MyImage(
                                    imagePath: 'coin.png',
                                    height: 18,
                                    width: 18,
                                  ),
                                  MyText(
                                    color: white,
                                    text: "${coins.toString()} Coins",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 15,
                                    fontsizeWeb: 14,
                                    multilanguage: false,
                                    fontweight: FontWeight.w600,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(
                          width: 5,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                          color: white,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyText(
                                color: bottmsheetTextColor,
                                text: "Current Balance",
                                textalign: TextAlign.start,
                                fontsizeNormal: 15,
                                fontsizeWeb: 14,
                                multilanguage: false,
                                fontweight: FontWeight.w600,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MyImage(
                                    imagePath: 'coin.png',
                                    height: 18,
                                    width: 18,
                                  ),
                                  MyText(
                                    color: white,
                                    text:
                                        "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 15,
                                    fontsizeWeb: 14,
                                    multilanguage: false,
                                    fontweight: FontWeight.w600,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if ((profileProvider
                                        .profileModel.result?[0].walletCoin ??
                                    0) >
                                coins) {
                              final episodebuyprovider =
                                  Provider.of<NovelSectionDataProvider>(context,
                                      listen: false);
                              Utils.showProgress(context, prDialog);
                              await episodebuyprovider.getEpisodeBuy(
                                  2, episodeID, 0, contentID, coins);
                              if (episodebuyprovider.episodeBuyModel.status ==
                                  200) {
                                Utils.showToast("Succesfully Buy");
                                if (!context.mounted) return;
                                Utils().hideProgress(context);
                                setState(() {
                                  _getData();
                                });
                                Navigator.pop(context);
                              } else {
                                Utils.showToast("Something Went Wrong");
                                if (!context.mounted) return;
                                Utils().hideProgress(context);
                              }
                            } else {
                              Utils.showToast(
                                  "Please Add The Coin In Your Account");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(10),
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: lightGreen,
                                borderRadius: BorderRadius.circular(10)),
                            child: MyText(
                              color: white,
                              text: "buythisepisode",
                              textalign: TextAlign.start,
                              fontsizeNormal: 14,
                              fontsizeWeb: 14,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Subscription();
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(10),
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: lightGreen,
                                borderRadius: BorderRadius.circular(10)),
                            child: MyText(
                              color: white,
                              text: "getmorecoin",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}

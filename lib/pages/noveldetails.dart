import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/main.dart';
import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/pages/pdfviewpage.dart';
import 'package:dtpocketfm/provider/novelsectiondataprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';

import 'package:dtpocketfm/utils/strings.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/moredetails.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class NovelDetails extends StatefulWidget {
  final int contentId, contentType;
  const NovelDetails(this.contentId, this.contentType, {super.key});

  @override
  State<NovelDetails> createState() => NovelDetailsState();
}

class NovelDetailsState extends State<NovelDetails> with RouteAware {
  /* Trailer init */
  VideoPlayerController? _trailerNormalController;
  YoutubePlayerController? _trailerYoutubeController;
  double? ratingGiven;
  final commentController = TextEditingController();
  /* Download init */
  // late bool _permissionReady;
  final ReceivePort _port = ReceivePort();
  late ProgressDialog prDialog;
  String? audioLanguages;
  // List<Cast>? directorList;
  late NovelSectionDataProvider novelDetailsProvider;
  late ScrollController _scrollController;
  late EpisodeProvider episodeProvider;
  late ProfileProvider profileProvider;
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    if (!kIsWeb) {
      /* Download init ****/
      // _bindBackgroundIsolate();
      // FlutterDownloader.registerCallback(downloadCallback, step: 1);
      /* ****/
    }
    prDialog = ProgressDialog(context);

    novelDetailsProvider =
        Provider.of<NovelSectionDataProvider>(context, listen: false);
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    novelDetailsProvider.setLoading(true);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    debugPrint("initState videoId ==> ${widget.contentId}");
    debugPrint("initState videoType ==> ${widget.contentType}");
    _getData();
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

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (novelDetailsProvider.tabNovelClickedOn == "chapters") {
        if ((novelDetailsProvider.novelcurrentPage ?? 0) <
            (novelDetailsProvider.noveltotalPage ?? 0)) {
          novelDetailsProvider.setLoadMore(true);
          _fetchData(
            novelDetailsProvider.novelcurrentPage ?? 0,
          );
        }
      } else {
        if ((novelDetailsProvider.reviewcurrentPage ?? 0) <
            (novelDetailsProvider.reviewtotalPage ?? 0)) {
          novelDetailsProvider.setLoadMore(true);
          await fetchComments((novelDetailsProvider.reviewcurrentPage ?? 0));
        }
      }
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await novelDetailsProvider.getNovelChapterdetails(
        widget.contentId, (nextPage ?? 0) + 1);
  }

  Future<void> fetchComments(int? nextPage) async {
    await novelDetailsProvider.getReviews(
        widget.contentId, widget.contentType, (nextPage ?? 0) + 1);
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    debugPrint("didPop");
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    debugPrint("didPopNext");

    super.didPopNext();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    debugPrint("didPush");
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    debugPrint("didPushNext");
    if (_trailerYoutubeController != null) {
      _trailerYoutubeController?.close();
      _trailerYoutubeController = null;
    }
    if (_trailerNormalController != null) {
      _trailerNormalController?.dispose();
      _trailerNormalController = null;
    }
    super.didPushNext();
  }

  Future<void> _getData() async {
    profileProvider.getProfile(context);

    await novelDetailsProvider.getContentDetails(
      widget.contentId,
      widget.contentType,
    );
    await _fetchData(0);
    await fetchComments(0);
    await _getUserData();
    await subscriptionProvider.getPackages();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
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

  Future<void> loadTrailer(trailerUrl, trailerType) async {
    debugPrint("loadTrailer URL ==========> $trailerUrl");
    debugPrint("loadTrailer Type =========> $trailerType");
    if (trailerType == "youtube") {
      var videoId = YoutubePlayerController.convertUrlToId(trailerUrl ?? "");
      debugPrint("Youtube Trailer videoId :====> $videoId");
      _trailerYoutubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId ?? '',
        autoPlay: true,
        startSeconds: 0,
        params: const YoutubePlayerParams(
          showControls: false,
          showVideoAnnotations: false,
          playsInline: true,
          mute: false,
          showFullscreenButton: false,
          loop: true,
        ),
      );
      _trailerYoutubeController?.playVideo();
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    } else {
      _trailerNormalController =
          VideoPlayerController.networkUrl(Uri.parse(trailerUrl ?? ""))
            ..initialize().then((value) {
              if (!mounted) return;
              setState(() {
                debugPrint(
                    "isPlaying =========> ${_trailerNormalController?.value.isPlaying}");
                _trailerNormalController?.play();
              });
            });
      _trailerNormalController?.setLooping(true);
      _trailerNormalController?.addListener(() async {
        if (_trailerNormalController?.value.hasError ?? false) {
          debugPrint(
              "VideoScreen errorDescription ====> ${_trailerNormalController?.value.errorDescription}");
        }
      });
    }
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    debugPrint(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    if (!kIsWeb) {
      IsolateNameServer.lookupPortByName(Constant.showDownloadPort)
          ?.send([id, status, progress]);
    }
  }

  @override
  void dispose() {
    debugPrint(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");
    if (!_port.isBroadcast) {
      novelDetailsProvider.clearProvider();
      episodeProvider.clearProvider();
    }
    routeObserver.unsubscribe(this);
    debugPrint(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");
    if (_trailerYoutubeController != null) {
      _trailerYoutubeController?.close();
      _trailerYoutubeController = null;
    }
    if (_trailerNormalController != null) {
      _trailerNormalController?.dispose();
      _trailerNormalController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        key: widget.key,
        // backgroundColor: appBgColor,
        body: SafeArea(
          child: _buildUIWithAppBar(),
        ),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget _buildUIWithAppBar() {
    return (novelDetailsProvider.loading)
        ? SingleChildScrollView(
            child: ((kIsWeb || Constant.isTV) &&
                    MediaQuery.of(context).size.width > 720)
                ? ShimmerUtils.buildDetailWebShimmer(context, "show")
                : ShimmerUtils.buildDetailMobileShimmer(context, "show"),
          )
        : (novelDetailsProvider.contentdetailsModel.status == 200 &&
                novelDetailsProvider.contentdetailsModel.result != null)
            ? _buildMobileData()
            : const NoData(title: 'nodata', subTitle: '');
  }

  Widget _buildMobileData() {
    return Container(
        width: MediaQuery.of(context).size.width,
        constraints: const BoxConstraints.expand(),
        child: RefreshIndicator(
            backgroundColor: white,
            color: complimentryColor,
            displacement: 80,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 1500))
                  .then((value) {
                novelDetailsProvider.setLoading(true);
                Future.delayed(Duration.zero).then((value) {
                  if (!mounted) return;
                  setState(() {});
                });
                _getData();
              });
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      authorProfileBg.withOpacity(0.8),
                      authorProfileBg.withOpacity(0.99),
                      appBgColor.withOpacity(0.9),
                      appBgColor
                    ])),
                child: Column(children: [
                  _buildMobilePoster(),

                  /* Other Details */
                  SizedBox(
                    child: Column(
                      children: [
                        /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                        Container(
                          width: MediaQuery.of(context).size.width,
                          constraints: const BoxConstraints(minHeight: 45),
                          margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: novelDetailsProvider
                                        .contentdetailsModel.result?[0].title ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.start,
                                fontsizeNormal: 18,
                                fontsizeWeb: 24,
                                fontweight: FontWeight.w600,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 20),

                              /* review and play, Total Views  */
                              _reviewAndPlay(),
                              const SizedBox(height: 20),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                width: MediaQuery.of(context).size.width,
                                constraints: const BoxConstraints(minHeight: 0),
                                alignment: Alignment.centerLeft,
                                child: ExpandableText(
                                  animation: true,
                                  novelDetailsProvider.contentdetailsModel
                                          .result?[0].description ??
                                      "",
                                  expandText: more,
                                  collapseText: less_,
                                  maxLines: (kIsWeb || Constant.isTV) ? 50 : 3,
                                  linkColor: primaryDark,
                                  expandOnTextTap: true,
                                  collapseOnTextTap: true,
                                  style: TextStyle(
                                    fontSize:
                                        (kIsWeb || Constant.isTV) ? 13 : 12,
                                    fontStyle: FontStyle.normal,
                                    color: white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _author(),

                              /* AdMob Banner */
                              Utils.showBannerAd(context),
                              const SizedBox(height: 10),
                              // /* Related ~ More Details */
                              Consumer<NovelSectionDataProvider>(
                                builder: (context, showDetailsProvider, child) {
                                  return _buildTabs();
                                },
                              ),
                              const SizedBox(height: 20),

                              /* Web Footer */
                              (kIsWeb)
                                  ? const FooterWeb()
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            )));
  }

  Widget _author() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AuthorProfile(
                  artistID: novelDetailsProvider
                          .contentdetailsModel.result?[0].artistId
                          .toString() ??
                      "",
                );
              },
            ),
          );
        },
        child: Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: MyNetworkImage(
                imageUrl: novelDetailsProvider
                        .contentdetailsModel.result?[0].artistImage
                        .toString() ??
                    "",
                imgHeight: 40,
                imgWidth: 40,
                fit: BoxFit.fill,
              )),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  color: white,
                  text: novelDetailsProvider
                          .contentdetailsModel.result?[0].artistName
                          .toString() ??
                      "",
                  textalign: TextAlign.center,
                  multilanguage: false,
                  fontweight: FontWeight.w500,
                  fontsizeNormal: 14,
                  fontsizeWeb: 16,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
                const SizedBox(height: 5),
                MyText(
                  color: white,
                  text:
                      "${novelDetailsProvider.contentdetailsModel.result?[0].artistFollowers.toString() ?? ""} Followers",
                  textalign: TextAlign.center,
                  multilanguage: false,
                  fontweight: FontWeight.w400,
                  fontsizeNormal: 12,
                  fontsizeWeb: 16,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMobilePoster() {
    return Stack(
      alignment: Alignment.center,
      children: [
        /* Poster & Trailer player */
        Container(
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: (kIsWeb || Constant.isTV)
              ? Dimens.detailWebPoster
              : MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyNetworkImage(
                imgHeight: 275,
                imgWidth: 194,
                fit: BoxFit.fill,
                imageUrl: novelDetailsProvider
                            .contentdetailsModel.result?[0].landscapeImg !=
                        ""
                    ? (novelDetailsProvider
                            .contentdetailsModel.result?[0].landscapeImg ??
                        "")
                    : (novelDetailsProvider
                            .contentdetailsModel.result?[0].portraitImg ??
                        ""),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (Constant.userID != null) {
                        if ((novelDetailsProvider
                                    .contentdetailsModel.result?[0].fullNovel ??
                                "")
                            .isNotEmpty) {
                          if (novelDetailsProvider
                                  .contentdetailsModel.result?[0].isPaidNovel ==
                              1) {
                            if (novelDetailsProvider
                                    .contentdetailsModel.result?[0].isBuy ==
                                1) {
                              if ((novelDetailsProvider.contentdetailsModel
                                          .result?[0].fullNovel ??
                                      "")
                                  .isNotEmpty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfViewPage(
                                              pdfLink: novelDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .fullNovel,
                                              title: novelDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .title
                                                      .toString() ??
                                                  "",
                                              contentID: novelDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .id,
                                              novelChapterID: 0,
                                            )));
                              }
                            } else {
                              openBottomSheet(
                                  0,
                                  novelDetailsProvider.contentdetailsModel
                                      .result?[0].isBookCoin,
                                  novelDetailsProvider
                                      .contentdetailsModel.result?[0].title,
                                  0,
                                  novelDetailsProvider
                                      .contentdetailsModel.result?[0].id);
                            }
                          } else {
                            if ((novelDetailsProvider.contentdetailsModel
                                        .result?[0].fullNovel ??
                                    "")
                                .isNotEmpty) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PdfViewPage(
                                            pdfLink: novelDetailsProvider
                                                .contentdetailsModel
                                                .result?[0]
                                                .fullNovel,
                                            title: novelDetailsProvider
                                                    .contentdetailsModel
                                                    .result?[0]
                                                    .title
                                                    .toString() ??
                                                "",
                                            contentID: novelDetailsProvider
                                                .contentdetailsModel
                                                .result?[0]
                                                .id,
                                            novelChapterID: 0,
                                          )));
                            }
                          }
                        } else {
                          if (novelDetailsProvider
                                  .novelchaptermodel.result?[0].isBookPaid ==
                              1) {
                            if (novelDetailsProvider
                                    .novelchaptermodel.result?[0].isBuy ==
                                1) {
                              if ((novelDetailsProvider
                                          .novelchaptermodel.result?[0].book ??
                                      "")
                                  .isNotEmpty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfViewPage(
                                              pdfLink: novelDetailsProvider
                                                  .novelchaptermodel
                                                  .result?[0]
                                                  .book,
                                              title: novelDetailsProvider
                                                      .novelchaptermodel
                                                      .result?[0]
                                                      .name
                                                      .toString() ??
                                                  "",
                                              contentID: novelDetailsProvider
                                                  .novelchaptermodel
                                                  .result?[0]
                                                  .contentId,
                                              novelChapterID:
                                                  novelDetailsProvider
                                                      .novelchaptermodel
                                                      .result?[0]
                                                      .id,
                                            )));
                              }
                            } else {
                              openBottomSheet(
                                  0,
                                  novelDetailsProvider
                                      .novelchaptermodel.result?[0].isBookCoin,
                                  novelDetailsProvider
                                      .novelchaptermodel.result?[0].name,
                                  novelDetailsProvider
                                      .novelchaptermodel.result?[0].id,
                                  novelDetailsProvider
                                      .novelchaptermodel.result?[0].contentId);
                            }
                          } else {
                            if ((novelDetailsProvider
                                        .novelchaptermodel.result?[0].book ??
                                    "")
                                .isNotEmpty) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PdfViewPage(
                                            pdfLink: novelDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .book,
                                            title: novelDetailsProvider
                                                    .novelchaptermodel
                                                    .result?[0]
                                                    .name
                                                    .toString() ??
                                                "",
                                            contentID: novelDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .contentId,
                                            novelChapterID: novelDetailsProvider
                                                .novelchaptermodel
                                                .result?[0]
                                                .id,
                                          )));
                            }
                          }
                        }
                      } else {
                        Utils.openLogin(
                            context: context, isHome: false, isReplace: false);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 0,
                        maxHeight: 45,
                        minWidth: 0,
                        // maxWidth: 120,
                      ),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(5),
                        shape: BoxShape.rectangle,
                      ),
                      child: Row(
                        children: [
                          MyImage(
                            imagePath: 'book.png',
                            height: 15,
                            width: 19,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          MyText(
                            color: white,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            multilanguage: true,
                            text: "readnow",
                            textalign: TextAlign.center,
                            fontsizeNormal: 16,
                            fontsizeWeb: 18,
                            fontweight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 0,
                      maxHeight: 45,
                      minWidth: 0,
                      // maxWidth: 120,
                    ),
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(5),
                      shape: BoxShape.rectangle,
                    ),
                    child: Row(
                      children: [
                        MyImage(
                          color: primaryDark,
                          imagePath: 'ic_info.png',
                          height: 15,
                          width: 19,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        MyText(
                          color: primaryDark,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          multilanguage: true,
                          text: "library",
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          fontsizeWeb: 18,
                          fontweight: FontWeight.w600,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        if (!kIsWeb)
          Positioned(
            top: 15,
            left: 15,
            child: Utils.buildBackBtn(context),
          ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
                      await novelDetailsProvider.setNovelTabClick("chapters");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: novelDetailsProvider.tabNovelClickedOn !=
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
                          visible: novelDetailsProvider.tabNovelClickedOn ==
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
                      await novelDetailsProvider.setNovelTabClick("details");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: novelDetailsProvider.tabNovelClickedOn !=
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
                          visible: novelDetailsProvider.tabNovelClickedOn ==
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
          (novelDetailsProvider.tabNovelClickedOn == "chapters")
              ? Container(
                  padding: ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720)
                      ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                      : const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      /* Episodes */
                      if (widget.contentType != 5)
                        (novelDetailsProvider.novelchaptermodel.result !=
                                    null &&
                                (novelDetailsProvider.novelList?.length ?? 0) >
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
                      novelDetailsProvider.contentdetailsModel.result?[0].id ??
                          0,
                  contentype: novelDetailsProvider
                          .contentdetailsModel.result?[0].contentType ??
                      0,
                )
        ],
      ),
    );
  }

  double getDynamicHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      return Dimens.heightLangGen;
    } else {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

  /* ========= Dialogs ========= */
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
                    text: novelDetailsProvider
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
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
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
                          ? "Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
                            ? "Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                            : "Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
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
                          ? "Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${novelDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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

  Widget _reviewAndPlay() {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyText(
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w600,
                    color: white,
                    text: formatNumber(novelDetailsProvider
                            .contentdetailsModel.result?[0].totalUserPlay ??
                        0)),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                    fontsizeNormal: 11,
                    fontweight: FontWeight.w500,
                    color: white.withOpacity(0.7),
                    text: "Play")
              ],
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(14)),
                      child: MyText(
                          fontsizeNormal: 15,
                          fontweight: FontWeight.w600,
                          color: white,
                          text: novelDetailsProvider
                                  .contentdetailsModel.result?[0].avgRating
                                  .toString() ??
                              "")),
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                    fontsizeNormal: 10,
                    maxline: 1,
                    fontweight: FontWeight.w500,
                    color: white.withOpacity(0.7),
                    text:
                        "${formatNumber(novelDetailsProvider.contentdetailsModel.result?[0].totalReviews ?? 0)} Reviews")
              ],
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          Flexible(
            child: InkWell(
              focusColor: gray.withOpacity(0.5),
              onTap: () async {
                debugPrint(
                    "isBookmark ====> ${novelDetailsProvider.contentdetailsModel.result?[0].isBookMark ?? 0}");
                AdHelper.showFullscreenAd(
                  context,
                  Constant.rewardAdType,
                  () async {
                    if (Constant.userID != null) {
                      await novelDetailsProvider.setBookMark(
                        context,
                        widget.contentType,
                        widget.contentId,
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
                );
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
                          ),
                        ),
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
                    ],
                  );
                },
              ),
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          Flexible(
            child: InkWell(
              onTap: () {
                // openReviewRatingDialog();
                _buildShareWithDialog();
              },
              child: MyImage(
                imagePath: "ic_sharedetails.png",
                height: 32,
                width: 32,
              ),
            ),
          )
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

            /* Add Rating */
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
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
                onChanged: (value) async {
                  // await detailprovider.notifyProvider();
                },
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
                            novelDetailsProvider
                                .contentdetailsModel.result?[0].id,
                            commentController.text,
                            novelDetailsProvider
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
                      Utils.openLogin(
                          context: context, isHome: false, isReplace: false);
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
                    (novelDetailsProvider.novelList?.length ?? 0),
                    (index) {
                      return Container(
                        color: appBgColor,
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        constraints: const BoxConstraints(minHeight: 60),
                        child: InkWell(
                          onTap: () {
                            if (Constant.userID != null) {
                              if (novelDetailsProvider
                                      .novelList?[index].isBookPaid ==
                                  1) {
                                if (novelDetailsProvider
                                        .novelList?[index].isBuy ==
                                    1) {
                                  if ((novelDetailsProvider
                                              .novelList?[index].book ??
                                          "")
                                      .isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PdfViewPage(
                                                  pdfLink: novelDetailsProvider
                                                      .novelList?[index].book,
                                                  title: novelDetailsProvider
                                                          .novelList?[index]
                                                          .name
                                                          .toString() ??
                                                      "",
                                                  contentID:
                                                      novelDetailsProvider
                                                          .novelList?[index]
                                                          .contentId,
                                                  novelChapterID:
                                                      novelDetailsProvider
                                                          .novelList?[index].id,
                                                ))).then((value) => _getData());
                                  }
                                } else {
                                  openBottomSheet(
                                      index,
                                      novelDetailsProvider
                                          .novelList?[index].isBookCoin,
                                      novelDetailsProvider
                                          .novelList?[index].name,
                                      novelDetailsProvider.novelList?[index].id,
                                      novelDetailsProvider
                                          .novelList?[index].contentId);
                                }
                              } else {
                                if ((novelDetailsProvider.novelList?[0].book ??
                                        "")
                                    .isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PdfViewPage(
                                                pdfLink: novelDetailsProvider
                                                    .novelList?[index].book,
                                                title: novelDetailsProvider
                                                        .novelList?[index].name
                                                        .toString() ??
                                                    "",
                                                contentID: novelDetailsProvider
                                                    .novelList?[index]
                                                    .contentId,
                                                novelChapterID:
                                                    novelDetailsProvider
                                                        .novelList?[index].id,
                                              )));
                                }
                              }
                            } else {
                              Utils.openLogin(
                                  context: context,
                                  isHome: false,
                                  isReplace: false);
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
                                        imageUrl: novelDetailsProvider
                                                .novelList?[index].image
                                                .toString() ??
                                            "",
                                      ),
                                    ),
                                  ),
                                  (novelDetailsProvider.novelList?[index]
                                                  .videoDuration !=
                                              null &&
                                          (novelDetailsProvider
                                                      .novelList?[index]
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
                                                novelDetailsProvider
                                                        .novelList?[index]
                                                        .videoDuration ??
                                                    0,
                                                novelDetailsProvider
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
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    MyText(
                                      color: white,
                                      text: novelDetailsProvider
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
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
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
                                            novelDetailsProvider
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
                                          width: 5,
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
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: MyText(
                                            color: white,
                                            text: formatDate(
                                                novelDetailsProvider
                                                        .novelList?[index]
                                                        .createdAt
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
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              MyText(
                                text: (novelDetailsProvider
                                                .novelList?[index].isBookPaid ??
                                            "") ==
                                        1
                                    ? (novelDetailsProvider
                                                    .novelList?[index].isBuy ??
                                                "") ==
                                            1
                                        ? ""
                                        : "${novelDetailsProvider.novelList?[index].isBookCoin} Coins"
                                    : "",
                                fontsizeNormal: 13,
                                color: white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyImage(
                                  imagePath: (novelDetailsProvider
                                                  .novelList?[index]
                                                  .isBookPaid ??
                                              "") ==
                                          1
                                      ? (novelDetailsProvider.novelList?[index]
                                                      .isBuy ??
                                                  "") ==
                                              1
                                          ? "play.png"
                                          : "ic_lock.png"
                                      : "play.png",
                                  height: 22,
                                  width: 22,
                                ),
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                  child: MyImage(
                    fit: BoxFit.cover,
                    imagePath: 'coinsBanner.png',
                    height: 120,
                    width: MediaQuery.of(context).size.width,
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
}

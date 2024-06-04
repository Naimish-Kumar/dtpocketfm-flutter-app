import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/main.dart';
import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/widget/videoepisodebycontent.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/moredetails.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/widget/episodebyseason.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
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
import 'package:social_share/social_share.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../model/episodebycontentmodel.dart';

class AudioBookDetails extends StatefulWidget {
  final int contentId, contentType;
  const AudioBookDetails(this.contentId, this.contentType, {super.key});

  @override
  State<AudioBookDetails> createState() => AudioBookDetailsState();
}

class AudioBookDetailsState extends State<AudioBookDetails> with RouteAware {
  VideoPlayerController? _trailerNormalController;
  YoutubePlayerController? _trailerYoutubeController;
  late ProgressDialog prDialog;

  final ReceivePort _port = ReceivePort();

  String? audioLanguages;
  late ShowDetailsProvider audioDetailsProvider;
  late EpisodeProvider episodeProvider;
  double? ratingGiven;
  final commentController = TextEditingController();
  late ProfileProvider profileProvider;
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  late ScrollController _scrollController;
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

    audioDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    audioDetailsProvider.setLoading(true);
    _getData();
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      debugPrint("AudioData Scroll Listner");
      if (audioDetailsProvider.tabClickedOn == "episodes") {
        if ((episodeProvider.audiocurrentPage ?? 0) <
            (episodeProvider.audiototalPage ?? 0)) {
          episodeProvider.setLoadMore(true);
          await _fetchDataAudio((episodeProvider.audiocurrentPage ?? 0));
        }
      } else if (audioDetailsProvider.tabClickedOn == "details") {
        if ((audioDetailsProvider.currentPage ?? 0) <
            (audioDetailsProvider.totalPage ?? 0)) {
          audioDetailsProvider.setLoadMore(true);
          await fetchComments((audioDetailsProvider.currentPage ?? 0));
        }
      } else {
        if ((episodeProvider.currentPage ?? 0) <
            (episodeProvider.totalPage ?? 0)) {
          await episodeProvider.videosetLoadMore(true);
          await _fetchDataVideo((episodeProvider.currentPage ?? 0));
        }
      }
    }
  }

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');
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

  Future<void> fetchComments(int? nextPage) async {
    await audioDetailsProvider.getReviews(
        widget.contentId, widget.contentType, (nextPage ?? 0) + 1);
  }

  Future<void> _fetchDataVideo(int? nextPage) async {
    await episodeProvider.getVideoByContent(
        widget.contentId, (nextPage ?? 0) + 1);
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    debugPrint("didPop");
    super.didPop();
  }

  @override
  void didPopNext() {}

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  @override
  void didPush() {
    debugPrint("didPush");
    super.didPush();
  }

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
    await audioDetailsProvider.getContentDetails(
      widget.contentId,
      widget.contentType,
    );

    await _fetchDataAudio(0);
    await _fetchDataVideo(0);
    await fetchComments(0);
    await subscriptionProvider.getPackages();
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {
        debugPrint(
            "setState videoId ======================> ${widget.contentId}");
      });
    });
  } /* Section Data Api */

  Future<void> _fetchDataAudio(int? nextPage) async {
    await episodeProvider.getAudioByContent(
        widget.contentId, (nextPage ?? 0) + 1);
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
    episodeProvider.clearProvider();
    debugPrint(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");

    routeObserver.unsubscribe(this);
    debugPrint(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");

    audioDetailsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        key: widget.key,
        backgroundColor: appBgColor,
        body: _buildUIWithAppBar(),
      ),
      Utils.buildMusicPanel(context),
    ]);
  }

  Widget _buildUIWithAppBar() {
    return (audioDetailsProvider.detailsLoading)
        ? ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
            ? SingleChildScrollView(
                child: ShimmerUtils.buildDetailWebShimmer(context, "show"))
            : SingleChildScrollView(
                child: ShimmerUtils.buildDetailMobileShimmer(context, "show"))
        : (audioDetailsProvider.contentdetailsModel.status == 200 &&
                audioDetailsProvider.contentdetailsModel.result != null)
            ? (((kIsWeb || Constant.isTV) &&
                    MediaQuery.of(context).size.width > 720)
                ? _buildWebData()
                : _buildMobileData())
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
            audioDetailsProvider.setLoading(true);
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
          child: Column(
            children: [
              /* Poster */
              // ((showDetailsProvider.contentdetailsModel.result?[0].trailerUrl ?? "")
              //         .isNotEmpty)
              //     ? setUpTrailerView()
              // :
              _buildMobilePoster(),

              /* Other Details */
              Column(
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
                          text: audioDetailsProvider
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
                        const SizedBox(height: 10),
                        MyText(
                            maxline: 3,
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w500,
                            color: white,
                            text: audioDetailsProvider
                                    .contentdetailsModel.result?[0].languageName
                                    .toString() ??
                                ""),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  /* review and play, Total Views  */
                  _reviewAndPlay(), const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(minHeight: 0),
                    alignment: Alignment.centerLeft,
                    child: ExpandableText(
                      animation: true,
                      audioDetailsProvider
                              .contentdetailsModel.result?[0].description ??
                          "",
                      expandText: more,
                      collapseText: less_,
                      maxLines: (kIsWeb || Constant.isTV) ? 50 : 3,
                      linkColor: primaryDark,
                      expandOnTextTap: true,
                      collapseOnTextTap: true,
                      style: TextStyle(
                        fontSize: (kIsWeb || Constant.isTV) ? 13 : 12,
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
                  Consumer<ShowDetailsProvider>(
                    builder: (context, showDetailsProvider, child) {
                      return _buildTabs();
                    },
                  ),
                  const SizedBox(height: 20),

                  /* Web Footer */
                  (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _author() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AuthorProfile(
                        artistID: audioDetailsProvider
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
                      imageUrl: audioDetailsProvider
                              .contentdetailsModel.result?[0].artistImage
                              .toString() ??
                          "",
                      imgHeight: 40,
                      imgWidth: 40,
                      fit: BoxFit.fill,
                    )),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text: audioDetailsProvider
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
                          "${audioDetailsProvider.contentdetailsModel.result?[0].artistFollowers.toString() ?? ""} Followers",
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
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Poster */
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  /* Poster */
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width *
                        (Dimens.webBannerImgPr),
                    height: Dimens.detailWebPoster,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.detailWebPoster,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                appBgColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                appBgColor,
                              ],
                            ),
                          ),
                        ),
                        MyNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: audioDetailsProvider.contentdetailsModel
                                      .result?[0].landscapeImg !=
                                  ""
                              ? (audioDetailsProvider.contentdetailsModel
                                      .result?[0].landscapeImg ??
                                  "")
                              : (audioDetailsProvider.contentdetailsModel
                                      .result?[0].portraitImg ??
                                  ""),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.detailWebPoster,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                appBgColor,
                                transparentColor,
                                transparentColor,
                                appBgColor,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /* Gradient */
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.detailWebPoster,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          appBgColor,
                          appBgColor,
                          appBgColor,
                          appBgColor,
                          transparentColor,
                          transparentColor,
                          transparentColor,
                          transparentColor,
                        ],
                      ),
                    ),
                  ),

                  /* Details */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.detailWebPoster + 30,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 0),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  MyText(
                                    color: white,
                                    text: audioDetailsProvider
                                            .contentdetailsModel
                                            .result?[0]
                                            .title ??
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
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      /* Category */
                                      (audioDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .categoryName !=
                                                  null &&
                                              audioDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .categoryName !=
                                                  "")
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              child: MyText(
                                                color: whiteLight,
                                                text: audioDetailsProvider
                                                        .contentdetailsModel
                                                        .result?[0]
                                                        .categoryName ??
                                                    "",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontsizeWeb: 13,
                                                fontweight: FontWeight.w600,
                                                multilanguage: false,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            )
                                          : const SizedBox.shrink(),

                                      /* IMDb */
                                      MyImage(
                                        width: 40,
                                        height: 15,
                                        imagePath: "imdb.png",
                                      ),
                                      MyText(
                                        color: otherColor,
                                        text:
                                            "${audioDetailsProvider.contentdetailsModel.result?[0].avgRating ?? 0}",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 14,
                                        fontweight: FontWeight.w600,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      /* IMDb */
                                    ],
                                  ),

                                  /* Language */
                                  const SizedBox(height: 5),
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          color: whiteLight,
                                          text: "language_",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w500,
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
                                            text: audioLanguages ?? "",
                                            textalign: TextAlign.start,
                                            fontsizeNormal: 13,
                                            fontweight: FontWeight.w500,
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

                                  /* Subtitle */
                                  Consumer<EpisodeProvider>(
                                    builder: (context, episodeProvider, child) {
                                      if (Constant.subtitleUrls.isNotEmpty) {
                                        return Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 0),
                                          margin: const EdgeInsets.only(top: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                color: whiteLight,
                                                text: "subtitle",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontweight: FontWeight.w500,
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
                                                  text: "Available",
                                                  textalign: TextAlign.start,
                                                  fontsizeNormal: 13,
                                                  fontweight: FontWeight.w500,
                                                  fontsizeWeb: 13,
                                                  maxline: 1,
                                                  multilanguage: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),

                                  /* Prime TAG */
                                  Consumer<ShowDetailsProvider>(
                                    builder:
                                        (context, showDetailsProvider, child) {
                                      if ((episodeProvider
                                                  .episodeBySeasonModel
                                                  .result?[showDetailsProvider
                                                      .mCurrentEpiPos]
                                                  .isPremium ??
                                              0) ==
                                          1) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              MyText(
                                                color: colorPrimary,
                                                text: "primetag",
                                                textalign: TextAlign.start,
                                                fontsizeNormal: 12,
                                                fontsizeWeb: 12,
                                                fontweight: FontWeight.w700,
                                                multilanguage: true,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                              const SizedBox(height: 2),
                                              MyText(
                                                color: white,
                                                text: "primetagdesc",
                                                multilanguage: true,
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 12,
                                                fontsizeWeb: 12,
                                                fontweight: FontWeight.w400,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),

                                  /* Description */
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.only(
                                            top: 15, bottom: 8),
                                        child: ExpandableText(
                                          audioDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .description ??
                                              "",
                                          animation: true,
                                          textAlign: TextAlign.start,
                                          expandOnTextTap: true,
                                          collapseOnTextTap: true,
                                          expandText: "",
                                          maxLines: 10,
                                          linkColor: colorPrimary,
                                          style: TextStyle(
                                            fontSize: (kIsWeb || Constant.isTV)
                                                ? 13
                                                : 13,
                                            fontStyle: FontStyle.normal,
                                            color: white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              Dimens.webBannerImgPr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /* Included Features buttons */
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
              margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* Continue Watching Button */
                  /* Watch Now button */
                  (widget.contentType == 5)
                      ? _buildWatchTrailer()
                      : _buildWatchNow(),
                  const SizedBox(width: 10),

                  /* Rent Button */
                  if (widget.contentType != 5)
                    Container(
                      constraints: const BoxConstraints(minWidth: 0),
                      // child: _buildRentBtn(),
                    ),
                  if (widget.contentType != 5) const SizedBox(width: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /* Other Details */
            /* Related ~ More Details */
            Consumer<ShowDetailsProvider>(
              builder: (context, showDetailsProvider, child) {
                return _buildTabs();
              },
            ),
            const SizedBox(height: 20),

            /* Web Footer */
            (kIsWeb || Constant.isTV)
                ? const FooterWeb()
                : const SizedBox.shrink(),
          ],
        ),
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
              : Dimens.detailPoster,
          child: MyNetworkImage(
            fit: BoxFit.fill,
            imageUrl: audioDetailsProvider
                    .contentdetailsModel.result?[0].portraitImg
                    .toString() ??
                "",
          ),
        ),
        Container(
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: (kIsWeb || Constant.isTV)
              ? Dimens.detailWebPoster
              : Dimens.detailPoster,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                transparentColor,
                transparentColor,
                appBgColor,
              ],
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(30),
          focusColor: white,
          onTap: () {
            // openPlayer("Trailer");

            if ((episodeProvider.videoList?[0].video ?? "").isNotEmpty) {
              openPlayer(
                0,
                episodeProvider.videoList ?? [],
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: MyImage(
              fit: BoxFit.fill,
              height: 45,
              width: 45,
              imagePath: "play.png",
            ),
          ),
        ),
        Positioned(
          bottom: 25,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  // openPlayer("Trailer");
                  playAudio(
                    playingType: episodeProvider
                            .audiobycontentmodel.result?[0].audioType
                            .toString() ??
                        "",
                    episodeid: episodeProvider.audiobycontentmodel.result?[0].id
                            .toString() ??
                        "",
                    contentid: episodeProvider
                            .audiobycontentmodel.result?[0].contentId
                            .toString() ??
                        "",
                    position: 0,
                    sectionBannerList:
                        episodeProvider.audiobycontentmodel.result ?? [],
                    contentName: episodeProvider
                            .audiobycontentmodel.result?[0].name
                            .toString() ??
                        "",
                    isBuy: episodeProvider.audiobycontentmodel.result?[0].isBuy
                            .toString() ??
                        "",
                    isAudioPaid: episodeProvider
                        .audiobycontentmodel.result?[0].isAudioPaid,
                  );
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 0,
                    maxHeight: 45,
                    minWidth: 0,
                    maxWidth: 120,
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
                    text: "playnow",
                    textalign: TextAlign.center,
                    fontsizeNormal: 16,
                    fontsizeWeb: 18,
                    fontweight: FontWeight.w700,
                    fontstyle: FontStyle.normal,
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
                  maxWidth: 130,
                ),
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: transparentColor,
                  borderRadius: BorderRadius.circular(5),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyImage(
                      imagePath: "ic_info.png",
                      height: 12,
                      width: 12,
                      color: white,
                    ),
                    MyText(
                      color: white,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      multilanguage: true,
                      text: "moreinfo",
                      textalign: TextAlign.center,
                      fontsizeNormal: 15,
                      fontsizeWeb: 18,
                      fontweight: FontWeight.w700,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!kIsWeb)
          Positioned(
            top: 45,
            left: 20,
            child: Utils.buildBackBtn(context),
          ),
      ],
    );
  }

  Widget _buildWatchTrailer() {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          // openPlayer("Trailer");
        },
        focusColor: white,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: (kIsWeb || Constant.isTV) ? 40 : 55,
            constraints: BoxConstraints(
              maxWidth: (kIsWeb || Constant.isTV)
                  ? 180
                  : MediaQuery.of(context).size.width,
            ),
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyImage(
                  width: 18,
                  height: 18,
                  imagePath: "ic_play.png",
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: "watch_trailer",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 15,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 16,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchNow() {
    return Consumer<EpisodeProvider>(
      builder: (context, episodeProvider, child) {
        if (audioDetailsProvider.mCurrentEpiPos != -1 &&
            (episodeProvider
                        .episodeBySeasonModel
                        .result?[audioDetailsProvider.mCurrentEpiPos]
                        .stopTime ??
                    0) >
                0 &&
            episodeProvider
                    .episodeBySeasonModel
                    .result?[audioDetailsProvider.mCurrentEpiPos]
                    .videoDuration !=
                null) {
          return Container(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                // openPlayer("Show");
              },
              focusColor: white,
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  height: (kIsWeb || Constant.isTV) ? 40 : 55,
                  constraints: BoxConstraints(
                    maxWidth: (kIsWeb || Constant.isTV)
                        ? 190
                        : MediaQuery.of(context).size.width,
                  ),
                  decoration: BoxDecoration(
                    color: primaryDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20),
                            MyImage(
                              width: 18,
                              height: 18,
                              imagePath: "ic_play.png",
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MyText(
                                    color: white,
                                    text:
                                        "Continue Watching Episode ${(audioDetailsProvider.mCurrentEpiPos + 1)}",
                                    multilanguage: false,
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 13,
                                    fontsizeWeb: 15,
                                    fontweight: FontWeight.w700,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  Row(
                                    children: [
                                      MyText(
                                        color: white,
                                        text: Utils.remainTimeInMin(((episodeProvider
                                                        .episodeBySeasonModel
                                                        .result?[
                                                            audioDetailsProvider
                                                                .mCurrentEpiPos]
                                                        .videoDuration ??
                                                    0) -
                                                (episodeProvider
                                                        .episodeBySeasonModel
                                                        .result?[
                                                            audioDetailsProvider
                                                                .mCurrentEpiPos]
                                                        .stopTime ??
                                                    0))
                                            .abs()),
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 10,
                                        fontsizeWeb: 12,
                                        multilanguage: false,
                                        fontweight: FontWeight.w500,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: white,
                                        text: "left",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 10,
                                        fontsizeWeb: 12,
                                        multilanguage: true,
                                        fontweight: FontWeight.w500,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                      Container(
                        height: 4,
                        constraints: const BoxConstraints(minWidth: 0),
                        margin: const EdgeInsets.all(3),
                        child: LinearPercentIndicator(
                          padding: const EdgeInsets.all(0),
                          barRadius: const Radius.circular(2),
                          lineHeight: 4,
                          percent: Utils.getPercentage(
                              episodeProvider
                                      .episodeBySeasonModel
                                      .result?[
                                          audioDetailsProvider.mCurrentEpiPos]
                                      .videoDuration ??
                                  0,
                              episodeProvider
                                      .episodeBySeasonModel
                                      .result?[
                                          audioDetailsProvider.mCurrentEpiPos]
                                      .stopTime ??
                                  0),
                          backgroundColor: secProgressColor,
                          progressColor: colorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                // openPlayer("Show");
              },
              focusColor: white,
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  height: (kIsWeb || Constant.isTV) ? 40 : 55,
                  constraints: BoxConstraints(
                    maxWidth: (kIsWeb || Constant.isTV)
                        ? 180
                        : MediaQuery.of(context).size.width,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                  decoration: BoxDecoration(
                    color: primaryDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_play.png",
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          color: white,
                          text: "Watch Episode 1",
                          multilanguage: false,
                          textalign: TextAlign.start,
                          fontsizeNormal: 14,
                          fontsizeWeb: 15,
                          fontweight: FontWeight.w700,
                          maxline: 2,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
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
                      await audioDetailsProvider.setTabClick("episodes");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: audioDetailsProvider.tabClickedOn !=
                                      "episodes"
                                  ? otherColor
                                  : primaryDark,
                              text: "episodes",
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
                          visible:
                              audioDetailsProvider.tabClickedOn == "episodes",
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
                // Videos
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await audioDetailsProvider.setTabClick("video");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  audioDetailsProvider.tabClickedOn != "video"
                                      ? otherColor
                                      : primaryDark,
                              text: "video",
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
                          visible: audioDetailsProvider.tabClickedOn == "video",
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
                      await audioDetailsProvider.setTabClick("details");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  audioDetailsProvider.tabClickedOn != "details"
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
                          visible:
                              audioDetailsProvider.tabClickedOn == "details",
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
          (audioDetailsProvider.tabClickedOn == "episodes")
              ? Container(
                  padding: ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720)
                      ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                      : const EdgeInsets.all(0),
                  child: (episodeProvider.audiobycontentmodel.result != null &&
                          (episodeProvider.audiobycontentmodel.result?.length ??
                                  0) >
                              0)
                      ? Container(
                          padding: ((kIsWeb || Constant.isTV) &&
                                  MediaQuery.of(context).size.width > 720)
                              ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
                              : const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          constraints: const BoxConstraints(minHeight: 50),
                          child: Consumer<EpisodeProvider>(
                            builder: (context, episodeProvider, child) {
                              return EpisodeBySeason(
                                  widget.contentId,
                                  audioDetailsProvider.seasonPos,
                                  audioDetailsProvider
                                      .audiobycontentmodel.result,
                                  audioDetailsProvider
                                      .audiobycontentmodel.result?[0],
                                  1,
                                  widget.contentType);
                            },
                          ),
                        )
                      : const SizedBox(
                          height: 250,
                          child: NoData(title: 'nodata', subTitle: '')),
                )
              : /* video */
              (audioDetailsProvider.tabClickedOn == "video")
                  ? Container(
                      padding: ((kIsWeb || Constant.isTV) &&
                              MediaQuery.of(context).size.width > 720)
                          ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                          : const EdgeInsets.all(0),
                      child: (episodeProvider.videobycontentmodel.result !=
                                  null &&
                              (episodeProvider.videoList?.length ?? 0) > 0)
                          ? Container(
                              padding: ((kIsWeb || Constant.isTV) &&
                                      MediaQuery.of(context).size.width > 720)
                                  ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
                                  : const EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 50),
                              child: Consumer<EpisodeProvider>(
                                builder: (context, episodeProvider, child) {
                                  return VideoEpiosdeByContent(
                                    videoId: widget.contentId,
                                  );
                                },
                              ),
                            )
                          : const SizedBox(
                              height: 250,
                              child: NoData(title: 'nodata', subTitle: '')),
                    )
                  : (audioDetailsProvider.tabClickedOn == "details")
                      ? MoreDetails(
                          type: 1,
                          contentid: audioDetailsProvider
                                  .contentdetailsModel.result?[0].id ??
                              0,
                          contentype: audioDetailsProvider
                                  .contentdetailsModel.result?[0].contentType ??
                              0,
                        )
                      : const SizedBox.shrink()
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
                    text: audioDetailsProvider
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
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
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
                          ? "Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
                            ? "Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                            : "Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
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
                          ? "Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${audioDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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

  Future<void> openPlayer(int position, List<Result>? dataList) async {
    if (Constant.userID == null) {
      Utils.openLogin(context: context, isHome: false, isReplace: false);
    } else if (audioDetailsProvider
            .videobycontentmodel.result?[position].isVideoPaid
            .toString() ==
        "1") {
      if (audioDetailsProvider.videobycontentmodel.result?[position].isBuy
              .toString() ==
          "0") {
        openBottomSheet(
            position,
            audioDetailsProvider
                .videobycontentmodel.result?[position].isVideoCoin,
            audioDetailsProvider.videobycontentmodel.result?[position].name,
            audioDetailsProvider.videobycontentmodel.result?[position].id,
            audioDetailsProvider
                .videobycontentmodel.result?[position].contentId);
      } else {
        Utils.openPlayer(
            context: context,
            playType: "video",
            videoId: dataList?[position].id ?? 0,
            videoType: dataList?[position].contentType ?? 0,
            videoUrl: dataList?[position].video ?? "",
            uploadType: dataList?[position].videoType.toString() ?? "",
            videoThumb: dataList?[position].image ?? "",
            vStopTime: dataList?[position].stopTime ?? 0,
            contentID: dataList?[position].contentId ?? 0);
      }
    } else {
      Utils.openPlayer(
          context: context,
          playType: "video",
          videoId: dataList?[position].id ?? 0,
          videoType: dataList?[position].contentType ?? 0,
          videoUrl: dataList?[position].video ?? "",
          uploadType: dataList?[position].videoType.toString() ?? "",
          videoThumb: dataList?[position].image ?? "",
          vStopTime: dataList?[position].stopTime ?? 0,
          contentID: dataList?[position].contentId ?? 0);
    }
  }

  /* Add Review - Reating START */
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
    ).whenComplete(() {
      _getData();
    });
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
                maxLines: 10,
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
                      final commentprovider = Provider.of<ShowDetailsProvider>(
                          context,
                          listen: false);

                      if (commentController.text.isNotEmpty &&
                          commentController.text != "") {
                        Utils.showProgress(context, prDialog);
                        await commentprovider.getAddReviews(
                          audioDetailsProvider
                              .contentdetailsModel.result?[0].id,
                          commentController.text,
                          audioDetailsProvider
                              .contentdetailsModel.result?[0].contentType,
                          ratingGiven ?? 0,
                        );
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        commentController.clear();
                        Navigator.pop(context);
                        // setState(() {});
                        _getData();
                      } else {
                        Utils.showToast("please_add_comment");
                      }
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginSocial(
                                    ishome: false,
                                  )));
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Consumer<ShowDetailsProvider>(
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

  Widget _reviewAndPlay() {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w600,
                    color: white,
                    text: formatNumber(audioDetailsProvider
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
                          text: audioDetailsProvider
                                  .contentdetailsModel.result?[0].avgRating
                                  .toString() ??
                              "")),
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                    fontsizeNormal: 11,
                    fontweight: FontWeight.w500,
                    color: white.withOpacity(0.7),
                    text:
                        "${formatNumber(audioDetailsProvider.contentdetailsModel.result?[0].totalReviews ?? 0)} Reviews")
              ],
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          // Flexible(
          //   child: MyText(
          //       maxline: 3,
          //       fontsizeNormal: 15,
          //       fontweight: FontWeight.w600,
          //       color: white,
          //       text: showDetailsProvider
          //               .contentdetailsModel.result?[0].languageName
          //               .toString() ??
          //           ""),
          // ),
          Flexible(
            child: InkWell(
              focusColor: gray.withOpacity(0.5),
              onTap: () async {
                debugPrint(
                    "isBookmark ====> ${audioDetailsProvider.contentdetailsModel.result?[0].isBookMark ?? 0}");
                AdHelper.showFullscreenAd(
                  context,
                  Constant.rewardAdType,
                  () async {
                    if (Constant.userID != null) {
                      await audioDetailsProvider.setBookMark(
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
              child: Consumer<ShowDetailsProvider>(
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
                    imagePath: "ic_sharedetails.png", height: 32, width: 32)),
          )
        ],
      ),
    );
  }

  /* PlayAudio Player */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    required List<Result>? sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
    required int? isAudioPaid,
  }) async {
    debugPrint("playingType =====>>>>>> ? $playingType");
    debugPrint("episodeid =====>>>>>> ? $episodeid");
    debugPrint("contentid =====>>>>>> ? $contentid");
    debugPrint("podcastimage =====>>>>>> ? $podcastimage");
    debugPrint("contentUserid =====>>>>>> ? $contentUserid");
    debugPrint("position =====>>>>>> ? $position");
    debugPrint(
        "sectionBannerList =====>>>>>> ? ${jsonEncode(sectionBannerList)}");
    debugPrint("playlistImages =====>>>>>> ? $playlistImages");
    debugPrint("contentName =====>>>>>> ? $contentName");

    /* Only Music Direct Play*/

    if (Constant.userID != null) {
      musicManager.setInitialMusic(
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, episodeid, contentid),
          false,
          0,
          isBuy ?? "",
          isAudioPaid ?? 0,
          "audioBook",
          "0");
    } else {
      Utils.openLogin(context: context, isHome: false, isReplace: false);
    }
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
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
                                  Navigator.push(
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
                    color: gray,
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
                                Provider.of<ShowDetailsProvider>(context,
                                    listen: false);
                            Utils.showProgress(context, prDialog);
                            await episodebuyprovider.getEpisodeBuy(
                                1, episodeID, 2, contentID, coins);
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
                              Utils.showToast(
                                  "${episodebuyprovider.episodeBuyModel.message}");
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
        }).whenComplete(() => _getData());
  }
}

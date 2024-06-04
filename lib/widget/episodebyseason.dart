import 'dart:convert';
import 'dart:io';

// import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:dtpocketfm/model/episodebycontentmodel.dart';
// import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
// import 'package:dtpocketfm/model/episodebycontentmodel.dart' as episode;
import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class EpisodeBySeason extends StatefulWidget {
  final int? videoId, seasonPos, type, contentType;
  final List<Result>? seasonList;
  final Result? sectionDetails;
  const EpisodeBySeason(this.videoId, this.seasonPos, this.seasonList,
      this.sectionDetails, this.type, this.contentType,
      {super.key});

  @override
  State<EpisodeBySeason> createState() => _EpisodeBySeasonState();
}

class _EpisodeBySeasonState extends State<EpisodeBySeason> {
  late EpisodeProvider episodeProvider;
  late ShowDetailsProvider showdetailsprovider;
  late ProgressDialog prDialog;
  late ProfileProvider profileProvider;
  String? finalVUrl = "";
  // final MusicManager musicManager = MusicManager();
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    showdetailsprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    // _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);

    getAllEpisode();
    prDialog = ProgressDialog(context);

    super.initState();
  }

  // _scrollListener() async {
  //   if (!_scrollController.hasClients) return;
  //   if (_scrollController.offset >=
  //           _scrollController.position.maxScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     debugPrint("AudioData Scroll Listner");

  //     if ((episodeProvider.audiocurrentPage ?? 0) <
  //         (episodeProvider.audiototalPage ?? 0)) {
  //       episodeProvider.setLoadMore(true);
  //       await _fetchDataAudio((episodeProvider.audiocurrentPage ?? 0));
  //     }
  //   }
  // }

  getAllEpisode() async {
    await profileProvider.getProfile(context);

    // await _fetchDataAudio(0);
    await subscriptionProvider.getPackages();
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
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
  }

  @override
  Widget build(BuildContext context) {
    return _buildUIAudioOther();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  Widget _buildUIAudioOther() {
    return Consumer<EpisodeProvider>(
      builder: (BuildContext context, episodeProvider, Widget? child) {
        debugPrint(
            "episodeProvider.audiobycontentmodel.status = ${episodeProvider.audiobycontentmodel.status}");
        return (episodeProvider.audiobycontentmodel.status == 200 &&
                episodeProvider.audioList != null &&
                (episodeProvider.audioList?.length ?? 0) > 0)
            ? Column(
                children: [
                  ResponsiveGridList(
                    minItemWidth: 60,
                    verticalGridSpacing: 8,
                    horizontalGridSpacing: 8,
                    minItemsPerRow: 1,
                    maxItemsPerRow:
                        (kIsWeb && MediaQuery.of(context).size.width > 720)
                            ? 1
                            : 1,
                    listViewBuilderOptions: ListViewBuilderOptions(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                    children: List.generate(
                      (episodeProvider.audioList?.length ?? 0),
                      (index) {
                        return Container(
                          color: appBgColor,
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                          constraints: const BoxConstraints(minHeight: 60),
                          child: InkWell(
                            onTap: () {
                              playAudio(
                                playingType: episodeProvider
                                        .audioList?[index].audioType
                                        .toString() ??
                                    "",
                                episodeid: episodeProvider.audioList?[index].id
                                        .toString() ??
                                    "",
                                contentid: episodeProvider
                                        .audioList?[index].contentId
                                        .toString() ??
                                    "",
                                position: index,
                                sectionBannerList:
                                    episodeProvider.audioList ?? [],
                                contentName: episodeProvider
                                        .audioList?[index].name
                                        .toString() ??
                                    "",
                                isBuy: episodeProvider.audioList?[index].isBuy
                                        .toString() ??
                                    "",
                                isAudioPaid: episodeProvider
                                    .audioList?[index].isAudioPaid,
                                isAudioCoin: episodeProvider
                                    .audioList?[index].isAudioCoin,
                              );
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
                                          imageUrl: episodeProvider
                                                  .audioList?[index].image
                                                  .toString() ??
                                              "",
                                        ),
                                      ),
                                    ),
                                    (episodeProvider.audioList?[index]
                                                    .videoDuration !=
                                                null &&
                                            (episodeProvider.audioList?[index]
                                                        .stopTime ??
                                                    0) >
                                                0)
                                        ? Container(
                                            height: 2,
                                            width: 32,
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            child: LinearPercentIndicator(
                                              padding: const EdgeInsets.all(0),
                                              barRadius:
                                                  const Radius.circular(2),
                                              lineHeight: 2,
                                              percent: Utils.getPercentage(
                                                  episodeProvider
                                                          .audioList?[index]
                                                          .videoDuration ??
                                                      0,
                                                  episodeProvider
                                                          .audioList?[index]
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      MyText(
                                        color: white,
                                        text: episodeProvider
                                                .audioList?[index].name ??
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
                                          widget.type == 2
                                              ? const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8.0),
                                                  child: Icon(
                                                    Icons
                                                        .remove_red_eye_outlined,
                                                    size: 20,
                                                    color: white,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          MyText(
                                            color: white,
                                            text: formatNumber(
                                              episodeProvider.audioList?[index]
                                                      .totalVideoPlayed ??
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
                                          widget.type == 1
                                              ? Container(
                                                  height: 4,
                                                  width: 4,
                                                  decoration: BoxDecoration(
                                                      color: white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                )
                                              : const SizedBox.shrink(),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: widget.type == 1
                                                ? MyText(
                                                    color: white,
                                                    text: ((episodeProvider
                                                                    .audioList?[
                                                                        index]
                                                                    .videoDuration ??
                                                                0) >
                                                            0)
                                                        ? Utils.convertToColonText(
                                                            episodeProvider
                                                                    .audioList?[
                                                                        index]
                                                                    .videoDuration ??
                                                                0)
                                                        : "",
                                                    textalign: TextAlign.start,
                                                    fontsizeNormal: 11,
                                                    fontsizeWeb: 12,
                                                    fontweight: FontWeight.w600,
                                                    maxline: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontstyle: FontStyle.normal,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          // Container(
                                          //   height: 4,
                                          //   width: 4,
                                          //   decoration: BoxDecoration(
                                          //       color: white,
                                          //       borderRadius:
                                          //           BorderRadius
                                          //               .circular(
                                          //                   50)),
                                          // ),
                                          // const SizedBox(
                                          //   width: 10,
                                          // ),
                                          // MyText(
                                          //   color: white,
                                          //   text: "1 year Ago",
                                          //   textalign:
                                          //       TextAlign.start,
                                          //   fontsizeNormal: 11,
                                          //   fontsizeWeb: 12,
                                          //   fontweight:
                                          //       FontWeight.w600,
                                          //   maxline: 1,
                                          //   overflow:
                                          //       TextOverflow.ellipsis,
                                          //   fontstyle:
                                          //       FontStyle.normal,
                                          // ),
                                          // const SizedBox(
                                          //   width: 10,
                                          // ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                MyText(
                                  text: (episodeProvider.audioList?[index]
                                                  .isAudioPaid ??
                                              "") ==
                                          1
                                      ? (episodeProvider.audioList?[index]
                                                      .isBuy ??
                                                  "") ==
                                              1
                                          ? ""
                                          : "${episodeProvider.audioList?[index].isAudioCoin} Coins"
                                      : "",
                                  fontsizeNormal: 13,
                                  fontsizeWeb: 13,
                                  color: white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyImage(
                                    imagePath: (episodeProvider
                                                    .audioList?[index]
                                                    .isAudioPaid ??
                                                "") ==
                                            1
                                        ? (episodeProvider.audioList?[index]
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
                  Consumer<EpisodeProvider>(
                    builder: (context, episodeProvider, child) {
                      if (episodeProvider.loadmore) {
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
            : const SizedBox.shrink();
      },
    );
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<EpisodeProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
  }

  addPlay(contentType, episodeid, contentId) async {
    final videototalplayprovider =
        Provider.of<EpisodeProvider>(context, listen: false);
    await videototalplayprovider.getAddContentPlay(1, episodeid, 2, contentId);
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
    required int? isAudioCoin,
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

    if (Constant.userID != null) {
      if (isAudioPaid == 1) {
        if (isBuy == "0") {
          if (kIsWeb) {
            openSubscriptionDialog(
              position,
              isAudioCoin,
              contentName,
              1,
              episodeid,
              contentid,
            );
          } else {
            openBottomSheet(
              position,
              isAudioCoin,
              contentName,
              1,
              episodeid,
              contentid,
            );
          }
        } else {
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
        }
      } else {
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
      }
      // }
    } else {
      if (kIsWeb) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => getAllEpisode());
      } else {
        Utils.openLogin(context: context, isHome: false, isReplace: false);
      }
    }
  }

  openBottomSheet(
      int index, coins, episodeName, audioBookType, episodeID, contentID) {
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
                      height: 10,
                    ),
                    const Icon(
                      Icons.lock_open_rounded,
                      color: gray,
                      size: 40,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: colorPrimary,
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
                              color: black,
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
                                  color: black,
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
                        color: black,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: black,
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
                                  color: black,
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
                                1, episodeID, audioBookType, contentID, coins);
                            if (episodebuyprovider.episodeBuyModel.status ==
                                200) {
                              Utils.showToast("Succesfully Buy");

                              if (!context.mounted) return;
                              Utils().hideProgress(context);

                              Navigator.pop(context);
                              setState(() {
                                showdetailsprovider.getContentDetails(
                                  widget.videoId,
                                  1,
                                );
                                episodeProvider.getAudioByContent(
                                    widget.videoId,
                                    (episodeProvider.audiocurrentPage ?? 0));
                                getAllEpisode();
                              });
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
                          ).then((value) => getAllEpisode());
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

  openSubscriptionDialog(
      int index, coins, episodeName, audioBookType, episodeID, contentID) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              backgroundColor: lightBlack,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
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
                            height: 10,
                          ),
                          const Icon(
                            Icons.lock_open_rounded,
                            color: gray,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MyText(
                            color: colorPrimary,
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
                                          isMobileReq:
                                              (userMobileNo ?? "").isEmpty,
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
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                fontsizeWeb: 18,
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
                                              fontsizeWeb: 16,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: black,
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
                                        color: black,
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
                              color: black,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: black,
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
                                        color: black,
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
                                if ((profileProvider.profileModel.result?[0]
                                            .walletCoin ??
                                        0) >
                                    coins) {
                                  final episodebuyprovider =
                                      Provider.of<ShowDetailsProvider>(context,
                                          listen: false);
                                  Utils.showProgress(context, prDialog);
                                  await episodebuyprovider.getEpisodeBuy(
                                      1,
                                      episodeID,
                                      audioBookType,
                                      contentID,
                                      coins);
                                  if (episodebuyprovider
                                          .episodeBuyModel.status ==
                                      200) {
                                    Utils.showToast("Succesfully Buy");

                                    if (!context.mounted) return;
                                    Utils().hideProgress(context);

                                    Navigator.pop(context);
                                    setState(() {
                                      showdetailsprovider.getContentDetails(
                                        widget.videoId,
                                        1,
                                      );
                                      episodeProvider.getAudioByContent(
                                          widget.videoId,
                                          (episodeProvider.audiocurrentPage ??
                                              0));
                                      getAllEpisode();
                                    });
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
                                ).then((value) => getAllEpisode());
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
                ),
              ));
        });
  }
}

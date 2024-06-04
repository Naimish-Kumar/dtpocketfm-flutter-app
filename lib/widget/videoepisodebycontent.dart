import 'dart:io';

import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../model/episodebycontentmodel.dart';

class VideoEpiosdeByContent extends StatefulWidget {
  final int? videoId;
  const VideoEpiosdeByContent({
    super.key,
    required this.videoId,
  });

  @override
  State<VideoEpiosdeByContent> createState() => _VideoEpiosdeByContentState();
}

class _VideoEpiosdeByContentState extends State<VideoEpiosdeByContent> {
  late EpisodeProvider episodeProvider;
  late ProgressDialog prDialog;
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();
  late ProfileProvider profileProvider;
  late SubscriptionProvider subscriptionProvider;
  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  @override
  void initState() {
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    // _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
    debugPrint("videoList == ${episodeProvider.videoList?.length}");
    getAllEpisode();
    prDialog = ProgressDialog(context);

    super.initState();
  }

  // _scrollListener() async {
  //   if (!_scrollController.hasClients) return;
  //   if (_scrollController.offset >=
  //           _scrollController.position.maxScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     debugPrint("VideoData Scroll Listner");
  //     if ((episodeProvider.currentPage ?? 0) <
  //         (episodeProvider.totalPage ?? 0)) {
  //       await episodeProvider.setLoadMore(true);
  //       await _fetchDataVideo((episodeProvider.currentPage ?? 0));
  //     }
  //   }
  // }

  getAllEpisode() async {
    await profileProvider.getProfile(context);
    // await _fetchDataVideo(0);
    await subscriptionProvider.getPackages();
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  } /* Section Data Api */

  // Future<void> _fetchDataVideo(int? nextPage) async {
  //   await episodeProvider.getVideoByContent(
  //       widget.videoId, (nextPage ?? 0) + 1);
  // }
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

  @override
  Widget build(BuildContext context) {
    return _buildUIOther();
  }

  Widget _buildUIOther() {
    return Consumer<EpisodeProvider>(
        builder: (BuildContext context, episodeProvider, Widget? child) {
      return (episodeProvider.videobycontentmodel.status == 200 &&
              (episodeProvider.videoList?.length ?? 0) > 0)
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
                    (episodeProvider.videoList?.length ?? 0),
                    (index) {
                      return Container(
                        color: appBgColor,
                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                        constraints: const BoxConstraints(minHeight: 60),
                        child: InkWell(
                          onTap: () {
                            debugPrint("===> index $index");
                            openPlayer(index, episodeProvider.videoList);
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
                                                .videobycontentmodel
                                                .result?[index]
                                                .image
                                                .toString() ??
                                            "",
                                      ),
                                    ),
                                  ),
                                  (episodeProvider.videoList?[index]
                                                  .videoDuration !=
                                              null &&
                                          (episodeProvider.videoList?[index]
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
                                                episodeProvider
                                                        .videoList?[index]
                                                        .videoDuration ??
                                                    0,
                                                episodeProvider
                                                        .videoList?[index]
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
                                      text: episodeProvider
                                              .videoList?[index].name ??
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
                                            episodeProvider.videoList?[index]
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
                                        MyText(
                                          color: white,
                                          text: ((episodeProvider
                                                          .videoList?[index]
                                                          .videoDuration ??
                                                      0) >
                                                  0)
                                              ? Utils.convertToColonText(
                                                  episodeProvider
                                                          .videoList?[index]
                                                          .videoDuration ??
                                                      0)
                                              : " ",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 11,
                                          fontsizeWeb: 12,
                                          fontweight: FontWeight.w600,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        // const SizedBox(
                                        //   width: 10,
                                        // ),
                                        // Container(
                                        //   height: 4,
                                        //   width: 4,
                                        //   decoration: BoxDecoration(
                                        //       color: white,
                                        //       borderRadius:
                                        //           BorderRadius
                                        //               .circular(50)),
                                        // ),
                                        // const SizedBox(
                                        //   width: 10,
                                        // ),
                                        // MyText(
                                        //   color: white,
                                        //   text: "1 year Ago",
                                        //   textalign: TextAlign.start,
                                        //   fontsizeNormal: 11,
                                        //   fontsizeWeb: 12,
                                        //   fontweight: FontWeight.w600,
                                        //   maxline: 1,
                                        //   overflow:
                                        //       TextOverflow.ellipsis,
                                        //   fontstyle: FontStyle.normal,
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
                                text: (episodeProvider.videoList?[index]
                                                .isVideoPaid ??
                                            "") ==
                                        1
                                    ? (episodeProvider
                                                    .videoList?[index].isBuy ??
                                                "") ==
                                            1
                                        ? ""
                                        : "${episodeProvider.videoList?[index].isVideoCoin} Coins"
                                    : "",
                                fontsizeNormal: 13,
                                fontsizeWeb: 16,
                                color: white,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyImage(
                                  imagePath: (episodeProvider.videoList?[index]
                                                  .isVideoPaid ??
                                              "") ==
                                          1
                                      ? (episodeProvider.videoList?[index]
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
          : const SizedBox(
              height: 250, child: NoData(title: 'nodata', subTitle: ''));
    });
  }

  Future<void> openPlayer(int position, List<Result>? dataList) async {
    if (Constant.userID == null) {
      if (kIsWeb) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => getAllEpisode());
      } else {
        Utils.openLogin(context: context, isHome: false, isReplace: false);
      }
    } else {
      // if (kIsWeb) {
      //   Utils.openPlayer(
      //       context: context,
      //       playType: "video",
      //       videoId: dataList?[position].id ?? 0,
      //       videoType: 1,
      //       videoUrl: dataList?[position].video ?? "",
      //       uploadType: dataList?[position].videoType.toString() ?? "",
      //       videoThumb: dataList?[position].image ?? "",
      //       vStopTime: dataList?[position].stopTime ?? 0,
      //       contentID: dataList?[position].contentId ?? 0);
      // } else {
      if (episodeProvider.videobycontentmodel.result?[position].isVideoPaid
              .toString() ==
          "1") {
        if (episodeProvider.videobycontentmodel.result?[position].isBuy
                .toString() ==
            "0") {
          if (kIsWeb) {
            openSubscriptionDialog(
              position,
              episodeProvider.videobycontentmodel.result?[position].isVideoCoin,
              episodeProvider.videobycontentmodel.result?[position].name,
              2,
              episodeProvider.videobycontentmodel.result?[position].id,
              episodeProvider.videobycontentmodel.result?[position].contentId,
            );
          } else {
            openBottomSheet(
              position,
              episodeProvider.videobycontentmodel.result?[position].isVideoCoin,
              episodeProvider.videobycontentmodel.result?[position].name,
              2,
              episodeProvider.videobycontentmodel.result?[position].id,
              episodeProvider.videobycontentmodel.result?[position].contentId,
            );
          }
        } else {
          // addPlay(dataList?[position].contentType ?? 0,
          //     dataList?[position].id ?? 0, dataList?[position].contentId ?? 0);
          Utils.openPlayer(
              context: context,
              playType: "video",
              videoId: dataList?[position].id ?? 0,
              videoType: 1,
              videoUrl: dataList?[position].video ?? "",
              uploadType: dataList?[position].videoType.toString() ?? "",
              videoThumb: dataList?[position].image ?? "",
              vStopTime: dataList?[position].stopTime ?? 0,
              contentID: dataList?[position].contentId ?? 0);
        }
      } else {
        // addPlay(dataList?[position].contentType ?? 0, dataList?[position].id ?? 0,
        //     dataList?[position].contentId ?? 0);
        Utils.openPlayer(
            context: context,
            playType: "video",
            videoId: dataList?[position].id ?? 0,
            videoType: 1,
            videoUrl: dataList?[position].video ?? "",
            uploadType: dataList?[position].videoType.toString() ?? "",
            videoThumb: dataList?[position].image ?? "",
            vStopTime: dataList?[position].stopTime ?? 0,
            contentID: dataList?[position].contentId ?? 0);
      }
      // }
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
                              episodeProvider.getVideoByContent(widget.videoId,
                                  (episodeProvider.currentPage ?? 0));
                              getAllEpisode();
                            });
                          } else {
                            Utils.showToast("Something Went Wrong");
                            if (!context.mounted) return;
                            Utils().hideProgress(context);
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

  openSubscriptionDialog(
      int index, coins, episodeName, audioBookType, episodeID, contentID) {
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
                                episodeProvider.getVideoByContent(
                                    widget.videoId,
                                    (episodeProvider.currentPage ?? 0));
                                getAllEpisode();
                              });
                            } else {
                              Utils.showToast("Something Went Wrong");
                              if (!context.mounted) return;
                              Utils().hideProgress(context);
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

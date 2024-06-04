import 'dart:io';

import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/provider/watchlistprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

class MyWatchlist extends StatefulWidget {
  const MyWatchlist({super.key});

  @override
  State<MyWatchlist> createState() => _MyWatchlistState();
}

class _MyWatchlistState extends State<MyWatchlist>
    with TickerProviderStateMixin {
  late WatchlistProvider watchlistProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    watchlistProvider.setLoading(true);
    _getData(0, 1, 1);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if ((watchlistProvider.currentPage ?? 0) <
          (watchlistProvider.totalPage ?? 0)) {
        watchlistProvider.setLoadMore(true);
        await fetchWatchListData((watchlistProvider.currentPage ?? 0));
      }
    }
  }

  fetchWatchListData(int? nextPage) async {
    await watchlistProvider.getWatchlist(
        watchlistProvider.selectedIndex + 1, (nextPage ?? 0) + 1);
  }

  _getData(tabPos, int contentType, int pageNo) async {
    await watchlistProvider.setSelectedTab(tabPos);
    await watchlistProvider.getWatchlist(contentType, pageNo);
  }

  @override
  void dispose() {
    watchlistProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(context, "watchlist", true, true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: white,
                color: complimentryColor,
                displacement: 80,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 1500))
                      .then((value) {
                    _getData(0, watchlistProvider.selectedIndex, 1);
                  });
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Column(
                    children: [
                      Consumer<WatchlistProvider>(
                        builder: (context, watchlistProvider, child) {
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          watchlistProvider.watchDataList = [];
                                          await _getData(0, 1, 1);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: MyText(
                                                color: white,
                                                text: "audiobooks",
                                                multilanguage: true,
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 14,
                                                fontsizeWeb: 16,
                                                fontweight: FontWeight.w600,
                                                maxline: 2,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Visibility(
                                              // visible: searchProvider.isVideoClick,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 2,
                                                color: watchlistProvider
                                                            .selectedIndex ==
                                                        0
                                                    ? white
                                                    : appBgColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          // searchProvider.setDataVisibility(
                                          //     true, false);\
                                          watchlistProvider.watchDataList = [];
                                          await _getData(1, 2, 1);
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: MyText(
                                                color: white,
                                                text: "novels",
                                                multilanguage: true,
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 14,
                                                fontsizeWeb: 16,
                                                fontweight: FontWeight.w600,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Visibility(
                                              // visible: searchProvider.isVideoClick,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 2,
                                                color: watchlistProvider
                                                            .selectedIndex ==
                                                        1
                                                    ? white
                                                    : appBgColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Consumer<WatchlistProvider>(
                                builder: (context, value, child) {
                                  if (watchlistProvider.loading &&
                                      watchlistProvider.loadMore == false) {
                                    return ShimmerUtils.buildWatchlistShimmer(
                                        context, 10);
                                  } else {
                                    if (watchlistProvider
                                                .watchlistModel.status ==
                                            200 &&
                                        watchlistProvider
                                                .watchlistModel.result !=
                                            null) {
                                      if ((watchlistProvider
                                                  .watchDataList?.length ??
                                              0) >
                                          0) {
                                        return watchlistitems();
                                      } else {
                                        return const NoData(
                                          title: 'browse_now_watch_later',
                                          subTitle: 'watchlist_note',
                                        );
                                      }
                                    } else {
                                      return const NoData(
                                        title: 'browse_now_watch_later',
                                        subTitle: 'watchlist_note',
                                      );
                                    }
                                  }
                                },
                              )
                            ],
                          );
                        },
                      ),
                      Consumer<WatchlistProvider>(
                        builder: (context, watchlistProvider, child) {
                          if (watchlistProvider.loadMore) {
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
                  ),
                ),
              ),
            ),
            /* AdMob Banner */
            Container(
              child: Utils.showBannerAd(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget watchlistitems() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: watchlistProvider.watchDataList?.length ?? 0,
      itemBuilder: (BuildContext context, int position) {
        return _buildWatchlistItem(position);
      },
    );
  }

  Widget _buildWatchlistItem(position) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(minHeight: Dimens.heightWatchlist),
      color: lightBlack,
      child: Row(
        children: [
          _buildImage(position),
          _buildDetails(position),
        ],
      ),
    );
  }

  Widget _buildImage(int position) {
    return Container(
      constraints: BoxConstraints(
        minHeight: Dimens.heightWatchlist,
        maxWidth: MediaQuery.of(context).size.width * 0.44,
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: Dimens.heightWatchlist,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(0),
              onTap: () {
                debugPrint("Clicked on position ==> $position");
                Utils.openDetails(
                  context: context,
                  videoId: watchlistProvider.watchDataList?[position].id ?? 0,
                  // upcomingType: 0,
                  videoType:
                      watchlistProvider.watchDataList?[position].contentType ??
                          0,
                );
              },
              child: MyNetworkImage(
                imageUrl: (watchlistProvider
                                .watchDataList?[position].landscapeImg ??
                            "")
                        .isNotEmpty
                    ? (watchlistProvider
                            .watchDataList?[position].landscapeImg ??
                        "")
                    : (watchlistProvider.watchDataList?[position].portraitImg ??
                        ""),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(int position) {
    return Flexible(
      child: Container(
        constraints: BoxConstraints(
          minHeight: Dimens.heightWatchlist,
          maxWidth: MediaQuery.of(context).size.width * 0.66,
        ),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              child: MyText(
                color: white,
                text: watchlistProvider.watchDataList?[position].title ?? "",
                textalign: TextAlign.start,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                fontsizeNormal: 13,
                fontweight: FontWeight.w600,
                fontstyle: FontStyle.normal,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  _buildVideoMoreDialog(position);
                },
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(6),
                  child: MyImage(
                    width: 18,
                    height: 18,
                    imagePath: "ic_more.png",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildVideoMoreDialog(position) {
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
                  /* Title */
                  MyText(
                    text:
                        watchlistProvider.watchDataList?[position].title ?? "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 20,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  /* Add to Watchlist / Remove from Watchlist */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      Navigator.pop(context);
                      debugPrint(
                          "isBookmark ====> ${watchlistProvider.watchDataList?[position].isBookmark ?? 0}");
                      if (Constant.userID != null) {
                        await watchlistProvider.setBookMark(
                          context,
                          position,
                          watchlistProvider
                                  .watchDataList?[position].contentType ??
                              0,
                          watchlistProvider.watchDataList?[position].id ?? 0,
                        );
                      } else {
                        if ((kIsWeb || Constant.isTV)) {
                          Utils.buildWebAlertDialog(context, "login", "").then(
                              (value) => _getData(
                                  0, watchlistProvider.selectedIndex, 1));
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
                    child: _buildDialogItems(
                      icon: ((watchlistProvider
                                      .watchDataList?[position].isBookmark ??
                                  0) ==
                              1)
                          ? "watchlist_remove.png"
                          : "ic_plus.png",
                      title: ((watchlistProvider
                                      .watchDataList?[position].isBookmark ??
                                  0) ==
                              1)
                          ? "remove_from_watchlist"
                          : "add_to_watchlist",
                      isMultilang: true,
                    ),
                  ),

                  /* Video Share */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      Navigator.pop(context);
                      _buildShareWithDialog(position);
                    },
                    child: _buildDialogItems(
                      icon: "ic_share.png",
                      title: "share",
                      isMultilang: true,
                    ),
                  ),

                  /* View Details */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      Navigator.pop(context);
                      debugPrint("Clicked on position :==> $position");
                      Utils.openDetails(
                        context: context,
                        videoId:
                            watchlistProvider.watchDataList?[position].id ?? 0,
                        // upcomingType: 0,
                        videoType: watchlistProvider
                                .watchDataList?[position].contentType ??
                            0,
                        // typeId: watchlistProvider
                        //         .watchlistModel.result?[position].typeId ??
                        //     0,
                      );
                    },
                    child: _buildDialogItems(
                      icon: "ic_info.png",
                      title: "view_details",
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

  _buildShareWithDialog(position) {
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
                    text:
                        watchlistProvider.watchDataList?[position].title ?? "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 20,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  /* SMS */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      if (Platform.isAndroid) {
                        Utils.redirectToUrl(
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
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
                          ? "Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
                            ? "Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                            : "Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
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
                          ? "Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${watchlistProvider.watchDataList?[position].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
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
            color: white,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: MyText(
              text: title,
              multilanguage: isMultilang,
              fontsizeNormal: 14,
              fontsizeWeb: 16,
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
}

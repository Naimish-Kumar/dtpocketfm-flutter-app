import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/model/sectionlistmodel.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/tvpages/webmusicviewall.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:dtpocketfm/provider/musicprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WebMusic extends StatefulWidget {
  const WebMusic({super.key});

  @override
  State<WebMusic> createState() => _WebMusicState();
}

class _WebMusicState extends State<WebMusic> {
  CarouselController bannerController = CarouselController();
  late MusicProvider musicProvider;
  late ScrollController _scrollController;
  late ProfileProvider profileProvider;
  late ScrollController playlistController;
  final playlistTitleController = TextEditingController();
  int episodeIndex = 0;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
    // musicDetailProvider =
    //     Provider.of<MusicDetailProvider>(context, listen: false);
    _scrollController = ScrollController();
    playlistController = ScrollController();
    _scrollController.addListener(_scrollListener);
    playlistController.addListener(_scrollListenerPlaylist);
    musicProvider.setLoading(true);
    super.initState();
    _fetchData("1", "0", 0);
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (musicProvider.sectioncurrentPage ?? 0) <
            (musicProvider.sectiontotalPage ?? 0)) {
      debugPrint("load more====>");
      musicProvider.setSectionLoadMore(true);
      if (musicProvider.tabindex == 0) {
        _fetchData("1", "0", musicProvider.sectioncurrentPage ?? 0);
      } else if (musicProvider.tabindex == 1) {
        _fetchData(
            "2", Constant.musicType, musicProvider.sectioncurrentPage ?? 0);
      } else if (musicProvider.tabindex == 2) {
        _fetchData(
            "2", Constant.radioType, musicProvider.sectioncurrentPage ?? 0);
      } else if (musicProvider.tabindex == 3) {
        _fetchData(
            "2", Constant.podcastType, musicProvider.sectioncurrentPage ?? 0);
      }
    }
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (musicProvider.playlistcurrentPage ?? 0) <
            (musicProvider.playlisttotalPage ?? 0)) {
      await musicProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(musicProvider.playlistcurrentPage ?? 0);
    }
  }

/* Section Data Api */
  Future<void> _fetchData(ishomepage, contenttype, int? nextPage) async {
    await profileProvider.getProfile(context);
    debugPrint("isMorePage  ======> ${musicProvider.sectionisMorePage}");
    debugPrint("currentPage ======> ${musicProvider.sectioncurrentPage}");
    debugPrint("totalPage   ======> ${musicProvider.sectiontotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicProvider.getSeactionList(
        ishomepage, contenttype, (nextPage ?? 0) + 1);
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    debugPrint("playlistmorePage  =======> ${musicProvider.playlistmorePage}");
    debugPrint(
        "playlistcurrentPage =======> ${musicProvider.playlistcurrentPage}");
    debugPrint(
        "playlisttotalPage   =======> ${musicProvider.playlisttotalPage}");
    debugPrint("nextPage   ========> $nextPage");
  }

  @override
  void dispose() {
    musicProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appBgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPage(),
              ],
            ),
          ),
        ),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget buildPage() {
    return Consumer<MusicProvider>(builder: (context, seactionprovider, child) {
      if (seactionprovider.sectionloading &&
          !seactionprovider.sectionLoadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            setSectionByType(),
            if (musicProvider.sectionLoadMore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Utils.pageLoader(),
              )
            else
              const SizedBox.shrink(),
            const FooterWeb()
          ],
        );
      }
    });
  }

  Widget setSectionByType() {
    if (musicProvider.sectionListModel.status == 200 &&
        musicProvider.sectionList != null) {
      if ((musicProvider.sectionList?.length ?? 0) > 0) {
        return ListView.builder(
          itemCount: musicProvider.sectionList?.length ?? 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (musicProvider.sectionList?[index].data != null &&
                (musicProvider.sectionList?[index].data?.length ?? 0) > 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: musicProvider.sectionList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textTitle,
                                  fontsizeWeb: Dimens.textTitle,
                                  // inter: false,
                                  maxline: 1,
                                  fontweight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 5),
                              MyText(
                                  color: gray,
                                  multilanguage: false,
                                  text: musicProvider
                                          .sectionList?[index].shortTitle
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textMedium,
                                  fontsizeWeb: Dimens.textMedium,
                                  // inter: false,
                                  maxline: 1,
                                  fontweight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                        musicProvider.sectionList?[index].viewAll == 1
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return WebMusicViewAll(
                                          isRent: false,
                                          sectionId: musicProvider
                                                  .sectionList?[index].id
                                                  .toString() ??
                                              "",
                                          contentType: musicProvider
                                                  .sectionList?[index]
                                                  .contentType
                                                  .toString() ??
                                              "",
                                          title: musicProvider
                                                  .sectionList?[index].title
                                                  .toString() ??
                                              "",
                                          screenLayout: musicProvider
                                                  .sectionList?[index]
                                                  .screenLayout
                                                  .toString() ??
                                              "",
                                        );
                                      },
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return child;
                                      },
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  child: MyText(
                                      color: colorAccent,
                                      multilanguage: true,
                                      text: "seeall",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 14,
                                      fontsizeWeb: 14,
                                      // inter: false,
                                      maxline: 1,
                                      fontweight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Section Data List
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: getRemainingDataHeight(
                      musicProvider.sectionList?[index].screenLayout
                              .toString() ??
                          "",
                    ),
                    child: setSectionData(
                        index: index, sectionList: musicProvider.sectionList),
                  )
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      } else {
        return const NoData(title: "nodata", subTitle: "");
      }
    } else {
      return const NoData(title: "nodata", subTitle: "");
    }
  }

  Widget setSectionData(
      {required int index, required List<Result>? sectionList}) {
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].screenLayout.toString() ?? "") == "list_view") {
      return listView(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "square") {
      return square(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "portrait") {
      return portrait(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") == "round") {
      return round(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "playlist") {
      return playlist(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "category") {
      return category(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "language") {
      return language(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "banner_view") {
      return bannerPodcast(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "grid_view") {
      return landscapPodcast(index, sectionList?[index].id ?? 0, sectionList);
    } else if ((sectionList?[index].screenLayout.toString() ?? "") ==
        "podcast_list_view") {
      return podcastListview(index, sectionList?[index].id ?? 0, sectionList);
    } else {
      return square(index, sectionList?[index].id ?? 0, sectionList);
    }
  }

  double getRemainingDataHeight(String? layoutType) {
    if (layoutType == "list_view") {
      return Dimens.landscapPodcastheight;
    } else if (layoutType == "portrait") {
      return Dimens.portraitheight;
    } else if (layoutType == "square") {
      return Dimens.squareheight;
    } else if (layoutType == "list_view") {
      return Dimens.heightMiniSeries;
    } else if (layoutType == "round") {
      return Dimens.roundheight;
    } else if (layoutType == "playlist") {
      return Dimens.playlistheight;
    } else if (layoutType == "category") {
      return Dimens.categoryheight;
    } else if (layoutType == "language") {
      return Dimens.languageheight;
    } else if (layoutType == "banner_view") {
      return Dimens.podcastbannerheight;
    } else if (layoutType == "landscape") {
      return Dimens.landscapPodcastheight;
    } else if (layoutType == "podcast_list_view") {
      return Dimens.podcastListviewheight;
    } else {
      return Dimens.squareheight;
    }
  }

/* Music Layout */

  Widget square(int sectionindex, int sectionId, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.squareheight,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 3),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MyNetworkImage(
                        imgWidth: 90,
                        imgHeight: 90,
                        fit: BoxFit.fill,
                        imageUrl: sectionList?[sectionindex]
                                .data?[index]
                                .portraitImg
                                .toString() ??
                            "",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: MyText(
                            color: white,
                            fontsizeWeb: Dimens.textSmall,
                            text: sectionList?[sectionindex]
                                    .data?[index]
                                    .title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            // inter: false,
                            multilanguage: false,
                            maxline: 2,
                            fontweight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(int sectionindex, int sectionId, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.portraitheight,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              debugPrint("Play Audio");
              playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: MyNetworkImage(
                      imgWidth: 150,
                      imgHeight: 140,
                      fit: BoxFit.fill,
                      imageUrl: sectionList?[sectionindex]
                              .data?[index]
                              .landscapeImg
                              .toString() ??
                          "",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: MyText(
                            color: white,
                            text: sectionList?[sectionindex]
                                    .data?[index]
                                    .title
                                    .toString() ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            // inter: false,
                            multilanguage: false,
                            maxline: 2,
                            fontweight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listviewLayout(int sectionindex, List<Result>? sectionList) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 270,
        // color: gray,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Wrap(direction: Axis.vertical, runSpacing: -2, children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 55,
                  margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: MyNetworkImage(
                            fit: BoxFit.fill,
                            imgWidth: 55,
                            imgHeight: 55,
                            imageUrl: sectionList?[sectionindex]
                                    .data?[index]
                                    .portraitImg
                                    .toString() ??
                                ""),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                                fontsizeWeb: Dimens.textDesc,
                                color: colorAccent,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textDesc,
                                // inter: false,
                                maxline: 1,
                                fontweight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                MyText(
                                    fontsizeWeb: Dimens.textSmall,
                                    color: white,
                                    multilanguage: false,
                                    text: sectionList?[sectionindex]
                                            .data?[index]
                                            .artistName
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textSmall,
                                    // inter: false,
                                    maxline: 1,
                                    fontweight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(width: 5),
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: Utils.kmbGenerator(int.parse(
                                        sectionList?[sectionindex]
                                                .data?[index]
                                                .totalPlayed
                                                .toString() ??
                                            "")),
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textSmall,
                                    fontsizeWeb: Dimens.textSmall,
                                    // inter: false,
                                    maxline: 1,
                                    fontweight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(width: 3),
                                MyText(
                                    color: white,
                                    multilanguage: false,
                                    text: "views",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textSmall,
                                    fontsizeWeb: Dimens.textSmall,
                                    // inter: false,
                                    maxline: 1,
                                    fontweight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ));
  }

/* Playlist Layout */

  Widget playlist(int sectionindex, int sectionId, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.playlistheight,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  podcastimage: sectionList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  playlistImages:
                      sectionList?[sectionindex].data?[index].landscapeImg ??
                          [],
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 150,
                    child: MyText(
                        color: white,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        // inter: false,
                        multilanguage: false,
                        maxline: 1,
                        fontweight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                            color: gray,
                            text: Utils.kmbGenerator(int.parse(
                                sectionList?[sectionindex]
                                        .data?[index]
                                        .totalPlayed
                                        .toString() ??
                                    "")),
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            // inter: false,
                            multilanguage: false,
                            maxline: 1,
                            fontweight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: gray,
                            text: "views",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            // inter: false,
                            multilanguage: true,
                            maxline: 1,
                            fontweight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget category(int sectionindex, int sectionId, List<Result>? sectionList) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: Dimens.categoryheight,
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(direction: Axis.vertical, runSpacing: -2, children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
                onTap: () {},
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                      foregroundDecoration: BoxDecoration(
                        color: colorAccent.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MyNetworkImage(
                            imgWidth: MediaQuery.of(context).size.width,
                            imgHeight: MediaQuery.of(context).size.height,
                            imageUrl: sectionList?[sectionindex]
                                    .data?[index]
                                    .portraitImg
                                    .toString() ??
                                "",
                            fit: BoxFit.fill),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 80,
                          child: MyText(
                              color: white,
                              multilanguage: false,
                              text: sectionList?[sectionindex]
                                      .data?[index]
                                      .title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textSmall,
                              fontsizeWeb: Dimens.textSmall,
                              // inter: false,
                              maxline: 2,
                              fontweight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ));
  }

  Widget language(int sectionindex, int sectionId, List<Result>? sectionList) {
    return Container(
      // color: gray,
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      height: Dimens.languageheight,
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: 3),
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              height: 45,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              alignment: Alignment.center,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [white, colorAccent.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                color: white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MyText(
                  color: white,
                  multilanguage: false,
                  text: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textSmall,
                  fontsizeWeb: Dimens.textSmall,
                  // inter: false,
                  maxline: 2,
                  fontweight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
          );
        },
      ),
    );
  }

/* Radio Layout */

  Widget round(int sectionindex, int sectionId, List<Result>? sectionList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.roundheight,
      child: ListView.separated(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        separatorBuilder: (context, index) => const SizedBox(width: 3),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // AdHelper.showFullscreenAd(context, Constant.rewardAdType, () {
              playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  podcastimage: sectionList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: MyNetworkImage(
                      imgWidth: 110,
                      imgHeight: 110,
                      fit: BoxFit.fill,
                      imageUrl: sectionList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: MyText(
                        color: white,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .artistName
                                .toString() ??
                            "",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textSmall,
                        fontsizeWeb: Dimens.textSmall,
                        // inter: false,
                        multilanguage: false,
                        maxline: 1,
                        fontweight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

/* Podcast */
  Widget bannerPodcast(
      int sectionindex, int sectionId, List<Result>? sectionList) {
    return Container(
      height: Dimens.podcastbannerheight,
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: CarouselSlider.builder(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        carouselController: bannerController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: true,
          autoPlay: false,
          autoPlayCurve: Curves.linear,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(seconds: 3),
          viewportFraction: 1.0,
          onPageChanged: (index, reason) async {},
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return InkWell(
            onTap: () {
              playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  podcastimage: sectionList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MyNetworkImage(
                      imgWidth: MediaQuery.of(context).size.width,
                      imgHeight: MediaQuery.of(context).size.height,
                      fit: BoxFit.fill,
                      imageUrl: sectionList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                    ),
                  ),
                  Positioned.fill(
                    left: 15,
                    right: 15,
                    bottom: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: sectionList?[sectionindex]
                                          .data?[index]
                                          .title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textTitle,
                                  fontsizeWeb: Dimens.textTitle,
                                  // inter: false,
                                  maxline: 1,
                                  fontweight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 5),
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .languageName
                                        .toString() ??
                                    "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textSmall,
                                fontsizeWeb: Dimens.textSmall,
                                // inter: false,
                                maxline: 1,
                                fontweight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                        MyImage(
                            width: 30, height: 30, imagePath: "ic_pause.png"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget landscapPodcast(
      int sectionindex, int sectionId, List<Result>? sectionList) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: Dimens.landscapPodcastheight,
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Wrap(direction: Axis.vertical, runSpacing: 0, children: [
            ...List.generate(
              sectionList?[sectionindex].data?.length ?? 0,
              (index) => InkWell(
                onTap: () {
                  playAudio(
                      playingType: sectionList?[sectionindex]
                              .data?[index]
                              .contentType
                              .toString() ??
                          "",
                      episodeid: sectionList?[sectionindex]
                              .data?[index]
                              .id
                              .toString() ??
                          "",
                      contentid: sectionList?[sectionindex]
                              .data?[index]
                              .id
                              .toString() ??
                          "",
                      position: index,
                      sectionBannerList: sectionList?[sectionindex].data ?? [],
                      contentName: sectionList?[sectionindex]
                              .data?[index]
                              .title
                              .toString() ??
                          "",
                      contentUserid: sectionList?[sectionindex]
                              .data?[index]
                              .id
                              .toString() ??
                          "",
                      podcastimage: sectionList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                      isBuy: "1",
                      sectionId: sectionId);
                },
                child: Container(
                  width: 210,
                  height: 170,
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MyNetworkImage(
                            imgWidth: MediaQuery.of(context).size.width,
                            imgHeight: 120,
                            imageUrl: sectionList?[sectionindex]
                                    .data?[index]
                                    .portraitImg
                                    .toString() ??
                                "",
                            fit: BoxFit.fill),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: MyText(
                              color: white,
                              multilanguage: false,
                              text: sectionList?[sectionindex]
                                      .data?[index]
                                      .title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textDesc,
                              fontsizeWeb: Dimens.textDesc,
                              // inter: false,
                              maxline: 1,
                              fontweight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ));
  }

  Widget listView(
      int sectionindex, int sectionId, List<Result>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length) == 1
          ? Dimens.heightMiniSeries / 3
          : (sectionDataList?.length) == 2
              ? Dimens.heightMiniSeries / 2
              : Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        crossAxisCount: (sectionDataList?.length ?? 0) > 4
            ? 4
            : (sectionDataList?.length ?? 0),
        itemCount: sectionDataList?[sectionindex].data?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              playAudio(
                  playingType: sectionDataList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid: sectionDataList?[sectionindex]
                          .data?[index]
                          .id
                          .toString() ??
                      "",
                  contentid: sectionDataList?[sectionindex]
                          .data?[index]
                          .id
                          .toString() ??
                      "",
                  position: index,
                  sectionBannerList: sectionDataList?[sectionindex].data ?? [],
                  contentName: sectionDataList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid: sectionDataList?[sectionindex]
                          .data?[index]
                          .id
                          .toString() ??
                      "",
                  podcastimage: sectionDataList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Container(
              height: Dimens.containerHeightMiniSeries,
              width: Dimens.webcontainerwidthMiniSeries,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(left: 10),
              color: appBgColor,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl: sectionDataList?[sectionindex]
                              .data?[index]
                              .portraitImg
                              .toString() ??
                          "",
                      fit: BoxFit.fill,
                      imgHeight: Dimens.imgheightMiniSeries,
                      imgWidth: Dimens.imgwidthMiniSeries,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        color: white,
                        text: sectionDataList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: 15,
                        fontweight: FontWeight.w600,
                        fontsizeWeb: 15,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          MyImage(
                            imagePath: "play.png",
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          MyText(
                            color: gray,
                            text:
                                "${formatNumber(sectionDataList?[sectionindex].data?[index].totalUserPlay?.toInt() ?? 0)} Play",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 15,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ],
                  ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget podcastListview(
      int sectionindex, int sectionId, List<Result>? sectionList) {
    return CarouselSlider.builder(
        itemCount: sectionList?[sectionindex].data?.length ?? 0,
        carouselController: bannerController,
        options: CarouselOptions(
          initialPage: 0,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: false,
          autoPlay: true,
          autoPlayCurve: Curves.linear,
          enableInfiniteScroll: true,
          viewportFraction: 1.0,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(seconds: 3),
          onPageChanged: (index, reason) async {},
        ),
        itemBuilder: (BuildContext context, int index, int pageViewIndex) {
          return InkWell(
            onTap: () {
              playAudio(
                  playingType: sectionList?[sectionindex]
                          .data?[index]
                          .contentType
                          .toString() ??
                      "",
                  episodeid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  contentid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  position: index,
                  sectionBannerList: sectionList?[sectionindex].data ?? [],
                  contentName: sectionList?[sectionindex]
                          .data?[index]
                          .title
                          .toString() ??
                      "",
                  contentUserid:
                      sectionList?[sectionindex].data?[index].id.toString() ??
                          "",
                  podcastimage: sectionList?[sectionindex]
                          .data?[index]
                          .portraitImg
                          .toString() ??
                      "",
                  isBuy: "1",
                  sectionId: sectionId);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorPrimaryDark,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MyNetworkImage(
                          imgWidth: 100,
                          imgHeight: 100,
                          imageUrl: sectionList?[sectionindex]
                                  .data?[index]
                                  .portraitImg
                                  .toString() ??
                              "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .title
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textExtraBig,
                                fontsizeWeb: Dimens.textExtraBig,
                                // inter: false,
                                maxline: 2,
                                fontweight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 8),
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: sectionList?[sectionindex]
                                        .data?[index]
                                        .description
                                        .toString() ??
                                    "",
                                textalign: TextAlign.left,
                                fontsizeNormal: Dimens.textMedium,
                                fontsizeWeb: Dimens.textMedium,
                                // inter: false,
                                maxline: 2,
                                fontweight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "episodes",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      // inter: false,
                      maxline: 2,
                      fontweight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 10),
                  ListView.builder(
                      itemCount: 1,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, position) {
                        episodeIndex = position;
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: MyNetworkImage(
                                    fit: BoxFit.fill,
                                    imgWidth: 55,
                                    imgHeight: 55,
                                    imageUrl: sectionList?[sectionindex]
                                            .data?[index]
                                            .portraitImg
                                            .toString() ??
                                        ""),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                        color: colorAccent,
                                        multilanguage: false,
                                        text: sectionList?[sectionindex]
                                                .data?[index]
                                                .name
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textTitle,
                                        fontsizeWeb: Dimens.textTitle,
                                        // inter: false,
                                        maxline: 1,
                                        fontweight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    const SizedBox(height: 8),
                                    MyText(
                                        color: white,
                                        multilanguage: false,
                                        text: sectionList?[sectionindex]
                                                .data?[index]
                                                .description
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: Dimens.textSmall,
                                        fontsizeWeb: Dimens.textSmall,
                                        // inter: false,
                                        maxline: 1,
                                        fontweight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  Align(
                      alignment: Alignment.centerRight,
                      child: MyImage(
                          width: 30, height: 30, imagePath: "ic_pause.png")),
                ],
              ),
            ),
          );
        });
  }

/* All Layout Common Shimmer */
  Widget commanShimmer() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.roundrectborder(height: 10, width: 150),
                  SizedBox(height: 5),
                  ShimmerWidget.roundrectborder(height: 10, width: 80),
                ],
              ),
              ShimmerWidget.roundrectborder(height: 10, width: 50),
            ],
          ),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.listviewLayoutheight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Wrap(direction: Axis.vertical, runSpacing: -2, children: [
                ...List.generate(
                  8,
                  (index) => Container(
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: 55,
                    margin: const EdgeInsets.fromLTRB(20, 7, 20, 7),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: const ShimmerWidget.roundrectborder(
                            width: 55,
                            height: 55,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.roundrectborder(
                              width: 120,
                              height: 8,
                            ),
                            SizedBox(height: 8),
                            ShimmerWidget.roundrectborder(
                              width: 120,
                              height: 8,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            )),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.roundrectborder(height: 10, width: 150),
                  SizedBox(height: 5),
                  ShimmerWidget.roundrectborder(height: 10, width: 80),
                ],
              ),
              ShimmerWidget.roundrectborder(height: 10, width: 50),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: Dimens.squareheight,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 3),
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShimmerWidget.roundrectborder(
                      width: 90,
                      height: 90,
                    ),
                    SizedBox(height: 5),
                    ShimmerWidget.roundrectborder(
                      width: 50,
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.roundrectborder(height: 10, width: 150),
                  SizedBox(height: 5),
                  ShimmerWidget.roundrectborder(height: 10, width: 80),
                ],
              ),
              ShimmerWidget.roundrectborder(height: 10, width: 50),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: Dimens.roundheight,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 3),
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShimmerWidget.circular(
                      width: 110,
                      height: 110,
                    ),
                    SizedBox(height: 5),
                    ShimmerWidget.roundrectborder(
                      width: 50,
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.getAddContentPlay(3, 0, 0, contentId);
  }

/* PlayAudio Player */
  Future<void> playAudio(
      {required String playingType,
      required String episodeid,
      required String contentid,
      String? podcastimage,
      String? contentUserid,
      required int position,
      required List<Datum>? sectionBannerList,
      dynamic playlistImages,
      required String contentName,
      required String? isBuy,
      required dynamic sectionId}) async {
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
      Constant.musicsectionId = sectionId.toString();
      musicManager.setInitialMusic(
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, contentid),
          false,
          0,
          isBuy ?? "",
          1,
          "music",
          "0");
    } else {
      Utils.buildWebAlertDialog(context, "login", "");
    }
  }
}

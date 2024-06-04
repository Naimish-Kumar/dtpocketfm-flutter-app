import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/seallprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../model/episodebycontentmodel.dart';

class WebMusicViewAll extends StatefulWidget {
  final String? title, contentType, sectionId, screenLayout;
  final bool isRent;
  const WebMusicViewAll(
      {super.key,
      required this.title,
      required this.isRent,
      this.contentType,
      required this.sectionId,
      required this.screenLayout});

  @override
  State<WebMusicViewAll> createState() => _WebMusicViewAllState();
}

class _WebMusicViewAllState extends State<WebMusicViewAll> {
  late SeeAllProvider seeAllProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    seeAllProvider = Provider.of<SeeAllProvider>(context, listen: false);

    _sectionDetailMusic(0);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      await seeAllProvider.setSeeAllLoadMore(true);

      if ((seeAllProvider.sectiondatacurrentPage ?? 0) <
          (seeAllProvider.sectiondatatotalPage ?? 0)) {
        debugPrint("load more Music====>");
        _sectionDetailMusic(seeAllProvider.sectiondatacurrentPage ?? 0);
      }
    }
  }

  Future<void> _sectionDetailMusic(int? nextPage) async {
    debugPrint("isMorePage  ======> ${seeAllProvider.sectiondataisMorePage}");
    debugPrint("currentPage ======> ${seeAllProvider.sectiondatacurrentPage}");
    debugPrint("totalPage   ======> ${seeAllProvider.sectiondatatotalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await seeAllProvider.getSeactionDetail(
        widget.sectionId, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    seeAllProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: appBgColor,
            appBar: Utils.myAppBarWithBack(
                context, widget.title ?? "", false, false),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.65,
                      ),
                      child: buildItem()),
                  const FooterWeb()
                ],
              ),
            ),
          ),
        ),
        Utils.buildMusicPanel(context),
      ],
    );
  }

  Widget buildItem() {
    return Consumer<SeeAllProvider>(
        builder: (context, sectiondataprovider, child) {
      if (sectiondataprovider.loading && !sectiondataprovider.seeallLoadMore) {
        return buildShimmer();
      } else {
        if (sectiondataprovider.musicSeeAllModel.status == 200 &&
            sectiondataprovider.sectionDataList != null) {
          if ((sectiondataprovider.sectionDataList?.length ?? 0) > 0) {
            return SafeArea(
              child: Column(
                children: [
                  if (widget.screenLayout == "grid_view")
                    Consumer<SeeAllProvider>(
                      builder: (context, seeAllProvider, child) {
                        return _landscapeGridView(
                            sectiondataprovider.sectionDataList);
                      },
                    ),
                  if (widget.screenLayout == "list_view")
                    Consumer<SeeAllProvider>(
                      builder: (context, seeAllProvider, child) {
                        return gridView(sectiondataprovider.sectionDataList);
                      },
                    ),
                  if (widget.screenLayout == "square")
                    Consumer<SeeAllProvider>(
                      builder: (context, seeAllProvider, child) {
                        return square(sectiondataprovider.sectionDataList);
                      },
                    ),
                  if (widget.screenLayout == "portrait")
                    Consumer<SeeAllProvider>(
                      builder: (context, seeAllProvider, child) {
                        return portrait(sectiondataprovider.sectionDataList);
                      },
                    ),
                  Consumer<SeeAllProvider>(
                    builder: (context, seeAllProvider, child) {
                      if (seeAllProvider.loadMore) {
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
            );
          } else {
            return const NoData(title: "nodata", subTitle: "");
          }
        } else {
          return const NoData(title: "nodata", subTitle: "");
        }
      }
    });
  }

  Widget setLayout(index, sectionDataList) {
    return _landscapeGridView(sectionDataList);
  }

  int setListCount() {
    if (widget.contentType == "1") {
      return 1;
    } else if (widget.contentType == "2") {
      return 2;
    } else if (widget.contentType == "3") {
      return 3;
    } else if (widget.contentType == "4") {
      return 2;
    } else {
      return 0;
    }
  }

  Widget gridView(List<Result>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.containerwidthMiniSeries,
        verticalGridSpacing: 10,
        horizontalGridSpacing: 10,
        minItemsPerRow: 1,
        maxItemsPerRow: 2,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (sectionDataList?.length ?? 0),
          (index) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                debugPrint("Clicked on index ==> $index");
                playAudio(
                  playingType:
                      sectionDataList?[index].contentType.toString() ?? "",
                  episodeid: sectionDataList?[index].id.toString() ?? "",
                  contentid: sectionDataList?[index].id.toString() ?? "",
                  position: index,
                  sectionBannerList: sectionDataList ?? [],
                  contentName: sectionDataList?[index].title.toString() ?? "",
                  isBuy: sectionDataList?[index].isBuy.toString() ?? "",
                );
              },
              child: Container(
                height: Dimens.containerHeightMiniSeries,
                width: Dimens.containerwidthMiniSeries,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.only(left: 10),
                color: appBgColor,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].portraitImg.toString() ??
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
                          text: sectionDataList?[index].title.toString() ?? "",
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
                                  "${formatNumber(sectionDataList?[index].totalAudioPlayed ?? 0)} Play",
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
      ),
    );
  }

  Widget portrait(List<Result>? sectionDataList) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthPort * 1.4,
        verticalGridSpacing: 10,
        horizontalGridSpacing: 10,
        minItemsPerRow: 2,
        maxItemsPerRow: 9,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (sectionDataList?.length ?? 0),
          (index) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                debugPrint("Clicked on index ==> $index");
                playAudio(
                  playingType:
                      sectionDataList?[index].contentType.toString() ?? "",
                  episodeid: sectionDataList?[index].id.toString() ?? "",
                  contentid: sectionDataList?[index].id.toString() ?? "",
                  position: index,
                  sectionBannerList: sectionDataList ?? [],
                  contentName: sectionDataList?[index].title.toString() ?? "",
                  isBuy: sectionDataList?[index].isBuy.toString() ?? "",
                );
              },
              child: SizedBox(
                width: Dimens.widthPort,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Dimens.viewallwidthPort,
                      height: Dimens.viewallheightPort,
                      padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].portraitImg.toString() ??
                                  "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: white,
                      text: sectionDataList?[index].title.toString() ?? "",
                      textalign: TextAlign.start,
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget square(List<Result>? sectionDataList) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthSquare * 1.4,
        verticalGridSpacing: 10,
        horizontalGridSpacing: 10,
        minItemsPerRow: 2,
        maxItemsPerRow: 9,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          sectionDataList?.length ?? 0,
          (index) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                playAudio(
                  playingType:
                      sectionDataList?[index].contentType.toString() ?? "",
                  episodeid: sectionDataList?[index].id.toString() ?? "",
                  contentid: sectionDataList?[index].id.toString() ?? "",
                  position: index,
                  sectionBannerList: sectionDataList ?? [],
                  contentName: sectionDataList?[index].title.toString() ?? "",
                  isBuy: sectionDataList?[index].isBuy.toString() ?? "",
                );
              },
              child: Column(
                children: [
                  Container(
                    width: Dimens.widthSquare,
                    height: Dimens.heightSquare,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].portraitImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.start,
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
            );
          },
        ),
      ),
    );
  }

  Widget _landscapeGridView(List<Result>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.imgwidthcontempory,
        minItemsPerRow: 1,
        maxItemsPerRow: 6,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(sectionDataList?.length ?? 0, (index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              playAudio(
                playingType:
                    sectionDataList?[index].contentType.toString() ?? "",
                episodeid: sectionDataList?[index].id.toString() ?? "",
                contentid: sectionDataList?[index].id.toString() ?? "",
                position: index,
                sectionBannerList: sectionDataList ?? [],
                contentName: sectionDataList?[index].title.toString() ?? "",
                isBuy: sectionDataList?[index].isBuy.toString() ?? "",
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              width: Dimens.imgwidthcontempory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].landscapeImg.toString() ?? "",
                      fit: BoxFit.fill,
                      imgHeight: Dimens.imgheightcontempory,
                      imgWidth: Dimens.imgwidthcontempory,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
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
                    height: 5,
                  ),
                  MyText(
                    color: primaryDark,
                    text:
                        "${formatNumber(sectionDataList?[index].totalAudioPlayed ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 13,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

/* All Shimmer */
  Widget buildShimmer() {
    if ((widget.screenLayout ?? "").isNotEmpty) {
      if (widget.screenLayout == "grid_view") {
        return landscapeListViewShimmer();
      } else if (widget.screenLayout == "list_view") {
        return gridViewShimmer();
      } else if (widget.screenLayout == "square") {
        return squareShimmer();
      } else if (widget.screenLayout == "portrait") {
        return portraitListViewShimmer();
      } else {
        return landscapeListViewShimmer();
      }
    } else {
      return landscapeListViewShimmer();
    }
  }

  setShimmer() {
    return buildMusicShimmer();
  }

  Widget buildMusicShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      height: 55,
      child: const Row(
        children: [
          ShimmerWidget.roundrectborder(
            width: 55,
            height: 55,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.roundrectborder(
                  width: 200,
                  height: 8,
                ),
                SizedBox(height: 8),
                ShimmerWidget.roundrectborder(
                  width: 200,
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadioShimmer() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerWidget.circular(
            width: 90,
            height: 90,
          ),
          SizedBox(height: 10),
          ShimmerWidget.roundrectborder(
            width: 80,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildPodcastShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerWidget.roundrectborder(
            width: MediaQuery.of(context).size.width,
            height: 100,
          ),
          const SizedBox(height: 10),
          const ShimmerWidget.roundrectborder(
            width: 100,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget buildPlaylistShimmer() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerWidget.rectangular(height: 150, width: 160),
          SizedBox(height: 10),
          ShimmerWidget.roundrectborder(height: 8, width: 140),
        ],
      ),
    );
  }

  Widget portraitListViewShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthPort * 1.4,
        verticalGridSpacing: 10,
        horizontalGridSpacing: 10,
        minItemsPerRow: 2,
        maxItemsPerRow: 9,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          20,
          (index) {
            return SizedBox(
              width: Dimens.widthPort,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Dimens.viewallwidthPort,
                    height: Dimens.viewallheightPort,
                    padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                    alignment: Alignment.center,
                    child: ShimmerWidget.roundcorner(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const ShimmerWidget.roundcorner(
                    height: 15,
                    width: 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget landscapeListViewShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.imgwidthcontempory,
        minItemsPerRow: 1,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.all(10),
            width: Dimens.imgwidthcontempory,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.roundcorner(
                  height: Dimens.imgheightcontempory,
                  width: Dimens.imgwidthcontempory,
                ),
                const SizedBox(
                  height: 5,
                ),
                const ShimmerWidget.roundcorner(
                  height: 15,
                  width: 70,
                ),
                const SizedBox(
                  height: 5,
                ),
                const ShimmerWidget.roundcorner(
                  height: 15,
                  width: 70,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget squareShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthSquare * 1.4,
        verticalGridSpacing: 10,
        horizontalGridSpacing: 10,
        minItemsPerRow: 2,
        maxItemsPerRow: 9,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          25,
          (index) {
            return Container(
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ShimmerWidget.roundcorner(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget gridViewShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ResponsiveGridList(
        minItemWidth: Dimens.containerwidthMiniSeries,
        verticalGridSpacing: 10,
        horizontalGridSpacing: 10,
        minItemsPerRow: 1,
        maxItemsPerRow: 2,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          20,
          (index) {
            return Container(
              height: Dimens.containerHeightMiniSeries,
              width: Dimens.containerwidthMiniSeries,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(left: 10),
              color: appBgColor,
              child: Row(
                children: [
                  ShimmerWidget.roundcorner(
                    height: Dimens.imgheightMiniSeries,
                    width: Dimens.imgwidthMiniSeries,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerWidget.roundcorner(
                        height: 15,
                        width: 80,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          ShimmerWidget.circular(
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          ShimmerWidget.roundcorner(
                            height: 15,
                            width: 60,
                          )
                        ],
                      ),
                    ],
                  ))
                ],
              ),
            );
          },
        ),
      ),
    );
  }

/* Open Pages */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    dynamic sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
  }) async {
    if (Constant.userID == null) {
      if (kIsWeb) {
        Utils.buildWebAlertDialog(context, "login", "");
      } else {
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
    } else {
      debugPrint("Enter===>");
      /* Play Music */

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
    }
  }

  addView(contentType, contentId) async {
    final audiototalplayprovider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(3, 0, 0, contentId);
  }
}

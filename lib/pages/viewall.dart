import 'package:dtpocketfm/provider/seallprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ViewAll extends StatefulWidget {
  final String? title, screenLayout;
  final int? sectionId;
  const ViewAll(
      {super.key,
      required this.title,
      required this.sectionId,
      required this.screenLayout});

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  late SeeAllProvider seeAllProvider;
  late ScrollController _scrollController;
  @override
  void initState() {
    seeAllProvider = Provider.of<SeeAllProvider>(context, listen: false);
    debugPrint("screenLayout == ${widget.screenLayout}");
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  Future<void> _fetchData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${seeAllProvider.isMorePage}");
    debugPrint("currentPage ======> ${seeAllProvider.currentPage}");
    debugPrint("totalPage   ======> ${seeAllProvider.totalPage}");

    await seeAllProvider.getSeeAllData(widget.sectionId, (nextPage ?? 0) + 1);

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (seeAllProvider.currentPage ?? 0) < (seeAllProvider.totalPage ?? 0)) {
      seeAllProvider.setLoadMore(true);
      _fetchData(seeAllProvider.currentPage ?? 0);
    }
  }

  @override
  void dispose() {
    seeAllProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkappbgcolor,
      appBar: Utils.myAppBarWithBack(context, widget.title ?? "", false, false),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 15, bottom: Dimens.bottomAdPadding),
        child: _buildPage(),
      ),
    );
  }

  _buildPage() {
    if (seeAllProvider.isLoading) {
      if ((widget.screenLayout ?? "").isNotEmpty) {
        if (widget.screenLayout == "landscape") {
          return landscapeListViewShimmer();
        } else if (widget.screenLayout == "big_square") {
          return bigSquareShimmer();
        } else if (widget.screenLayout == "details_square") {
          return detailsSquareShimmer();
        } else if (widget.screenLayout == "grid_view") {
          return gridViewShimmer();
        } else if (widget.screenLayout == "list_view") {
          return verticalGridShimmer();
        } else if (widget.screenLayout == "square") {
          return squareShimmer();
        } else if (widget.screenLayout == "small_square") {
          return smallSquareShimmer();
        } else if (widget.screenLayout == "portrait") {
          return portraitListViewShimmer();
        } else {
          return landscapeListViewShimmer();
        }
      }
    } else {
      return SafeArea(
        child: Column(
          children: [
            if (widget.screenLayout == "landscape")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return _landscapeGridView();
                },
              ),
            if (widget.screenLayout == "details_square")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return detailsSquare();
                },
              ),
            if (widget.screenLayout == "big_square")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return bigSquare();
                },
              ),
            if (widget.screenLayout == "grid_view")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return gridView();
                },
              ),
            if (widget.screenLayout == "list_view")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return listViw();
                },
              ),
            if (widget.screenLayout == "square")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return square();
                },
              ),
            if (widget.screenLayout == "small_square")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return continueWatchingSmallSquare();
                },
              ),
            if (widget.screenLayout == "portrait")
              Consumer<SeeAllProvider>(
                builder: (context, seeAllProvider, child) {
                  return portrait();
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
    }
  }

  Widget portrait() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 10),
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                // (sectionDataList?[index].videoType ?? 0) == 2
                // ?
                "showdetail",
                // : "videodetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
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
                        imageUrl: seeAllProvider.contentList?[index].portraitImg
                                .toString() ??
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
                    text: seeAllProvider.contentList?[index].title.toString() ??
                        "",
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
    );
  }

  Widget continueWatchingSmallSquare() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightContiLandList,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: (seeAllProvider.contentList?.length ?? 0),
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  InkWell(
                    focusColor: white,
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      debugPrint("Clicked on index ==> $index");
                      openDetailPage(
                        "showdetail",
                        // : "videodetail",
                        seeAllProvider.contentList?[index].id ?? 0,
                        seeAllProvider.contentList?[index].contentType ?? 0,
                      );
                    },
                    child: Container(
                      width: Dimens.viewallwidthContiLand,
                      height: Dimens.viewallheightContiLand,
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              seeAllProvider.contentList?[index].landscapeImg ??
                                  "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            // openPlayer("ContinueWatch", index,
                            //     continueWatchingList);
                          },
                          child: MyImage(
                            width: 30,
                            height: 30,
                            imagePath: "play.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              MyText(
                color: white,
                multilanguage: false,
                text: ((seeAllProvider.contentList?[index].title ?? "").isEmpty)
                    ? (seeAllProvider.contentList?[index].title.toString() ??
                        "")
                    : seeAllProvider.contentList?[index].title.toString() ?? "",
                textalign: TextAlign.left,
                fontsizeNormal: 11,
                fontweight: FontWeight.w600,
                fontsizeWeb: 10,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(
                height: 5,
              ),
              MyText(
                color: gray,
                multilanguage: false,
                text:
                    "${formatNumber(seeAllProvider.contentList?[index].totalUserPlay ?? 0)} Play",
                textalign: TextAlign.left,
                fontsizeNormal: 11,
                fontweight: FontWeight.w600,
                fontsizeWeb: 10,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget square() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: seeAllProvider.contentList?[index].portraitImg
                          .toString() ??
                      "",
                  fit: BoxFit.fill,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bigSquare() {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightbestSellingStries,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: Dimens.imgwidthcontempory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl: seeAllProvider.contentList?[index].landscapeImg
                              .toString() ??
                          "",
                      fit: BoxFit.fill,
                      imgHeight: Dimens.imgheightbestSellingStories,
                      imgWidth: Dimens.imgwidthbestSellingStories,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: white,
                    text: seeAllProvider.contentList?[index].title.toString() ??
                        "",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w500,
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
                    color: gray,
                    text:
                        "${formatNumber(seeAllProvider.contentList?[index].totalUserPlay ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget detailsSquare() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: Dimens.newreleaseContainerheight,
      child: ListView.separated(
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.vertical,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl: seeAllProvider.contentList?[index].landscapeImg
                            .toString() ??
                        "",
                    fit: BoxFit.fill,
                    imgHeight: Dimens.newreleaseimgwidth,
                    imgWidth: Dimens.newreleaseimgheight,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text:
                          seeAllProvider.contentList?[index].title.toString() ??
                              "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 16,
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
                          color: gray,
                          imagePath: "ic_play.png",
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        MyText(
                          color: gray,
                          text:
                              "${formatNumber(seeAllProvider.contentList?[index].totalUserPlay ?? 0)} Play",
                          textalign: TextAlign.left,
                          fontsizeNormal: 14,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 15,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const Spacer(),
                        Container(
                          height: 26,
                          width: 70,
                          decoration: const BoxDecoration(
                              color: colorPrimary,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              MyImage(
                                imagePath: "Star.png",
                                height: 18,
                                width: 18,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: MyText(
                                  color: brown,
                                  text: seeAllProvider
                                          .contentList?[index].avgRating
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: 12,
                                  fontweight: FontWeight.w600,
                                  fontsizeWeb: 15,
                                  multilanguage: false,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: white,
                      text: seeAllProvider.contentList?[index].description
                              .toString() ??
                          "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w400,
                      fontsizeWeb: 15,
                      multilanguage: false,
                      maxline: 3,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ))
              ],
            ),
          );
        },
      ),
    );
  }

  Widget gridView() {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 1,
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
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
                      imageUrl: seeAllProvider.contentList?[index].landscapeImg
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
                        text: seeAllProvider.contentList?[index].title
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
                                "${formatNumber(seeAllProvider.contentList?[index].totalUserPlay ?? 0)} Play",
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

  Widget listViw() {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(10),
        crossAxisCount: 2,
        itemCount: seeAllProvider.contentList?.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Stack(children: [
                RotationTransition(
                  alignment: Alignment.bottomCenter,
                  turns: const AlwaysStoppedAnimation(12 / 360),
                  child: Container(
                    width: Dimens.top10imgwidth,
                    height: MediaQuery.of(context).size.height * 0.17,
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: lightappbgcolor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(7),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl: seeAllProvider
                                .contentList?[index].landscapeImg
                                .toString() ??
                            "",
                        fit: BoxFit.fill,
                        imgHeight: Dimens.top10imgHeight,
                        imgWidth: Dimens.top10imgwidth,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  top: 10,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 40,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = primaryDark,
                        ),
                      ),
                      Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _landscapeGridView() {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                seeAllProvider.contentList?[index].id ?? 0,
                seeAllProvider.contentList?[index].contentType ?? 0,
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
                      imageUrl: seeAllProvider.contentList?[index].landscapeImg
                              .toString() ??
                          "",
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
                    text: seeAllProvider.contentList?[index].title.toString() ??
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
                    height: 5,
                  ),
                  MyText(
                    color: primaryDark,
                    text:
                        "${formatNumber(seeAllProvider.contentList?[index].totalUserPlay ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget landscapeListViewShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
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
        },
      ),
    );
  }

  Widget verticalGridShimmer() {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 2,
        itemCount: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(10),
            child: Stack(children: [
              RotationTransition(
                alignment: Alignment.bottomCenter,
                turns: const AlwaysStoppedAnimation(12 / 360),
                child: Container(
                  width: Dimens.top10imgwidth,
                  height: MediaQuery.of(context).size.height * 0.17,
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: lightappbgcolor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: ShimmerWidget.roundcorner(
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        height: Dimens.top10imgHeight,
                        width: Dimens.top10imgwidth,
                      )),
                ),
              ),
              Positioned(
                left: 15,
                top: 10,
                child: Stack(
                  children: <Widget>[
                    Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 40,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = gray,
                      ),
                    ),
                    Text(
                      (index + 1).toString(),
                      style: const TextStyle(
                        fontSize: 40,
                        color: white,
                      ),
                    ),
                  ],
                ),
              )
            ]),
          );
        },
      ),
    );
  }

  Widget bigSquareShimmer() {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightbestSellingStries,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: Dimens.imgwidthcontempory,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.roundcorner(
                  shapeBorder: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  height: Dimens.imgheightbestSellingStories,
                  width: Dimens.imgwidthbestSellingStories,
                ),
                const SizedBox(
                  height: 5,
                ),
                const ShimmerWidget.roundcorner(
                  height: 15,
                  width: 75,
                ),
                const SizedBox(
                  height: 5,
                ),
                const ShimmerWidget.roundcorner(
                  height: 15,
                  width: 75,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget smallSquareShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightContiLandList,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: 6,
        shrinkWrap: true,
        padding:
            const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
        scrollDirection: Axis.vertical,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Container(
                    width: Dimens.viewallwidthContiLand,
                    height: Dimens.viewallheightContiLand,
                    alignment: Alignment.center,
                    child: ShimmerWidget.roundcorner(
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {},
                          child: const ShimmerWidget.circular(
                            shimmerBgColor: black,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ShimmerWidget.roundcorner(
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 15,
                width: 45,
              ),
              const SizedBox(
                height: 5,
              ),
              ShimmerWidget.roundcorner(
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 15,
                width: 45,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget portraitListViewShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: 6,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.vertical,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (BuildContext context, int index) {
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
    );
  }

  Widget squareShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: seeAllProvider.contentList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemBuilder: (BuildContext context, int index) {
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
    );
  }

  Widget gridViewShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisCount: 1,
        itemCount: 15,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
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
    );
  }

  Widget detailsSquareShimmer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: [
              ShimmerWidget.roundcorner(
                height: Dimens.newreleaseimgwidth,
                width: Dimens.newreleaseimgwidth,
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
          );
        },
      ),
    );
  }

  openDetailPage(
    String pageName,
    int videoId,
    int videoType,
  ) async {
    debugPrint("pageName =======> $pageName");
    debugPrint("videoId ========> $videoId");

    debugPrint("videoType ======> $videoType");
    if (pageName != "" && (kIsWeb || Constant.isTV)) {
      // await setSelectedTab(-1);
    }
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      videoType: videoType,
    );
  }
}

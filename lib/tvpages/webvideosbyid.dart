import 'dart:async';

import 'package:dtpocketfm/pages/home.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:dtpocketfm/provider/videobyidprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebVideosByID extends StatefulWidget {
  final String appBarTitle, layoutType;
  final int itemID, typeId;
  const WebVideosByID(
    this.itemID,
    this.typeId,
    this.appBarTitle,
    this.layoutType, {
    super.key,
  });

  @override
  State<WebVideosByID> createState() => WebVideosByIDState();
}

class WebVideosByIDState extends State<WebVideosByID> {
  HomeState? homeStateObject;
  late ScrollController _scrollController;
  late VideoByIDProvider videoByIDProvider;

  @override
  void initState() {
    homeStateObject = context.findAncestorStateOfType<HomeState>();
    videoByIDProvider = Provider.of<VideoByIDProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _getData();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      debugPrint("AudioData Scroll Listner");
      if (widget.layoutType == "ByCategory") {
        if ((videoByIDProvider.currentPage ?? 0) <
            (videoByIDProvider.totalPage ?? 0)) {
          videoByIDProvider.setLoadMore(true);
          await fetchVideoByCategory((videoByIDProvider.currentPage ?? 0));
        }
      } else if (widget.layoutType == "ByLanguage") {
        if ((videoByIDProvider.currentPage ?? 0) <
            (videoByIDProvider.totalPage ?? 0)) {
          videoByIDProvider.setLoadMore(true);
          await fetchVideoByLanguage((videoByIDProvider.currentPage ?? 0));
        }
      }
    }
  }

  Future<void> fetchVideoByCategory(int? nextPage) async {
    await videoByIDProvider.getVideoByCategory(
      widget.itemID,
      widget.typeId,
      (nextPage ?? 0) + 1,
    );
  }

  Future<void> fetchVideoByLanguage(int? nextPage) async {
    await videoByIDProvider.getVideoByLanguage(
      widget.itemID,
      widget.typeId,
      (nextPage ?? 0) + 1,
    );
  }

 
  _getData() async {
    if (widget.layoutType == "ByCategory") {
      await fetchVideoByCategory(0);
    } else if (widget.layoutType == "ByLanguage") {
      await fetchVideoByLanguage(0);
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });

    if (videoByIDProvider.isMorePage == true) {
      if (widget.layoutType == "ByCategory") {
        if ((videoByIDProvider.currentPage ?? 0) <
            (videoByIDProvider.totalPage ?? 0)) {
          videoByIDProvider.setLoadMore(true);
          await fetchVideoByCategory((videoByIDProvider.currentPage ?? 0));
        }
      } else if (widget.layoutType == "ByLanguage") {
        if ((videoByIDProvider.currentPage ?? 0) <
            (videoByIDProvider.totalPage ?? 0)) {
          videoByIDProvider.setLoadMore(true);
          await fetchVideoByLanguage((videoByIDProvider.currentPage ?? 0));
        }
      }
    }
  }

  @override
  void dispose() {
    videoByIDProvider.clearVideoByIDProvider();
    super.dispose();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  @override
  Widget build(BuildContext context) {
    final videoByIDProvider =
        Provider.of<VideoByIDProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(context, widget.appBarTitle, false, false),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.65),
                child: videoByIDProvider.loading
                    ? ShimmerUtils.responsiveGrid(
                        context,
                        Dimens.heightLand,
                        Dimens.widthLand,
                        2,
                        (kIsWeb || Constant.isTV) ? 40 : 20)
                    : (videoByIDProvider.videoByIdModel.status == 200 &&
                            videoByIDProvider.videoByIdModel.result != null)
                        ? (videoByIDProvider.videoDataList?.length ?? 0) > 0
                            ? _buildVideoItem()
                            : const NoData(title: 'nodata', subTitle: '')
                        : const NoData(title: 'nodata', subTitle: ''),
              ),
              Consumer<VideoByIDProvider>(
                builder: (context, videoByIDProvider, child) {
                  if (videoByIDProvider.loadMore) {
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
              const SizedBox(height: 20),
              const FooterWeb()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthLand,
        verticalGridSpacing: 8,
        horizontalGridSpacing: 8,
        minItemsPerRow: 2,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (videoByIDProvider.videoDataList?.length ?? 0),
          (position) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                focusColor: white,
                onTap: () {
                  Utils.openDetails(
                    context: context,
                    videoId: videoByIDProvider.videoDataList?[position].id ?? 0,
                    // upcomingType: 0,
                    videoType: videoByIDProvider
                            .videoDataList?[position].contentType ??
                        0,
                    // typeId: videoByIDProvider
                    //         .videoByIdModel.result?[position].contentType ??
                    //     0,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Dimens.widthLand,
                        height: Dimens.heightLand,
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: MyNetworkImage(
                            imageUrl: videoByIDProvider
                                    .videoDataList?[position].landscapeImg
                                    .toString() ??
                                "",
                            fit: BoxFit.fill,
                            imgHeight: MediaQuery.of(context).size.height,
                            imgWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005,
                      ),
                      MyText(
                          color: primaryDark,
                          maxline: 1,
                          fontsizeNormal: 15,
                          fontsizeWeb: 13,
                          text: videoByIDProvider.videoDataList?[position].title
                                  .toString() ??
                              ""),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005,
                      ),
                      MyText(
                          color: white,
                          maxline: 1,
                          fontsizeNormal: 15,
                          fontsizeWeb: 12,
                          text:
                              "${formatNumber(videoByIDProvider.videoDataList?[position].totalUserPlay ?? 0)} Played")
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

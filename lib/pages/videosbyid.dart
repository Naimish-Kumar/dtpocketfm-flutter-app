import 'dart:async';

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

class VideosByID extends StatefulWidget {
  final String appBarTitle, layoutType;
  final int itemID, typeId;
  const VideosByID(
    this.itemID,
    this.typeId,
    this.appBarTitle,
    this.layoutType, {
    super.key,
  });

  @override
  State<VideosByID> createState() => VideosByIDState();
}

class VideosByIDState extends State<VideosByID> {
  late VideoByIDProvider videoByIDProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
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

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _getData() async {
    if (widget.layoutType == "ByCategory") {
      await fetchVideoByCategory(0);
      // await videoByIDProvider.getVideoByCategory(widget.itemID, widget.typeId);
    } else if (widget.layoutType == "ByLanguage") {
      await fetchVideoByLanguage(0);
      // await videoByIDProvider.getVideoByLanguage(widget.itemID, 1);
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    videoByIDProvider.clearVideoByIDProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appBgColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Utils.myAppBarWithBack(context, widget.appBarTitle, true, false),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: const BoxConstraints.expand(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        videoByIDProvider.loading
                            ? ShimmerUtils.responsiveGrid(
                                context,
                                Dimens.heightLand,
                                Dimens.widthLand,
                                2,
                                kIsWeb ? 40 : 20)
                            : Consumer<VideoByIDProvider>(
                                builder: (context, artistProvider, child) {
                                  return (videoByIDProvider
                                              .videoByIdModel.status ==
                                          200)
                                      ? (videoByIDProvider
                                                      .videoDataList?.length ??
                                                  0) >
                                              0
                                          ? _buildVideoItem()
                                          : const NoData(
                                              title: 'nodata',
                                              subTitle: 'nodata',
                                            )
                                      : const NoData(
                                          title: 'nodata',
                                          subTitle: '',
                                        );
                                },
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

                        /* Web Footer */
                        (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
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
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget _buildVideoItem() {
    return RefreshIndicator(
      backgroundColor: white,
      color: complimentryColor,
      displacement: 80,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          videoByIDProvider.setLoading(true);
          Future.delayed(Duration.zero).then((value) {
            if (!mounted) return;
            setState(() {});
          });
          _getData();
        });
      },
      child: Container(
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
              return InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on position ==> $position");
                  Utils.openDetails(
                    context: context,
                    videoId: videoByIDProvider.videoDataList?[position].id ?? 0,
                    // upcomingType: 0,
                    videoType: videoByIDProvider
                            .videoDataList?[position].contentType ??
                        0,
                  );
                },
                child: SizedBox(
                  width: Dimens.widthLand,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl: videoByIDProvider
                                  .videoDataList?[position].landscapeImg
                                  .toString() ??
                              "",
                          fit: BoxFit.fill,
                          imgHeight: 150,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MyText(
                        color: white,
                        text: videoByIDProvider.videoDataList?[position].title
                                .toString() ??
                            "",
                        fontsizeNormal: 15,
                        fontweight: FontWeight.w600,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MyText(
                        color: primaryDark,
                        text:
                            "${formatNumber(videoByIDProvider.videoDataList?[position].totalUserPlay ?? 0)} Play",
                        fontsizeNormal: 14,
                        fontweight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  openDetailPage(String pageName, int videoId, int upcomingType, int videoType,
      int typeId) async {
    debugPrint("pageName =======> $pageName");
    debugPrint("videoId ========> $videoId");
    debugPrint("upcomingType ===> $upcomingType");
    debugPrint("videoType ======> $videoType");
    debugPrint("typeId =========> $typeId");
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

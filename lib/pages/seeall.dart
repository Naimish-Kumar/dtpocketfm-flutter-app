import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/seallprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../model/episodebycontentmodel.dart';

class SeeAll extends StatefulWidget {
  final String? title, contentType, sectionId;
  final bool isRent;
  const SeeAll({
    super.key,
    required this.title,
    required this.isRent,
    this.contentType,
    required this.sectionId,
  });

  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  // final MusicManager musicManager = MusicManager();
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
            appBar: Utils()
                .otherPageAppBar(context, widget.title.toString(), false),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: buildItem(),
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
            return Column(
              children: [
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: ResponsiveGridList(
                      minItemWidth: 120,
                      // minItemsPerRow: setListCount(),
                      maxItemsPerRow: 1,
                      horizontalGridSpacing: 10,
                      verticalGridSpacing: 50,
                      listViewBuilderOptions: ListViewBuilderOptions(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                      ),
                      children: List.generate(
                          sectiondataprovider.sectionDataList?.length ?? 0,
                          (index) {
                        return setLayout(
                            index, sectiondataprovider.sectionDataList);
                      }),
                    ),
                  ),
                ),
                if (seeAllProvider.seeallLoadMore)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                    child: Utils.pageLoader(),
                  )
                else
                  const SizedBox.shrink(),
              ],
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

/* ContentType = 1 = Music */
/* ContentType = 2 = Podcast */
/* ContentType = 3 = Radio */
/* ContentType = 4 = Playlist */

  Widget setLayout(index, sectionDataList) {
    return buildMusic(index, sectionDataList);
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

/* Music Layout */
  Widget buildMusic(int index, List<Result>? sectionDataList) {
    return InkWell(
      onTap: () {
        playAudio(
          playingType: sectionDataList?[index].contentType.toString() ?? "",
          episodeid: sectionDataList?[index].id.toString() ?? "",
          contentid: sectionDataList?[index].id.toString() ?? "",
          position: index,
          sectionBannerList: sectionDataList ?? [],
          contentName: sectionDataList?[index].title.toString() ?? "",
          isBuy: sectionDataList?[index].isBuy.toString() ?? "",
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.70,
        height: 70,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyNetworkImage(
                  fit: BoxFit.fill,
                  imgWidth: 55,
                  imgHeight: 55,
                  imageUrl:
                      sectionDataList?[index].portraitImg.toString() ?? ""),
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
                      text: sectionDataList?[index].title.toString() ?? "",
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
                      text:
                          sectionDataList?[index].description.toString() ?? "",
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
      ),
    );
  }

/* All Shimmer */
  Widget buildShimmer() {
    return Column(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ResponsiveGridList(
              minItemWidth: 120,
              // minItemsPerRow: setListCount(),
              maxItemsPerRow: 1,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
              ),
              children: List.generate(10, (index) {
                return buildMusicShimmer();
              }),
            ),
          ),
        ),
        if (seeAllProvider.seeallLoadMore)
          Container(
            height: 50,
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
            child: Utils.pageLoader(),
          )
        else
          const SizedBox.shrink(),
      ],
    );
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

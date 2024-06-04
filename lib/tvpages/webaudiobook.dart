import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/model/audiosectionlistmodel.dart' as list;
import 'package:dtpocketfm/model/sectionbannermodel.dart' as banner;
import 'package:dtpocketfm/model/genresmodel.dart' as type;
import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/provider/audiosectiondataprovider.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/tvpages/webvideosbyid.dart';
import 'package:dtpocketfm/tvpages/webviewall.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/audiosectionlistmodel.dart';

class WebAudioBook extends StatefulWidget {
  const WebAudioBook({super.key});

  @override
  State<WebAudioBook> createState() => WebAudioBookState();
}

class WebAudioBookState extends State<WebAudioBook> {
  late AudioSectionDataProvider audioSectionProvider;
  CarouselController carouselController = CarouselController();
  late ScrollController _scrollController;
  late HomeProvider homeProvider;
  @override
  void initState() {
    audioSectionProvider =
        Provider.of<AudioSectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _getData(0);
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _getData(pageno) async {
    await homeProvider.setLoading(true);
    await audioSectionProvider.setLoading(true);
    await homeProvider.getGenres();

    if (!homeProvider.loading) {
      if (homeProvider.genresModel.status == 200 &&
          homeProvider.genresModel.result != null) {
        if ((homeProvider.genresModel.result?.length ?? 0) > 0) {
          // if ((sectionDataProvider.audiosectionListModel.result?.length ?? 0) ==
          //     0) {
          // getTabData(0, homeProvider.genresModel.result, pageno);
          _fetchData(pageno, 0);
          // }
        }
      }
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    Utils.getCurrencySymbol();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (audioSectionProvider.currentPage ?? 0) <
            (audioSectionProvider.totalPage ?? 0)) {
      audioSectionProvider.setLoadMore(true);

      _fetchData(audioSectionProvider.currentPage ?? 0, 0);
    }
  }

  _fetchData(pageno, position) {
    getTabData(position, [], pageno + 1);
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
      await setSelectedTab(-1);
    }
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      videoType: videoType,
    );
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList, pageNo) async {
    debugPrint("getTabData position ====> $position");
    await setSelectedTab(position);
    await audioSectionProvider.setLoading(true);
    await audioSectionProvider.getSectionBanner(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
    await audioSectionProvider.getAudioSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2",
        pageNo);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> setSelectedTab(int tabPos) async {
    debugPrint("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);
    debugPrint(
        "setSelectedTab selectedIndex ====> ${homeProvider.selectedIndex}");
    debugPrint(
        "setSelectedTab lastTabPosition ====> ${audioSectionProvider.lastTabPosition}");
    if (audioSectionProvider.lastTabPosition == tabPos) {
      return;
    } else {
      audioSectionProvider.setTabPosition(tabPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appBgColor,
        body: SafeArea(
          child: _buildChannelPage(),
        ),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget _buildChannelPage() {
    if (homeProvider.loading) {
      return SingleChildScrollView(
        child: channelShimmer(),
      );
    } else {
      if (homeProvider.genresModel.status == 200) {
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /* Banner */
              Consumer<AudioSectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingBanner) {
                    if ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720) {
                      return ShimmerUtils.bannerWeb(context);
                    } else {
                      return ShimmerUtils.bannerMobile(context);
                    }
                  } else {
                    if (sectionDataProvider.sectionBannerModel.status == 200 &&
                        sectionDataProvider.sectionBannerModel.result != null) {
                      if ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720) {
                        return _webHomeBanner(
                            sectionDataProvider.sectionBannerModel.result);
                      } else {
                        return _mobileChannelBanner(
                            sectionDataProvider.sectionBannerModel.result);
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              Consumer<AudioSectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingSection &&
                      sectionDataProvider.loadmore == false) {
                    return channelShimmer();
                  } else {
                    if (sectionDataProvider.audiosectionListModel.status ==
                        200) {
                      return ((sectionDataProvider.sectionListData?.length ??
                                  0) >
                              0)
                          ? setSectionByType(
                              sectionDataProvider.sectionListData)
                          : const SizedBox.shrink();
                    } else {
                      return const NoData(title: 'nodata', subTitle: '');
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              Consumer<AudioSectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadmore) {
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
              /* Web Footer */
              kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
            ],
          ),
        );
      } else {
        return const NoData(title: 'nodata', subTitle: '');
      }
    }
  }

  /* Section Shimmer */
  Widget channelShimmer() {
    return Column(
      children: [
        /* Remaining Sections */
        ListView.builder(
          itemCount: 10, // itemCount must be greater than 5
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 1) {
              return ShimmerUtils.setChannelSections(context, "potrait");
            } else if (index == 2) {
              return ShimmerUtils.setChannelSections(context, "square");
            } else if (index == 3) {
              return ShimmerUtils.setChannelSections(context, "potrait");
            } else {
              return ShimmerUtils.setChannelSections(context, "landscape");
            }
          },
        ),
      ],
    );
  }

  Widget _mobileChannelBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.channelBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.channelBanner,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await audioSectionProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () async {
                    debugPrint("Clicked on index ==> $index");
                    openDetailPage(
                      "showdetail",
                      sectionBannerList?[index].id ?? 0,
                      sectionBannerList?[index].contentType ?? 0,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.channelBanner,
                          child: MyNetworkImage(
                            imageUrl:
                                (sectionBannerList?[index].webBannerImage ?? "")
                                        .isNotEmpty
                                    ? (sectionBannerList?[index]
                                            .webBannerImage ??
                                        "")
                                    : sectionBannerList?[index].landscapeImg ??
                                        "",
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.channelBanner,
                          alignment: Alignment.center,
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
                        Positioned.fill(
                          bottom: 50,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 150,
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
                                      fontsizeWeb: 16,
                                      fontweight: FontWeight.w700,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 150,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: transparentColor,
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
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
                                          fontsizeWeb: 15,
                                          fontweight: FontWeight.w700,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Consumer<AudioSectionDataProvider>(
              builder: (context, channelSectionProvider, child) {
                return AnimatedSmoothIndicator(
                  count: (sectionBannerList?.length ?? 0),
                  activeIndex: channelSectionProvider.cBannerIndex ?? 0,
                  effect: const ScrollingDotsEffect(
                    spacing: 8,
                    radius: 4,
                    activeDotColor: dotsActiveColor,
                    dotColor: dotsDefaultColor,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _webHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.homeWebBanner,
        child: Stack(children: [
          CarouselSlider.builder(
            itemCount: (sectionBannerList?.length ?? 0),
            carouselController: carouselController,
            options: CarouselOptions(
              initialPage: 0,
              height: Dimens.homeWebBanner,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayCurve: Curves.easeInOutQuart,
              enableInfiniteScroll: true,
              autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
              autoPlayAnimationDuration:
                  Duration(milliseconds: Constant.animationDuration),
              viewportFraction: 1,
              onPageChanged: (val, _) async {
                await audioSectionProvider.setCurrentBanner(val);
              },
            ),
            itemBuilder: (BuildContext context, int index, int pageViewIndex) {
              return InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  openDetailPage(
                    "showdetail",
                    sectionBannerList?[index].id ?? 0,
                    sectionBannerList?[index].contentType ?? 0,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeWebBanner,
                          child: MyNetworkImage(
                            imageUrl:
                                (sectionBannerList?[index].webBannerImage ?? "")
                                        .isNotEmpty
                                    ? (sectionBannerList?[index]
                                            .webBannerImage ??
                                        "")
                                    : sectionBannerList?[index].landscapeImg ??
                                        "",
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeWebBanner,
                          alignment: Alignment.center,
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
                        Positioned.fill(
                          bottom: 50,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 200,
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
                                      fontsizeWeb: 16,
                                      fontweight: FontWeight.w700,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 260,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: transparentColor,
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
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
                                          fontsizeWeb: 15,
                                          fontweight: FontWeight.w700,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<AudioSectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  return AnimatedSmoothIndicator(
                    count: (sectionBannerList?.length ?? 0),
                    activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                    effect: const ScrollingDotsEffect(
                      spacing: 8,
                      radius: 4,
                      activeDotColor: primaryDark,
                      dotColor: gray,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.separated(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        color: white,
                        text: sectionList?[index].title.toString() ?? "",
                        textalign: TextAlign.left,
                        fontsizeNormal: 14,
                        fontsizeWeb: 14,
                        multilanguage: false,
                        maxline: 1,
                        fontweight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                    sectionList?[index].viewAll == 1
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        WebViewAll(
                                      screenLayout: sectionList?[index]
                                              .screenLayout
                                              .toString() ??
                                          "",
                                      sectionId: sectionList?[index].id,
                                      title: sectionList?[index]
                                              .title
                                              .toString() ??
                                          "",
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return child;
                                    },
                                  ));
                            },
                            child: MyText(
                              color: primaryDark,
                              text: 'seeall',
                              textalign: TextAlign.center,
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w500,
                              fontsizeWeb: 13,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
              const SizedBox(height: 12),
              setSectionData(sectionList: sectionList, index: index),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show */
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].screenLayout ?? "") == "landscape") {
      return landscape(1, sectionList?[index].data,
          sectionList?[index].screenLayout.toString() ?? "");
    } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
      return portrait(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "small_square") {
      return square(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "language") {
      return languageLayout(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "grid_view") {
      return miniSeries(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "big_square") {
      return bestSellingStories(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "list_view") {
      return top10series(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "details_square") {
      return newRelease(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "round") {
      return author(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "category") {
      return categories(1, sectionList?[index].data);
    } else {
      return landscape(1, sectionList?[index].data,
          sectionList?[index].screenLayout.toString() ?? "");
    }
  }

  double getRemainingDataHeight(String? videoType, String? layoutType) {
    if (layoutType == "landscape") {
      return Dimens.heightcontemporyRomance;
    } else if (layoutType == "grid_view") {
      return Dimens.heightMiniSeries;
    } else if (layoutType == "list_view") {
      return Dimens.heightMiniSeries;
    } else if (layoutType == "big_square") {
      return Dimens.heightbestSellingStries;
    } else if (layoutType == "portrait") {
      return Dimens.heightPort;
    } else if (layoutType == "small_square") {
      return Dimens.heightSquare;
    } else if (layoutType == "banner_view") {
      return Dimens.homeWebBanner;
    } else if (layoutType == "details_square") {
      return Dimens.webnewreleaseContainerheight;
    } else if (layoutType == "language") {
      return Dimens.webheightLangGen;
    } else {
      return Dimens.webheightLand;
    }
  }

  Widget miniSeries(int? upcomingType, List<Datum>? sectionDataList) {
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
        itemCount: sectionDataList?.length ?? 0,
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
              debugPrint("Clicked on index ==> $index");

              openDetailPage(
                // (sectionDataList?[index].videoType ?? 0) == 2
                // ?
                "showdetail",
                // : "videodetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
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
                      imageUrl:
                          sectionDataList?[index].landscapeImg.toString() ?? "",
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
                        fontsizeWeb: 13,
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
                                "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 13,
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

  Widget categories(int? upCmingType, List<Datum>? sectionTypeList) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: darkappbgcolor,
      ),
      child: ListView.separated(
        itemCount: sectionTypeList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(13, 2, 13, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  debugPrint("index ===========> $index");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebVideosByID(
                          sectionTypeList?[index].id ?? 0,
                          1,
                          sectionTypeList?[index].title ?? "",
                          "ByCategory",
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                  child: Card(
                    color: appBgColor,
                    elevation: 10,
                    shadowColor: primaryDark,
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [white, lightpink]),
                                borderRadius: BorderRadius.circular(50)),
                            child: MyNetworkImage(
                              imageUrl: sectionTypeList?[index]
                                      .portraitImg
                                      .toString() ??
                                  "",
                              imgHeight: 30,
                              imgWidth: 22,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          MyText(
                            color: white,
                            multilanguage: false,
                            // text: index == 0
                            //     ? "Home"
                            //     : index > 0
                            //         ?
                            text:
                                (sectionTypeList?[index].name.toString() ?? "")
                            // : ""
                            ,
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 13,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget author(int? upcomingType, List<Datum>? sectionTypeList) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 180,
      decoration: const BoxDecoration(
        color: darkappbgcolor,
      ),
      child: ListView.separated(
        itemCount: sectionTypeList?.length ?? 0,
        shrinkWrap: true,
        // controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {},
                child: SizedBox(
                  width: 90,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                AuthorProfile(
                                    artistID: sectionTypeList?[index].id),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          ));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            imageUrl:
                                sectionTypeList?[index].image.toString() ?? "",
                            imgHeight: 80,
                            imgWidth: 80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          textalign: TextAlign.center,
                          maxline: 2,
                          color: white,
                          text:
                              sectionTypeList?[index].userName.toString() ?? "",
                          fontsizeNormal: 12,
                          fontsizeWeb: 10,
                          fontweight: FontWeight.w500,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget bestSellingStories(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) > 8
          ? Dimens.heightbestSellingStries
          : Dimens.heightbestSellingStries / 1.8,
      child: AlignedGridView.count(
        crossAxisCount: (sectionDataList?.length ?? 0) > 8 ? 2 : 1,
        itemCount: (sectionDataList?.length ?? 0) > 20
            ? 20
            : (sectionDataList?.length ?? 0),
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: Dimens.imgwidthcontempory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscapeImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: Dimens.imgheightbestSellingStories,
                        imgWidth: Dimens.imgwidthbestSellingStories,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 13,
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
                        "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 12,
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
        },
      ),
    );
  }

  Widget newRelease(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: Dimens.newreleaseContainerheight,
      child: AlignedGridView.count(
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        crossAxisCount: 2,
        itemCount: (sectionDataList?.length ?? 0) > 6
            ? 6
            : sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.vertical,
        // separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl:
                        sectionDataList?[index].landscapeImg.toString() ?? "",
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
                      text: sectionDataList?[index].title.toString() ?? "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 16,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 13,
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
                        Expanded(
                          child: MyText(
                            color: gray,
                            text:
                                "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 13,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                        MediaQuery.of(context).size.width > 720
                            ? Container(
                                height: 26,
                                width: 85,
                                constraints: const BoxConstraints(maxWidth: 85),
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
                                        text: sectionDataList?[index]
                                                .avgRating
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: 12,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 13,
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
                            : const SizedBox.shrink()
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: white,
                      text:
                          sectionDataList?[index].description.toString() ?? "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w400,
                      fontsizeWeb: 12,
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

  Widget top10series(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) > 8
          ? Dimens.heightMiniSeries
          : Dimens.heightMiniSeries / 2,
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: (sectionDataList?.length ?? 0) > 8 ? 2 : 1,
        itemCount:
            (sectionDataList?.length ?? 0) > 20 ? 20 : sectionDataList?.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
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
                        imageUrl:
                            sectionDataList?[index].landscapeImg.toString() ??
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

  Widget languageLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.webheightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebVideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByLanguage",
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.webwidthLangGen,
                  height: Dimens.webheightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
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
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: MyText(
                      color: white,
                      text: sectionDataList?[index].name.toString() ?? "",
                      textalign: TextAlign.center,
                      fontsizeNormal: 14,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 14,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget landscape(
      int? upcomingType, List<Datum>? sectionDataList, String screenLayout) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) < 8
          ? Dimens.heightcontemporyRomance / 2
          : Dimens.heightcontemporyRomance,
      child: AlignedGridView.count(
        mainAxisSpacing: 10, crossAxisSpacing: 10,
        crossAxisCount: (sectionDataList?.length ?? 0) > 8 ? 2 : 1,
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        // separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              if (screenLayout == "round") {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AuthorProfile(
                        artistID: sectionDataList?[index].id,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ));
              } else {
                openDetailPage(
                  "showdetail",
                  sectionDataList?[index].id ?? 0,
                  sectionDataList?[index].contentType ?? 0,
                );
              }
            },
            child: Container(
              width: Dimens.imgwidthcontempory,
              height: Dimens.imgheightcontempory,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: (sectionDataList?[index].landscapeImg.toString() ??
                                  "")
                              .isEmpty ||
                          (sectionDataList?[index].landscapeImg) == null
                      ? (sectionDataList?[index].image.toString() ?? "")
                      : (sectionDataList?[index].landscapeImg.toString() ?? ""),
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

  Widget portrait(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              debugPrint("Clicked on index ==> $index");

              if (!mounted) return;
              Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                videoType: sectionDataList?[index].contentType ?? 0,
              );
            },
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: Dimens.widthPort,
              height: Dimens.heightPort,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl:
                      sectionDataList?[index].portraitImg.toString() ?? "",
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

  Widget square(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              if (!mounted) return;
              Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                videoType: sectionDataList?[index].contentType ?? 0,
              );
            },
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl:
                      sectionDataList?[index].portraitImg.toString() ?? "",
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
}

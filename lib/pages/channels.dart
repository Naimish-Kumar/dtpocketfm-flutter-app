import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/model/channelsectionmodel.dart';
import 'package:dtpocketfm/model/channelsectionmodel.dart' as list;
import 'package:dtpocketfm/model/channelsectionmodel.dart' as banner;
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/players/player_video.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:dtpocketfm/players/player_vimeo.dart';
import 'package:dtpocketfm/players/player_youtube.dart';
import 'package:dtpocketfm/provider/channelsectionprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Channels extends StatefulWidget {
  const Channels({super.key});

  @override
  State<Channels> createState() => ChannelsState();
}

class ChannelsState extends State<Channels> {
  late ChannelSectionProvider channelSectionProvider;
  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    channelSectionProvider =
        Provider.of<ChannelSectionProvider>(context, listen: false);
    super.initState();
    _getData();
  }

  _getData() async {
    await channelSectionProvider.getChannelSection();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    channelSectionProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: _buildChannelPage(),
      ),
    );
  }

  Widget _buildChannelPage() {
    if (channelSectionProvider.loading) {
      return SingleChildScrollView(child: channelShimmer());
    } else {
      if (channelSectionProvider.channelSectionModel.status == 200) {
        return RefreshIndicator(
          backgroundColor: white,
          color: complimentryColor,
          displacement: 80,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) {
              channelSectionProvider.setLoading(true);
              Future.delayed(Duration.zero).then((value) {
                if (!mounted) return;
                setState(() {});
              });
              _getData();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                /* Banner */
                (channelSectionProvider.channelSectionModel.liveUrl != null)
                    ? (((kIsWeb || Constant.isTV) &&
                            MediaQuery.of(context).size.width > 720)
                        ? _webChannelBanner(
                            channelSectionProvider.channelSectionModel.liveUrl)
                        : _mobileChannelBanner(
                            channelSectionProvider.channelSectionModel.liveUrl))
                    : const SizedBox.shrink(),

                /* AdMob Banner */
                const SizedBox(height: 10),
                Utils.showBannerAd(context),
                const SizedBox(height: 10),

                /* Remaining Data */
                (channelSectionProvider.channelSectionModel.result != null)
                    ? setSectionByType(
                        channelSectionProvider.channelSectionModel.result)
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),

                /* Web Footer */
                kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      } else {
        return const NoData(title: '', subTitle: '');
      }
    }
  }

  /* Section Shimmer */
  Widget channelShimmer() {
    return Column(
      children: [
        /* Banner */
        if ((kIsWeb || Constant.isTV) &&
            MediaQuery.of(context).size.width > 720)
          ShimmerUtils.channelBannerWeb(context)
        else
          ShimmerUtils.channelBannerMobile(context),

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

  Widget _mobileChannelBanner(List<banner.LiveUrl>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        fit: StackFit.passthrough,
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
                  await channelSectionProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () async {
                    debugPrint("Clicked on index ==> $index");
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () {
                      openPlayer(sectionBannerList, index);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      fit: StackFit.passthrough,
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.channelBanner,
                          child: MyNetworkImage(
                            imageUrl: sectionBannerList?[index].image ?? "",
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Consumer<ChannelSectionProvider>(
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

  Widget _webChannelBanner(List<banner.LiveUrl>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.channelWebBanner,
        child: CarouselSlider.builder(
          itemCount: (sectionBannerList?.length ?? 0),
          carouselController: carouselController,
          options: CarouselOptions(
            initialPage: 0,
            height: Dimens.channelWebBanner,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOutQuart,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
            autoPlayAnimationDuration:
                Duration(milliseconds: Constant.animationDuration),
            viewportFraction: 0.95,
            onPageChanged: (val, _) async {
              await channelSectionProvider.setCurrentBanner(val);
            },
          ),
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () async {
                debugPrint("Clicked on index ==> $index");
                openPlayer(sectionBannerList, index);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    fit: StackFit.passthrough,
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            (Dimens.webBannerImgPr),
                        height: Dimens.channelWebBanner,
                        child: MyNetworkImage(
                          imageUrl: sectionBannerList?[index].image ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.channelWebBanner,
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              lightBlack,
                              lightBlack,
                              lightBlack,
                              lightBlack,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.channelWebBanner,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  (1.0 - Dimens.webBannerImgPr),
                              constraints: const BoxConstraints(minHeight: 0),
                              padding:
                                  const EdgeInsets.fromLTRB(35, 50, 55, 35),
                              alignment: Alignment.centerLeft,
                              child: MyText(
                                color: white,
                                text: sectionBannerList?[index].name ?? "",
                                textalign: TextAlign.start,
                                fontsizeNormal: 14,
                                fontweight: FontWeight.w700,
                                fontsizeWeb: 25,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: MyText(
                  color: otherColor,
                  text: sectionList?[index].channelName.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 10,
                  fontsizeWeb: 14,
                  multilanguage: false,
                  maxline: 1,
                  fontweight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: MyText(
                  color: white,
                  text: sectionList?[index].title.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 15,
                  fontsizeWeb: 18,
                  multilanguage: false,
                  maxline: 1,
                  fontweight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: getRemainingDataHeight(
                  sectionList?[index].videoType.toString() ?? "",
                  sectionList?[index].screenLayout ?? "",
                ),
                child: setSectionData(sectionList: sectionList, index: index),
              ),
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
    if ((sectionList?[index].videoType ?? 0) == 1) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(sectionList?[index].data);
      } else {
        return landscape(sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 2) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(sectionList?[index].data);
      } else {
        return landscape(sectionList?[index].data);
      }
    } else {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(sectionList?[index].data);
      } else {
        return landscape(sectionList?[index].data);
      }
    }
  }

  double getRemainingDataHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      return Dimens.heightLangGen;
    } else {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

  Widget landscape(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
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
              Utils.openDetails(
                videoId: sectionDataList?[index].id ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                context: context,
              );
            },
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: Dimens.widthLand,
              height: Dimens.heightLand,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: sectionDataList?[index].landscape.toString() ?? "",
                  fit: BoxFit.cover,
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
              Utils.openDetails(
                videoId: sectionDataList?[index].id ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                context: context,
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
                  imageUrl: sectionDataList?[index].thumbnail.toString() ?? "",
                  fit: BoxFit.cover,
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
              Utils.openDetails(
                videoId: sectionDataList?[index].id ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                context: context,
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
                  imageUrl: sectionDataList?[index].thumbnail.toString() ?? "",
                  fit: BoxFit.cover,
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

  /* ========= Open Player ========= */
  openPlayer(List<banner.LiveUrl>? sectionBannerList, int index) async {
    if (Constant.userID != null) {
      if ((sectionBannerList?[index].link ?? "").isNotEmpty) {
        if ((sectionBannerList?[index].isBuy ?? 0) == 1) {
          if (kIsWeb) {
            if ((sectionBannerList?[index].link ?? "").contains("youtube")) {
              return PlayerYoutube(
                1,
                "Channel",
                0,
                0,
                0,
                // 0,
                sectionBannerList?[index].link ?? "",
                0,
                "",
                sectionBannerList?[index].image ?? "",
              );
            } else {
              return PlayerVideo(
                1,
                "Channel",
                0,
                0,
                0,
                // 0,
                sectionBannerList?[index].link ?? "",
                0,
                "",
                sectionBannerList?[index].image ?? "",
              );
            }
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if ((sectionBannerList?[index].link ?? "")
                      .contains("youtube")) {
                    return PlayerYoutube(
                      1,
                      "Channel",
                      0,
                      0,
                      0,
                      // 0,
                      sectionBannerList?[index].link ?? "",
                      0,
                      "",
                      sectionBannerList?[index].image ?? "",
                    );
                  } else if ((sectionBannerList?[index].link ?? "")
                      .contains("vimeo")) {
                    return PlayerVimeo(
                      1,
                      "Channel",
                      0,
                      0,
                      0,
                      // 0,
                      sectionBannerList?[index].link ?? "",
                      0,
                      "",
                      sectionBannerList?[index].image ?? "",
                    );
                  } else {
                    return PlayerVideo(
                      1,
                      "Channel",
                      0,
                      0,
                      0,
                      // 0,
                      sectionBannerList?[index].link ?? "",
                      0,
                      "",
                      sectionBannerList?[index].image ?? "",
                    );
                  }
                },
              ),
            );
          }
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          debugPrint("isSubscribed ==========> $isSubscribed");
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
        }
      } else {
        if (!mounted) return;
        Utils.showSnackbar(context, "fail", "invalid_url", true);
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
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
  }
  /* ========= Open Player ========= */
}

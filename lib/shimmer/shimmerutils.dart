import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class ShimmerUtils {
  static Widget buildHomeMobileShimmer(context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720)
                    ? bannerWeb(context)
                    : bannerMobile(context),
                ListView.builder(
                  itemCount: 10, // itemCount must be greater than 5
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 1) {
                      debugPrint("banner view");
                      return setHomeSections(context, "banner_view");
                    } else if (index == 2) {
                      return setHomeSections(context, "potrait");
                    } else if (index == 3) {
                      return setHomeSections(context, "square");
                    } else if (index == 4) {
                      return setHomeSections(context, "langGen");
                    } else if (index == 5) {
                      return setHomeSections(context, "grid_landscape");
                    } else if (index == 6) {
                      return setHomeSections(context, "verticalGrid");
                    } else if (index == 7) {
                      return setHomeSections(context, "grid_view");
                    } else if (index == 8) {
                      return setHomeSections(context, "big_square");
                    } else if (index == 9) {
                      return setHomeSections(context, "small_square");
                    } else {
                      return setHomeSections(context, "landscape");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: Dimens.homeTabHeight,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          color: black.withOpacity(0.8),
          child: ListView.separated(
            itemCount: 5,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(13, 5, 13, 5),
            separatorBuilder: (context, index) => const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 32),
                decoration: Utils.setBackground(shimmerItemColor, 20),
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                child: const ShimmerWidget.roundrectborder(
                  height: 15,
                  width: 80,
                  shimmerBgColor: black,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget bannerMobile(context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: Dimens.homeBanner,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: Dimens.homeBanner,
                child: ShimmerWidget.roundcorner(
                  height: Dimens.homeBanner,
                  shapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                height: Dimens.homeBanner,
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
        Positioned(
          bottom: 0,
          child: CarouselIndicator(
            count: 6,
            index: 1,
            space: 8,
            height: 8,
            width: 8,
            cornerRadius: 4,
            color: dotsDefaultColor,
            activeColor: dotsActiveColor,
          ),
        ),
      ],
    );
  }

  static Widget bannerWeb(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.homeWebBanner,
      margin: const EdgeInsets.fromLTRB(27, 2, 27, 7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          color: shimmerItemColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeWebBanner,
            child: ShimmerWidget.roundcorner(
              height: Dimens.homeWebBanner,
              shimmerBgColor: shimmerItemColor,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          ),
        ),
      ),
    );
  }

  static Widget channelBannerMobile(context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: Dimens.channelBanner,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: Dimens.channelBanner,
                child: ShimmerWidget.roundcorner(
                  height: Dimens.channelBanner,
                  shapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
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
        Positioned(
          bottom: 0,
          child: CarouselIndicator(
            count: 6,
            index: 1,
            space: 8,
            height: 8,
            width: 8,
            cornerRadius: 4,
            color: dotsDefaultColor,
            activeColor: dotsActiveColor,
          ),
        ),
      ],
    );
  }

  static Widget channelBannerWeb(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.channelWebBanner,
      margin: const EdgeInsets.fromLTRB(27, 2, 27, 7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          color: shimmerItemColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.channelWebBanner,
            child: ShimmerWidget.roundcorner(
              height: Dimens.channelWebBanner,
              shimmerBgColor: shimmerItemColor,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          ),
        ),
      ),
    );
  }

  static Widget continueWatching(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ShimmerWidget.roundrectborder(
            height: 15,
            width: 100,
            shimmerBgColor: shimmerItemColor,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: Dimens.heightContiLand,
          child: ListView.separated(
            itemCount: kIsWeb ? 6 : 3,
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 20, right: 20),
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            separatorBuilder: (context, index) => const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Container(
                    width: Dimens.widthContiLand,
                    height: Dimens.heightContiLand,
                    alignment: Alignment.center,
                    child: ShimmerWidget.roundcorner(
                      width: Dimens.widthContiLand,
                      height: Dimens.heightContiLand,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 8),
                        child: ShimmerWidget.circular(
                          width: 30,
                          height: 30,
                          shimmerBgColor: black,
                        ),
                      ),
                      Container(
                        width: Dimens.widthContiLand,
                        constraints: const BoxConstraints(minWidth: 0),
                        padding: const EdgeInsets.all(3),
                        child: ShimmerWidget.roundcorner(
                          width: Dimens.widthContiLand,
                          height: 4,
                          shimmerBgColor: black,
                          shapeBorder: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2))),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget gridView(context) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        crossAxisCount: 4,
        itemCount: 15,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.horizontal,
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
                      width: 50,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        ShimmerWidget.circular(
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 50,
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

  static Widget setHomeSections(context, String layoutType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: layoutType == "banner_view" ? 0 : 25),
        if (layoutType == "banner_view")
          const SizedBox.shrink()
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: ShimmerWidget.roundrectborder(
              height: 15,
              width: 100,
              shimmerBgColor: shimmerItemColor,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
            ),
          ),
        const SizedBox(height: 12),
        if (layoutType == "landscape") landscapeListView(context),
        if (layoutType == "potrait") portraitListView(context),
        if (layoutType == "square") squareListView(context),
        if (layoutType == "langGen") langGenListView(context),
        if (layoutType == "grid_landscape") gridLandscape(context),
        if (layoutType == "verticalGrid") verticalGrid(context),
        if (layoutType == "grid_view") gridView(context),
        if (layoutType == "big_square") bigSquare(context),
        if (layoutType == "small_square") smallSquare(context),
      ],
    );
  }

  static Widget setChannelSections(context, String layoutType) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 25),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ShimmerWidget.roundrectborder(
            height: 10,
            width: 60,
            shimmerBgColor: shimmerItemColor,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 2),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ShimmerWidget.roundrectborder(
            height: 15,
            width: 100,
            shimmerBgColor: shimmerItemColor,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 12),
        if (layoutType == "landscape") landscapeListView(context),
        if (layoutType == "potrait") portraitListView(context),
        if (layoutType == "square") squareListView(context),
        if (layoutType == "langGen") langGenListView(context),
      ],
    );
  }

  static Widget buildRentShimmer(context, double itemHeight, double itemWidth) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          padding: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              ShimmerWidget.circular(
                height: 20,
                width: 20,
                shimmerBgColor: shimmerItemColor,
              ),
              SizedBox(width: 8),
              ShimmerWidget.roundrectborder(
                height: 18,
                width: 80,
                shimmerBgColor: shimmerItemColor,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              SizedBox(width: 5),
              ShimmerWidget.roundrectborder(
                height: 13,
                width: 50,
                shimmerBgColor: shimmerItemColor,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        normalHorizontalGrid(context, itemHeight, itemWidth, 3),
        const SizedBox(height: 22),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          padding: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              ShimmerWidget.circular(
                height: 20,
                width: 20,
                shimmerBgColor: shimmerItemColor,
              ),
              SizedBox(width: 8),
              ShimmerWidget.roundrectborder(
                height: 18,
                width: 80,
                shimmerBgColor: shimmerItemColor,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              SizedBox(width: 5),
              ShimmerWidget.roundrectborder(
                height: 13,
                width: 50,
                shimmerBgColor: shimmerItemColor,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        normalHorizontalGrid(context, itemHeight, itemWidth, 3),
        const SizedBox(height: 20),
      ],
    );
  }

  static Widget buildFindShimmer(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* Browse by START */
        Container(
          width: 120,
          padding: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.centerLeft,
          child: const ShimmerWidget.roundrectborder(
            height: 20,
            shimmerBgColor: shimmerItemColor,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 10),
        normalVerticalGrid(
            context, 65, (MediaQuery.of(context).size.width / 2), 2, 8),
        /* Browse by END */
        const SizedBox(height: 22),

        // /* Genres START */
        // Container(
        //   width: 120,
        //   padding: const EdgeInsets.only(left: 20, right: 20),
        //   alignment: Alignment.centerLeft,
        //   child: const ShimmerWidget.roundrectborder(
        //     height: 20,
        //     shimmerBgColor: shimmerItemColor,
        //     shapeBorder: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(5))),
        //   ),
        // ),
        // const SizedBox(height: 15),
        // normalVerticalGrid(
        //     context, 47, MediaQuery.of(context).size.width, 1, 5),
        // Container(
        //   height: 30,
        //   padding: const EdgeInsets.only(left: 20, right: 20),
        //   alignment: Alignment.centerLeft,
        //   child: const ShimmerWidget.roundrectborder(
        //     height: 30,
        //     width: 80,
        //     shimmerBgColor: shimmerItemColor,
        //     shapeBorder: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(5))),
        //   ),
        // ),
        // /* Genres END */
        // const SizedBox(height: 30),

        // /* Language START */
        // Container(
        //   width: 120,
        //   padding: const EdgeInsets.only(left: 20, right: 20),
        //   alignment: Alignment.centerLeft,
        //   child: const ShimmerWidget.roundrectborder(
        //     height: 20,
        //     shimmerBgColor: shimmerItemColor,
        //     shapeBorder: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(5))),
        //   ),
        // ),
        // const SizedBox(height: 15),
        // normalVerticalGrid(
        //     context, 47, MediaQuery.of(context).size.width, 1, 5),
        // Container(
        //   height: 30,
        //   padding: const EdgeInsets.only(left: 20, right: 20),
        //   alignment: Alignment.centerLeft,
        //   child: const ShimmerWidget.roundrectborder(
        //     height: 30,
        //     width: 80,
        //     shimmerBgColor: shimmerItemColor,
        //     shapeBorder: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(5))),
        //   ),
        // ),
        /* Language END */
      ],
    );
  }

  static Widget landscapeListView(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: kIsWeb ? 20 : 10,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: Dimens.widthLand,
            height: Dimens.heightLand,
            alignment: Alignment.center,
            child: ShimmerWidget.roundcorner(
              height: Dimens.heightLand,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          );
        },
      ),
    );
  }

  static Widget portraitListView(context) {
    // return SizedBox(
    //   width: MediaQuery.of(context).size.width,
    //   height: Dimens.heightPort,
    //   child: ListView.separated(
    //     itemCount: kIsWeb ? 20 : 10,
    //     shrinkWrap: true,
    //     physics:
    //         const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    //     padding: const EdgeInsets.only(left: 20, right: 20),
    //     scrollDirection: Axis.horizontal,
    //     separatorBuilder: (context, index) => const SizedBox(width: 5),
    //     itemBuilder: (BuildContext context, int index) {
    //       return Container(
    //         width: Dimens.widthPort,
    //         height: Dimens.heightPort,
    //         alignment: Alignment.center,
    //         child: ShimmerWidget.roundcorner(
    //           height: Dimens.heightPort,
    //           shapeBorder: const RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(4))),
    //         ),
    //       );
    //     },
    //   ),
    // );
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPortCont,
      child: ListView.separated(
        itemCount: 6,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: Dimens.widthPort,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Dimens.widthPort,
                  height: Dimens.heightPort,
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
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget squareListView(context) {
    // return SizedBox(
    //   width: MediaQuery.of(context).size.width,
    //   height: Dimens.heightSquare,
    //   child: ListView.separated(
    //     itemCount: kIsWeb ? 20 : 10,
    //     shrinkWrap: true,
    //     physics:
    //         const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    //     padding: const EdgeInsets.only(left: 20, right: 20),
    //     scrollDirection: Axis.horizontal,
    //     separatorBuilder: (context, index) => const SizedBox(width: 5),
    //     itemBuilder: (BuildContext context, int index) {
    //       return Container(
    //         width: Dimens.widthSquare,
    //         height: Dimens.heightSquare,
    //         alignment: Alignment.center,
    //         child: ShimmerWidget.roundcorner(
    //           height: Dimens.heightSquare,
    //           shapeBorder: const RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(4))),
    //         ),
    //       );
    //     },
    //   ),
    // );
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: 3,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: Dimens.widthSquare,
            height: Dimens.heightSquare,
            alignment: Alignment.center,
            padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ShimmerWidget.roundcorner(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget langGenListView(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        // itemCount: sectionDataList?.length ?? 0,
        itemCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(5),
            width: Dimens.containerWidthLan,
            height: Dimens.containerHeightLan,
            alignment: Alignment.center,
            padding: EdgeInsets.all(Constant.isTV ? 2 : 4),
            child: ShimmerWidget.roundcorner(
              width: Dimens.containerWidthLan,
              height: Dimens.containerHeightLan,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          );
        },
      ),
    );
  }

  static Widget normalHorizontalGrid(
      context, double itemHeight, double itemWidth, int crossAxisCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      height: itemHeight * crossAxisCount,
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemCount: kIsWeb ? 40 : 20,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int position) {
          return Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: ShimmerWidget.roundcorner(
              height: itemHeight,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          );
        },
      ),
    );
  }

  static Widget normalVerticalGrid(context, double itemHeight, double itemWidth,
      int crossAxisCount, int itemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemCount: kIsWeb ? (itemCount + 10) : itemCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: ShimmerWidget.roundcorner(
              height: itemHeight,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          );
        },
      ),
    );
  }

  static Widget responsiveGrid(context, double itemHeight, double itemWidth,
      int minCrossCount, int itemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: ResponsiveGridList(
        minItemWidth: itemWidth,
        verticalGridSpacing: 8,
        horizontalGridSpacing: 8,
        minItemsPerRow: minCrossCount,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          itemCount,
          (position) {
            return Container(
              width: itemWidth,
              height: itemHeight,
              alignment: Alignment.center,
              child: ShimmerWidget.roundcorner(
                height: itemHeight,
                shapeBorder: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget buildDetailMobileShimmer(context, String detailType) {
    return Column(
      children: [
        /* Poster */
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: kIsWeb ? Dimens.detailWebPoster : Dimens.detailPoster,
              child: ShimmerWidget.roundcorner(
                height: kIsWeb ? Dimens.detailWebPoster : Dimens.detailPoster,
                shapeBorder: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: kIsWeb
                  ? Dimens.detailWebPoster
                  : MediaQuery.of(context).size.height * 0.55,
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
            const ShimmerWidget.circular(
              height: 60,
              width: 60,
              shimmerBgColor: black,
            ),
          ],
        ),
        const SizedBox(height: 10),
        /* Other Details */
        SizedBox(
          // transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
              Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 85),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   width: 65,
                    //   height: 85,
                    //   alignment: Alignment.centerLeft,
                    //   child: const ShimmerWidget.roundcorner(
                    //     width: 65,
                    //     height: 85,
                    //     shapeBorder: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(0))),
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ShimmerWidget.roundrectborder(
                            height: 20,
                            width: MediaQuery.of(context).size.width,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: const ShimmerWidget.roundrectborder(
                                  height: 40,
                                  width: 70,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: const ShimmerWidget.roundrectborder(
                                  height: 40,
                                  width: 70,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: const ShimmerWidget.roundrectborder(
                                  height: 40,
                                  width: 70,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: const ShimmerWidget.roundrectborder(
                                  height: 40,
                                  width: 70,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ShimmerWidget.roundrectborder(
                              height: 30,
                              width: MediaQuery.of(context).size.width,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              /* Season Title */
              if (detailType == "show")
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: const SizedBox(
                    height: 45,
                    child: Row(
                      children: [
                        ShimmerWidget.circular(
                          height: 45,
                          width: 45,
                          shimmerBgColor: shimmerItemColor,
                        ),
                        SizedBox(width: 5),
                        ShimmerWidget.roundrectborder(
                          height: 18,
                          width: 100,
                          shimmerBgColor: shimmerItemColor,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ],
                    ),
                  ),
                ),

              // /* Prime TAG */
              // Container(
              //   margin: const EdgeInsets.only(top: 11),
              //   width: MediaQuery.of(context).size.width,
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //   child: const Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     mainAxisSize: MainAxisSize.max,
              //     children: [
              //       ShimmerWidget.roundrectborder(
              //         height: 18,
              //         width: 100,
              //         shimmerBgColor: shimmerItemColor,
              //         shapeBorder: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.all(Radius.circular(5))),
              //       ),
              //       SizedBox(height: 2),
              //       ShimmerWidget.roundrectborder(
              //         height: 13,
              //         width: 150,
              //         shimmerBgColor: shimmerItemColor,
              //         shapeBorder: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.all(Radius.circular(5))),
              //       ),
              //     ],
              //   ),
              // ),

              /* Rent TAG */
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ShimmerWidget.circular(
                    //   height: 20,
                    //   width: 20,
                    //   shimmerBgColor: shimmerItemColor,
                    // ),
                    ShimmerWidget.roundrectborder(
                      height: 20,
                      width: 55,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    ShimmerWidget.roundrectborder(
                      height: 20,
                      width: 55,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    ShimmerWidget.roundrectborder(
                      height: 20,
                      width: 55,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                  ],
                ),
              ),

              /* Continue Watching Button */
              /* Watch Now button */
              if (!kIsWeb)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: ShimmerWidget.roundrectborder(
                    height: kIsWeb ? 40 : 55,
                    width: MediaQuery.of(context).size.width,
                    shimmerBgColor: shimmerItemColor,
                    shapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                ),
              if (!kIsWeb)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: ShimmerWidget.roundrectborder(
                    height: kIsWeb ? 40 : 55,
                    width: MediaQuery.of(context).size.width,
                    shimmerBgColor: shimmerItemColor,
                    shapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                ),
              if (!kIsWeb)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: ShimmerWidget.roundrectborder(
                    height: kIsWeb ? 40 : 55,
                    width: MediaQuery.of(context).size.width,
                    shimmerBgColor: shimmerItemColor,
                    shapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                ),

              /* Included Features buttons */
              // Align(
              //   alignment: Alignment.center,
              //   child: Container(
              //     width: kIsWeb
              //         ? (MediaQuery.of(context).size.width / 2)
              //         : MediaQuery.of(context).size.width,
              //     constraints: const BoxConstraints(minHeight: 0),
              //     margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         /* Rent Button */
              //         Expanded(
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Container(
              //                 width: kIsWeb
              //                     ? Dimens.featureWebSize
              //                     : Dimens.featureSize,
              //                 height: kIsWeb
              //                     ? Dimens.featureWebSize
              //                     : Dimens.featureSize,
              //                 alignment: Alignment.center,
              //                 decoration: BoxDecoration(
              //                   border: Border.all(color: shimmerItemColor),
              //                   borderRadius: BorderRadius.circular((kIsWeb
              //                           ? Dimens.featureWebSize
              //                           : Dimens.featureSize) /
              //                       2),
              //                 ),
              //                 child: ShimmerWidget.circular(
              //                   height: MediaQuery.of(context).size.height,
              //                   width: MediaQuery.of(context).size.width,
              //                   shimmerBgColor: shimmerItemColor,
              //                 ),
              //               ),
              //               const SizedBox(height: 5),
              //               ShimmerWidget.circular(
              //                 height: kIsWeb
              //                     ? Dimens.featureIconWebSize
              //                     : Dimens.featureIconSize,
              //                 shimmerBgColor: shimmerItemColor,
              //               ),
              //             ],
              //           ),
              //         ),
              //         const SizedBox(width: 5),

              //         /* Start Over & Trailer */
              //         Expanded(
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Container(
              //                 width: kIsWeb
              //                     ? Dimens.featureWebSize
              //                     : Dimens.featureSize,
              //                 height: kIsWeb
              //                     ? Dimens.featureWebSize
              //                     : Dimens.featureSize,
              //                 alignment: Alignment.center,
              //                 decoration: BoxDecoration(
              //                   border: Border.all(color: shimmerItemColor),
              //                   borderRadius: BorderRadius.circular((kIsWeb
              //                           ? Dimens.featureWebSize
              //                           : Dimens.featureSize) /
              //                       2),
              //                 ),
              //                 child: ShimmerWidget.circular(
              //                   height: MediaQuery.of(context).size.height,
              //                   width: MediaQuery.of(context).size.width,
              //                   shimmerBgColor: shimmerItemColor,
              //                 ),
              //               ),
              //               const SizedBox(height: 5),
              //               ShimmerWidget.circular(
              //                 height: kIsWeb
              //                     ? Dimens.featureIconWebSize
              //                     : Dimens.featureIconSize,
              //                 shimmerBgColor: shimmerItemColor,
              //               ),
              //             ],
              //           ),
              //         ),
              //         const SizedBox(width: 5),

              //         /* Download */
              //         if (!kIsWeb)
              //           Expanded(
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Container(
              //                   width: kIsWeb
              //                       ? Dimens.featureWebSize
              //                       : Dimens.featureSize,
              //                   height: kIsWeb
              //                       ? Dimens.featureWebSize
              //                       : Dimens.featureSize,
              //                   alignment: Alignment.center,
              //                   decoration: BoxDecoration(
              //                     border: Border.all(color: shimmerItemColor),
              //                     borderRadius: BorderRadius.circular((kIsWeb
              //                             ? Dimens.featureWebSize
              //                             : Dimens.featureSize) /
              //                         2),
              //                   ),
              //                   child: ShimmerWidget.circular(
              //                     height: MediaQuery.of(context).size.height,
              //                     width: MediaQuery.of(context).size.width,
              //                     shimmerBgColor: shimmerItemColor,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 5),
              //                 ShimmerWidget.circular(
              //                   height: kIsWeb
              //                       ? Dimens.featureIconWebSize
              //                       : Dimens.featureIconSize,
              //                   shimmerBgColor: shimmerItemColor,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         const SizedBox(width: 5),

              //         /* Watchlist */
              //         Expanded(
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Container(
              //                 width: kIsWeb
              //                     ? Dimens.featureWebSize
              //                     : Dimens.featureSize,
              //                 height: kIsWeb
              //                     ? Dimens.featureWebSize
              //                     : Dimens.featureSize,
              //                 alignment: Alignment.center,
              //                 decoration: BoxDecoration(
              //                   border: Border.all(color: shimmerItemColor),
              //                   borderRadius: BorderRadius.circular((kIsWeb
              //                           ? Dimens.featureWebSize
              //                           : Dimens.featureSize) /
              //                       2),
              //                 ),
              //                 child: ShimmerWidget.circular(
              //                   height: MediaQuery.of(context).size.height,
              //                   width: MediaQuery.of(context).size.width,
              //                   shimmerBgColor: shimmerItemColor,
              //                 ),
              //               ),
              //               const SizedBox(height: 5),
              //               ShimmerWidget.circular(
              //                 height: kIsWeb
              //                     ? Dimens.featureIconWebSize
              //                     : Dimens.featureIconSize,
              //                 shimmerBgColor: shimmerItemColor,
              //               ),
              //             ],
              //           ),
              //         ),
              //         const SizedBox(width: 5),

              //         /* More */
              //         if (!kIsWeb)
              //           Expanded(
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Container(
              //                   width: kIsWeb
              //                       ? Dimens.featureWebSize
              //                       : Dimens.featureSize,
              //                   height: kIsWeb
              //                       ? Dimens.featureWebSize
              //                       : Dimens.featureSize,
              //                   alignment: Alignment.center,
              //                   decoration: BoxDecoration(
              //                     border: Border.all(color: shimmerItemColor),
              //                     borderRadius: BorderRadius.circular((kIsWeb
              //                             ? Dimens.featureWebSize
              //                             : Dimens.featureSize) /
              //                         2),
              //                   ),
              //                   child: ShimmerWidget.circular(
              //                     height: MediaQuery.of(context).size.height,
              //                     width: MediaQuery.of(context).size.width,
              //                     shimmerBgColor: shimmerItemColor,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 5),
              //                 ShimmerWidget.circular(
              //                   height: kIsWeb
              //                       ? Dimens.featureIconWebSize
              //                       : Dimens.featureIconSize,
              //                   shimmerBgColor: shimmerItemColor,
              //                 ),
              //               ],
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),

              // /* Description, IMDb, Languages & Subtitles */
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Container(
              //         width: MediaQuery.of(context).size.width,
              //         padding: const EdgeInsets.only(bottom: 5),
              //         child: const ShimmerWidget.roundrectborder(
              //           height: 16,
              //           shimmerBgColor: shimmerItemColor,
              //           shapeBorder: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(5))),
              //         ),
              //       ),
              //       Container(
              //         width: MediaQuery.of(context).size.width,
              //         padding: const EdgeInsets.only(bottom: 5),
              //         child: const ShimmerWidget.roundrectborder(
              //           height: 16,
              //           shimmerBgColor: shimmerItemColor,
              //           shapeBorder: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(5))),
              //         ),
              //       ),
              //       Container(
              //         width: MediaQuery.of(context).size.width,
              //         padding: const EdgeInsets.only(bottom: 5),
              //         child: const ShimmerWidget.roundrectborder(
              //           height: 16,
              //           shimmerBgColor: shimmerItemColor,
              //           shapeBorder: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(5))),
              //         ),
              //       ),
              //       Container(
              //         width: MediaQuery.of(context).size.width,
              //         padding: const EdgeInsets.only(bottom: 5),
              //         child: const ShimmerWidget.roundrectborder(
              //           height: 16,
              //           shimmerBgColor: shimmerItemColor,
              //           shapeBorder: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(5))),
              //         ),
              //       ),
              //       const SizedBox(height: 18),
              //       const Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           ShimmerWidget.roundrectborder(
              //             height: 25,
              //             width: 80,
              //             shimmerBgColor: shimmerItemColor,
              //             shapeBorder: RoundedRectangleBorder(
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(5))),
              //           ),
              //           SizedBox(width: 5),
              //           ShimmerWidget.roundrectborder(
              //             height: 15,
              //             width: 80,
              //             shimmerBgColor: shimmerItemColor,
              //             shapeBorder: RoundedRectangleBorder(
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(5))),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 5),
              //       Container(
              //         constraints: const BoxConstraints(minHeight: 30),
              //         child: const Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             ShimmerWidget.roundrectborder(
              //               height: 16,
              //               width: 100,
              //               shimmerBgColor: shimmerItemColor,
              //               shapeBorder: RoundedRectangleBorder(
              //                   borderRadius:
              //                       BorderRadius.all(Radius.circular(5))),
              //             ),
              //             SizedBox(width: 5),
              //             Expanded(
              //               child: ShimmerWidget.roundrectborder(
              //                 height: 15,
              //                 width: 100,
              //                 shimmerBgColor: shimmerItemColor,
              //                 shapeBorder: RoundedRectangleBorder(
              //                     borderRadius:
              //                         BorderRadius.all(Radius.circular(5))),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Container(
              //         constraints: const BoxConstraints(minHeight: 30),
              //         child: const Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             ShimmerWidget.roundrectborder(
              //               height: 16,
              //               width: 100,
              //               shimmerBgColor: shimmerItemColor,
              //               shapeBorder: RoundedRectangleBorder(
              //                   borderRadius:
              //                       BorderRadius.all(Radius.circular(5))),
              //             ),
              //             SizedBox(width: 5),
              //             Expanded(
              //               child: ShimmerWidget.roundrectborder(
              //                 height: 15,
              //                 width: 100,
              //                 shimmerBgColor: shimmerItemColor,
              //                 shapeBorder: RoundedRectangleBorder(
              //                     borderRadius:
              //                         BorderRadius.all(Radius.circular(5))),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // /* Related ~ More Details */
              // Container(
              //   constraints: BoxConstraints(
              //     maxWidth: kIsWeb
              //         ? (MediaQuery.of(context).size.width * 0.5)
              //         : MediaQuery.of(context).size.width,
              //   ),
              //   margin: kIsWeb
              //       ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
              //       : const EdgeInsets.all(0),
              //   height: kIsWeb ? 35 : Dimens.detailTabs,
              //   child: Row(
              //     children: [
              //       /* Related */
              //       Expanded(
              //         child: Column(
              //           children: [
              //             Expanded(
              //               child: Container(
              //                 alignment: Alignment.center,
              //                 padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              //                 child: const ShimmerWidget.roundrectborder(
              //                   height: 18,
              //                   shimmerBgColor: shimmerItemColor,
              //                   shapeBorder: RoundedRectangleBorder(
              //                       borderRadius:
              //                           BorderRadius.all(Radius.circular(5))),
              //                 ),
              //               ),
              //             ),
              //             Container(
              //               height: 2,
              //               color: shimmerItemColor,
              //               constraints: BoxConstraints(
              //                 maxWidth: MediaQuery.of(context).size.width,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       /* More Details */
              //       Expanded(
              //         child: Container(
              //           alignment: Alignment.center,
              //           padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              //           child: const ShimmerWidget.roundrectborder(
              //             height: 18,
              //             shimmerBgColor: shimmerItemColor,
              //             shapeBorder: RoundedRectangleBorder(
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(5))),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Container(
              //   height: 0.5,
              //   color: shimmerItemColor,
              //   constraints: BoxConstraints(
              //     maxWidth: kIsWeb
              //         ? (MediaQuery.of(context).size.width * 0.5)
              //         : MediaQuery.of(context).size.width,
              //   ),
              // ),
              // if (detailType == "show") Container(),
              // const SizedBox(height: 25),
              // Container(
              //   width: 100,
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //   child: const ShimmerWidget.roundrectborder(
              //     height: 18,
              //     width: 100,
              //     shimmerBgColor: shimmerItemColor,
              //     shapeBorder: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5))),
              //   ),
              // ),
              // const SizedBox(height: 12),
              // landscapeListView(context),
              // const SizedBox(height: 25),
              // Container(
              //   width: 100,
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //   alignment: Alignment.centerLeft,
              //   child: const ShimmerWidget.roundrectborder(
              //     height: 18,
              //     width: 100,
              //     shimmerBgColor: shimmerItemColor,
              //     shapeBorder: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(5))),
              //   ),
              // ),
              // const SizedBox(height: 2),
              // Container(
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.max,
              //     children: [
              //       Container(
              //         margin: const EdgeInsets.only(right: 10),
              //         child: const ShimmerWidget.roundrectborder(
              //           height: 18,
              //           width: 100,
              //           shimmerBgColor: shimmerItemColor,
              //           shapeBorder: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(5))),
              //         ),
              //       ),
              //       Container(
              //         width: 100,
              //         margin: const EdgeInsets.only(right: 10),
              //         padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
              //         decoration: BoxDecoration(
              //           border: Border.all(color: shimmerItemColor, width: .7),
              //           borderRadius: BorderRadius.circular(4),
              //           shape: BoxShape.rectangle,
              //         ),
              //         child: ShimmerWidget.roundrectborder(
              //           height: 18,
              //           width: MediaQuery.of(context).size.width,
              //           shimmerBgColor: shimmerItemColor,
              //           shapeBorder: const RoundedRectangleBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(5))),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 12),
              // responsiveGrid(
              //   context,
              //   kIsWeb ? Dimens.heightCastWeb : Dimens.heightCast,
              //   kIsWeb ? Dimens.widthCastWeb : Dimens.widthCast,
              //   3,
              //   6,
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  static Widget bigSquare(context) {
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
                  width: 45,
                ),
                const SizedBox(
                  height: 5,
                ),
                const ShimmerWidget.roundcorner(
                  height: 15,
                  width: 45,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget smallSquare(context) {
    return Container(
      padding: const EdgeInsets.all(5),
      color: darkappbgcolor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.heightContiLandList,
            child: ListView.separated(
              itemCount: 6,
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              separatorBuilder: (context, index) => const SizedBox(
                width: 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          width: Dimens.widthContiLand,
                          height: Dimens.heightContiLand,
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
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  // openPlayer("ContinueWatch", index,
                                  //     continueWatchingList);
                                },
                                child: const ShimmerWidget.circular(
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget gridLandscape(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightcontemporyRomance,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: 6,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.all(10),
            width: Dimens.imgwidthcontempory,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.roundcorner(
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  height: Dimens.imgheightcontempory,
                  width: Dimens.imgwidthcontempory,
                ),
                const SizedBox(
                  height: 5,
                ),
                ShimmerWidget.roundcorner(
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  height: 15,
                  width: 50,
                ),
                const SizedBox(
                  height: 5,
                ),
                ShimmerWidget.roundcorner(
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  height: 13,
                  width: 50,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget verticalGrid(context) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 2,
        itemCount: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            // height: Dimens.containerHeightMiniSeries,
            // width: Dimens.containerwidthMiniSeries,
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

  static Widget buildDetailWebShimmer(context, String detailType) {
    return Column(
      children: [
        /* Poster */
        Container(
          padding: const EdgeInsets.all(0),
          height: Dimens.detailWebPoster,
          width: MediaQuery.of(context)
              .size
              .width /*  * (Dimens.webBannerImgPr) */,
          child: ShimmerWidget.roundrectborder(
            height: Dimens.detailWebPoster,
            shimmerBgColor: shimmerItemColor,
            shapeBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 20),

        /* Other Details */
        Container(
          // height: Dimens.detailWeb,
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!kIsWeb)
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: InkWell(
                    autofocus: true,
                    focusColor: gray.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      child: const ShimmerWidget.roundrectborder(
                        height: 35,
                        shimmerBgColor: shimmerItemColor,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
              Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 0),
                padding: const EdgeInsets.fromLTRB(0, kIsWeb ? 20 : 0, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const ShimmerWidget.roundrectborder(
                      height: 10,
                      width: 500,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 60,
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerWidget.roundrectborder(
                                  height: 10,
                                  width: 50,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ShimmerWidget.roundrectborder(
                                  height: 10,
                                  width: 50,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const VerticalDivider(
                              width: 50,
                              color: white,
                              thickness: 1,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: primaryDark,
                                      borderRadius: BorderRadius.circular(14)),
                                  child: const ShimmerWidget.roundrectborder(
                                    height: 10,
                                    width: 50,
                                    shimmerBgColor: shimmerItemColor,
                                    shapeBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const ShimmerWidget.roundrectborder(
                                  height: 10,
                                  width: 50,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const VerticalDivider(
                              color: white,
                              thickness: 1,
                              width: 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: primaryDark,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const ShimmerWidget.roundrectborder(
                                    height: 25,
                                    width: 25,
                                    shimmerBgColor: shimmerItemColor,
                                    shapeBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                const ShimmerWidget.roundrectborder(
                                  height: 10,
                                  width: 150,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const VerticalDivider(
                              color: white,
                              thickness: 1,
                              width: 50,
                            ),
                            const ShimmerWidget.roundrectborder(
                              height: 10,
                              width: 150,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              color: white,
                              thickness: 1,
                              width: 50,
                            ),
                            const ShimmerWidget.circular(
                              height: 35,
                              width: 35,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    /* Category */

                    Container(
                      constraints: const BoxConstraints(minHeight: 0),
                      margin: const EdgeInsets.only(top: 5),
                      child: const Row(
                        children: [
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 80,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 10,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 150,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    /* Language */
                    Container(
                      constraints: const BoxConstraints(minHeight: 0),
                      margin: const EdgeInsets.only(top: 5),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 80,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 10,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 150,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /* Description */
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 200,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 200,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // /* Related ~ More Details */
        // Container(
        //   alignment: Alignment.center,
        //   constraints: BoxConstraints(
        //     maxWidth: kIsWeb
        //         ? (MediaQuery.of(context).size.width * 0.5)
        //         : MediaQuery.of(context).size.width,
        //   ),
        //   margin: kIsWeb
        //       ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
        //       : const EdgeInsets.all(0),
        //   height: kIsWeb ? 35 : Dimens.detailTabs,
        //   child: Row(
        //     children: [
        //       /* Related */
        //       Expanded(
        //         child: Column(
        //           children: [
        //             Expanded(
        //               child: Container(
        //                 alignment: Alignment.center,
        //                 padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        //                 child: const ShimmerWidget.roundrectborder(
        //                   height: 18,
        //                   shimmerBgColor: shimmerItemColor,
        //                   shapeBorder: RoundedRectangleBorder(
        //                       borderRadius:
        //                           BorderRadius.all(Radius.circular(5))),
        //                 ),
        //               ),
        //             ),
        //             Container(
        //               height: 2,
        //               color: shimmerItemColor,
        //               constraints: BoxConstraints(
        //                 maxWidth: MediaQuery.of(context).size.width,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       /* More Details */
        //       Expanded(
        //         child: Container(
        //           alignment: Alignment.center,
        //           padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        //           child: const ShimmerWidget.roundrectborder(
        //             height: 18,
        //             shimmerBgColor: shimmerItemColor,
        //             shapeBorder: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.all(Radius.circular(5))),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // Container(
        //   height: 0.5,
        //   color: shimmerItemColor,
        //   constraints: BoxConstraints(
        //     maxWidth: kIsWeb
        //         ? (MediaQuery.of(context).size.width * 0.5)
        //         : MediaQuery.of(context).size.width,
        //   ),
        // ),
        // if (detailType == "show") Container(),
        // const SizedBox(height: 25),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Container(
        //     width: 100,
        //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        //     child: const ShimmerWidget.roundrectborder(
        //       height: 18,
        //       width: 100,
        //       shimmerBgColor: shimmerItemColor,
        //       shapeBorder: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.all(Radius.circular(5))),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 50),
        // landscapeListView(context),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                ShimmerWidget.roundrectborder(
                  height: 10,
                  width: 150,
                  shimmerBgColor: shimmerItemColor,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ShimmerWidget.roundrectborder(
                  height: 3,
                  width: 150,
                  shimmerBgColor: shimmerItemColor,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              children: [
                ShimmerWidget.roundrectborder(
                  height: 10,
                  width: 150,
                  shimmerBgColor: shimmerItemColor,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ShimmerWidget.roundrectborder(
                  height: 3,
                  width: 150,
                  shimmerBgColor: shimmerItemColor,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Container(
        //     width: 100,
        //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        //     alignment: Alignment.centerLeft,
        //     child: const ShimmerWidget.roundrectborder(
        //       height: 18,
        //       width: 100,
        //       shimmerBgColor: shimmerItemColor,
        //       shapeBorder: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.all(Radius.circular(5))),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 2),
        // Container(
        //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        //   alignment: Alignment.centerLeft,
        //   child: Row(
        //     mainAxisSize: MainAxisSize.max,
        //     children: [
        //       Container(
        //         margin: const EdgeInsets.only(right: 10),
        //         child: const ShimmerWidget.roundrectborder(
        //           height: 18,
        //           width: 100,
        //           shimmerBgColor: shimmerItemColor,
        //           shapeBorder: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.all(Radius.circular(5))),
        //         ),
        //       ),
        //       Container(
        //         width: 100,
        //         padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
        //         decoration: BoxDecoration(
        //           border: Border.all(color: shimmerItemColor, width: .7),
        //           borderRadius: BorderRadius.circular(4),
        //           shape: BoxShape.rectangle,
        //         ),
        //         child: ShimmerWidget.roundrectborder(
        //           height: 18,
        //           width: MediaQuery.of(context).size.width,
        //           shimmerBgColor: shimmerItemColor,
        //           shapeBorder: const RoundedRectangleBorder(
        //               borderRadius: BorderRadius.all(Radius.circular(5))),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 25),
        ResponsiveGridList(
          minItemWidth: 50,
          verticalGridSpacing: 8,
          horizontalGridSpacing: 8,
          minItemsPerRow: 1,
          maxItemsPerRow:
              (kIsWeb && MediaQuery.of(context).size.width > 720) ? 2 : 1,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (10),
            (index) {
              return Container(
                color: appBgColor,
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                constraints: const BoxConstraints(minHeight: 60),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ShimmerWidget.roundrectborder(
                      height: 10,
                      width: 10,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
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
                            child: const ShimmerWidget.roundrectborder(
                              height: 50,
                              width: 50,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 120,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
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
                                child: ShimmerWidget.roundrectborder(
                                  height: 20,
                                  width: 20,
                                  shimmerBgColor: shimmerItemColor,
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                              const ShimmerWidget.roundrectborder(
                                height: 10,
                                width: 120,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 4,
                                width: 4,
                                decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const ShimmerWidget.roundrectborder(
                                height: 10,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const ShimmerWidget.roundrectborder(
                      height: 10,
                      width: 50,
                      shimmerBgColor: shimmerItemColor,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ShimmerWidget.roundrectborder(
                        height: 22,
                        width: 22,
                        shimmerBgColor: shimmerItemColor,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),

        // responsiveGrid(
        //   context,
        //   kIsWeb ? Dimens.heightCastWeb : Dimens.heightCast,
        //   kIsWeb ? Dimens.widthCastWeb : Dimens.widthCast,
        //   3,
        //   10,
        // ),
      ],
    );
  }

  static Widget buildWatchlistShimmer(context, int itemCount) {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kIsWeb ? (itemCount + 10) : itemCount,
      itemBuilder: (BuildContext context, int position) {
        return Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(minHeight: Dimens.heightWatchlist),
          color: shimmerItemColor,
          child: Row(
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: Dimens.heightWatchlist,
                  maxWidth: MediaQuery.of(context).size.width * 0.44,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.44,
                      height: Dimens.heightWatchlist,
                      alignment: Alignment.center,
                      child: ShimmerWidget.roundcorner(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightWatchlist,
                        shimmerBgColor: shimmerItemColor,
                        shapeBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0))),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 8),
                          child: ShimmerWidget.circular(
                            width: 30,
                            height: 30,
                            shimmerBgColor: black,
                          ),
                        ),
                        Container(
                          width: Dimens.widthContiLand,
                          constraints: const BoxConstraints(minWidth: 0),
                          padding: const EdgeInsets.all(3),
                          child: ShimmerWidget.roundcorner(
                            width: Dimens.widthContiLand,
                            height: 4,
                            shimmerBgColor: black,
                            shapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /* Title */
                            const ShimmerWidget.roundrectborder(
                              height: 18,
                              width: 100,
                              shimmerBgColor: black,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            const SizedBox(height: 3),
                            /* Release Year & Video Duration */
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: const ShimmerWidget.roundrectborder(
                                    height: 15,
                                    width: 60,
                                    shimmerBgColor: black,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  child: const ShimmerWidget.roundrectborder(
                                    height: 15,
                                    width: 80,
                                    shimmerBgColor: black,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            /* Prime TAG  & Rent TAG */
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* Prime TAG */
                                ShimmerWidget.roundrectborder(
                                  height: 13,
                                  width: 80,
                                  shimmerBgColor: black,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                                SizedBox(height: 3),
                                /* Rent TAG */
                                ShimmerWidget.roundrectborder(
                                  height: 13,
                                  width: 80,
                                  shimmerBgColor: black,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(6),
                          child: const ShimmerWidget.circular(
                            height: 18,
                            width: 18,
                            shimmerBgColor: black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget buildWebWatchListShimmer(context) {
    return ResponsiveGridList(
        // shrinkWrap: true,
        // crossAxisCount: 1,
        // crossAxisSpacing: 0,
        // mainAxisSpacing: 8,
        // physics: const NeverScrollableScrollPhysics(),
        // itemCount: watchlistProvider.watchDataList?.length ?? 0,
        minItemWidth: 300,
        verticalGridSpacing: 8,
        horizontalGridSpacing: 8,
        minItemsPerRow: 1,
        maxItemsPerRow: 2,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        // itemBuilder: (BuildContext context, int position) {
        //   return _buildWatchlistItem(position);
        // },
        children: List.generate((10), (position) {
          return Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(minHeight: Dimens.webheightWatchlist),
            color: shimmerItemColor,
            child: Row(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.heightWatchlist,
                    // maxWidth: MediaQuery.of(context).size.width * 0.44,
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        height: Dimens.heightWatchlist,
                        alignment: Alignment.center,
                        child: ShimmerWidget.roundcorner(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.heightWatchlist,
                          shimmerBgColor: shimmerItemColor,
                          shapeBorder: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0))),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 8),
                            child: ShimmerWidget.circular(
                              width: 30,
                              height: 30,
                              shimmerBgColor: black,
                            ),
                          ),
                          Container(
                            width: Dimens.widthContiLand,
                            constraints: const BoxConstraints(minWidth: 0),
                            padding: const EdgeInsets.all(3),
                            child: ShimmerWidget.roundcorner(
                              width: Dimens.widthContiLand,
                              height: 4,
                              shimmerBgColor: black,
                              shapeBorder: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: Dimens.heightWatchlist,
                      // maxWidth: MediaQuery.of(context).size.width * 0.66,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              /* Title */
                              const ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: black,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              const SizedBox(height: 3),
                              /* Release Year & Video Duration */
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: const ShimmerWidget.roundrectborder(
                                      height: 15,
                                      width: 60,
                                      shimmerBgColor: black,
                                      shapeBorder: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                    ),
                                  ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(right: 20),
                                  //   child: const ShimmerWidget.roundrectborder(
                                  //     height: 15,
                                  //     width: 80,
                                  //     shimmerBgColor: black,
                                  //     shapeBorder: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(5))),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              /* Prime TAG  & Rent TAG */
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /* Prime TAG */
                                  ShimmerWidget.roundrectborder(
                                    height: 13,
                                    width: 80,
                                    shimmerBgColor: black,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  SizedBox(height: 3),
                                  /* Rent TAG */
                                  ShimmerWidget.roundrectborder(
                                    height: 13,
                                    width: 80,
                                    shimmerBgColor: black,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 25,
                            height: 25,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(6),
                            child: const ShimmerWidget.circular(
                              height: 18,
                              width: 18,
                              shimmerBgColor: black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }

  static Widget buildDownloadShimmer(context, int itemCount) {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kIsWeb ? (itemCount + 10) : itemCount,
      itemBuilder: (BuildContext context, int position) {
        return Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(minHeight: Dimens.heightWatchlist),
          color: shimmerItemColor,
          child: Row(
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: Dimens.heightWatchlist,
                  maxWidth: MediaQuery.of(context).size.width * 0.44,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.44,
                      height: Dimens.heightWatchlist,
                      alignment: Alignment.center,
                      child: ShimmerWidget.roundcorner(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightWatchlist,
                        shimmerBgColor: shimmerItemColor,
                        shapeBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0))),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 8),
                          child: ShimmerWidget.circular(
                            width: 30,
                            height: 30,
                            shimmerBgColor: black,
                          ),
                        ),
                        Container(
                          width: Dimens.widthContiLand,
                          constraints: const BoxConstraints(minWidth: 0),
                          padding: const EdgeInsets.all(3),
                          child: ShimmerWidget.roundcorner(
                            width: Dimens.widthContiLand,
                            height: 4,
                            shimmerBgColor: black,
                            shapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /* Title */
                            const ShimmerWidget.roundrectborder(
                              height: 18,
                              width: 100,
                              shimmerBgColor: black,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            const SizedBox(height: 3),
                            /* Release Year & Video Duration */
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: const ShimmerWidget.roundrectborder(
                                    height: 15,
                                    width: 60,
                                    shimmerBgColor: black,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 20),
                                  child: const ShimmerWidget.roundrectborder(
                                    height: 15,
                                    width: 80,
                                    shimmerBgColor: black,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            /* Prime TAG  & Rent TAG */
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* Prime TAG */
                                ShimmerWidget.roundrectborder(
                                  height: 13,
                                  width: 80,
                                  shimmerBgColor: black,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                                SizedBox(height: 3),
                                /* Rent TAG */
                                ShimmerWidget.roundrectborder(
                                  height: 13,
                                  width: 80,
                                  shimmerBgColor: black,
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(6),
                          child: const ShimmerWidget.circular(
                            height: 18,
                            width: 18,
                            shimmerBgColor: black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget buildSubscribeShimmer(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Row(
            children: [
              ShimmerWidget.roundrectborder(
                width: 70,
                height: 20,
              ),
              SizedBox(width: 15),
              ShimmerWidget.roundrectborder(
                width: 70,
                height: 20,
              ),
              SizedBox(width: 15),
              ShimmerWidget.roundrectborder(
                width: 70,
                height: 20,
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.18,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MyImage(
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height,
                          color: gray.withOpacity(0.40),
                          imagePath: "ic_halfround.png"),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShimmerWidget.roundrectborder(
                            width: 80,
                            height: 15,
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShimmerWidget.roundrectborder(
                                width: 40,
                                height: 15,
                              ),
                              SizedBox(width: 3),
                              ShimmerWidget.roundrectborder(
                                width: 50,
                                height: 15,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ShimmerWidget.roundrectborder(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ShimmerWidget.roundrectborder(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ShimmerWidget.roundcorner(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildSubscribeWebShimmer(context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.center,
          child: ShimmerWidget.roundrectborder(
            height: 20,
            width: MediaQuery.of(context).size.width,
            shimmerBgColor: black,
            shapeBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 30, right: 30),
          alignment: Alignment.center,
          child: ShimmerWidget.roundrectborder(
            height: 20,
            width: MediaQuery.of(context).size.width,
            shimmerBgColor: black,
            shapeBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        const SizedBox(height: 12),
        /* Remaining Data */
        Container(
          height: 350,
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  color: black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        constraints: const BoxConstraints(minHeight: 55),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidget.roundrectborder(
                              height: 18,
                              width: 120,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            ShimmerWidget.roundrectborder(
                              height: 16,
                              width: 80,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 0.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: shimmerItemColor,
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /* Choose Plan */
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: ShimmerWidget.roundrectborder(
                            height: 52,
                            width: MediaQuery.of(context).size.width * 0.5,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  color: black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        constraints: const BoxConstraints(minHeight: 55),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidget.roundrectborder(
                              height: 18,
                              width: 120,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            ShimmerWidget.roundrectborder(
                              height: 16,
                              width: 80,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 0.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: shimmerItemColor,
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /* Choose Plan */
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: ShimmerWidget.roundrectborder(
                            height: 52,
                            width: MediaQuery.of(context).size.width * 0.5,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5,
                  color: black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        constraints: const BoxConstraints(minHeight: 55),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidget.roundrectborder(
                              height: 18,
                              width: 120,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            ShimmerWidget.roundrectborder(
                              height: 16,
                              width: 80,
                              shimmerBgColor: shimmerItemColor,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 0.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: shimmerItemColor,
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Row(
                          children: [
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 100,
                                shimmerBgColor: shimmerItemColor,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                            SizedBox(width: 20),
                            ShimmerWidget.circular(
                              height: 30,
                              width: 30,
                              shimmerBgColor: shimmerItemColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /* Choose Plan */
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: ShimmerWidget.roundrectborder(
                            height: 52,
                            width: MediaQuery.of(context).size.width * 0.5,
                            shimmerBgColor: shimmerItemColor,
                            shapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static Widget buildAvatarGrid(context, double itemHeight, double itemWidth,
      int crossAxisCount, int itemCount) {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: kIsWeb ? (itemCount + 10) : itemCount,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int position) {
        return Container(
          width: itemWidth,
          height: itemHeight,
          alignment: Alignment.center,
          child: ShimmerWidget.circular(
            height: itemHeight,
            shimmerBgColor: shimmerItemColor,
          ),
        );
      },
    );
  }

  static Widget buildHistoryShimmer(context, int itemCount) {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 12,
      padding: const EdgeInsets.only(left: 15, right: 15),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kIsWeb ? (itemCount + 10) : itemCount,
      itemBuilder: (BuildContext context, int position) {
        return Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(minHeight: Dimens.heightHistory),
          decoration: Utils.setBackground(lightBlack, 5),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /* Title */
                      const ShimmerWidget.roundrectborder(
                        height: 20,
                        width: 120,
                        shimmerBgColor: black,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),

                      /* Price */
                      Container(
                        constraints: const BoxConstraints(minHeight: 0),
                        margin: const EdgeInsets.only(top: 5),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.roundrectborder(
                              height: 15,
                              width: 80,
                              shimmerBgColor: black,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            SizedBox(width: 5),
                            ShimmerWidget.roundrectborder(
                              height: 15,
                              width: 3,
                              shimmerBgColor: black,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 120,
                                shimmerBgColor: black,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /* Expire On */
                      Container(
                        constraints: const BoxConstraints(minHeight: 0),
                        margin: const EdgeInsets.only(top: 5),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.roundrectborder(
                              height: 15,
                              width: 80,
                              shimmerBgColor: black,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            SizedBox(width: 5),
                            ShimmerWidget.roundrectborder(
                              height: 15,
                              width: 3,
                              shimmerBgColor: black,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: ShimmerWidget.roundrectborder(
                                height: 18,
                                width: 120,
                                shimmerBgColor: black,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 30,
                constraints: const BoxConstraints(minWidth: 0),
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                alignment: Alignment.center,
                child: const ShimmerWidget.roundrectborder(
                  height: 20,
                  width: 100,
                  shimmerBgColor: black,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

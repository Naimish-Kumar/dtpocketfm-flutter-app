import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtpocketfm/model/subscriptionmodel.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// import 'package:dtpocketfm/model/subscriptionmodel.dart' as type;

class Subscription extends StatefulWidget {
  const Subscription({
    super.key,
  });

  @override
  State<Subscription> createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription>
    with TickerProviderStateMixin {
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  SharedPre sharedPre = SharedPre();
  String? userName, userEmail, userMobileNo;
  TabController? tabController;

  @override
  void initState() {
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    super.initState();
    _getData();
  }

  _getData() async {
    Utils.getCurrencySymbol();
    await subscriptionProvider.getPackages();
    tabController = TabController(
        length: subscriptionProvider.subscriptionModel.result?.length ?? 0,
        vsync: this);
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscriptionProvider.clearProvider();
    super.dispose();
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    if (Constant.userID != null) {
      // for (var i = 0; i < (packageList?.length ?? 0); i++) {
      //   if (packageList?[i].isBuy == 1) {
      //     debugPrint("<============= Purchaged =============>");
      //     Utils.showSnackbar(context, "info", "already_purchased", true);
      //     return;
      //   }
      // }
      // if (packageList?[index].isBuy == 0) {
      /* Update Required data for payment */
      if ((userName ?? "").isEmpty ||
          (userEmail ?? "").isEmpty ||
          (userMobileNo ?? "").isEmpty) {
        await updateDataDialog(
          isNameReq: (userName ?? "").isEmpty,
          isEmailReq: (userEmail ?? "").isEmpty,
          isMobileReq: (userMobileNo ?? "").isEmpty,
        );
        return;
      }
      /* Update Required data for payment */
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AllPayment(
              payType: 'Package',
              itemId: packageList?[index].id.toString() ?? '',
              price: packageList?[index].price.toString() ?? '',
              itemTitle: packageList?[index].name.toString() ?? '',
              coin: packageList?[index].coin.toString() ?? "",
              typeId: '',
              videoType: '',
              productPackage: (!kIsWeb)
                  ? (Platform.isIOS
                      ? (packageList?[index].iosProductPackage.toString() ?? '')
                      : (packageList?[index].androidProductPackage.toString() ??
                          ''))
                  : '',
              currency: '',
            );
          },
        ),
      );
      // }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "");
        return;
      }
      await Navigator.push(
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

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');
  }

  updateDataDialog({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    debugPrint('getUserData isMobileReq ==> $isMobileReq');
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      constraints: BoxConstraints(
          maxWidth: kIsWeb
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width),
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        backgroundColor: appBgColor,
        body: SingleChildScrollView(
          child: _buildSubscription(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: appBgColor,
        // appBar: Utils.myAppBarWithBack(context, "subsciption", true),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Premium Image (Static)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.40,
                    alignment: Alignment.center,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimaryDark.withOpacity(0.1),
                          colorPrimaryDark.withOpacity(1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: MyImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fill,
                        imagePath: "introbg.png"),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.25,
                          imagePath: "ic_premium.png"),
                      MyText(
                        fontsizeWeb: 18,
                        color: white,
                        text: "freehdaudiodownload",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 18,
                        // inter: true,
                        maxline: 2,
                        fontweight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      MyText(
                        fontsizeWeb: 18,
                        color: white,
                        text: "fiftypercentoff",
                        textalign: TextAlign.center,
                        fontsizeNormal: 18,
                        multilanguage: true,
                        // inter: true,
                        maxline: 2,
                        fontweight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  Positioned(
                    top: 50,
                    left: 15,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          focusColor: white.withOpacity(0.40),
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: MyImage(
                                width: 18,
                                height: 18,
                                imagePath: "backwith_bg.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(child: _buildSubscription())),
            /* AdMob Banner */
            Container(
              child: Utils.showBannerAd(context),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSubscription() {
    if (subscriptionProvider.loading) {
      if ((kIsWeb || Constant.isTV) &&
          MediaQuery.of(context).size.width > 720) {
        return ShimmerUtils.buildSubscribeShimmer(context);
      } else {
        return ShimmerUtils.buildSubscribeShimmer(context);
      }
    } else {
      if (subscriptionProvider.subscriptionModel.status == 200) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Premium Image (Static)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  alignment: Alignment.center,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appBgColor.withOpacity(0.1),
                        appBgColor.withOpacity(1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: MyImage(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.fill,
                      imagePath: "introbg.png"),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.25,
                        imagePath: "ic_premium.png"),
                    MyText(
                      fontsizeWeb: 18,
                      color: white,
                      text: "freehdaudiodownload",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: 18,
                      // inter: true,
                      maxline: 2,
                      fontweight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    MyText(
                      fontsizeWeb: 18,
                      color: white,
                      text: "fiftypercentoff",
                      textalign: TextAlign.center,
                      fontsizeNormal: 18,
                      multilanguage: true,
                      // inter: true,
                      maxline: 2,
                      fontweight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                Positioned(
                  top: 50,
                  left: 15,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        focusColor: white.withOpacity(0.40),
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: MyImage(
                              width: 18,
                              height: 18,
                              imagePath: "backwith_bg.png"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
                height: ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720)
                    ? 40
                    : 12),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.center,
              child: MyText(
                color: otherColor,
                text: "subscriptiondesc",
                multilanguage: true,
                textalign: TextAlign.center,
                fontsizeNormal: 16,
                fontsizeWeb: 18,
                maxline: 2,
                fontweight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
            ),
            SizedBox(
                height: ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720)
                    ? 40
                    : 12),

            /* Remaining Data */
            _buildItems(subscriptionProvider.subscriptionModel.result),
            const SizedBox(height: 20),

            /* Web Footer */
            kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
          ],
        );
      } else {
        return const NoData(title: 'nodata', subTitle: '');
      }
    }
    // return Consumer<SubscriptionProvider>(
    //   builder: (context, subscriptionProvider, child) {
    //     if (subscriptionProvider.loading) {
    //       debugPrint("Shimmer Calling");
    //       return coinPacksShimmer();
    //     } else {
    //       if (subscriptionProvider.subscriptionModel.status == 200 &&
    //           subscriptionProvider.subscriptionModel.result != null) {
    //         return ListView.builder(
    //           scrollDirection: Axis.vertical,
    //           shrinkWrap: true,
    //           physics: const NeverScrollableScrollPhysics(),
    //           itemCount: subscriptionProvider.subscriptionModel.result?.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return InkWell(
    //               onTap: () async {
    //                 if (Constant.userID != null) {
    //                   _checkAndPay(
    //                       subscriptionProvider.subscriptionModel.result, index);
    //                   // await Navigator.push(
    //                   //   context,
    //                   //   MaterialPageRoute(
    //                   //     builder: (context) {
    //                   //       return AllPayment(
    //                   //         payType: 'Package',
    //                   //         itemId: subscriptionProvider
    //                   //                 .subscriptionModel.result?[index].id
    //                   //                 .toString() ??
    //                   //             '',
    //                   //         price: subscriptionProvider
    //                   //                 .subscriptionModel.result?[index].price
    //                   //                 .toString() ??
    //                   //             '',
    //                   //         itemTitle: subscriptionProvider
    //                   //                 .subscriptionModel.result?[index].name
    //                   //                 .toString() ??
    //                   //             '',
    //                   //         coin: subscriptionProvider
    //                   //                 .subscriptionModel.result?[index].coin
    //                   //                 .toString() ??
    //                   //             "",
    //                   //         typeId: '',
    //                   //         videoType: '',
    //                   //         productPackage: (!kIsWeb)
    //                   //             ? (Platform.isIOS
    //                   //                 ? (subscriptionProvider.subscriptionModel
    //                   //                         .result?[index].iosProductPackage
    //                   //                         .toString() ??
    //                   //                     '')
    //                   //                 : (subscriptionProvider
    //                   //                         .subscriptionModel
    //                   //                         .result?[index]
    //                   //                         .androidProductPackage
    //                   //                         .toString() ??
    //                   //                     ''))
    //                   //             : '',
    //                   //         currency: '',
    //                   //       );
    //                   //     },
    //                   //   ),
    //                   // );
    //                 } else {
    //                   Utils.openLogin(
    //                       context: context, isHome: false, isReplace: false);
    //                 }
    //               },
    //               child: Card(
    //                 clipBehavior: Clip.antiAliasWithSaveLayer,
    //                 elevation: 3,
    //                 color: subscriptionBG,
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 child: Container(
    //                   color: black1,
    //                   width: MediaQuery.of(context).size.width,
    //                   padding: const EdgeInsets.only(
    //                       left: 18, right: 18, top: 10, bottom: 10),
    //                   constraints: const BoxConstraints(minHeight: 55),
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             MyText(
    //                               color: white,
    //                               text: subscriptionProvider.subscriptionModel
    //                                       .result?[index].name ??
    //                                   "",
    //                               textalign: TextAlign.start,
    //                               fontsizeNormal: 15,
    //                               fontsizeWeb: 24,
    //                               maxline: 1,
    //                               multilanguage: false,
    //                               overflow: TextOverflow.ellipsis,
    //                               fontweight: FontWeight.w600,
    //                               fontstyle: FontStyle.normal,
    //                             ),
    //                             const SizedBox(
    //                               height: 10,
    //                             ),
    //                             Row(
    //                               children: [
    //                                 MyImage(
    //                                   imagePath: "coin.png",
    //                                   height: Dimens.coinImgHeight,
    //                                   width: Dimens.coinImgWidth,
    //                                 ),
    //                                 const SizedBox(
    //                                   width: 10,
    //                                 ),
    //                                 MyText(
    //                                   maxline: 3,
    //                                   color: colorPrimary,
    //                                   multilanguage: false,
    //                                   text:
    //                                       "You will get ${subscriptionProvider.subscriptionModel.result?[index].coin.toString() ?? ""} Coins",
    //                                   fontsizeNormal: 13,
    //                                   fontweight: FontWeight.w500,
    //                                   fontsizeWeb: 15,
    //                                 ),

    //                                 //
    //                               ],
    //                             )
    //                           ],
    //                         ),
    //                       ),
    //                       const SizedBox(width: 5),
    //                       Container(
    //                         padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
    //                         alignment: Alignment.center,
    //                         height: Dimens.coinPriceContHeight,
    //                         width: Dimens.coinPriceContWidth,
    //                         decoration: BoxDecoration(
    //                           gradient:
    //                               LinearGradient(colors: coinPrice.colors),
    //                           borderRadius: BorderRadius.circular(10),
    //                         ),
    //                         child: MyText(
    //                           color: white,
    //                           fontsizeWeb: 15,
    //                           multilanguage: false,
    //                           text:
    //                               "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
    //                           fontsizeNormal: 14,
    //                           fontweight: FontWeight.w600,
    //                         ),
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             );
    //           },
    //         );
    //       } else {
    //         return const SizedBox.shrink();
    //       }
    //     }
    //   },
    // );
  }

  Widget _buildItems(List<Result>? packageList) {
    if ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 800) {
      return buildMobileItem(packageList);
    } else {
      return buildMobileItem(packageList);
    }
  }

  Widget buildMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return Column(
        children: [
          TabBar(
            indicatorColor: colorAccent,
            isScrollable: true,
            unselectedLabelColor: gray,
            labelPadding: const EdgeInsets.only(left: 15, right: 15),
            physics: const AlwaysScrollableScrollPhysics(),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 1,
                color: colorAccent,
              ),
            ),
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontStyle: FontStyle.normal,
              color: colorAccent,
              fontWeight: FontWeight.w500,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.all(0),
            labelColor: colorAccent,
            indicatorPadding: const EdgeInsets.only(left: 15, right: 10),
            controller: tabController,
            tabs: List<Widget>.generate(packageList.length, (ind) {
              return Tab(child: Text(packageList[ind].name.toString()));
            }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: TabBarView(
              controller: tabController,
              physics: const BouncingScrollPhysics(),
              children: List<Widget>.generate(
                subscriptionProvider.subscriptionModel.result?.length ?? 0,
                (ind) {
                  return SingleChildScrollView(
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  height: MediaQuery.of(context).size.height,
                                  imagePath: "ic_halfround.png"),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                      fontsizeWeb: 24,
                                      color: white,
                                      text:
                                          "${Constant.currencySymbol.toString()} ${subscriptionProvider.subscriptionModel.result?[ind].price.toString() ?? ""}",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 24,
                                      // // // inter: true,
                                      maxline: 6,
                                      fontweight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 10),
                                  MyText(
                                      fontsizeWeb: 15,
                                      color: white,
                                      text:
                                          "${subscriptionProvider.subscriptionModel.result?[ind].coin.toString() ?? ""} Coins",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 15,
                                      // // // inter: true,
                                      maxline: 6,
                                      fontweight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // packageItem(
                        //     "ic_audio.png", "freehdqulityaudio"),
                        // const SizedBox(height: 15),
                        // packageItem("ic_downloadAudio.png",
                        //     "freeunlimiteddownload"),
                        // const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () {
                              _checkAndPay(
                                  subscriptionProvider.subscriptionModel.result,
                                  ind);
                            },
                            child: _buildPayBtn(
                              price: subscriptionProvider
                                      .subscriptionModel.result?[ind].price
                                      .toString() ??
                                  "",
                              isBuy: subscriptionProvider
                                      .subscriptionModel.result?[ind].isBuy ??
                                  0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget coinPacksShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 10,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          alignment: Alignment.centerLeft,
          height: Dimens.coinPacksContHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: darkappbgcolor,
              border: Border.all(
                width: 0.2,
                color: white,
              ),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 22,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      decoration: BoxDecoration(
                          // color: colorPrimary,
                          borderRadius: BorderRadius.circular(5)),
                      child: const ShimmerWidget.roundcorner(
                        height: 15,
                        width: 80,
                      ),
                    ),
                    Row(
                      children: [
                        ShimmerWidget.circular(
                          height: Dimens.coinImgHeight,
                          width: Dimens.coinImgWidth,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const ShimmerWidget.roundcorner(
                          height: 20,
                          width: 80,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        const ShimmerWidget.roundcorner(
                          height: 20,
                          width: 60,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                alignment: Alignment.center,
                height: Dimens.coinPriceContHeight,
                width: Dimens.coinPriceContWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: coinPrice.colors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const ShimmerWidget.roundcorner(
                  height: 20,
                  width: 35,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayBtn({required String price, required int isBuy}) {
    // if (isBuy == 1) {
    //   return Container(
    //     width: MediaQuery.of(context).size.width,
    //     height: 45,
    //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     alignment: Alignment.center,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(9),
    //       gradient: LinearGradient(
    //         colors: [
    //           colorAccent.withOpacity(0.6),
    //           yellow.withOpacity(1),
    //         ],
    //         begin: Alignment.centerLeft,
    //         end: Alignment.centerRight,
    //       ),
    //     ),
    //     child: MyText(
    //       color: white,
    //       text: "current",
    //       multilanguage: true,
    //       textalign: TextAlign.center,
    //       fontsizeNormal: 16,
    //       // inter: true,
    //       maxline: 6,
    //       fontweight: FontWeight.w600,
    //       overflow: TextOverflow.ellipsis,
    //       fontstyle: FontStyle.normal,
    //     ),
    //   );
    // } else {
    return Container(
      width: kIsWeb
          ? MediaQuery.of(context).size.width * 0.55
          : MediaQuery.of(context).size.width,
      height: 45,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        gradient: LinearGradient(
          colors: [
            colorAccent.withOpacity(0.6),
            yellow.withOpacity(1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: Constant.currencySymbol.toString(),
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    color: white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: " $price",
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        color: white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MyText(
            color: white,
            text: "buynow", fontsizeWeb: 18,
            multilanguage: true,
            textalign: TextAlign.center,
            fontsizeNormal: 16,
            // inter: true,
            maxline: 6,
            fontweight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ],
      ),
    );
    // }
  }

  Widget buildWebItem(List<Result>? packageList) {
    // if (packageList != null) {
    //   return Container(
    //     padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
    //     child: ResponsiveGridList(
    //       minItemWidth: (MediaQuery.of(context).size.width > 720)
    //           ? Dimens.widthPackageWeb
    //           : Dimens.widthPackage,
    //       verticalGridSpacing: 8,
    //       horizontalGridSpacing: 6,
    //       minItemsPerRow: 1,
    //       maxItemsPerRow: 3,
    //       listViewBuilderOptions: ListViewBuilderOptions(
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //       ),
    //       children: List.generate(
    //         (packageList.length),
    //         (index) {
    //           return Card(
    //             clipBehavior: Clip.antiAliasWithSaveLayer,
    //             elevation: 3,
    //             color: (packageList[index].isBuy == 1 ? colorPrimary : black),
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(8),
    //             ),
    //             child: Column(
    //               children: [
    //                 Container(
    //                   width: MediaQuery.of(context).size.width,
    //                   padding: const EdgeInsets.only(left: 18, right: 18),
    //                   constraints: const BoxConstraints(minHeight: 55),
    //                   child: Row(
    //                     crossAxisAlignment: CrossAxisAlignment.center,
    //                     children: [
    //                       Expanded(
    //                         child: MyText(
    //                           color: (packageList[index].isBuy == 1
    //                               ? black
    //                               : colorPrimary),
    //                           text: packageList[index].name ?? "",
    //                           textalign: TextAlign.start,
    //                           fontsizeNormal: 18,
    //                           fontsizeWeb: 24,
    //                           maxline: 1,
    //                           multilanguage: false,
    //                           overflow: TextOverflow.ellipsis,
    //                           fontweight: FontWeight.w700,
    //                           fontstyle: FontStyle.normal,
    //                         ),
    //                       ),
    //                       const SizedBox(width: 5),
    //                       MyText(
    //                         color: (packageList[index].isBuy == 1
    //                             ? black
    //                             : colorPrimary),
    //                         text:
    //                             "${Constant.currencySymbol} ${packageList[index].price.toString()} ",
    //                         textalign: TextAlign.center,
    //                         fontsizeNormal: 16,
    //                         fontsizeWeb: 22,
    //                         maxline: 1,
    //                         multilanguage: false,
    //                         overflow: TextOverflow.ellipsis,
    //                         fontweight: FontWeight.w600,
    //                         fontstyle: FontStyle.normal,
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 Container(
    //                   width: MediaQuery.of(context).size.width,
    //                   height: 0.5,
    //                   margin: const EdgeInsets.only(bottom: 12),
    //                   color: otherColor,
    //                 ),
    //                 // Container(
    //                 //   margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
    //                 //   height: 300,
    //                 //   child: SingleChildScrollView(
    //                 //     child: _buildBenefits(packageList, index),
    //                 //   ),
    //                 // ),
    //                 const SizedBox(height: 20),

    //                 /* Choose Plan */
    //                 Align(
    //                   alignment: Alignment.bottomCenter,
    //                   child: Container(
    //                     margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    //                     child: InkWell(
    //                       borderRadius: BorderRadius.circular(5),
    //                       onTap: () async {
    //                         _checkAndPay(packageList, index);
    //                       },
    //                       child: Container(
    //                         height: 45,
    //                         padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    //                         decoration: BoxDecoration(
    //                           color: (packageList[index].isBuy == 1
    //                               ? white
    //                               : colorPrimary),
    //                           borderRadius: BorderRadius.circular(5),
    //                         ),
    //                         alignment: Alignment.center,
    //                         child: Consumer<SubscriptionProvider>(
    //                           builder: (context, subscriptionProvider, child) {
    //                             return MyText(
    //                               color: black,
    //                               text: (packageList[index].isBuy == 1)
    //                                   ? "current"
    //                                   : "chooseplan",
    //                               textalign: TextAlign.center,
    //                               fontsizeNormal: 16,
    //                               fontsizeWeb: 20,
    //                               fontweight: FontWeight.w700,
    //                               multilanguage: true,
    //                               maxline: 1,
    //                               overflow: TextOverflow.ellipsis,
    //                               fontstyle: FontStyle.normal,
    //                             );
    //                           },
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 20),
    //               ],
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   );
    // } else {
    //   return const SizedBox.shrink();
    // }
    if (packageList != null) {
      return Column(
        children: [
          TabBar(
            indicatorColor: colorAccent,
            isScrollable: true,
            unselectedLabelColor: gray,
            labelPadding: const EdgeInsets.only(left: 15, right: 15),
            physics: const AlwaysScrollableScrollPhysics(),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 1,
                color: colorAccent,
              ),
            ),
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontStyle: FontStyle.normal,
              color: colorAccent,
              fontWeight: FontWeight.w500,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.all(0),
            labelColor: colorAccent,
            indicatorPadding: const EdgeInsets.only(left: 15, right: 10),
            controller: tabController,
            tabs: List<Widget>.generate(packageList.length, (ind) {
              return Tab(child: Text(packageList[ind].name.toString()));
            }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: TabBarView(
              controller: tabController,
              physics: const BouncingScrollPhysics(),
              children: List<Widget>.generate(
                subscriptionProvider.subscriptionModel.result?.length ?? 0,
                (ind) {
                  return SingleChildScrollView(
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  height: MediaQuery.of(context).size.height,
                                  imagePath: "ic_halfround.png"),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                      fontsizeWeb: 24,
                                      color: white,
                                      text:
                                          "${Constant.currencySymbol.toString()} ${subscriptionProvider.subscriptionModel.result?[ind].price.toString() ?? ""}",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 24,
                                      // // // inter: true,
                                      maxline: 6,
                                      fontweight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(height: 10),
                                  MyText(
                                      fontsizeWeb: 15,
                                      color: white,
                                      text:
                                          "${subscriptionProvider.subscriptionModel.result?[ind].coin.toString() ?? ""} Coins",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 15,
                                      // // // inter: true,
                                      maxline: 6,
                                      fontweight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // packageItem(
                        //     "ic_audio.png", "freehdqulityaudio"),
                        // const SizedBox(height: 15),
                        // packageItem("ic_downloadAudio.png",
                        //     "freeunlimiteddownload"),
                        // const SizedBox(height: 15),
                        Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () {
                              _checkAndPay(
                                  subscriptionProvider.subscriptionModel.result,
                                  ind);
                            },
                            child: _buildPayBtn(
                              price: subscriptionProvider
                                      .subscriptionModel.result?[ind].price
                                      .toString() ??
                                  "",
                              isBuy: subscriptionProvider
                                      .subscriptionModel.result?[ind].isBuy ??
                                  0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Widget _buildBenefits(List<Result>? packageList, int? index) {
  //   if (packageList?[index ?? 0].data != null &&
  //       (packageList?[index ?? 0].data?.length ?? 0) > 0) {
  //     return AlignedGridView.count(
  //       shrinkWrap: true,
  //       crossAxisCount: 1,
  //       crossAxisSpacing: 8,
  //       mainAxisSpacing: 25,
  //       padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
  //       itemCount: (packageList?[index ?? 0].data?.length ?? 0),
  //       physics: const NeverScrollableScrollPhysics(),
  //       scrollDirection: Axis.vertical,
  //       itemBuilder: (BuildContext context, int position) {
  //         return Container(
  //           constraints: const BoxConstraints(minHeight: 15),
  //           width: MediaQuery.of(context).size.width,
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: MyText(
  //                   color: (packageList?[index ?? 0].isBuy == 1
  //                       ? black
  //                       : otherColor),
  //                   text: packageList?[index ?? 0].data?[position].packageKey ??
  //                       "",
  //                   textalign: TextAlign.start,
  //                   multilanguage: false,
  //                   fontsizeNormal: 15,
  //                   fontsizeWeb: 18,
  //                   maxline: 3,
  //                   overflow: TextOverflow.ellipsis,
  //                   fontweight: FontWeight.w600,
  //                   fontstyle: FontStyle.normal,
  //                 ),
  //               ),
  //               const SizedBox(width: 20),
  //               ((packageList?[index ?? 0].data?[position].packageValue ??
  //                               "") ==
  //                           "1" ||
  //                       (packageList?[index ?? 0]
  //                                   .data?[position]
  //                                   .packageValue ??
  //                               "") ==
  //                           "0")
  //                   ? MyImage(
  //                       width: 23,
  //                       height: 23,
  //                       color: (packageList?[index ?? 0]
  //                                       .data?[position]
  //                                       .packageValue ??
  //                                   "") ==
  //                               "1"
  //                           ? (packageList?[index ?? 0].isBuy == 1
  //                               ? black
  //                               : colorPrimary)
  //                           : redColor,
  //                       imagePath: (packageList?[index ?? 0]
  //                                       .data?[position]
  //                                       .packageValue ??
  //                                   "") ==
  //                               "1"
  //                           ? "tick_mark.png"
  //                           : "cross_mark.png",
  //                     )
  //                   : MyText(
  //                       color: (packageList?[index ?? 0].isBuy == 1
  //                           ? black
  //                           : otherColor),
  //                       text: packageList?[index ?? 0]
  //                               .data?[position]
  //                               .packageValue ??
  //                           "",
  //                       textalign: TextAlign.center,
  //                       fontsizeNormal: 16,
  //                       fontsizeWeb: 24,
  //                       multilanguage: false,
  //                       maxline: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       fontweight: FontWeight.bold,
  //                       fontstyle: FontStyle.normal,
  //                     ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }
}

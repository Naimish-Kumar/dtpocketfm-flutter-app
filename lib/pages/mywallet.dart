import 'dart:io';

import 'package:dtpocketfm/pages/viewrewards.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/subscription/wallet.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  late ProfileProvider profileProvider;
  late HomeProvider homeProvider;
  late ScrollController _scrollController;
  late SubscriptionProvider subscriptionProvider;
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();
  @override
  void initState() {
    debugPrint("Userid is == ${Constant.userID}");
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    // walletProvider = Provider.of<WalletProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    homeProvider.setLoading(true);
    subscriptionProvider.setLoading(true);
    _initializeData();

    super.initState();
  }

  void _initializeData() async {
    await _getUserData();
    getApi();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');
  }

  @override
  void dispose() {
    homeProvider.clearProvider();
    super.dispose();
  }

  updateDataDialog({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
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

  getApi() async {
    await profileProvider.getProfile(context);
    await subscriptionProvider.getPackages();
    _fetchData(0);
  }

  _scrollListener() async {
    debugPrint("scroll controll ");
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (homeProvider.transactioncurrentPage ?? 0) <
            (homeProvider.transactiontotalPage ?? 0)) {
      debugPrint("load more====>");
      homeProvider.setLoadMore(true);
      await _fetchData((homeProvider.transactioncurrentPage ?? 0) + 1);
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    debugPrint("isMorePage  ======> ${profileProvider.isMorePage}");
    debugPrint("currentPage ======> ${profileProvider.currentPage}");
    debugPrint("totalPage   ======> ${profileProvider.totalPage}");
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    await homeProvider.getWalletTransactionList((nextPage ?? 0) + 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: MyImage(
              imagePath: 'backwith_bg.png',
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: appBgColor,
        centerTitle: false,
        elevation: 0,
        title: MyText(
          multilanguage: true,
          fontsizeWeb: 18,
          color: white,
          text: "my_wallet",
          fontsizeNormal: 20,
          fontweight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            kIsWeb ? webcurrentBalance() : currentBalance(),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: MyText(
                  multilanguage: true,
                  color: white,
                  text: "coin_packs",
                  fontsizeWeb: 15,
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w600,
                ),
              ),
            ),
            kIsWeb ? webCoinPacks() : coinPacks()
          ],
        ),
      ),
    );
  }

  Widget currentBalance() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.3
                : MediaQuery.of(context).size.width,
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: MyImage(
                  fit: BoxFit.cover,
                  imagePath: "currentbalance_bg.png",
                  height: 110,
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.3
                      : MediaQuery.of(context).size.width,
                ),
              ),
              Positioned(
                  top: 25,
                  left: 10,
                  child: SizedBox(
                    width: kIsWeb
                        ? MediaQuery.of(context).size.width * 0.29
                        : MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                multilanguage: true,
                                fontsizeWeb: 14,
                                text: "current_balance",
                                fontsizeNormal: 14,
                                maxline: 1,
                                fontweight: FontWeight.w500,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  MyImage(
                                    imagePath: "coin.png",
                                    height: Dimens.coinImgHeight,
                                    width: Dimens.coinImgWidth,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Consumer<ProfileProvider>(
                                    builder: (context, profileprovider, child) {
                                      if (profileprovider.loading) {
                                        return Container();
                                      } else {
                                        if (profileprovider
                                                    .profileModel.status ==
                                                200 &&
                                            (profileprovider.profileModel.result
                                                        ?.length ??
                                                    0) >
                                                0) {
                                          return MyText(
                                            color: white,
                                            multilanguage: false,
                                            fontsizeWeb: 14,
                                            text:
                                                "${profileprovider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins ",
                                            fontsizeNormal: 14,
                                            fontweight: FontWeight.w600,
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      }
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        MediaQuery.of(context).size.width > 800
                            ? InkWell(
                                onTap: () async {
                                  // Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //             builder: (context) => const ViewRewards()))
                                  //     .then((value) => getApi());
                                  if (Constant.userID != null) {
                                    await Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Wallet(),
                                          ),
                                        )
                                        .then((value) => getApi());
                                  } else {
                                    if (kIsWeb) {
                                      Utils.buildWebAlertDialog(
                                          context, "login", "");
                                    } else {
                                      Utils.openLogin(
                                          context: context,
                                          isHome: false,
                                          isReplace: false);
                                    }
                                  }
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 0,
                                    maxHeight: 45,
                                    minWidth: 0,
                                    maxWidth: 150,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(10),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: MyText(
                                    color: black,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    multilanguage: true,
                                    text: "view_wallet",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 14,
                                    fontsizeWeb: 14,
                                    fontweight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ))
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              if (Constant.userID != null) {
                await Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const ViewRewards(),
                      ),
                    )
                    .then((value) => getApi());
              } else {
                if (kIsWeb) {
                  Utils.buildWebAlertDialog(context, "login", "");
                } else {
                  Utils.openLogin(
                      context: context, isHome: false, isReplace: false);
                }
              }
            },
            child: Container(
              constraints: const BoxConstraints(
                  minHeight: 0, maxHeight: 40, minWidth: 0, maxWidth: 200),
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(10),
                shape: BoxShape.rectangle,
              ),
              child: MyText(
                color: black,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                multilanguage: true,
                text: "view_rewards",
                textalign: TextAlign.center,
                fontsizeNormal: 14,
                fontsizeWeb: 14,
                fontweight: FontWeight.w500,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget webcurrentBalance() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              height: 110,
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/currentbalance_bg.png"),
                  )),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          multilanguage: true,
                          fontsizeWeb: 14,
                          text: "current_balance",
                          fontsizeNormal: 14,
                          maxline: 2,
                          fontweight: FontWeight.w500,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            MyImage(
                              imagePath: "coin.png",
                              height: Dimens.coinImgHeight,
                              width: Dimens.coinImgWidth,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Consumer<ProfileProvider>(
                                builder: (context, profileprovider, child) {
                                  if (profileprovider.loading) {
                                    return Container();
                                  } else {
                                    if (profileprovider.profileModel.status ==
                                            200 &&
                                        (profileprovider.profileModel.result
                                                    ?.length ??
                                                0) >
                                            0) {
                                      return MyText(
                                        color: white,
                                        multilanguage: false,
                                        fontsizeWeb: 14,
                                        text:
                                            "${profileprovider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins ",
                                        fontsizeNormal: 14,
                                        fontweight: FontWeight.w600,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      // Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => const ViewRewards()))
                      //     .then((value) => getApi());
                      if (Constant.userID != null) {
                        await Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const Wallet(),
                              ),
                            )
                            .then((value) => getApi());
                      } else {
                        if (kIsWeb) {
                          Utils.buildWebAlertDialog(context, "login", "");
                        } else {
                          Utils.openLogin(
                              context: context,
                              isHome: false,
                              isReplace: false);
                        }
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 0,
                        maxHeight: 45,
                      ),
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: MyText(
                        color: black,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        multilanguage: true,
                        text: "view_wallet",
                        textalign: TextAlign.center,
                        fontsizeNormal: 14,
                        fontsizeWeb: 14,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            !kIsWeb
                ? InkWell(
                    onTap: () async {
                      if (Constant.userID != null) {
                        await Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const ViewRewards(),
                              ),
                            )
                            .then((value) => getApi());
                      } else {
                        if (kIsWeb) {
                          Utils.buildWebAlertDialog(context, "login", "");
                        } else {
                          Utils.openLogin(
                              context: context,
                              isHome: false,
                              isReplace: false);
                        }
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                          minHeight: 0,
                          maxHeight: 40,
                          minWidth: 0,
                          maxWidth: 200),
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: MyText(
                        color: black,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        multilanguage: true,
                        text: "view_rewards",
                        textalign: TextAlign.center,
                        fontsizeNormal: 14,
                        fontsizeWeb: 14,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget coinPacks() {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        if (subscriptionProvider.loading) {
          debugPrint("Shimmer Calling");
          return coinPacksShimmer();
        } else {
          if (subscriptionProvider.subscriptionModel.status == 200 &&
              subscriptionProvider.subscriptionModel.result != null) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subscriptionProvider.subscriptionModel.result?.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () async {
                    if (Constant.userID != null) {
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
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AllPayment(
                                payType: 'Package',
                                itemId: subscriptionProvider
                                        .subscriptionModel.result?[index].id
                                        .toString() ??
                                    '',
                                price: subscriptionProvider
                                        .subscriptionModel.result?[index].price
                                        .toString() ??
                                    '',
                                itemTitle: subscriptionProvider
                                        .subscriptionModel.result?[index].name
                                        .toString() ??
                                    '',
                                coin: subscriptionProvider
                                        .subscriptionModel.result?[index].coin
                                        .toString() ??
                                    "",
                                typeId: '',
                                videoType: '',
                                productPackage: (!kIsWeb)
                                    ? (Platform.isIOS
                                        ? (subscriptionProvider
                                                .subscriptionModel
                                                .result?[index]
                                                .iosProductPackage
                                                .toString() ??
                                            '')
                                        : (subscriptionProvider
                                                .subscriptionModel
                                                .result?[index]
                                                .androidProductPackage
                                                .toString() ??
                                            ''))
                                    : '',
                                currency: '',
                              );
                            },
                          ),
                        );
                      }
                    } else {
                      if (kIsWeb) {
                        Utils.buildWebAlertDialog(context, "login", "");
                      } else {
                        Utils.openLogin(
                            context: context, isHome: false, isReplace: false);
                      }
                    }
                  },
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 3,
                    color: subscriptionBG,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      color: black1,
                      // width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          left: 18, right: 18, top: 10, bottom: 10),
                      constraints: const BoxConstraints(minHeight: 55),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  color: white,
                                  text: subscriptionProvider.subscriptionModel
                                          .result?[index].name ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 24,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontweight: FontWeight.w600,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    MyImage(
                                      imagePath: "coin.png",
                                      height: Dimens.coinImgHeight,
                                      width: Dimens.coinImgWidth,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    MyText(
                                      maxline: 3,
                                      color: colorPrimary,
                                      fontsizeWeb: 13,
                                      multilanguage: false,
                                      text:
                                          "You will get ${subscriptionProvider.subscriptionModel.result?[index].coin.toString() ?? ""} Coins",
                                      fontsizeNormal: 13,
                                      fontweight: FontWeight.w500,
                                    ),

                                    //
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                            alignment: Alignment.center,
                            height: Dimens.coinPriceContHeight,
                            width: Dimens.coinPriceContWidth,
                            decoration: BoxDecoration(
                              gradient:
                                  LinearGradient(colors: coinPrice.colors),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MyText(
                              color: white,
                              multilanguage: false,
                              fontsizeWeb: 14,
                              text:
                                  "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                              fontsizeNormal: 14,
                              fontweight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget webCoinPacks() {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        if (subscriptionProvider.loading) {
          debugPrint("Shimmer Calling");
          return webCoinPacksShimmer();
        } else {
          if (subscriptionProvider.subscriptionModel.status == 200 &&
              subscriptionProvider.subscriptionModel.result != null) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ResponsiveGridList(
                  minItemWidth: 500,
                  minItemsPerRow: 1,
                  maxItemsPerRow: 2,
                  horizontalGridSpacing: 10,
                  verticalGridSpacing: 10,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: List.generate(
                    subscriptionProvider.subscriptionModel.result?.length ?? 0,
                    (index) {
                      return InkWell(
                        onTap: () async {
                          if (Constant.userID != null) {
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
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AllPayment(
                                      payType: 'Package',
                                      itemId: subscriptionProvider
                                              .subscriptionModel
                                              .result?[index]
                                              .id
                                              .toString() ??
                                          '',
                                      price: subscriptionProvider
                                              .subscriptionModel
                                              .result?[index]
                                              .price
                                              .toString() ??
                                          '',
                                      itemTitle: subscriptionProvider
                                              .subscriptionModel
                                              .result?[index]
                                              .name
                                              .toString() ??
                                          '',
                                      coin: subscriptionProvider
                                              .subscriptionModel
                                              .result?[index]
                                              .coin
                                              .toString() ??
                                          "",
                                      typeId: '',
                                      videoType: '',
                                      productPackage: (!kIsWeb)
                                          ? (Platform.isIOS
                                              ? (subscriptionProvider
                                                      .subscriptionModel
                                                      .result?[index]
                                                      .iosProductPackage
                                                      .toString() ??
                                                  '')
                                              : (subscriptionProvider
                                                      .subscriptionModel
                                                      .result?[index]
                                                      .androidProductPackage
                                                      .toString() ??
                                                  ''))
                                          : '',
                                      currency: '',
                                    );
                                  },
                                ),
                              );
                            }
                          } else {
                            if (kIsWeb) {
                              Utils.buildWebAlertDialog(context, "login", "");
                            } else {
                              Utils.openLogin(
                                  context: context,
                                  isHome: false,
                                  isReplace: false);
                            }
                          }
                        },
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 3,
                          color: subscriptionBG,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            color: black1,
                            // width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.only(
                                left: 18, right: 18, top: 10, bottom: 10),
                            constraints: const BoxConstraints(minHeight: 55),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        color: white,
                                        text: subscriptionProvider
                                                .subscriptionModel
                                                .result?[index]
                                                .name ??
                                            "",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 15,
                                        fontsizeWeb: 24,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontweight: FontWeight.w600,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          MyImage(
                                            imagePath: "coin.png",
                                            height: Dimens.coinImgHeight,
                                            width: Dimens.coinImgWidth,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          MyText(
                                            maxline: 3,
                                            color: colorPrimary,
                                            fontsizeWeb: 13,
                                            multilanguage: false,
                                            text:
                                                "You will get ${subscriptionProvider.subscriptionModel.result?[index].coin.toString() ?? ""} Coins",
                                            fontsizeNormal: 13,
                                            fontweight: FontWeight.w500,
                                          ),

                                          //
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                  alignment: Alignment.center,
                                  height: Dimens.coinPriceContHeight,
                                  width: Dimens.coinPriceContWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: coinPrice.colors),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: MyText(
                                    color: white,
                                    multilanguage: false,
                                    fontsizeWeb: 14,
                                    text:
                                        "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
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

  Widget webCoinPacksShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ResponsiveGridList(
        minItemWidth: 500,
        minItemsPerRow: 1,
        maxItemsPerRow: 2,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          3,
          (index) {
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
        ),
      ),
    );
  }
}

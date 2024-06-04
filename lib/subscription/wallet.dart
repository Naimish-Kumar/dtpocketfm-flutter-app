import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> with TickerProviderStateMixin {
  late ProfileProvider profileProvider;
  late HomeProvider homeProvider;
  late ScrollController _scrollController;
  late TabController _controller;

  controllerEvent() {
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      homeProvider.setTabPosition(_controller.index);
      setState(() {});
      debugPrint("Selected Index: ${_controller.index}");
    });
  }

  // late WalletProvider walletProvider;
  @override
  void initState() {
    debugPrint("Userid is == ${Constant.userID}");
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    controllerEvent();
    homeProvider.setLoading(true);
    getApi();
    super.initState();
  }

  @override
  void dispose() {
    homeProvider.clearProvider();
    _controller.dispose();
    super.dispose();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (homeProvider.selectedTab == 0) {
        if ((homeProvider.transactioncurrentPage ?? 0) <
            (homeProvider.transactiontotalPage ?? 0)) {
          homeProvider.setLoadMore(true);
          await _fetchData((homeProvider.transactioncurrentPage ?? 0));
        }
      } else if (homeProvider.selectedTab == 1) {
        if ((homeProvider.wallettransactioncurrentPage ?? 0) <
            (homeProvider.wallettransactiontotalPage ?? 0)) {
          homeProvider.setLoadMore(true);
          await fetchTransactionData(
              (homeProvider.wallettransactioncurrentPage ?? 0));
        }
      }
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    await homeProvider.getWalletTransactionList((nextPage ?? 0) + 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /* Section Data Api */
  Future<void> fetchTransactionData(int? nextPage) async {
    await homeProvider.getTransactionList((nextPage ?? 0) + 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  getApi() async {
    await profileProvider.getProfile(context);
    _fetchData(0);
    fetchTransactionData(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(
          context, "Wallet", kIsWeb ? false : true, false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mycoins(),
          const Divider(
            color: gray,
            thickness: 1,
          ),
          Expanded(
              child: homeProvider.walletloading
                  ? kIsWeb
                      ? webCoinPacksShimmer()
                      : coinPacksShimmer()
                  : kIsWeb
                      ? webBuildTabs()
                      : _buildTabs())
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          TabBar(
            controller: _controller,
            labelPadding: const EdgeInsets.all(5),
            unselectedLabelColor: white,
            indicatorColor: primaryDark,
            labelColor: primaryDark,
            tabs: [
              MyText(
                fontsizeWeb: 11,
                color: primaryDark,
                text: "Usage History",
                fontsizeNormal: 13,
              ),
              MyText(
                fontsizeWeb: 11,
                color: primaryDark,
                text: "Purchase History",
                fontsizeNormal: 13,
              ),
            ],
          ),
          _tabbarview(),
        ],
      ),
    );
  }

  Widget webBuildTabs() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: TabBar(
              controller: _controller,
              labelPadding: const EdgeInsets.all(5),
              unselectedLabelColor: white,
              indicatorColor: primaryDark,
              labelColor: primaryDark,
              tabs: [
                MyText(
                  fontsizeWeb: 11,
                  color: primaryDark,
                  text: "Usage History",
                  fontsizeNormal: 13,
                ),
                MyText(
                  fontsizeWeb: 11,
                  color: primaryDark,
                  text: "Purchase History",
                  fontsizeNormal: 13,
                ),
              ],
            ),
          ),
          _tabbarview(),
        ],
      ),
    );
  }

  Widget _tabbarview() {
    switch (homeProvider.selectedTab) {
      case 0:
        return kIsWeb ? webCoinPacks() : coinPacks();
      case 1:
        return kIsWeb ? webTransactionList() : transactionList();

      default:
        return kIsWeb ? webCoinPacks() : coinPacks();
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

  Widget webCoinPacksShimmer() {
    return ResponsiveGridList(
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
    );
  }

  Widget coinPacks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<HomeProvider>(
          builder: (context, transactionprovider, child) {
            if (transactionprovider.transactionListModel.status == 200 &&
                (transactionprovider.walletTransactionlist?.length ?? 0) > 0) {
              return ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount:
                    transactionprovider.walletTransactionlist?.length ?? 0,
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
                    alignment: Alignment.center,
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
                                alignment: Alignment.center,
                                height: 22,
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  children: [
                                    MyText(
                                      color: black,
                                      multilanguage: false,
                                      text: transactionprovider
                                                  .walletTransactionlist?[index]
                                                  .contentType ==
                                              1
                                          ? (transactionprovider
                                                      .walletTransactionlist?[
                                                          index]
                                                      .audiobookType) ==
                                                  1
                                              ? "Audio --"
                                              : "Video --"
                                          : "Novel --",
                                      fontsizeNormal: 12,
                                      fontweight: FontWeight.w500,
                                      fontsizeWeb: 10,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        color: black,
                                        text: transactionprovider
                                                .walletTransactionlist?[index]
                                                .episodeName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: 10,
                                        fontsizeWeb: 10,
                                        fontweight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              MyText(
                                fontsizeWeb: 10,
                                color: colorPrimary,
                                multilanguage: false,
                                text:
                                    "-- ${formatDate(transactionprovider.walletTransactionlist?[index].createdAt.toString() ?? "")}",
                                fontsizeNormal: 12,
                                fontweight: FontWeight.w500,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyImage(
                                  imagePath: "coin.png",
                                  height: Dimens.coinImgHeight,
                                  width: Dimens.coinImgWidth,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                MyText(
                                  fontsizeWeb: 12,
                                  color: white,
                                  multilanguage: false,
                                  text: transactionprovider
                                          .walletTransactionlist?[index].coin
                                          .toString() ??
                                      "",
                                  fontsizeNormal: 14,
                                  fontweight: FontWeight.w600,
                                ),
                              ],
                            ))
                      ],
                    ),
                  );
                },
              );
            } else {
              return const NoData(title: 'nodata', subTitle: '');
            }
          },
        ),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            if (homeProvider.loadmore) {
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
    );
  }

  Widget webCoinPacks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<HomeProvider>(
          builder: (context, transactionprovider, child) {
            if (transactionprovider.transactionListModel.status == 200 &&
                (transactionprovider.walletTransactionlist?.length ?? 0) > 0) {
              return ResponsiveGridList(
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
                  transactionprovider.walletTransactionlist?.length ?? 0,
                  (index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
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
                                  alignment: Alignment.center,
                                  height: 22,
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    children: [
                                      MyText(
                                        color: black,
                                        multilanguage: false,
                                        text: transactionprovider
                                                    .walletTransactionlist?[
                                                        index]
                                                    .contentType ==
                                                1
                                            ? (transactionprovider
                                                        .walletTransactionlist?[
                                                            index]
                                                        .audiobookType) ==
                                                    1
                                                ? "Audio --"
                                                : "Video --"
                                            : "Novel --",
                                        fontsizeNormal: 12,
                                        fontweight: FontWeight.w500,
                                        fontsizeWeb: 10,
                                      ),
                                      Expanded(
                                        child: MyText(
                                          color: black,
                                          text: transactionprovider
                                                  .walletTransactionlist?[index]
                                                  .episodeName
                                                  .toString() ??
                                              "",
                                          fontsizeNormal: 10,
                                          fontsizeWeb: 10,
                                          fontweight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MyText(
                                  fontsizeWeb: 10,
                                  color: colorPrimary,
                                  multilanguage: false,
                                  text:
                                      "-- ${formatDate(transactionprovider.walletTransactionlist?[index].createdAt.toString() ?? "")}",
                                  fontsizeNormal: 12,
                                  fontweight: FontWeight.w500,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyImage(
                                    imagePath: "coin.png",
                                    height: Dimens.coinImgHeight,
                                    width: Dimens.coinImgWidth,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  MyText(
                                    fontsizeWeb: 12,
                                    color: white,
                                    multilanguage: false,
                                    text: transactionprovider
                                            .walletTransactionlist?[index].coin
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                  ),
                                ],
                              ))
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return const NoData(title: 'nodata', subTitle: '');
            }
          },
        ),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            if (homeProvider.loadmore) {
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
    );
  }

  Widget mycoins() {
    return Consumer<ProfileProvider>(
      builder: (context, profileprovider, child) {
        if (profileprovider.loading) {
          return profileShimmer();
        } else {
          if (profileprovider.profileModel.status == 200 &&
              (profileprovider.profileModel.result?.length ?? 0) > 0) {
            return kIsWeb ? webCoinsDetails() : coinsDetails();
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget coinsDetails() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyImage(
                      imagePath: "coin.png",
                      height: 25,
                      width: 25,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MyText(
                      fontsizeWeb: 18,
                      color: white,
                      text:
                          "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins ",
                      fontsizeNormal: 22,
                      fontweight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                MyText(
                  fontsizeWeb: 12,
                  multilanguage: true,
                  color: white,
                  text: "current_balance",
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w400,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Subscription();
                  },
                ),
              );
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: MyText(
                fontsizeWeb: 13,
                color: colorPrimaryDark,
                text: "Add Coins",
                fontsizeNormal: 16,
                fontweight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget webCoinsDetails() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MyImage(
                    imagePath: "coin.png",
                    height: 25,
                    width: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MyText(
                    fontsizeWeb: 18,
                    color: white,
                    text:
                        "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins ",
                    fontsizeNormal: 22,
                    fontweight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              MyText(
                fontsizeWeb: 12,
                multilanguage: true,
                color: white,
                text: "current_balance",
                fontsizeNormal: 15,
                fontweight: FontWeight.w400,
              ),
            ],
          ),
          const SizedBox(
            width: 50,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Subscription();
                  },
                ),
              );
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: MyText(
                fontsizeWeb: 13,
                color: colorPrimaryDark,
                text: "Add Coins",
                fontsizeNormal: 16,
                fontweight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget transactionList() {
  //   return Consumer<WalletProvider>(
  //     builder: (context, walletprovider, child) {
  //       if (walletprovider.loading) {
  //         return listShimmer();
  //       } else {
  //         if (walletprovider.episodeTransactionModel.status == 200 &&
  //             (walletprovider.episodeTransactionModel.result?.length ?? 0) >
  //                 0) {
  //           return ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: walletprovider.episodeTransactionModel.result?.length,
  //             itemBuilder: (BuildContext context, int index) {
  //               return Container(
  //                 margin: const EdgeInsets.all(10),
  //                 padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
  //                 height: 90,
  //                 decoration: BoxDecoration(
  //                     color: white, borderRadius: BorderRadius.circular(10)),
  //                 child: Row(
  //                   children: [
  //                     ClipRRect(
  //                       borderRadius: const BorderRadius.all(
  //                         Radius.circular(50),
  //                       ),
  //                       child: MyNetworkImage(
  //                         imageUrl: walletprovider.episodeTransactionModel
  //                                 .result?[index].userImage
  //                                 .toString() ??
  //                             "",
  //                         imgHeight: 60,
  //                         imgWidth: 60,
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                     const SizedBox(
  //                       width: 10,
  //                     ),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           MyText(
  //                             color: black,
  //                             text: walletprovider.episodeTransactionModel
  //                                     .result?[index].userName
  //                                     .toString() ??
  //                                 "",
  //                             fontsizeNormal: 18,
  //                             fontweight: FontWeight.w600,
  //                           ),
  //                           const SizedBox(
  //                             height: 10,
  //                           ),
  //                           MyText(
  //                             color: colorPrimaryDark,
  //                             text: walletprovider.episodeTransactionModel
  //                                     .result?[index].episodeName
  //                                     .toString() ??
  //                                 "",
  //                             fontsizeNormal: 16,
  //                             fontweight: FontWeight.w600,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     Column(
  //                       children: [
  //                         MyText(
  //                           color: black,
  //                           text: walletprovider.episodeTransactionModel
  //                                   .result?[index].totalAmount
  //                                   .toString() ??
  //                               "",
  //                           fontsizeNormal: 22,
  //                           fontweight: FontWeight.w600,
  //                         ),
  //                         const SizedBox(
  //                           height: 5,
  //                         ),
  //                         MyText(
  //                           color: black.withOpacity(0.6),
  //                           text: "Coins",
  //                           fontsizeNormal: 16,
  //                           fontweight: FontWeight.w600,
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               );
  //             },
  //           );
  //         } else {
  //           return Stack(children: [
  //             MyImage(
  //               height: 300,
  //               width: MediaQuery.of(context).size.width,
  //               fit: BoxFit.contain,
  //               imagePath: "nocoins.png",
  //             ),
  //             Positioned.fill(
  //               top: 250,
  //               child: Column(
  //                 children: [
  //                   MyText(
  //                     fontweight: FontWeight.w700,
  //                     multilanguage: true,
  //                     color: white,
  //                     text: "no_usage_history",
  //                     fontsizeNormal: 18,
  //                   ),
  //                   MyText(
  //                     multilanguage: true,
  //                     fontweight: FontWeight.w500,
  //                     color: white,
  //                     text: "coinswillappear",
  //                     fontsizeNormal: 15,
  //                   ),
  //                 ],
  //               ),
  //             )
  //           ]);
  //         }
  //       }
  //     },
  //   );
  // }

  Widget title() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: MyText(
        fontsizeWeb: 16,
        color: white,
        text: "Usage History ",
        fontsizeNormal: 22,
        fontweight: FontWeight.w600,
      ),
    );
  }

  Widget profileShimmer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const ShimmerWidget.roundcorner(
            height: 50,
            width: 400,
          ),
        ),
      ],
    );
  }

  Widget transactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<HomeProvider>(
          builder: (context, transactionprovider, child) {
            if (transactionprovider.wallettransactionListModel.status == 200 &&
                (transactionprovider.transactionlist?.length ?? 0) > 0) {
              return ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: transactionprovider.transactionlist?.length ?? 0,
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
                    alignment: Alignment.center,
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
                                alignment: Alignment.center,
                                height: 22,
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                decoration: BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: MyText(
                                  fontsizeWeb: 10,
                                  color: black,
                                  text: transactionprovider
                                          .transactionlist?[index].packageName
                                          .toString() ??
                                      "",
                                  fontsizeNormal: 10,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  MyImage(
                                    imagePath: "coin.png",
                                    height: Dimens.coinImgHeight,
                                    width: Dimens.coinImgWidth,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  MyText(
                                    fontsizeWeb: 10,
                                    color: white,
                                    multilanguage: false,
                                    text: transactionprovider
                                            .transactionlist?[index].coin
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  MyText(
                                    fontsizeWeb: 10,
                                    color: colorPrimary,
                                    multilanguage: false,
                                    text:
                                        "-- ${formatDate(transactionprovider.transactionlist?[index].createdAt.toString() ?? "")}",
                                    fontsizeNormal: 12,
                                    fontweight: FontWeight.w500,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        // Container(
                        //   padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                        //   alignment: Alignment.center,
                        //   height: Dimens.coinPriceContHeight,
                        //   width: Dimens.coinPriceContWidth,
                        //   decoration: BoxDecoration(
                        //     gradient:
                        //         LinearGradient(colors: coinPrice.colors),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: MyText(
                        //     color: white,
                        //     multilanguage: false,
                        //     text: transactionprovider.transactionlist?[index]
                        //                 .contentType ==
                        //             1
                        //         ? (transactionprovider.transactionlist?[index]
                        //                     .audiobookType) ==
                        //                 1
                        //             ? "Audio"
                        //             : "Video"
                        //         : "Novel",
                        //     fontsizeNormal: 14,
                        //     fontweight: FontWeight.w600,
                        //   ),
                        // )
                      ],
                    ),
                  );
                },
              );
            } else {
              return const NoData(title: 'nodata', subTitle: '');
            }
          },
        ),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            if (homeProvider.loadmore) {
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
    );
  }

  Widget webTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<HomeProvider>(
          builder: (context, transactionprovider, child) {
            if (transactionprovider.wallettransactionListModel.status == 200 &&
                (transactionprovider.transactionlist?.length ?? 0) > 0) {
              return ResponsiveGridList(
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
                  transactionprovider.transactionlist?.length ?? 0,
                  (index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
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
                                  alignment: Alignment.center,
                                  height: 22,
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: MyText(
                                    fontsizeWeb: 10,
                                    color: black,
                                    text: transactionprovider
                                            .transactionlist?[index].packageName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 10,
                                    fontweight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    MyImage(
                                      imagePath: "coin.png",
                                      height: Dimens.coinImgHeight,
                                      width: Dimens.coinImgWidth,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    MyText(
                                      fontsizeWeb: 10,
                                      color: white,
                                      multilanguage: false,
                                      text: transactionprovider
                                              .transactionlist?[index].coin
                                              .toString() ??
                                          "",
                                      fontsizeNormal: 14,
                                      fontweight: FontWeight.w600,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    MyText(
                                      fontsizeWeb: 10,
                                      color: colorPrimary,
                                      multilanguage: false,
                                      text:
                                          "-- ${formatDate(transactionprovider.transactionlist?[index].createdAt.toString() ?? "")}",
                                      fontsizeNormal: 12,
                                      fontweight: FontWeight.w500,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          // Container(
                          //   padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                          //   alignment: Alignment.center,
                          //   height: Dimens.coinPriceContHeight,
                          //   width: Dimens.coinPriceContWidth,
                          //   decoration: BoxDecoration(
                          //     gradient:
                          //         LinearGradient(colors: coinPrice.colors),
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: MyText(
                          //     color: white,
                          //     multilanguage: false,
                          //     text: transactionprovider.transactionlist?[index]
                          //                 .contentType ==
                          //             1
                          //         ? (transactionprovider.transactionlist?[index]
                          //                     .audiobookType) ==
                          //                 1
                          //             ? "Audio"
                          //             : "Video"
                          //         : "Novel",
                          //     fontsizeNormal: 14,
                          //     fontweight: FontWeight.w600,
                          //   ),
                          // )
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return const NoData(title: 'nodata', subTitle: '');
            }
          },
        ),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            if (homeProvider.loadmore) {
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
    );
  }

  listShimmer() {
    return SingleChildScrollView(
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        itemBuilder: (BuildContext context, int index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: ShimmerWidget.roundcorner(
              height: 90,
              width: 400,
            ),
          );
        },
      ),
    );
  }
}

import 'package:dtpocketfm/provider/rewardprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
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
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewRewards extends StatefulWidget {
  const ViewRewards({super.key});

  @override
  State<ViewRewards> createState() => _ViewRewardsState();
}

class _ViewRewardsState extends State<ViewRewards> {
  late RewardProvider rewardProvider;
  late ScrollController _scrollController;
  late ProgressDialog prDialog;
  dynamic progress;
  SharedPre sharedPre = SharedPre();
  int? daysSinceLastClaim;
  @override
  void initState() {
    prDialog = ProgressDialog(context);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    rewardProvider.setLoading(true);
    _getData();
    super.initState();
  }

  _scrollListener() async {
    debugPrint("scroll controll ");
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (rewardProvider.currentPage ?? 0) < (rewardProvider.totalPage ?? 0)) {
      debugPrint("load more====>");
      rewardProvider.setLoadMore(true);
      await _fetchData((rewardProvider.currentPage ?? 0));
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    await rewardProvider.getEarnTransactionsList((nextPage ?? 0) + 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _getData() async {
    progress = await sharedPre.read('progress') ?? 0.0;
    debugPrint("progress == $progress");
    await rewardProvider.getEarnCoins();

    await _fetchData(0);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    rewardProvider.cleaProvider();
    super.dispose();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
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
            padding: const EdgeInsets.all(18.0),
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
          color: white,
          text: "my_rewards",
          fontsizeNormal: 16,
          fontsizeWeb: 15,
          fontweight: FontWeight.w500,
        ),
      ),
      body: bonusdata(),
    );
  }

  Widget bonusdata() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(children: [
            MyImage(
              imagePath: "bonus_bg.png",
              height: Dimens.bonusBgImgheight,
              // width: Dimens.bonusBgImgwidth,
              fit: BoxFit.cover,
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.65
                  : Dimens.bonusBgImgwidth,
            ),
          ]),
          Container(
            transform: Matrix4.translationValues(0, -105, 0),
            child: Column(
              children: [
                SizedBox(
                    width: kIsWeb
                        ? MediaQuery.of(context).size.width * 0.5
                        : Dimens.bonusBgImgwidth,
                    child: dayReward()),
                rewardProvider.isLoading
                    ? kIsWeb
                        ? webRewardListShimmer()
                        : rewardListShimmer()
                    : kIsWeb
                        ? webRewardsList()
                        : rewardsList()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget dayReward() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(color: gray.withOpacity(0.5), width: 0.2)),
        shadowColor: gray,
        elevation: 3,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            height: Dimens.dailyrewardHeight,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13), color: appBgColor),
            child: Consumer<RewardProvider>(
              builder: (context, rewardProvider, child) {
                if (rewardProvider.isLoading) {
                  return coinsShimmer();
                } else {
                  if (rewardProvider.earncoinsModel.status == 200 &&
                      (rewardProvider.earncoinsModel.dailyLogin?.length ?? 0) >
                          0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          fontsizeWeb: 15,
                          multilanguage: false,
                          color: colorPrimary,
                          text: "Check-in Streak: 0 Days",
                          fontsizeNormal: 16,
                          fontweight: FontWeight.w500,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Stack(children: [
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: rewardProvider
                                      .earncoinsModel.dailyLogin?.length ??
                                  0,
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  width: 12,
                                );
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    MyImage(
                                      imagePath: "rewardCoin.png",
                                      height: Dimens.coinImgHeight,
                                      width: Dimens.coinImgWidth,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    MyText(
                                      fontsizeWeb: 14,
                                      multilanguage: false,
                                      color: white,
                                      text:
                                          "${rewardProvider.earncoinsModel.dailyLogin?[index].value.toString() ?? ""} coins",
                                      fontsizeNormal: 12,
                                      fontweight: FontWeight.w500,
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    MyText(
                                      fontsizeWeb: 12,
                                      multilanguage: false,
                                      color: gray,
                                      text: rewardProvider.earncoinsModel
                                              .dailyLogin?[index].key
                                              .toString() ??
                                          "",
                                      fontsizeNormal: 10,
                                      fontweight: FontWeight.w500,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ]),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              if (Constant.userID != null) {
                                final earntransaction =
                                    Provider.of<RewardProvider>(context,
                                        listen: false);
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                int lastClaimedTimestamp =
                                    prefs.getInt('lastClaimedTimestamp') ?? 0;
                                int lastClaimedDay =
                                    prefs.getInt('lastClaimedDay') ?? 0;
                                int lastIndex = prefs.getInt('lastIndex') ?? 0;

                                int currentTimestamp =
                                    DateTime.now().millisecondsSinceEpoch;

                                int hoursDifference =
                                    (currentTimestamp - lastClaimedTimestamp) ~/
                                        (1000 * 60 * 60);

                                int newDay = lastClaimedDay;
                                int newIndex = lastIndex;

                                if (hoursDifference >= 24) {
                                  newDay = (lastClaimedDay % 7) + 1;
                                  newIndex = (lastIndex % 7) + 1;
                                  if (!context.mounted) return;
                                  AdHelper.rewardedAd(context, () async {
                                    Utils.showProgress(context, prDialog);
                                    await earntransaction.getEarnTransactions(
                                        rewardProvider.earncoinsModel
                                            .dailyLogin?[newIndex - 1].value,
                                        2);
                                    if (rewardProvider
                                            .earntransactionmodel.status ==
                                        200) {
                                      if (!context.mounted) return;
                                      Utils().hideProgress(context);
                                      Utils.showToast(
                                          "Reward Get Successfully");

                                      prefs.setInt('lastClaimedTimestamp',
                                          currentTimestamp);
                                      prefs.setInt('lastClaimedDay', newDay);
                                      prefs.setInt('lastIndex', newIndex);

                                      progress = 14.2857142857 * newIndex;
                                      await sharedPre.save(
                                          'progress', progress.toString());
                                    } else {
                                      if (!context.mounted) return;
                                      Utils().hideProgress(context);
                                      Utils.showToast("Something Went Wrong");
                                    }
                                  });
                                  // API Calling
                                } else {
                                  int remainingHours = 24 - hoursDifference;
                                  Utils.showToast(
                                      "You can claim your reward after $remainingHours hours");
                                }
                              } else {
                                Utils.openLogin(
                                    context: context,
                                    isHome: false,
                                    isReplace: false);
                              }
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
                                gradient:
                                    LinearGradient(colors: lightOrange.colors),
                                borderRadius: BorderRadius.circular(44),
                                shape: BoxShape.rectangle,
                              ),
                              child: MyText(
                                color: white,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                multilanguage: true,
                                text: "checkin",
                                textalign: TextAlign.center,
                                fontsizeNormal: 14,
                                fontsizeWeb: 16,
                                fontweight: FontWeight.w500,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            )),
      ),
    );
  }

  Widget coinsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerWidget.roundcorner(
          height: 20,
          width: 120,
          shimmerBgColor: shimmerItemColor,
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 12,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return Stack(children: [
                Column(
                  children: [
                    ShimmerWidget.circular(
                      height: Dimens.coinImgHeight,
                      width: Dimens.coinImgWidth,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ShimmerWidget.roundcorner(
                      height: 15,
                      width: 40,
                      shimmerBgColor: shimmerItemColor,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const ShimmerWidget.roundcorner(
                      height: 12,
                      width: 40,
                      shimmerBgColor: shimmerItemColor,
                    ),
                  ],
                ),
                Positioned(
                    top: 60,
                    child: Container(
                      color: profileBottomSheetBG,
                      height: 20,
                      width: MediaQuery.of(context).size.width,
                    ))
              ]);
            },
          ),
        ),
        const Center(
          child: ShimmerWidget.roundcorner(
            height: 45,
            width: 150,
          ),
        ),
      ],
    );
  }

  Widget rewardsList() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, child) {
        if (rewardProvider.earntransactionlistmodel.status == 200 &&
            (rewardProvider.transactionlist?.length ?? 0) > 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MyText(
                  fontsizeWeb: 15,
                  multilanguage: true,
                  color: colorPrimary,
                  text: "rewards_list",
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w600,
                ),
              ),
              ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: rewardProvider.transactionlist?.length ?? 0,
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
                                    fontsizeWeb: 15,
                                    color: white,
                                    multilanguage: false,
                                    text:
                                        "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 22,
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: MyText(
                                  color: gray,
                                  text: formatDate(rewardProvider
                                          .transactionlist?[index].createdAt
                                          .toString() ??
                                      ""),
                                  fontsizeNormal: 10,
                                  fontsizeWeb: 12,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.center,
                          height: Dimens.coinPriceContHeight,
                          // width: Dimens.coinPriceContWidth,
                          decoration: BoxDecoration(
                            color: darkBrown,
                            borderRadius: BorderRadius.circular(38),
                          ),
                          child: MyText(
                            color: white,
                            multilanguage: false,
                            fontsizeWeb: 15,
                            text:
                                "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              Consumer<RewardProvider>(
                builder: (context, rewardProvider, child) {
                  if (rewardProvider.loadmore) {
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
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget webRewardsList() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, child) {
        if (rewardProvider.earntransactionlistmodel.status == 200 &&
            (rewardProvider.transactionlist?.length ?? 0) > 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MyText(
                  fontsizeWeb: 15,
                  multilanguage: true,
                  color: colorPrimary,
                  text: "rewards_list",
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w600,
                ),
              ),
              Padding(
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
                    rewardProvider.transactionlist?.length ?? 0,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                        fontsizeWeb: 15,
                                        color: white,
                                        multilanguage: false,
                                        text:
                                            "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                                        fontsizeNormal: 14,
                                        fontweight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    height: 22,
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: MyText(
                                      color: gray,
                                      text: formatDate(rewardProvider
                                              .transactionlist?[index].createdAt
                                              .toString() ??
                                          ""),
                                      fontsizeNormal: 10,
                                      fontsizeWeb: 12,
                                      fontweight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.center,
                              height: Dimens.coinPriceContHeight,
                              // width: Dimens.coinPriceContWidth,
                              decoration: BoxDecoration(
                                color: darkBrown,
                                borderRadius: BorderRadius.circular(38),
                              ),
                              child: MyText(
                                color: white,
                                multilanguage: false,
                                fontsizeWeb: 15,
                                text:
                                    "${rewardProvider.transactionlist?[index].coin.toString() ?? ""} Coins",
                                fontsizeNormal: 14,
                                fontweight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Consumer<RewardProvider>(
                builder: (context, rewardProvider, child) {
                  if (rewardProvider.loadmore) {
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
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget rewardListShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: ShimmerWidget.roundcorner(
            height: 20,
            width: 120,
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.all(15),
          itemCount: 10,
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
                          ],
                        ),
                        Container(
                            alignment: Alignment.centerLeft,
                            height: 22,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: const ShimmerWidget.roundcorner(
                              height: 12,
                              width: 80,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    height: Dimens.coinPriceContHeight,
                    // width: Dimens.coinPriceContWidth,
                    decoration: BoxDecoration(
                      color: darkBrown,
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: const ShimmerWidget.roundcorner(
                      height: 15,
                      width: 30,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget webRewardListShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: ShimmerWidget.roundcorner(
            height: 20,
            width: 120,
          ),
        ),
        ResponsiveGridList(
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
            5,
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
                            ],
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              height: 22,
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: const ShimmerWidget.roundcorner(
                                height: 12,
                                width: 80,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
                      height: Dimens.coinPriceContHeight,
                      // width: Dimens.coinPriceContWidth,
                      decoration: BoxDecoration(
                        color: darkBrown,
                        borderRadius: BorderRadius.circular(38),
                      ),
                      child: const ShimmerWidget.roundcorner(
                        height: 15,
                        width: 30,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

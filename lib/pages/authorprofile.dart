import 'dart:convert';
import 'dart:io';

import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/pages/noveldetails.dart';
import 'package:dtpocketfm/pages/audiobookdetails.dart';
import 'package:dtpocketfm/provider/avatarprovider.dart';
import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/tvpages/webaudiobookdetails.dart';
import 'package:dtpocketfm/tvpages/webnoveldetails.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/getcontentbyartistmodel.dart';
import '../widget/mytext.dart';

class AuthorProfile extends StatefulWidget {
  final dynamic artistID;
  const AuthorProfile({super.key, required this.artistID});

  @override
  State<AuthorProfile> createState() => _AuthorProfileState();
}

class _AuthorProfileState extends State<AuthorProfile>
    with TickerProviderStateMixin {
  late TabController _controller;
  int selectedIndex = 0;
  late AvatarProvider artistProvider;
  late ScrollController _scrollController;
  late ShowDetailsProvider showdetailsprovider;
  late ProgressDialog prDialog;
  late ProfileProvider profileProvider;
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();
  late SubscriptionProvider subscriptionProvider;
  @override
  void initState() {
    super.initState();
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    showdetailsprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    artistProvider = Provider.of<AvatarProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    artistProvider.setLoading(true);
    controllerEvent();
    prDialog = ProgressDialog(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
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
    artistProvider.clearProvider();
    _controller.dispose();
    super.dispose();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  Future<void> _getData() async {
    await profileProvider.getProfile(context);
    await artistProvider.getArtistProfile(widget.artistID);
    await fetchAudioBook(0);
    await fetchmusic(0);
    await fetchNovel(0);
    await fetchThreads(0);
    await _getUserData();

    await subscriptionProvider.getPackages();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  Future<void> _launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  controllerEvent() {
    _controller = TabController(length: 4, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      artistProvider.setTabPosition(_controller.index);
      debugPrint("Selected Index: ${_controller.index}");
    });
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      debugPrint("AudioData Scroll Listner");
      if (artistProvider.selectedTab == 0) {
        if ((artistProvider.currentPage ?? 0) <
            (artistProvider.totalPage ?? 0)) {
          artistProvider.setLoadMore(true);
          await fetchAudioBook((artistProvider.currentPage ?? 0));
        }
      } else if (artistProvider.selectedTab == 1) {
        if ((artistProvider.musiccurrentPage ?? 0) <
            (artistProvider.musictotalPage ?? 0)) {
          artistProvider.musicsetLoadMore(true);
          await fetchmusic((artistProvider.musiccurrentPage ?? 0));
        }
      } else if (artistProvider.selectedTab == 2) {
        if ((artistProvider.novelcurrentPage ?? 0) <
            (artistProvider.noveltotalPage ?? 0)) {
          await artistProvider.novelsetLoadMore(true);
          await fetchNovel((artistProvider.novelcurrentPage ?? 0));
        }
      } else {
        if ((artistProvider.threadscurrentPage ?? 0) <
            (artistProvider.threadstotalPage ?? 0)) {
          await artistProvider.threadssetLoadMore(true);
          await fetchThreads((artistProvider.threadscurrentPage ?? 0));
        }
      }
    }
  }

  Future<void> fetchAudioBook(int? nextPage) async {
    await artistProvider.getContentByArtistID(
      1,
      widget.artistID,
      (nextPage ?? 0) + 1,
    );
  }

  Future<void> fetchThreads(int? nextPage) async {
    await artistProvider.getThreadByArtist(
      widget.artistID,
      (nextPage ?? 0) + 1,
    );
  }

  Future<void> fetchNovel(int? nextPage) async {
    await artistProvider.getNovelByArtistID(
        2, widget.artistID, (nextPage ?? 0) + 1);
  }

  Future<void> fetchmusic(int? nextPage) async {
    await artistProvider.getMusicByArtistID(
        widget.artistID, (nextPage ?? 0) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  authorProfileBg,
                  authorProfileBg.withOpacity(0.5),
                  appBgColor.withOpacity(0.2),
                  appBgColor
                ])),
            child: Consumer<AvatarProvider>(
              builder: (context, getartistprovider, child) {
                if (getartistprovider.loading &&
                    getartistprovider.isloading &&
                    getartistprovider.musicloading &&
                    getartistprovider.novelloading &&
                    getartistprovider.threadloading) {
                  return authorShimmer();
                } else {
                  if (getartistprovider.artistProfileModel.status == 200 &&
                      (getartistprovider.artistProfileModel.result?.length ??
                              0) >
                          0) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          backBtnRow(),
                          profile(),
                          kIsWeb ? _webBuildTabs() : _buildTabs()
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            )),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          labelPadding: const EdgeInsets.all(5),
          unselectedLabelColor: white,
          indicatorColor: primaryDark,
          labelColor: primaryDark,
          tabs: [
            MyText(
              fontsizeWeb: 15,
              color: primaryDark,
              text: "AudioBook",
              fontsizeNormal: 12,
            ),
            MyText(
              fontsizeWeb: 15,
              color: primaryDark,
              text: "Music",
              fontsizeNormal: 12,
            ),
            MyText(
              fontsizeWeb: 15,
              color: primaryDark,
              text: "Novel",
              fontsizeNormal: 12,
            ),
            MyText(
              fontsizeWeb: 15,
              color: primaryDark,
              text: "Threads",
              fontsizeNormal: 12,
            )
          ],
        ),
        _tabbarview(),
      ],
    );
  }

  Widget _webBuildTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width < 1000
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width * 0.3,
          child: TabBar(
            controller: _controller,
            labelPadding: const EdgeInsets.all(5),
            unselectedLabelColor: white,
            indicatorColor: primaryDark,
            labelColor: primaryDark,
            tabs: [
              MyText(
                maxline: 1,
                fontsizeWeb: 13,
                color: primaryDark,
                text: "AudioBook",
                fontsizeNormal: 12,
              ),
              MyText(
                maxline: 1,
                fontsizeWeb: 13,
                color: primaryDark,
                text: "Music",
                fontsizeNormal: 12,
              ),
              MyText(
                maxline: 1,
                fontsizeWeb: 13,
                color: primaryDark,
                text: "Novel",
                fontsizeNormal: 12,
              ),
              MyText(
                maxline: 1,
                fontsizeWeb: 13,
                color: primaryDark,
                text: "Threads",
                fontsizeNormal: 12,
              )
            ],
          ),
        ),
        _tabbarview(),
      ],
    );
  }

  Widget _tabbarview() {
    switch (artistProvider.selectedTab) {
      case 0:
        return audioBook();
      case 1:
        return music();
      case 2:
        return novel();
      case 3:
        return kIsWeb ? webThreads() : threads();
      default:
        return audioBook();
    }
  }

  profile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: MyNetworkImage(
                  imageUrl: artistProvider.artistProfileModel.result?[0].image
                          .toString() ??
                      "",
                  imgHeight: 89,
                  imgWidth: 89,
                  fit: BoxFit.fill,
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                fontsizeWeb: 16,
                color: white,
                text: artistProvider.artistProfileModel.result?[0].userName
                        .toString() ??
                    "",
                fontsizeNormal: 15,
                fontweight: FontWeight.w600,
              ),
              const SizedBox(
                width: 10,
              ),
              MyImage(
                imagePath: "ic_bluetick.png",
                height: 20,
                width: 20,
                fit: BoxFit.cover,
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _launchURL(artistProvider
                                .artistProfileModel.result?[0].instagramUrl
                                .toString() ??
                            "");
                      },
                      child: MyImage(
                        imagePath: 'instagram.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      if (Constant.userID != null) {
                        final addremovefollow =
                            Provider.of<AvatarProvider>(context, listen: false);
                        await addremovefollow.addremovefollow(
                          artistProvider.artistProfileModel.result?[0].id,
                        );
                      } else {
                        if (kIsWeb) {
                          Utils.buildWebAlertDialog(context, "login", "")
                              .then((value) => _getData());
                        } else {
                          Utils.openLogin(
                              context: context,
                              isHome: false,
                              isReplace: false);
                        }
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      height: Dimens.profilefollowBtnHeight,
                      width: Dimens.profilefollowBtnWidth,
                      constraints: BoxConstraints(
                        maxWidth: Dimens.profilefollowBtnWidth,
                      ),
                      decoration: BoxDecoration(
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(38)),
                      child: MyText(
                        fontsizeWeb: 12,
                        multilanguage: true,
                        fontsizeNormal: 13,
                        fontweight: FontWeight.w700,
                        color: white,
                        text: artistProvider
                                    .artistProfileModel.result?[0].isFollow ==
                                0
                            ? "follow"
                            : "unfollow",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _launchURL(artistProvider
                                .artistProfileModel.result?[0].facebookUrl
                                .toString() ??
                            "");
                      },
                      child: MyImage(
                        imagePath: 'ic_facebook.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  MyText(
                    fontsizeWeb: 15,
                    color: white,
                    text: artistProvider.artistProfileModel.result?[0].followes
                            .toString() ??
                        "",
                    fontsizeNormal: 15,
                    fontweight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    fontsizeWeb: 15,
                    color: white,
                    text: "Followers",
                    fontsizeNormal: 11,
                    fontweight: FontWeight.w400,
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          ExpandableText(
            animation: true,
            artistProvider.artistProfileModel.result?[0].bio.toString() ?? "",
            expandText: more,
            collapseText: less_,
            maxLines: (kIsWeb || Constant.isTV) ? 50 : 5,
            linkColor: primaryDark,
            expandOnTextTap: true,
            collapseOnTextTap: true,
            style: TextStyle(
              fontSize: (kIsWeb || Constant.isTV) ? 13 : 12,
              fontStyle: FontStyle.normal,
              color: white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget audioBook() {
    return Consumer<AvatarProvider>(
      builder: (context, getcontentprovider, child) {
        if (getcontentprovider.isloading &&
            getcontentprovider.loadMore == false) {
          return dataSHimmer();
        } else {
          if (getcontentprovider.getcontentbyartistmodel.status == 200 &&
              (getcontentprovider.contentDataList?.length ?? 0) > 0) {
            return Column(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: getcontentprovider.contentDataList?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        if (kIsWeb) {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        WebAudioBookDetails(
                                            getcontentprovider
                                                    .contentDataList?[index]
                                                    .id ??
                                                0,
                                            1),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child;
                                },
                              ));
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioBookDetails(
                                    getcontentprovider
                                            .contentDataList?[index].id ??
                                        0,
                                    1)),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: getcontentprovider
                                        .contentDataList?[index].portraitImg
                                        .toString() ??
                                    "",
                                imgHeight: 60,
                                imgWidth: 60),
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
                                text: getcontentprovider
                                        .contentDataList?[index].title
                                        .toString() ??
                                    "",
                                fontsizeNormal: 13,
                                fontsizeWeb: 15,
                                fontweight: FontWeight.w600,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              MyText(
                                color: primaryDark,
                                text:
                                    "${getcontentprovider.contentDataList?[index].totalEpisode.toString() ?? ""} Episodes",
                                fontsizeNormal: 12,
                                fontsizeWeb: 15,
                                fontweight: FontWeight.w600,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              MyText(
                                color: edtBG,
                                text:
                                    "${formatNumber(getcontentprovider.contentDataList?[index].totalUserPlay ?? 0)} Play",
                                fontsizeNormal: 12,
                                fontsizeWeb: 15,
                                fontweight: FontWeight.w600,
                              )
                            ],
                          ))
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                ),
                Consumer<AvatarProvider>(
                  builder: (context, artistProvider, child) {
                    if (artistProvider.loadMore) {
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
            return const SizedBox(
                height: 250, child: NoData(title: 'nodata', subTitle: ''));
          }
        }
      },
    );
  }

  Widget novel() {
    return Consumer<AvatarProvider>(
      builder: (context, getcontentprovider, child) {
        if (getcontentprovider.getNovelbyartistmodel.status == 200 &&
            (getcontentprovider.novelDataList?.length ?? 0) > 0) {
          return Column(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: getcontentprovider.novelDataList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      WebNovelDetails(
                                getcontentprovider.novelDataList?[index].id ??
                                    0,
                                2,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return child;
                              },
                            ));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return NovelDetails(
                                getcontentprovider.novelDataList?[index].id ??
                                    0,
                                2,
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: getcontentprovider
                                      .novelDataList?[index].portraitImg
                                      .toString() ??
                                  "",
                              imgHeight: 60,
                              imgWidth: 60),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              fontsizeWeb: 15,
                              color: white,
                              text: getcontentprovider
                                      .novelDataList?[index].title
                                      .toString() ??
                                  "",
                              fontsizeNormal: 13,
                              fontweight: FontWeight.w600,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            MyText(
                              fontsizeWeb: 15,
                              color: primaryDark,
                              text:
                                  "${getcontentprovider.novelDataList?[index].totalEpisode.toString() ?? ""} Episodes",
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w600,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            MyText(
                              fontsizeWeb: 15,
                              color: edtBG,
                              text:
                                  "${formatNumber(getcontentprovider.novelDataList?[index].totalUserPlay ?? 0)} Play",
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w600,
                            )
                          ],
                        ))
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
              ),
              Consumer<AvatarProvider>(
                builder: (context, artistProvider, child) {
                  if (artistProvider.loadMore) {
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
          return const SizedBox(
              height: 250, child: NoData(title: 'nodata', subTitle: ''));
        }
      },
    );
  }

  dataSHimmer() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(5),
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: const Row(
            children: [
              ShimmerWidget.roundcorner(
                height: 55,
                width: 55,
                shimmerBgColor: shimmerItemColor,
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.roundcorner(
                      height: 15,
                      width: 100,
                      shimmerBgColor: shimmerItemColor,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ShimmerWidget.roundcorner(
                      height: 15,
                      width: 75,
                      shimmerBgColor: shimmerItemColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget music() {
    return Consumer<AvatarProvider>(
      builder: (context, getcontentprovider, child) {
        if (getcontentprovider.getMusicbyartistmodel.status == 200 &&
            (getcontentprovider.musicDataList?.length ?? 0) > 0) {
          return Column(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: getcontentprovider.musicDataList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      playAudio(
                        playingType: "3",
                        episodeid: getcontentprovider.musicDataList?[index].id
                                .toString() ??
                            "",
                        contentid: getcontentprovider.musicDataList?[index].id
                                .toString() ??
                            "",
                        position: index,
                        sectionBannerList:
                            getcontentprovider.musicDataList ?? [],
                        contentName: getcontentprovider
                                .musicDataList?[index].title
                                .toString() ??
                            "",
                        isBuy: "1",
                        artistID: getcontentprovider
                            .musicDataList?[index].artistId
                            .toString(),
                        //  sectionList?[sectionindex]
                        //         .data?[index]
                        //         .isBuy
                        //         .toString() ??
                        //     "",
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: MyNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: getcontentprovider
                                      .musicDataList?[index].portraitImg
                                      .toString() ??
                                  "",
                              imgHeight: 60,
                              imgWidth: 60),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              fontsizeWeb: 15,
                              color: white,
                              text: getcontentprovider
                                      .musicDataList?[index].title
                                      .toString() ??
                                  "",
                              fontsizeNormal: 13,
                              fontweight: FontWeight.w600,
                            ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // MyText(
                            //   color: primaryDark,
                            //   text:
                            //       "${getcontentprovider.musicDataList?[index].totalEpisode.toString() ?? ""} Episodes",
                            //   fontsizeNormal: 12,
                            //   fontweight: FontWeight.w600,
                            // ),
                            const SizedBox(
                              height: 10,
                            ),
                            MyText(
                              fontsizeWeb: 15,
                              color: edtBG,
                              text:
                                  "${formatNumber(getcontentprovider.musicDataList?[index].totalUserPlay ?? 0)} Play",
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w600,
                            )
                          ],
                        ))
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
              ),
              Consumer<AvatarProvider>(
                builder: (context, artistProvider, child) {
                  if (artistProvider.loadMore) {
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
          return const SizedBox(
              height: 250, child: NoData(title: 'nodata', subTitle: ''));
        }
      },
    );
  }

  Widget backBtnRow() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: MyImage(
              imagePath: "backwith_bg.png",
              height: 20,
              width: 20,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            height: Dimens.followBtnHeight,
            width: Dimens.followBtnWidth,
            decoration: BoxDecoration(
                color: infoBG, borderRadius: BorderRadius.circular(38)),
            child: MyText(
              fontsizeWeb: 10,
              multilanguage: true,
              fontsizeNormal: 12,
              fontweight: FontWeight.w500,
              color: white,
              text: "author",
            ),
          )
        ],
      ),
    );
  }

  authorShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 150,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: ShimmerWidget.circular(
                  height: 89,
                  width: 89,
                  shimmerBgColor: shimmerItemColor,
                )),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerWidget.roundcorner(
                      height: 15,
                      width: 80,
                      shimmerBgColor: shimmerItemColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ShimmerWidget.circular(
                      height: 20,
                      width: 20,
                      shimmerBgColor: shimmerItemColor,
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: ShimmerWidget.roundcorner(
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(38)),
                    height: Dimens.profilefollowBtnHeight,
                    width: Dimens.profilefollowBtnWidth,
                    shimmerBgColor: shimmerItemColor,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 20,
                          shimmerBgColor: shimmerItemColor,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 20,
                          shimmerBgColor: shimmerItemColor,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 20,
                          shimmerBgColor: shimmerItemColor,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 20,
                          shimmerBgColor: shimmerItemColor,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 20,
                          shimmerBgColor: shimmerItemColor,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ShimmerWidget.roundcorner(
                          height: 15,
                          width: 20,
                          shimmerBgColor: shimmerItemColor,
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ShimmerWidget.roundcorner(
                  height: 15,
                  width: MediaQuery.of(context).size.width * 0.5,
                  shimmerBgColor: shimmerItemColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                ShimmerWidget.roundcorner(
                  height: 15,
                  width: MediaQuery.of(context).size.width * 0.5,
                  shimmerBgColor: shimmerItemColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                const ShimmerWidget.roundcorner(
                  height: 20,
                  width: 20,
                  shimmerBgColor: shimmerItemColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                const ShimmerWidget.roundcorner(
                  height: 25,
                  width: 60,
                  shimmerBgColor: shimmerItemColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                const ShimmerWidget.roundcorner(
                  height: 25,
                  width: 60,
                  shimmerBgColor: shimmerItemColor,
                ),
              ],
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ShimmerWidget.roundcorner(
                  height: 25,
                  width: 20,
                  shimmerBgColor: shimmerItemColor,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: ShimmerWidget.roundcorner(
                  height: 25,
                  width: 20,
                  shimmerBgColor: shimmerItemColor,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: ShimmerWidget.roundcorner(
                  height: 25,
                  width: 20,
                  shimmerBgColor: shimmerItemColor,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: [
                  ShimmerWidget.roundcorner(
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    height: 60,
                    width: 60,
                    shimmerBgColor: shimmerItemColor,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget.roundcorner(
                        height: 15,
                        width: 100,
                        shimmerBgColor: shimmerItemColor,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ShimmerWidget.roundcorner(
                        height: 15,
                        width: 75,
                        shimmerBgColor: shimmerItemColor,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ShimmerWidget.roundcorner(
                        height: 15,
                        width: 50,
                        shimmerBgColor: shimmerItemColor,
                      )
                    ],
                  ))
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 10,
              );
            },
          )
        ],
      ),
    );
  }

  Widget threads() {
    return Consumer<AvatarProvider>(builder: (context, profileProvider, child) {
      if (profileProvider.threadsbyartistModel.status == 200 &&
          (profileProvider.threadDataList?.length ?? 0) > 0) {
        return Column(
          children: [
            ListView.separated(
              itemCount: profileProvider.threadDataList?.length ?? 0,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 20,
                );
              },
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: MyText(
                              color: primaryDark,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: false,
                              text: profileProvider
                                      .threadDataList?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.start,
                              fontsizeNormal: 11,
                              fontsizeWeb: 18,
                              fontweight: FontWeight.w400,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            MyText(
                              color: gray,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: false,
                              text: formatDate(profileProvider
                                      .threadDataList?[index].createdAt
                                      .toString() ??
                                  ""),
                              textalign: TextAlign.center,
                              fontsizeNormal: 12,
                              fontsizeWeb: 18,
                              fontweight: FontWeight.w400,
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.more_horiz_outlined,
                              color: white,
                              size: 30,
                            )
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Column(
                          children: [
                            SizedBox(
                              height: 343,
                              child: VerticalDivider(
                                color: gray,
                                thickness: 0.8,
                                width: 50,
                                indent: 0,
                                endIndent: 0,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MyNetworkImage(
                                  imageUrl: profileProvider
                                          .threadDataList?[index].image
                                          .toString() ??
                                      "",
                                  imgHeight: 343,
                                  imgWidth: 343,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  // MyText(
                                  //   color: gray,
                                  //   text:
                                  //       "${threadDataProvider.threadbyuserlist?[index].totalComment.toString() ?? ""} Replies",
                                  //   fontsizeNormal: 12,
                                  //   fontweight: FontWeight.w500,
                                  // ),
                                  // const SizedBox(
                                  //   width: 10,
                                  // ),
                                  Container(
                                    height: 5,
                                    width: 5,
                                    decoration: BoxDecoration(
                                        color: gray,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  MyText(
                                    color: gray,
                                    text:
                                        "${profileProvider.threadDataList?[index].totalLike.toString() ?? ""} Likes",
                                    fontsizeNormal: 12,
                                    fontsizeWeb: 14,
                                    fontweight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                );
              },
            ),
            Consumer<AvatarProvider>(
              builder: (context, artistProvider, child) {
                if (artistProvider.loadMore) {
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
        return const SizedBox(
            height: 250, child: NoData(title: 'nodata', subTitle: ''));
      }
    });
  }

  Widget webThreads() {
    return Consumer<AvatarProvider>(builder: (context, profileProvider, child) {
      if (profileProvider.threadsbyartistModel.status == 200 &&
          (profileProvider.threadDataList?.length ?? 0) > 0) {
        return Column(
          children: [
            ListView.separated(
              itemCount: profileProvider.threadDataList?.length ?? 0,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 20,
                );
              },
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 720
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: MyText(
                                color: primaryDark,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                multilanguage: false,
                                text: profileProvider
                                        .threadDataList?[index].description
                                        .toString() ??
                                    "",
                                textalign: TextAlign.start,
                                fontsizeNormal: 11,
                                fontsizeWeb: 16,
                                fontweight: FontWeight.w400,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              MyText(
                                color: gray,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                multilanguage: false,
                                text: formatDate(profileProvider
                                        .threadDataList?[index].createdAt
                                        .toString() ??
                                    ""),
                                textalign: TextAlign.center,
                                fontsizeNormal: 12,
                                fontsizeWeb: 16,
                                fontweight: FontWeight.w400,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.more_horiz_outlined,
                                color: white,
                                size: 30,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 720
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          const Column(
                            children: [
                              SizedBox(
                                height: 343,
                                child: VerticalDivider(
                                  color: gray,
                                  thickness: 0.8,
                                  width: 50,
                                  indent: 0,
                                  endIndent: 0,
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: MyNetworkImage(
                                    imageUrl: profileProvider
                                            .threadDataList?[index].image
                                            .toString() ??
                                        "",
                                    imgHeight: 343,
                                    imgWidth: 343,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 5,
                                      width: 5,
                                      decoration: BoxDecoration(
                                          color: gray,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    MyText(
                                      color: gray,
                                      text:
                                          "${profileProvider.threadDataList?[index].totalLike.toString() ?? ""} Likes",
                                      fontsizeNormal: 12,
                                      fontsizeWeb: 14,
                                      fontweight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
            Consumer<AvatarProvider>(
              builder: (context, artistProvider, child) {
                if (artistProvider.loadMore) {
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
        return const SizedBox(
            height: 250, child: NoData(title: 'nodata', subTitle: ''));
      }
    });
  }

  threadShimmer() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 20,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            const Row(
              children: [
                ShimmerWidget.circular(
                  height: 40,
                  width: 40,
                  shimmerBgColor: shimmerItemColor,
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ShimmerWidget.roundrectborder(
                      height: 15,
                      width: 100,
                      shimmerBgColor: shimmerItemColor,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ShimmerWidget.roundrectborder(
                      height: 15,
                      width: 100,
                      shimmerBgColor: shimmerItemColor,
                    ),
                  ],
                )),
                Row(
                  children: [
                    ShimmerWidget.roundrectborder(
                      height: 15,
                      width: 40,
                      shimmerBgColor: shimmerItemColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.more_horiz_outlined,
                      color: white,
                      size: 30,
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 343,
                      child: VerticalDivider(
                        color: gray,
                        thickness: 0.8,
                        width: 50,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ),
                    Stack(children: [
                      Container(
                        height: 35,
                        width: 35,
                        color: appBgColor,
                      ),
                      const Positioned(
                        top: 0,
                        left: 0,
                        child: ShimmerWidget.circular(
                          height: 18,
                          width: 18,
                          shimmerBgColor: shimmerItemColor,
                        ),
                      ),
                      const Positioned(
                        top: 10,
                        right: 0,
                        child: ShimmerWidget.circular(
                          height: 18,
                          width: 18,
                          shimmerBgColor: shimmerItemColor,
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        left: 10,
                        child: ShimmerWidget.circular(
                          height: 18,
                          width: 18,
                          shimmerBgColor: shimmerItemColor,
                        ),
                      )
                    ])
                  ],
                ),
                Flexible(
                  child: Column(
                    children: [
                      const ShimmerWidget.roundrectborder(
                        height: 343,
                        width: 343,
                        shimmerBgColor: shimmerItemColor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          ShimmerWidget.roundrectborder(
                            height: Dimens.coinImgHeight,
                            width: Dimens.coinImgWidth,
                            shimmerBgColor: shimmerItemColor,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ShimmerWidget.roundrectborder(
                            height: Dimens.coinImgHeight,
                            width: Dimens.coinImgWidth,
                            shimmerBgColor: shimmerItemColor,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ShimmerWidget.roundrectborder(
                            height: Dimens.coinImgHeight,
                            width: Dimens.coinImgWidth,
                            shimmerBgColor: shimmerItemColor,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 40,
                            shimmerBgColor: shimmerItemColor,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                                color: gray,
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const ShimmerWidget.roundrectborder(
                            height: 10,
                            width: 40,
                            shimmerBgColor: shimmerItemColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        );
      },
      itemCount: 3,
    );
  }

  /* PlayAudio Player */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    required List<Result>? sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
    required String? artistID,
  }) async {
    debugPrint("playingType =====>>>>>> ? $playingType");
    debugPrint("episodeid =====>>>>>> ? $episodeid");
    debugPrint("contentid =====>>>>>> ? $contentid");
    debugPrint("podcastimage =====>>>>>> ? $podcastimage");
    debugPrint("contentUserid =====>>>>>> ? $contentUserid");
    debugPrint("position =====>>>>>> ? $position");
    debugPrint(
        "sectionBannerList =====>>>>>> ? ${jsonEncode(sectionBannerList)}");
    debugPrint("playlistImages =====>>>>>> ? $playlistImages");
    debugPrint("contentName =====>>>>>> ? $contentName");

    if (Constant.userID != null) {
      musicManager.setInitialMusic(
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, episodeid, contentid),
          false,
          0,
          "1",
          1,
          "author",
          artistID.toString());

      /* Only Music Direct Play*/
    } else {
      if (kIsWeb) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
      } else {
        Utils.openLogin(context: context, isHome: false, isReplace: false);
      }
    }
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<EpisodeProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
  }

  openBottomSheet(
      int index, coins, episodeName, audioBookType, episodeID, contentID) {
    showModalBottomSheet(
        backgroundColor: black,
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                SizedBox(
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.3
                      : MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    child: MyImage(
                      fit: BoxFit.cover,
                      imagePath: 'coinsBanner.png',
                      height: 120,
                      width: kIsWeb
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Icon(
                      Icons.lock_open_rounded,
                      color: gray,
                      size: 40,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: colorPrimary,
                      text: episodeName.toString(),
                      textalign: TextAlign.start,
                      fontsizeNormal: 15,
                      fontsizeWeb: 14,
                      multilanguage: false,
                      fontweight: FontWeight.w600,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<SubscriptionProvider>(
                  builder: (context, subscriptionProvider, child) {
                    if (subscriptionProvider.loading) {
                      debugPrint("Shimmer Calling");
                      return Container();
                    } else {
                      if (subscriptionProvider.subscriptionModel.status ==
                              200 &&
                          subscriptionProvider.subscriptionModel.result !=
                              null) {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subscriptionProvider
                              .subscriptionModel.result?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () async {
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
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
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
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return child;
                                      },
                                    ),
                                  );
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
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                      left: 18, right: 18),
                                  constraints:
                                      const BoxConstraints(minHeight: 55),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: MyText(
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
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: white,
                                        text:
                                            "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 22,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontweight: FontWeight.w500,
                                        fontstyle: FontStyle.normal,
                                      ),
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
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: gray,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: black,
                              text: "Need To Unlock",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyImage(
                                  imagePath: 'coin.png',
                                  height: 18,
                                  width: 18,
                                ),
                                MyText(
                                  color: black,
                                  text: "${coins.toString()} Coins",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 5,
                        thickness: 1,
                        indent: 15,
                        endIndent: 15,
                        color: black,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: black,
                              text: "Current Balance",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyImage(
                                  imagePath: 'coin.png',
                                  height: 18,
                                  width: 18,
                                ),
                                MyText(
                                  color: black,
                                  text:
                                      "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final episodebuyprovider =
                              Provider.of<ShowDetailsProvider>(context,
                                  listen: false);
                          Utils.showProgress(context, prDialog);
                          await episodebuyprovider.getEpisodeBuy(
                              1, episodeID, audioBookType, contentID, coins);
                          if (episodebuyprovider.episodeBuyModel.status ==
                              200) {
                            Utils.showToast("Succesfully Buy");
                            if (!context.mounted) return;
                            Utils().hideProgress(context);
                            if (!mounted) return;
                            Navigator.pop(context);
                            setState(() {
                              _getData();
                            });
                          } else {
                            Utils.showToast("Something Went Wrong");
                            if (!context.mounted) return;
                            Utils().hideProgress(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: MyText(
                            color: white,
                            text: "buythisepisode",
                            textalign: TextAlign.start,
                            fontsizeNormal: 14,
                            fontsizeWeb: 14,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
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
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: MyText(
                            color: white,
                            text: "getmorecoin",
                            textalign: TextAlign.start,
                            fontsizeNormal: 15,
                            fontsizeWeb: 14,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
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
}

import 'package:dtpocketfm/pages/profileedit.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/myusernetworkimg.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  final String? type, userid;
  const MyProfile({super.key, required this.type, this.userid});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> with TickerProviderStateMixin {
  late ProgressDialog prDialog;
  late ProfileProvider profileProvider;
  late ScrollController _scrollController;
  late TabController _controller;
  int selectedIndex = 0;
  @override
  void initState() {
    debugPrint("Constant.userID == ${Constant.userID}");
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    prDialog = ProgressDialog(context);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    profileProvider.setLoading(true);
    getUserData();
    controllerEvent();
    super.initState();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  void getUserData() async {
    if (widget.type == 'myProfile') {
      await profileProvider.getProfile(context);
    } else {
      await profileProvider.getOtherProfile(widget.userid);
    }

    await _fetchData(0);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (profileProvider.currentPage ?? 0) < (profileProvider.totalPage ?? 0)) {
      profileProvider.setLoadMore(true);
      await _fetchData((profileProvider.currentPage ?? 0));
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    debugPrint("nextpage   ======> $nextPage");
    debugPrint("Call MyCourse");
    debugPrint("Pageno:== ${(nextPage ?? 0) + 1}");
    if (widget.type == 'myProfile') {
      await profileProvider.getThreadsByUserList(
          Constant.userID, (nextPage ?? 0) + 1);
    } else {
      await profileProvider.getThreadsByUserList(
          widget.userid, (nextPage ?? 0) + 1);
    }
    // await profileProvider.getThreadsByUserList(1, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  controllerEvent() {
    _controller = TabController(length: 1, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      setState(() {
        selectedIndex = _controller.index;
      });
      debugPrint("Selected Index: ${_controller.index}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBgColor,
        appBar: Utils.myAppBarWithBack(
            context, "profile", kIsWeb ? false : true, true),
        body: widget.type == 'myProfile' ? myProfile() : otherUser());
  }

  Widget otherUser() {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Profile Image */
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  return Column(children: [
                    Container(
                      color: appBgColor,
                      height: kIsWeb ? 260 : 130,
                      width: MediaQuery.of(context).size.width,
                      child: MyUserNetworkImage(
                        imageUrl:
                            profileProvider.otheruserprofilemodel.status == 200
                                ? profileProvider
                                            .otheruserprofilemodel.result !=
                                        null
                                    ? (profileProvider.otheruserprofilemodel
                                            .result?[0].image ??
                                        "")
                                    : ""
                                : "",
                        fit: BoxFit.cover,
                        imgHeight: 90,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Container(
                      transform:
                          Matrix4.translationValues(0, -kToolbarHeight, 0),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 0.5, color: primaryDark)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            clipBehavior: Clip.antiAlias,
                            child: MyUserNetworkImage(
                              imageUrl: profileProvider
                                          .otheruserprofilemodel.status ==
                                      200
                                  ? profileProvider
                                              .otheruserprofilemodel.result !=
                                          null
                                      ? (profileProvider.otheruserprofilemodel
                                              .result?[0].image ??
                                          "")
                                      : ""
                                  : "",
                              fit: BoxFit.cover,
                              imgHeight: 90,
                              imgWidth: 90,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]);
                },
              ),
              const SizedBox(
                height: 8,
              ),
              /* Change Button */
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.loading) {
                    debugPrint("Shimmer Calling");
                    return threadShimmer();
                  } else {
                    if (profileProvider.otheruserprofilemodel.status == 200 &&
                        (profileProvider.otheruserprofilemodel.result?.length ??
                                0) >
                            0 &&
                        profileProvider.otheruserprofilemodel.result != null) {
                      return Container(
                        transform:
                            Matrix4.translationValues(0, -kToolbarHeight, 0),
                        // constraints: const BoxConstraints(
                        //   minHeight: 35,
                        //   // maxWidth: 100,
                        // ),
                        // alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  MyText(
                                    text: profileProvider.otheruserprofilemodel
                                            .result?[0].userName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 16,
                                    fontsizeWeb: 16,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontweight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.center,
                                    color: primaryDark,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MyText(
                                    text: profileProvider.otheruserprofilemodel
                                            .result?[0].email
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 16,
                                    fontsizeWeb: 16,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontweight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.center,
                                    color: otherColor,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: MyText(
                                text: profileProvider
                                        .otheruserprofilemodel.result?[0].bio
                                        .toString() ??
                                    "",
                                fontsizeNormal: 12,
                                fontsizeWeb: 16,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontweight: FontWeight.w500,
                                fontstyle: FontStyle.normal,
                                textalign: TextAlign.center,
                                color: white,
                              ),
                            ),
                            _buildTabs()
                          ],
                        ),
                      );
                    } else {
                      return const NoData(title: 'no_logged_in', subTitle: '');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myProfile() {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Profile Image */
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  return Column(children: [
                    Container(
                      color: appBgColor,
                      height: kIsWeb ? 260 : 130,
                      width: MediaQuery.of(context).size.width,
                      child: MyUserNetworkImage(
                        imageUrl: profileProvider.profileModel.status == 200
                            ? profileProvider.profileModel.result != null
                                ? (profileProvider
                                        .profileModel.result?[0].image ??
                                    "")
                                : ""
                            : "",
                        fit: BoxFit.cover,
                        imgHeight: 90,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Container(
                      transform:
                          Matrix4.translationValues(0, -kToolbarHeight, 0),
                      child: Center(
                        child: Stack(children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border:
                                    Border.all(width: 0.5, color: primaryDark)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              clipBehavior: Clip.antiAlias,
                              child: MyUserNetworkImage(
                                imageUrl:
                                    profileProvider.profileModel.status == 200
                                        ? profileProvider.profileModel.result !=
                                                null
                                            ? (profileProvider.profileModel
                                                    .result?[0].image ??
                                                "")
                                            : ""
                                        : "",
                                fit: BoxFit.cover,
                                imgHeight: 90,
                                imgWidth: 90,
                              ),
                            ),
                          ),
                          Constant.userID != null
                              ? Positioned(
                                  bottom: 2,
                                  right: 5,
                                  child: InkWell(
                                    onTap: () {
                                      if (kIsWeb) {
                                        Utils.buildWebAlertDialog(
                                            context, "profile", "");
                                      } else {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProfileEdit()))
                                            .then((value) => getUserData());
                                      }
                                    },
                                    child: MyImage(
                                      imagePath: 'ic_edit.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()
                        ]),
                      ),
                    ),
                  ]);
                },
              ),
              const SizedBox(
                height: 8,
              ),
              /* Change Button */
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.loading) {
                    debugPrint("Shimmer Calling");
                    return threadShimmer();
                  } else {
                    if (profileProvider.profileModel.status == 200 &&
                        (profileProvider.profileModel.result?.length ?? 0) >
                            0 &&
                        profileProvider.profileModel.result != null) {
                      return Container(
                        transform:
                            Matrix4.translationValues(0, -kToolbarHeight, 0),
                        // constraints: const BoxConstraints(
                        //   minHeight: 35,
                        //   // maxWidth: 100,
                        // ),
                        // alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  MyText(
                                    text: profileProvider
                                            .profileModel.result?[0].userName
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 16,
                                    fontsizeWeb: 12,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontweight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.center,
                                    color: primaryDark,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MyText(
                                    text: profileProvider
                                            .profileModel.result?[0].email
                                            .toString() ??
                                        "",
                                    fontsizeNormal: 16,
                                    fontsizeWeb: 16,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontweight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.center,
                                    color: otherColor,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (kIsWeb) {
                                        Utils.buildWebAlertDialog(
                                            context, "profile", "");
                                      } else {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProfileEdit()))
                                            .then((value) => getUserData());
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
                                        color: white,
                                        borderRadius: BorderRadius.circular(44),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: MyText(
                                        color: primaryDark,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        multilanguage: true,
                                        text: "editprofile",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 12,
                                        fontweight: FontWeight.w500,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: MyText(
                                text: profileProvider
                                        .profileModel.result?[0].bio
                                        .toString() ??
                                    "",
                                fontsizeNormal: 12,
                                fontsizeWeb: 16,
                                multilanguage: false,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontweight: FontWeight.w500,
                                fontstyle: FontStyle.normal,
                                textalign: TextAlign.center,
                                color: white,
                              ),
                            ),
                            _buildTabs()
                          ],
                        ),
                      );
                    } else {
                      return const NoData(title: 'no_logged_in', subTitle: '');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return kIsWeb
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: TabBar(
                  controller: _controller,
                  labelPadding: const EdgeInsets.all(5),
                  unselectedLabelColor: white,
                  indicatorColor: primaryDark,
                  labelColor: primaryDark,
                  tabs: [
                    MyText(
                      fontsizeWeb: 15,
                      color: primaryDark,
                      text: "Threads",
                      fontsizeNormal: 13,
                    ),
                  ],
                ),
              ),
              _tabbarview(),
            ],
          )
        : Column(
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
                    text: "Threads",
                    fontsizeNormal: 13,
                  ),
                ],
              ),
              _tabbarview(),
            ],
          );
  }

  Widget _tabbarview() {
    if (selectedIndex == 0) {
      return Column(
        children: [
          kIsWeb ? webThreadByUser() : threadByUser(),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              if (profileProvider.loadmore) {
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
      return kIsWeb ? webThreadByUser() : threadByUser();
    }
  }

  Widget library() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyImage(
                  fit: BoxFit.cover,
                  imagePath: "movie.png",
                  height: 60,
                  width: 60),
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
                  text: "Insta Millionaire",
                  fontsizeNormal: 13,
                  fontweight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                  color: primaryDark,
                  text: "100 Episodes",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                  color: edtBG,
                  text: "2M Plays",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w600,
                )
              ],
            )),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                    backgroundColor: profileBottomSheetBG,
                    showDragHandle: false,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    builder: (BuildContext context) {
                      return Container(
                          constraints: const BoxConstraints(minHeight: 0),
                          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: libraryBottomSheet());
                    },
                    context: context);
              },
              child: const Icon(
                Icons.more_vert,
                size: 25,
                color: gray,
              ),
            )
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 15,
        );
      },
    );
  }

  Widget threadByUser() {
    if (profileProvider.threadloading && profileProvider.loadmore == false) {
      debugPrint("Shimmer Calling");
      return threadShimmer();
    } else {
      return Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
        if (profileProvider.threadbyusermodel.status == 200 &&
            (profileProvider.threadbyuserlist?.length ?? 0) > 0) {
          return ListView.separated(
            itemCount: profileProvider.threadbyuserlist?.length ?? 0,
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
                                    .threadbyuserlist?[index].description
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
                                    .threadbyuserlist?[index].createdAt
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
                          Constant.userID ==
                                  (profileProvider
                                      .threadbyuserlist?[index].userId
                                      .toString())
                              ? InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                        backgroundColor: profileBottomSheetBG,
                                        showDragHandle: false,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30))),
                                        builder: (BuildContext context) {
                                          return Container(
                                              constraints: const BoxConstraints(
                                                  minHeight: 0),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 20, 15, 20),
                                              child: threadBottomSheet(
                                                  profileProvider
                                                      .threadbyuserlist?[index]
                                                      .id,
                                                  profileProvider
                                                          .threadbyuserlist?[
                                                              index]
                                                          .image
                                                          .toString() ??
                                                      "",
                                                  profileProvider
                                                          .threadbyuserlist?[
                                                              index]
                                                          .description
                                                          .toString() ??
                                                      "",
                                                  profileProvider
                                                          .threadbyuserlist?[
                                                              index]
                                                          .totalLike ??
                                                      0,
                                                  index));
                                        },
                                        context: context);
                                  },
                                  child: const Icon(
                                    Icons.more_horiz_outlined,
                                    color: white,
                                    size: 30,
                                  ),
                                )
                              : const SizedBox.shrink()
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
                                        .threadbyuserlist?[index].image
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
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                MyText(
                                  fontsizeWeb: 14,
                                  color: gray,
                                  text:
                                      "${formatNumber(profileProvider.threadbyuserlist?[index].totalLike ?? 0)} Likes",
                                  fontsizeNormal: 12,
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
          );
        } else {
          return const SizedBox(
              height: 250,
              child: NoData(title: 'noonethreadupload', subTitle: ''));
        }
      });
    }
  }

  Widget webThreadByUser() {
    if (profileProvider.threadloading && profileProvider.loadmore == false) {
      debugPrint("Shimmer Calling");
      return threadShimmer();
    } else {
      return Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
        if (profileProvider.threadbyusermodel.status == 200 &&
            (profileProvider.threadbyuserlist?.length ?? 0) > 0) {
          return ListView.separated(
            itemCount: profileProvider.threadbyuserlist?.length ?? 0,
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
                    width: MediaQuery.of(context).size.width > 1000
                        ? MediaQuery.of(context).size.width * 0.35
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
                                      .threadbyuserlist?[index].description
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
                                      .threadbyuserlist?[index].createdAt
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
                            Constant.userID ==
                                    (profileProvider
                                        .threadbyuserlist?[index].userId
                                        .toString())
                                ? InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          backgroundColor: profileBottomSheetBG,
                                          showDragHandle: false,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  topRight:
                                                      Radius.circular(30))),
                                          builder: (BuildContext context) {
                                            return Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        minHeight: 0),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 20, 15, 20),
                                                child: threadBottomSheet(
                                                    profileProvider
                                                        .threadbyuserlist?[
                                                            index]
                                                        .id,
                                                    profileProvider
                                                            .threadbyuserlist?[
                                                                index]
                                                            .image
                                                            .toString() ??
                                                        "",
                                                    profileProvider
                                                            .threadbyuserlist?[
                                                                index]
                                                            .description
                                                            .toString() ??
                                                        "",
                                                    profileProvider
                                                            .threadbyuserlist?[
                                                                index]
                                                            .totalLike ??
                                                        0,
                                                    index));
                                          },
                                          context: context);
                                    },
                                    child: const Icon(
                                      Icons.more_horiz_outlined,
                                      color: white,
                                      size: 30,
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 1000
                        ? MediaQuery.of(context).size.width * 0.35
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
                                          .threadbyuserlist?[index].image
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
                                    fontsizeWeb: 14,
                                    color: gray,
                                    text:
                                        "${formatNumber(profileProvider.threadbyuserlist?[index].totalLike ?? 0)} Likes",
                                    fontsizeNormal: 12,
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
          );
        } else {
          return const SizedBox(
              height: 250,
              child: NoData(title: 'noonethreadupload', subTitle: ''));
        }
      });
    }
  }

  threadShimmer() {
    debugPrint("Shimmer Calling1");
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

  Widget libraryBottomSheet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyImage(
                  fit: BoxFit.cover,
                  imagePath: "movie.png",
                  height: 60,
                  width: 60),
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
                  text: "Insta Millionaire",
                  fontsizeNormal: 13,
                  fontweight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                  color: primaryDark,
                  text: "100 Episodes",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                  color: edtBG,
                  text: "2M Plays",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w600,
                )
              ],
            )),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: MyText(
            color: white,
            text: 'readnow',
            multilanguage: true,
            fontsizeNormal: 12,
            fontweight: FontWeight.w500,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: MyText(
            color: white,
            text: 'moreinfo',
            multilanguage: true,
            fontsizeNormal: 12,
            fontweight: FontWeight.w500,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: MyText(
            color: white,
            text: 'remove_from_library',
            multilanguage: true,
            fontsizeNormal: 12,
            fontweight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  Widget threadBottomSheet(id, String image, String desc, int likes, index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: image,
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
                  text: desc,
                  fontsizeNormal: 13,
                  fontweight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                  fontsizeWeb: 14,
                  color: edtBG,
                  text: "${formatNumber(likes)} Likes",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w600,
                )
              ],
            )),
          ],
        ),
        InkWell(
          onTap: () async {
            final deletethreadorivider =
                Provider.of<ProfileProvider>(context, listen: false);

            await deletethreadorivider.getDeleteThreads(id);
            if (deletethreadorivider.deleteThreadsModel.status == 200) {
              setState(() {
                deletethreadorivider.threadbyuserlist?.removeAt(index);
                Navigator.pop(context);
              });
            } else {
              Utils.showToast("Threads Delete Unsuccessfully");
            }
          },
          child: Container(
            margin: const EdgeInsets.only(top: 20, left: 20),
            child: MyText(
              fontsizeWeb: 14,
              color: white,
              text: 'deletenow',
              multilanguage: true,
              fontsizeNormal: 12,
              fontweight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

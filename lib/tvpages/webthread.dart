import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/pages/newthread.dart';
import 'package:dtpocketfm/pages/profile.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/threadprovider.dart';
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class WebThreads extends StatefulWidget {
  const WebThreads({super.key});

  @override
  State<WebThreads> createState() => _WebThreadsState();
}

class _WebThreadsState extends State<WebThreads> {
  late ProfileProvider profileProvider;
  late ThreadProvider threadProvider;
  late ProgressDialog prDialog;
  late ScrollController _scrollController;
  late ScrollController commentscrollController;
  late ScrollController replyscrollController;

  double? rating;
  final commentController = TextEditingController();
  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    threadProvider = Provider.of<ThreadProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    commentscrollController = ScrollController();
    commentscrollController.addListener(_commentscrollListener);
    replyscrollController = ScrollController();
    replyscrollController.addListener(_replyscrollListener);
    threadProvider.setLoading(true);
    prDialog = ProgressDialog(context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (threadProvider.threadcurrentPage ?? 0) <
            (threadProvider.threadtotalPage ?? 0)) {
      await threadProvider.setLoadMore(true);
      await _fetchData((threadProvider.threadcurrentPage ?? 0));
    }
  }

  _commentscrollListener() async {
    if (!commentscrollController.hasClients) return;
    if (commentscrollController.offset >=
            commentscrollController.position.maxScrollExtent &&
        !commentscrollController.position.outOfRange &&
        (threadProvider.commentcurrentPage ?? 0) <
            (threadProvider.commenttotalPage ?? 0)) {
      await threadProvider.setLoadMore(true);
      await _fetchcomment((threadProvider.commentcurrentPage ?? 0));
    }
  }

  _replyscrollListener() async {
    if (!replyscrollController.hasClients) return;
    if (replyscrollController.offset >=
            replyscrollController.position.maxScrollExtent &&
        !replyscrollController.position.outOfRange &&
        (threadProvider.replycommentcurrentPage ?? 0) <
            (threadProvider.replycommenttotalPage ?? 0)) {
      await threadProvider.setLoadMore(true);
      await _fetchreplycomment((threadProvider.replycommentcurrentPage ?? 0));
    }
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    await threadProvider.getThreadsList((nextPage ?? 0) + 1);
  }

  /* Section Data Api */
  Future<void> _fetchcomment(int? nextPage) async {
    await threadProvider.getThreadComment(
        threadProvider.threadid, (nextPage ?? 0) + 1);
  }

  /* Section Data Api */
  Future<void> _fetchreplycomment(int? nextPage) async {
    await threadProvider.getReplyComment(
        threadProvider.commentid, (nextPage ?? 0) + 1);
  }

  getcmtList(index, id, nextpage) async {
    await threadProvider.getThreadComment(id, (nextpage ?? 0) + 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  getreplycmtList(index, id, nextpage) async {
    await threadProvider.getReplyComment(id, (nextpage ?? 0) + 1);

    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MMM-yyyy').format(dateTime);
    return formattedDate;
  }

  _getData() async {
    await profileProvider.getProfile(context);

    await _fetchData(0);
    await threadProvider.getSuggestArtistList();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    threadProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: darkappbgcolor,
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: darkappbgcolor,
        leading: Consumer<ProfileProvider>(
          builder: (context, value, child) {
            return InkWell(
              onTap: () {
                if (Constant.userID == null) {
                  // Utils.openLogin(
                  //     context: context, isHome: true, isReplace: false);
                  Utils.buildWebAlertDialog(context, "login", "")
                      .then((value) => _getData());
                } else {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MyProfile(
                          type: 'myProfile',
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                      ));
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  clipBehavior: Clip.antiAlias,
                  child: MyUserNetworkImage(
                    imageUrl: profileProvider.profileModel.status == 200
                        ? profileProvider.profileModel.result != null
                            ? (profileProvider.profileModel.result?[0].image ??
                                "")
                            : ""
                        : "",
                    fit: BoxFit.cover,
                    imgHeight: 46,
                    imgWidth: 46,
                  ),
                ),
              ),
            );
          },
        ),
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            splashColor: transparentColor,
            highlightColor: transparentColor,
            child: MyText(
              multilanguage: true,
              color: white,
              fontsizeWeb: 15,
              text: "threads",
              fontsizeNormal: 15,
              fontweight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              if (Constant.userID != null) {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CreateThread(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    )).then((value) => _getData());
              } else {
                // Utils.openLogin(
                //     context: context, isHome: false, isReplace: false);
                Utils.buildWebAlertDialog(context, "login", "")
                    .then((value) => _getData());
              }
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              width: 20,
              child: MyImage(
                imagePath: "ic_Threadedit.png",
                height: 46,
                width: 46,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        displacement: 50,
        backgroundColor: white,
        color: primaryDark,
        strokeWidth: 3,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () {
          return _getData();
        },
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                suggestForYou(),
                Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width > 800
                        ? MediaQuery.of(context).size.width * 0.4
                        : MediaQuery.of(context).size.width,
                    child: threadData()),
                Consumer<ThreadProvider>(
                  builder: (context, value, child) {
                    if (value.loadmore) {
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
            )),
      ),
    );
  }

  Widget threadData() {
    // if (threadProvider.loading) {
    //   return threadShimmer();
    // } else {
    return Consumer<ThreadProvider>(builder: (context, threadProvider, child) {
      if (threadProvider.loading && threadProvider.loadmore == false) {
        return threadShimmer();
      } else {
        if (threadProvider.threadlistmodel.status == 200 &&
            (threadProvider.threadslist?.length ?? 0) > 0) {
          return ListView.separated(
            itemCount: threadProvider.threadslist?.length ?? 0,
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
                  InkWell(
                    onTap: () {
                      if (threadProvider.threadslist?[index].isArtist == 2) {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AuthorProfile(
                                artistID:
                                    threadProvider.threadslist?[index].userId,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return child;
                              },
                            ));
                      } else {
                        if (Constant.userID ==
                            threadProvider.threadslist?[index].userId
                                .toString()) {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const MyProfile(type: 'myProfile'),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child;
                                },
                              ));
                        } else {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MyProfile(
                                  type: 'otherUser',
                                  userid: threadProvider
                                      .threadslist?[index].userId
                                      .toString(),
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child;
                                },
                              ));
                        }
                      }
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            imageUrl: threadProvider
                                    .threadslist?[index].userImage
                                    .toString() ??
                                "",
                            imgHeight: 40,
                            imgWidth: 40,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MyText(
                              color: white,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: false,
                              text: (threadProvider
                                              .threadslist?[index].fullName
                                              .toString() ??
                                          "")
                                      .isNotEmpty
                                  ? (threadProvider.threadslist?[index].fullName
                                          .toString() ??
                                      "")
                                  : threadProvider.threadslist?[index].userName
                                          .toString() ??
                                      "",
                              textalign: TextAlign.start,
                              fontsizeNormal: 12,
                              fontsizeWeb: 15,
                              fontweight: FontWeight.w600,
                              fontstyle: FontStyle.normal,
                            ),
                            MyText(
                              color: primaryDark,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: false,
                              text: threadProvider
                                      .threadslist?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.start,
                              fontsizeNormal: 11,
                              fontsizeWeb: 13,
                              fontweight: FontWeight.w400,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        )),
                        Row(
                          children: [
                            MyText(
                              color: gray,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: false,
                              text: formatDate(threadProvider
                                      .threadslist?[index].createdAt
                                      .toString() ??
                                  ""),
                              textalign: TextAlign.center,
                              fontsizeNormal: 12,
                              fontsizeWeb: 13,
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
                            Positioned(
                              top: 0,
                              left: 0,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: (threadProvider.threadslist?[index]
                                                  .images?.length ??
                                              0) >
                                          0
                                      ? MyNetworkImage(
                                          imageUrl: threadProvider
                                                  .threadslist?[index]
                                                  .images?[0]
                                                  .toString() ??
                                              "",
                                          imgHeight: 18,
                                          imgWidth: 18,
                                          fit: BoxFit.fill,
                                        )
                                      : MyImage(
                                          imagePath: 'threaduser.png',
                                          height: 18,
                                          width: 18,
                                        )),
                            ),
                            Positioned(
                              top: 10,
                              right: 0,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: (threadProvider.threadslist?[index]
                                                  .images?.length ??
                                              0) >
                                          1
                                      ? MyNetworkImage(
                                          imageUrl: threadProvider
                                                  .threadslist?[index]
                                                  .images?[1]
                                                  .toString() ??
                                              "",
                                          imgHeight: 14,
                                          imgWidth: 14,
                                          fit: BoxFit.fill,
                                        )
                                      : MyImage(
                                          imagePath: 'threaduser.png',
                                          height: 14,
                                          width: 14,
                                        )),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 10,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: (threadProvider.threadslist?[index]
                                                  .images?.length ??
                                              0) >
                                          2
                                      ? MyNetworkImage(
                                          imageUrl: threadProvider
                                                  .threadslist?[index]
                                                  .images?[2]
                                                  .toString() ??
                                              "",
                                          imgHeight: 12,
                                          imgWidth: 12,
                                          fit: BoxFit.fill,
                                        )
                                      : MyImage(
                                          imagePath: 'threaduser.png',
                                          height: 12,
                                          width: 12,
                                        )),
                            )
                          ])
                        ],
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                imageUrl: threadProvider
                                        .threadslist?[index].image
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
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (Constant.userID != null) {
                                      final addremovelike =
                                          Provider.of<ThreadProvider>(context,
                                              listen: false);
                                      await addremovelike.addremoveLike(
                                          addremovelike.threadslist?[index].id,
                                          index);
                                    } else {
                                      Utils.buildWebAlertDialog(
                                              context, "login", "")
                                          .then((value) => _getData());
                                    }
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    color: threadProvider
                                                .threadslist?[index].isLike ==
                                            1
                                        ? primaryDark
                                        : white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    final getCommentProvider =
                                        Provider.of<ThreadProvider>(context,
                                            listen: false);
                                    threadProvider.commentlist = [];
                                    await getCommentProvider.storeThreadID(
                                        threadProvider.threadslist?[index].id);

                                    openCommentDialog(index,
                                        threadProvider.threadslist?[index].id);
                                    await getcmtList(
                                        index,
                                        threadProvider.threadslist?[index].id,
                                        0);
                                  },
                                  child: MyImage(
                                    imagePath: "ic_cmt.png",
                                    height: Dimens.coinImgHeight,
                                    width: Dimens.coinImgWidth,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                MyImage(
                                  imagePath: "ic_sendThread.png",
                                  height: Dimens.coinImgHeight,
                                  width: Dimens.coinImgWidth,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                MyText(
                                  color: gray,
                                  fontsizeWeb: 14,
                                  text:
                                      "${threadProvider.threadslist?[index].totalComment.toString() ?? ""} Replies",
                                  fontsizeNormal: 12,
                                  fontweight: FontWeight.w500,
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
                                MyText(
                                  color: gray,
                                  fontsizeWeb: 14,
                                  text:
                                      "${formatNumber(threadProvider.threadslist?[index].totalLike ?? 0)} Likes",
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
          return const SizedBox.shrink();
        }
      }
    });
    // }
  }

  openBottomSheet(int index, thredid) {
    return Container(
      alignment: Alignment.center,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: MediaQuery.of(context).size.height * 0.75,
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 30,
                width: 30,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), color: gray),
                child: MyImage(
                  color: white,
                  imagePath: "ic_close.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
                controller: commentscrollController,
                child: Column(
                  children: [
                    Consumer<ThreadProvider>(
                        builder: (context, commentlistprovider, child) {
                      if (threadProvider.threadCommentLoading &&
                          threadProvider.loadmore == false) {
                        return commentShimmer();
                      } else {
                        if (commentlistprovider.threadCommentListModel.status ==
                                200 &&
                            (commentlistprovider.commentlist?.length ?? 0) >
                                0) {
                          return ListView.separated(
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount:
                                  commentlistprovider.commentlist?.length ?? 0,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: MyNetworkImage(
                                            imageUrl: commentlistprovider
                                                    .commentlist?[index].image
                                                    .toString() ??
                                                "",
                                            imgHeight: 55,
                                            imgWidth: 55,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          MyText(
                                              fontsizeNormal: 15,
                                              fontsizeWeb: 15,
                                              fontweight: FontWeight.w600,
                                              color: colorPrimaryDark,
                                              text: (commentlistprovider
                                                                  .commentlist?[
                                                                      index]
                                                                  .fullName ??
                                                              "")
                                                          .isEmpty ||
                                                      (commentlistprovider
                                                              .commentlist?[
                                                                  index]
                                                              .fullName)
                                                          .toString()
                                                          .contains("null")
                                                  ? (commentlistprovider
                                                          .commentlist?[index]
                                                          .userName
                                                          .toString() ??
                                                      "")
                                                  : (commentlistprovider
                                                          .commentlist?[index]
                                                          .fullName
                                                          .toString() ??
                                                      "")),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          MyText(
                                              fontsizeNormal: 15,
                                              fontsizeWeb: 15,
                                              fontweight: FontWeight.w500,
                                              color: colorPrimaryDark,
                                              text: commentlistprovider
                                                      .commentlist?[index]
                                                      .comment
                                                      .toString() ??
                                                  ""),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  commentController.clear();
                                                  threadProvider
                                                      .replycommentlist = [];

                                                  await threadProvider
                                                      .storeCommentId(
                                                          commentlistprovider
                                                              .commentlist?[
                                                                  index]
                                                              .id);
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                  openreplyCommentDialog(
                                                      index,
                                                      thredid,
                                                      commentlistprovider
                                                          .commentlist?[index]
                                                          .id,
                                                      commentlistprovider
                                                          .commentlist?[index]
                                                          .image,
                                                      (commentlistprovider
                                                                          .commentlist?[
                                                                              index]
                                                                          .fullName ??
                                                                      "")
                                                                  .isEmpty ||
                                                              (commentlistprovider
                                                                      .commentlist?[
                                                                          index]
                                                                      .fullName)
                                                                  .toString()
                                                                  .contains(
                                                                      "null")
                                                          ? (commentlistprovider
                                                                  .commentlist?[
                                                                      index]
                                                                  .userName
                                                                  .toString() ??
                                                              "")
                                                          : (commentlistprovider
                                                                  .commentlist?[
                                                                      index]
                                                                  .fullName
                                                                  .toString() ??
                                                              ""),
                                                      commentlistprovider
                                                          .commentlist?[index]
                                                          .comment);

                                                  await getreplycmtList(
                                                      index,
                                                      threadProvider.commentid,
                                                      0);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: MyText(
                                                      fontsizeNormal: 14,
                                                      fontsizeWeb: 15,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      color: gray,
                                                      text:
                                                          "${commentlistprovider.commentlist?[index].totalReply} Reply"),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Row(
                                                  children: [
                                                    if (commentlistprovider
                                                            .commentlist?[index]
                                                            .userId
                                                            .toString() ==
                                                        Constant.userID)
                                                      InkWell(
                                                        onTap: () {
                                                          openReviewRatingDialog(
                                                              index,
                                                              commentlistprovider
                                                                  .commentlist?[
                                                                      index]
                                                                  .id);
                                                        },
                                                        child: MyImage(
                                                          imagePath:
                                                              'ic_edit.png',
                                                          height: 20,
                                                          width: 20,
                                                        ),
                                                      )
                                                    else
                                                      const SizedBox.shrink(),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    if (commentlistprovider
                                                            .commentlist?[index]
                                                            .userId
                                                            .toString() ==
                                                        Constant.userID)
                                                      InkWell(
                                                        onTap: () async {
                                                          final commentprovider =
                                                              Provider.of<
                                                                      ThreadProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);

                                                          await commentprovider
                                                              .getdeleteComment(
                                                            commentprovider
                                                                .commentlist?[
                                                                    index]
                                                                .id,
                                                          );
                                                          if (commentprovider
                                                                  .deleteCommentModel
                                                                  .status ==
                                                              200) {
                                                            commentprovider
                                                                .commentlist
                                                                ?.removeAt(
                                                                    index);
                                                          }
                                                          setState(() {});
                                                        },
                                                        child: MyImage(
                                                          imagePath:
                                                              'ic_delete.png',
                                                          height: 20,
                                                          width: 20,
                                                          color: primaryDark,
                                                        ),
                                                      )
                                                    else
                                                      const SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              });
                        } else {
                          return SizedBox(
                            height: 250,
                            child: Column(
                              children: [
                                const Expanded(
                                    child: NoData(title: '', subTitle: '')),
                                MyText(
                                  color: black,
                                  text: "nodata",
                                  fontsizeNormal: 16,
                                  fontsizeWeb: 12,
                                  maxline: 2,
                                  multilanguage: true,
                                  overflow: TextOverflow.ellipsis,
                                  fontweight: FontWeight.w600,
                                  textalign: TextAlign.center,
                                  fontstyle: FontStyle.normal,
                                )
                              ],
                            ),
                          );
                        }
                      }
                    }),
                    Consumer<ThreadProvider>(
                      builder: (context, threadProvider, child) {
                        if (threadProvider.loadmore) {
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
                )),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, bottom: 10),
            height: 50,
            constraints: const BoxConstraints(maxHeight: 50),
            child:
                // Column(
                //   children: [
                Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    height: 50,
                    child: TextFormField(
                      maxLines: 1,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      controller: commentController,
                      textInputAction: TextInputAction.next,
                      cursorColor: black,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: white,
                        contentPadding: EdgeInsets.only(left: 10.0),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                            borderSide:
                                BorderSide(width: 1, color: colorPrimary)),
                        hintText: " Add Comment",
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Constant.userID != null) {
                      debugPrint(
                          "Submit comment =======> ${commentController.text}");
                      final threadDataProvider =
                          Provider.of<ThreadProvider>(context, listen: false);

                      if (commentController.text.isNotEmpty &&
                          commentController.text != "") {
                        Utils.showProgress(context, prDialog);

                        await threadDataProvider.getAddComment(
                          0,
                          commentController.text,
                          thredid,
                          index,
                        );
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        commentController.clear();
                      } else {
                        Utils.showToast("please_add_comment");
                      }
                    } else {
                      Utils.buildWebAlertDialog(context, "login", "")
                          .then((value) => _getData());
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    child: Consumer<ThreadProvider>(
                      builder: (context, homeProvider, child) {
                        return MyText(
                          color: (commentController.text.toString().isEmpty)
                              ? white
                              : white,
                          text: "submit",
                          multilanguage: true,
                          fontsizeWeb: 15,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          maxline: 1,
                          fontweight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  replyBottomSheet(int index, threadid, commentid, commentUserImage,
      commentUsername, comment) {
    return Container(
      alignment: Alignment.center,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: MediaQuery.of(context).size.height * 0.75,
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: white)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                        imageUrl: commentUserImage,
                        fit: BoxFit.fill,
                        imgWidth: 35,
                        imgHeight: 35),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          color: colorPrimaryDark,
                          text: commentUsername,
                          fontsizeNormal: Dimens.textMedium,
                          fontweight: FontWeight.w500,
                          multilanguage: false,
                          maxline: 1,
                          fontsizeWeb: 12,
                          overflow: TextOverflow.ellipsis,
                          // inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 5),
                      MyText(
                          color: colorPrimaryDark,
                          text: comment,
                          fontsizeNormal: Dimens.textSmall,
                          fontweight: FontWeight.w400,
                          fontsizeWeb: 10,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          // inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 25,
                    width: 25,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50), color: gray),
                    child: MyImage(
                      color: white,
                      imagePath: "ic_close.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              controller: replyscrollController,
              child: Column(
                children: [
                  Consumer<ThreadProvider>(
                    builder: (context, threadProvider, child) {
                      if ((threadProvider.replyLoading &&
                          threadProvider.loadmore == false)) {
                        return commentShimmer();
                      } else {
                        if ((threadProvider.replyCommentListModel.status ==
                                200 &&
                            (threadProvider.replycommentlist?.length ?? 0) >
                                0)) {
                          return Column(
                            children: [
                              ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      threadProvider.replycommentlist?.length ??
                                          0,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: MyNetworkImage(
                                                imageUrl: threadProvider
                                                        .replycommentlist?[
                                                            index]
                                                        .image
                                                        .toString() ??
                                                    "",
                                                imgHeight: 55,
                                                imgWidth: 55,
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              MyText(
                                                  fontsizeNormal: 15,
                                                  fontsizeWeb: 15,
                                                  fontweight: FontWeight.w600,
                                                  color: colorPrimaryDark,
                                                  text: (threadProvider
                                                                      .replycommentlist?[
                                                                          index]
                                                                      .fullName ??
                                                                  "")
                                                              .isEmpty ||
                                                          (threadProvider
                                                                  .replycommentlist?[
                                                                      index]
                                                                  .fullName)
                                                              .toString()
                                                              .contains("null")
                                                      ? (threadProvider
                                                              .replycommentlist?[
                                                                  index]
                                                              .userName
                                                              .toString() ??
                                                          "")
                                                      : (threadProvider
                                                              .replycommentlist?[
                                                                  index]
                                                              .fullName
                                                              .toString() ??
                                                          "")),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: MyText(
                                                        fontsizeNormal: 15,
                                                        fontsizeWeb: 15,
                                                        fontweight:
                                                            FontWeight.w500,
                                                        color: colorPrimaryDark,
                                                        text: threadProvider
                                                                .replycommentlist?[
                                                                    index]
                                                                .comment
                                                                .toString() ??
                                                            ""),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: Row(
                                                      children: [
                                                        if (threadProvider
                                                                .replycommentlist?[
                                                                    index]
                                                                .userId
                                                                .toString() ==
                                                            Constant.userID)
                                                          InkWell(
                                                            onTap: () {
                                                              openReviewRatingDialog(
                                                                  index,
                                                                  threadProvider
                                                                      .replycommentlist?[
                                                                          index]
                                                                      .id);
                                                            },
                                                            child: MyImage(
                                                              imagePath:
                                                                  'ic_edit.png',
                                                              height: 20,
                                                              width: 20,
                                                            ),
                                                          )
                                                        else
                                                          const SizedBox
                                                              .shrink(),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        if (threadProvider
                                                                .replycommentlist?[
                                                                    index]
                                                                .userId
                                                                .toString() ==
                                                            Constant.userID)
                                                          InkWell(
                                                            onTap: () async {
                                                              final commentprovider =
                                                                  Provider.of<
                                                                          ThreadProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);

                                                              await commentprovider
                                                                  .getdeleteComment(
                                                                commentprovider
                                                                    .replycommentlist?[
                                                                        index]
                                                                    .id,
                                                              );
                                                              if (commentprovider
                                                                      .deleteCommentModel
                                                                      .status ==
                                                                  200) {
                                                                commentprovider
                                                                    .replycommentlist
                                                                    ?.removeAt(
                                                                        index);
                                                              }
                                                              setState(() {});
                                                            },
                                                            child: MyImage(
                                                              imagePath:
                                                                  'ic_delete.png',
                                                              height: 20,
                                                              width: 20,
                                                              color:
                                                                  primaryDark,
                                                            ),
                                                          )
                                                        else
                                                          const SizedBox
                                                              .shrink(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ],
                          );
                        } else {
                          return SizedBox(
                            height: 250,
                            child: Column(
                              children: [
                                const Expanded(
                                    child: NoData(title: '', subTitle: '')),
                                MyText(
                                  color: black,
                                  text: "nodata",
                                  fontsizeNormal: 16,
                                  fontsizeWeb: 12,
                                  maxline: 2,
                                  multilanguage: true,
                                  overflow: TextOverflow.ellipsis,
                                  fontweight: FontWeight.w600,
                                  textalign: TextAlign.center,
                                  fontstyle: FontStyle.normal,
                                )
                              ],
                            ),
                          );
                        }
                      }
                    },
                  ),
                  Consumer<ThreadProvider>(
                    builder: (context, threadProvider, child) {
                      if (threadProvider.loadmore) {
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
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, bottom: 10),
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    height: 50,
                    child: TextFormField(
                      maxLines: 1,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      controller: commentController,
                      textInputAction: TextInputAction.next,
                      cursorColor: black,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: white,
                        contentPadding: EdgeInsets.only(left: 10.0),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          borderSide: BorderSide(width: 1, color: colorPrimary),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                            borderSide:
                                BorderSide(width: 1, color: colorPrimary)),
                        hintText: " Add Comment",
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Constant.userID != null) {
                      debugPrint(
                          "Submit comment =======> ${commentController.text}");
                      final threadDataProvider =
                          Provider.of<ThreadProvider>(context, listen: false);

                      if (commentController.text.isNotEmpty &&
                          commentController.text != "") {
                        Utils.showProgress(context, prDialog);
                        await threadDataProvider.getAddComment(
                          commentid,
                          commentController.text,
                          threadid,
                          index,
                        );
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        commentController.clear();
                        Navigator.pop(context);
                        setState(() {});
                      } else {
                        Utils.showToast("please_add_comment");
                      }
                    } else {
                      Utils.buildWebAlertDialog(context, "login", "")
                          .then((value) => _getData());
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    child: Consumer<ThreadProvider>(
                      builder: (context, homeProvider, child) {
                        return MyText(
                          color: (commentController.text.toString().isEmpty)
                              ? white
                              : white,
                          text: "submit",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          fontsizeWeb: 15,
                          maxline: 1,
                          fontweight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
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

  Widget commentShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(5),
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: const Row(
            children: [
              ShimmerWidget.circular(
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

  /* Add Review - Reating START */
  openReviewRatingDialog(position, id) {
    debugPrint("Position == $position");
    debugPrint("Id is == $id");
    showGeneralDialog<void>(
      barrierColor: black.withOpacity(0.9),
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Dialog(
            insetPadding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            backgroundColor: white,
            alignment: Alignment.center,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Wrap(
              children: [_buildCommentDialog(id)],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _getData();
    });
  }

  Widget _buildCommentDialog(id) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            /* Close Button */
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: MyText(
                      color: primaryDark,
                      fontsizeWeb: 18,
                      text: "reviewandrating",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: 17,
                      maxline: 1,
                      fontweight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        debugPrint("Clicked on Close!");
                        commentController.clear();

                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: black,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.2, decoration: Utils.setBackground(gray, 1)),

            /* Add Review */
            Container(
              height: 150,
              decoration: Utils.setBGWithBorder(
                  colorPrimary.withOpacity(0.2), gray.withOpacity(0.5), 8, 0.5),
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
              child: TextFormField(
                controller: commentController,
                scrollPhysics: const AlwaysScrollableScrollPhysics(),
                textAlign: TextAlign.start,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                onChanged: (value) async {},
                decoration: InputDecoration(
                  filled: true,
                  fillColor: transparentColor,
                  border: InputBorder.none,
                  hintText: "Add comments...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: gray,
                  ),
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                ),
                obscureText: false,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: colorPrimaryDark,
                ),
              ),
            ),

            /* Submit button */
            FittedBox(
              child: Container(
                height: 35,
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
                decoration: Utils.setBGWithBorder(colorAccent, gray, 5, 0.5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    debugPrint(
                        "Submit comment =======> ${commentController.text}");
                    final commentprovider =
                        Provider.of<ThreadProvider>(context, listen: false);

                    if (commentController.text.isNotEmpty &&
                        commentController.text != "") {
                      await commentprovider.getEditComment(
                        id,
                        commentController.text,
                      );

                      commentController.clear();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      await threadProvider.getReplyComment(
                          threadProvider.commentid,
                          (threadProvider.replycommentcurrentPage ?? 0));
                      await threadProvider.getThreadComment(
                          threadProvider.threadid,
                          threadProvider.commentcurrentPage);
                      setState(() {});
                    } else {
                      Utils.showToast("please_add_comment");
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Consumer<ThreadProvider>(
                      builder: (context, homeProvider, child) {
                        return MyText(
                          color: (commentController.text.toString().isEmpty)
                              ? white
                              : white,
                          text: "submit",
                          multilanguage: true,
                          fontsizeWeb: 15,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          maxline: 1,
                          fontweight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget suggestForYou() {
    return Consumer<ThreadProvider>(
      builder: (context, threadDataProvider, child) {
        if (threadDataProvider.loading) {
          return suggestedshimmer();
        } else {
          if (threadDataProvider.suggestartistProfileModel.status == 200 &&
              (threadDataProvider.suggestartistProfileModel.result?.length ??
                      0) >
                  0) {
            return Container(
              height: 280,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: gray, width: 0.5),
                      bottom: BorderSide(color: white, width: 0.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: MyText(
                      multilanguage: true,
                      color: white,
                      fontsizeWeb: 15,
                      text: "suggest_for_you",
                      fontsizeNormal: 15,
                      fontweight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      itemCount: threadDataProvider
                              .suggestartistProfileModel.result?.length ??
                          0,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      AuthorProfile(
                                    artistID: threadProvider
                                        .suggestartistProfileModel
                                        .result?[index]
                                        .id,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return child;
                                  },
                                ));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            height: 210,
                            width: 154,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5, color: gray),
                                color: appBgColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: MyNetworkImage(
                                      imageUrl: threadDataProvider
                                              .suggestartistProfileModel
                                              .result?[index]
                                              .image
                                              .toString() ??
                                          "",
                                      imgHeight: 80,
                                      imgWidth: 80,
                                      fit: BoxFit.fill,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                MyText(
                                  textalign: TextAlign.center,
                                  maxline: 2,
                                  fontsizeWeb: 12,
                                  color: white,
                                  text: threadDataProvider
                                          .suggestartistProfileModel
                                          .result?[index]
                                          .userName
                                          .toString() ??
                                      "",
                                  fontsizeNormal: 12,
                                  fontweight: FontWeight.w500,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (Constant.userID != null) {
                                      final addremovefollow =
                                          Provider.of<ThreadProvider>(context,
                                              listen: false);
                                      await addremovefollow.addremovefollow(
                                        threadDataProvider
                                            .suggestartistProfileModel
                                            .result?[index]
                                            .id,
                                      );
                                    } else {
                                      // Utils.openLogin(
                                      //     context: context,
                                      //     isHome: true,
                                      //     isReplace: false);
                                      Utils.buildWebAlertDialog(
                                          context, "login", "");
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    alignment: Alignment.center,
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: primaryDark,
                                      borderRadius: BorderRadius.circular(38),
                                    ),
                                    child: MyText(
                                      color: white,
                                      multilanguage: true,
                                      fontsizeWeb: 8,
                                      text: threadDataProvider
                                                  .suggestartistProfileModel
                                                  .result?[index]
                                                  .isFollow ==
                                              0
                                          ? "follow"
                                          : "following",
                                      fontsizeNormal: 12,
                                      fontweight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          width: 20,
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  suggestedshimmer() {
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: gray, width: 0.5),
              bottom: BorderSide(color: white, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: ShimmerWidget.roundcorner(
                height: 15,
                width: 100,
              )),
          SizedBox(
            height: 192,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: 3,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return const ShimmerWidget.roundcorner(
                  height: 192,
                  width: 154,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  width: 20,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  openCommentDialog(int index, thredid) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: white,
          child: openBottomSheet(index, thredid),
        );
      },
    ).whenComplete(() => (() => threadProvider.commentlist = []));
  }

  openreplyCommentDialog(int index, threadid, commentid, commentUserImage,
      commentUsername, comment) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: white,
          child: replyBottomSheet(index, threadid, commentid, commentUserImage,
              commentUsername, comment),
        );
      },
    ).whenComplete(() => (() => threadProvider.commentlist = []));
  }
}

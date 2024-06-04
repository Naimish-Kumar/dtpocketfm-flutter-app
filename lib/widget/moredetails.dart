// import 'package:dtpocketfm/model/sectiondetailmodel.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/provider/novelsectiondataprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
// import 'package:dtpocketfm/utils/constant.dart';
// import 'package:dtpocketfm/widget/castcrew.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
// import 'package:dtpocketfm/widget/nodata.dart';
// import 'package:dtpocketfm/widget/relatedvideoshow.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MoreDetails extends StatefulWidget {
  final int? type;
  final dynamic contentid, contentype;
  // final List<MoreDetail>? moreDetailList;
  // final List<GetRelatedVideo>? reatedData;
  // final List<Cast>? cast;
  const MoreDetails(
      {
      // required this.moreDetailList,
      // this.reatedData,
      required this.type,
      this.contentid,
      this.contentype,
      // this.cast,
      super.key});

  @override
  State<MoreDetails> createState() => _MoreDetailsState();
}

class _MoreDetailsState extends State<MoreDetails> {
  late ShowDetailsProvider showDetailsProvider;
  late EpisodeProvider episodeProvider;
  late NovelSectionDataProvider novelDetailsProvider;
  double? ratingGiven;
  late ProgressDialog prDialog;
  final commentController = TextEditingController();
  List moreLikeItems = [
    "Aarzoo",
    "Sandip Maheshawri",
    "Badla",
    "Adhuri Kahani",
    "Insta milllionaire",
    "Aek me aur ek tu"
  ];
  int? _value;
  @override
  void initState() {
    debugPrint("Widget Content id == ${widget.contentid}");
    debugPrint("Widget Content type == ${widget.contentype}");
    prDialog = ProgressDialog(context);
    showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    novelDetailsProvider =
        Provider.of<NovelSectionDataProvider>(context, listen: false);
    // getAllEpisode();
    super.initState();
  }

  getAllEpisode() async {
    // await showDetailsProvider.getReviews(widget.contentid, widget.contentype);

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (showDetailsProvider.getReviewModel.result != null &&
    //     (showDetailsProvider.getReviewModel.result?.length ?? 0) > 0) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (Constant.userID != null) {
              if (episodeProvider.doComment == true ||
                  novelDetailsProvider.doComment == true) {
                openAddReviewRatingDialog(context);
              } else {
                Utils.showToast("You are not able to comment");
              }
            } else {
              if (kIsWeb) {
                Utils.buildWebAlertDialog(context, "login", "");
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginSocial(
                      ishome: false,
                    ),
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: 45,
                maxWidth: kIsWeb ? 250 : MediaQuery.of(context).size.width),
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
              text: "addfeedback",
              textalign: TextAlign.center,
              fontsizeNormal: 15,
              fontsizeWeb: 18,
              fontweight: FontWeight.w700,
              fontstyle: FontStyle.normal,
            ),
          ),
        ),
        kIsWeb
            ? widget.type == 1
                ? webcomment()
                : webnovelcomment()
            : widget.type == 1
                ? commentList()
                : novelcommentList(),
      ],
    );
    // } else {
    //   return const NoData(title: '', subTitle: '');
    // }
  }

  Widget novelcommentList() {
    debugPrint("Novel Commentist");
    return Consumer<NovelSectionDataProvider>(
      builder: (context, novelDetailsProvider, child) {
        if (novelDetailsProvider.getReviewModel.status == 200 &&
            (novelDetailsProvider.reviewList?.length ?? 0) > 0) {
          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: darkappbgcolor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "Top Reviews",
                          fontsizeNormal: 15,
                          fontweight: FontWeight.w500,
                          fontsizeWeb: 15,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          color: white,
                          text:
                              "${(novelDetailsProvider.reviewList?.length ?? 0)} Comments",
                          fontsizeNormal: 11,
                          fontweight: FontWeight.w400,
                          fontsizeWeb: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: novelDetailsProvider.reviewList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MyNetworkImage(
                          imgWidth: 46,
                          imgHeight: 46,
                          imageUrl: novelDetailsProvider
                                  .reviewList?[index].image
                                  .toString() ??
                              "",
                          fit: BoxFit.fill,
                        )),
                    title: Row(
                      children: [
                        Expanded(
                          child: MyText(
                              fontsizeWeb: 12,
                              maxline: 3,
                              fontsizeNormal: 11,
                              fontweight: FontWeight.w400,
                              color: gray,
                              text: novelDetailsProvider
                                      .reviewList?[index].comment
                                      .toString() ??
                                  ""),
                        ),
                        Row(
                          children: [
                            if (novelDetailsProvider.reviewList?[index].userId
                                    .toString() ==
                                Constant.userID)
                              InkWell(
                                onTap: () {
                                  openReviewRatingDialog(
                                      index,
                                      novelDetailsProvider
                                          .reviewList?[index].id);
                                },
                                child: MyImage(
                                  imagePath: 'ic_edit.png',
                                  height: 20,
                                  width: 20,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            const SizedBox(
                              width: 10,
                            ),
                            if (novelDetailsProvider.reviewList?[index].userId
                                    .toString() ==
                                Constant.userID)
                              InkWell(
                                onTap: () async {
                                  final commentprovider =
                                      Provider.of<NovelSectionDataProvider>(
                                          context,
                                          listen: false);

                                  await commentprovider.getdeleteReviews(
                                    commentprovider.reviewList?[index].id,
                                  );
                                  // if (!mounted) return;
                                  // Utils().hideProgress(context);
                                  if (commentprovider
                                          .deletereviewModel.status ==
                                      200) {
                                    commentprovider.reviewList?.removeAt(index);
                                    setState(() {});
                                  }
                                },
                                child: MyImage(
                                  imagePath: 'ic_delete.png',
                                  height: 20,
                                  width: 20,
                                  color: white,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Consumer<ShowDetailsProvider>(
                builder: (context, showDetailsProvider, child) {
                  if (showDetailsProvider.loadmore) {
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
          return const Center(
            child: SizedBox(
                height: 250,
                width: 250,
                child: NoData(title: 'nodata', subTitle: '')),
          );
        }
      },
    );
  }

  Widget commentList() {
    return Consumer<ShowDetailsProvider>(
      builder: (context, sectionDataProvider, child) {
        if (sectionDataProvider.getReviewModel.status == 200 &&
            (showDetailsProvider.getReviewModel.result?.length ?? 0) > 0) {
          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: darkappbgcolor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          fontsizeWeb: 15,
                          color: white,
                          text: "Top Reviews",
                          fontsizeNormal: 15,
                          fontweight: FontWeight.w500,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          fontsizeWeb: 12,
                          color: white,
                          text:
                              "${showDetailsProvider.reviewList?.length ?? 0} Comments",
                          fontsizeNormal: 11,
                          fontweight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: showDetailsProvider.reviewList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MyNetworkImage(
                          imgWidth: 46,
                          imgHeight: 46,
                          imageUrl: showDetailsProvider.reviewList?[index].image
                                  .toString() ??
                              "",
                          fit: BoxFit.fill,
                        )),
                    title: Row(
                      children: [
                        Expanded(
                          child: MyText(
                              maxline: 3,
                              fontsizeNormal: 11,
                              fontweight: FontWeight.w400,
                              color: gray,
                              fontsizeWeb: 12,
                              text: showDetailsProvider
                                      .reviewList?[index].comment
                                      .toString() ??
                                  ""),
                        ),
                        Row(
                          children: [
                            if (showDetailsProvider.reviewList?[index].userId
                                    .toString() ==
                                Constant.userID)
                              InkWell(
                                onTap: () {
                                  openReviewRatingDialog(
                                      index,
                                      showDetailsProvider
                                          .reviewList?[index].id);
                                },
                                child: MyImage(
                                  imagePath: 'ic_edit.png',
                                  height: 20,
                                  width: 20,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            const SizedBox(
                              width: 10,
                            ),
                            if (showDetailsProvider.reviewList?[index].userId
                                    .toString() ==
                                Constant.userID)
                              InkWell(
                                onTap: () async {
                                  if (widget.type == 1) {
                                    final commentprovider =
                                        Provider.of<ShowDetailsProvider>(
                                            context,
                                            listen: false);

                                    await commentprovider.getdeleteReviews(
                                      commentprovider.reviewList?[index].id,
                                    );
                                    // if (!mounted) return;
                                    // Utils().hideProgress(context);
                                    if (commentprovider
                                            .deletereviewModel.status ==
                                        200) {
                                      setState(() {
                                        commentprovider.reviewList
                                            ?.removeAt(index);
                                      });
                                    }
                                  } else {
                                    final commentprovider =
                                        Provider.of<NovelSectionDataProvider>(
                                            context,
                                            listen: false);

                                    await commentprovider.getdeleteReviews(
                                      commentprovider.reviewList?[index].id,
                                    );
                                    // if (!mounted) return;
                                    // Utils().hideProgress(context);
                                    if (commentprovider
                                            .deletereviewModel.status ==
                                        200) {
                                      setState(() {
                                        commentprovider.reviewList
                                            ?.removeAt(index);
                                      });
                                    }
                                  }
                                },
                                child: MyImage(
                                  imagePath: 'ic_delete.png',
                                  height: 20,
                                  width: 20,
                                  color: white,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Consumer<ShowDetailsProvider>(
                builder: (context, showDetailsProvider, child) {
                  if (showDetailsProvider.loadmore) {
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
          return const Center(
            child: SizedBox(
                height: 250,
                width: 250,
                child: NoData(title: 'nodata', subTitle: '')),
          );
        }
      },
    );
  }

  Widget moreLikeThis() {
    return Wrap(
      spacing: 10, // Adjust the spacing between chips as needed
      alignment: WrapAlignment.start,
      children: List.generate(
        moreLikeItems.length,
        (index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChoiceChip(
                elevation: 0,
                pressElevation: 0.0,
                selectedColor: colorPrimary,
                backgroundColor: appBgColor,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: moreLikeTxt, width: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                label: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: MyText(
                    color: moreLikeTxt,
                    text: moreLikeItems[index],
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w400,
                    maxline: 1,
                    fontsizeWeb: 12,
                    textalign: TextAlign.left,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                selected: _value == index,
                onSelected: (selected) {
                  setState(() {
                    _value = (selected ? index : null)!;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  openReviewRatingDialog(position, id) {
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
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  minWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: _buildCommentDialog(context, position, id)),
          ),
        );
      },
    ).whenComplete(() {});
  }

  Widget webcomment() {
    debugPrint("Web Comment Calling");
    debugPrint(
        "Web Comment Calling == ${showDetailsProvider.reviewList?.length}");
    return Consumer<ShowDetailsProvider>(
      builder: (context, sectionDataProvider, child) {
        if (sectionDataProvider.getReviewModel.status == 200 &&
            (showDetailsProvider.reviewList?.length ?? 0) > 0) {
          debugPrint(
              "Web Comment Calling == ${showDetailsProvider.reviewList?.length}");
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: darkappbgcolor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      fontsizeWeb: 14,
                      color: white,
                      text: "Top Reviews",
                      fontsizeNormal: 15,
                      fontweight: FontWeight.w500,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      fontsizeWeb: 12,
                      color: white,
                      text:
                          "${showDetailsProvider.reviewList?.length ?? 0} Comments",
                      fontsizeNormal: 11,
                      fontweight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              ResponsiveGridList(
                minItemWidth: 60,
                verticalGridSpacing: 8,
                horizontalGridSpacing: 8,
                minItemsPerRow: 1,
                maxItemsPerRow:
                    (kIsWeb && MediaQuery.of(context).size.width > 720) ? 1 : 1,
                listViewBuilderOptions: ListViewBuilderOptions(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                children: List.generate(
                  showDetailsProvider.reviewList?.length ?? 0,
                  (index) {
                    debugPrint(
                        "Web Comment  == ${showDetailsProvider.reviewList?[index].comment}");
                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8.0),
                      height: 100,
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                imgWidth: 46,
                                imgHeight: 46,
                                imageUrl: showDetailsProvider
                                        .reviewList?[index].image
                                        .toString() ??
                                    "",
                                fit: BoxFit.fill,
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    maxline: 1,
                                    fontsizeNormal: 11,
                                    fontsizeWeb: 12,
                                    fontweight: FontWeight.w400,
                                    color: gray,
                                    text: ((showDetailsProvider
                                                    .reviewList?[index]
                                                    .fullName ??
                                                "")
                                            .isEmpty)
                                        ? (showDetailsProvider
                                                .reviewList?[index].userName
                                                .toString() ??
                                            "")
                                        : (showDetailsProvider
                                                .reviewList?[index].fullName
                                                .toString() ??
                                            "")),
                                const SizedBox(
                                  height: 10,
                                ),
                                MyText(
                                    maxline: 1,
                                    fontsizeNormal: 11,
                                    fontsizeWeb: 10,
                                    fontweight: FontWeight.w400,
                                    color: gray,
                                    text: showDetailsProvider
                                            .reviewList?[index].comment
                                            .toString() ??
                                        ""),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (showDetailsProvider.reviewList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                InkWell(
                                  onTap: () {
                                    openReviewRatingDialog(
                                        index,
                                        showDetailsProvider
                                            .reviewList?[index].id);
                                  },
                                  child: MyImage(
                                    imagePath: 'ic_edit.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              const SizedBox(
                                width: 10,
                              ),
                              if (showDetailsProvider.reviewList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                InkWell(
                                  onTap: () async {
                                    final commentprovider =
                                        Provider.of<ShowDetailsProvider>(
                                      context,
                                      listen: false,
                                    );

                                    if (commentprovider.reviewList != null &&
                                        index <
                                            (commentprovider
                                                    .reviewList?.length ??
                                                0)) {
                                      final itemId =
                                          commentprovider.reviewList?[index].id;

                                      await commentprovider
                                          .getdeleteReviews(itemId);

                                      if (commentprovider
                                              .deletereviewModel.status ==
                                          200) {
                                        setState(() {
                                          commentprovider.reviewList
                                              ?.removeAt(index);
                                        });
                                      }
                                    }
                                  },
                                  child: MyImage(
                                    imagePath: 'ic_delete.png',
                                    height: 20,
                                    width: 20,
                                    color: white,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                      // title: Row(
                      //   children: [
                      //     MyText(
                      //         maxline: 1,
                      //         fontsizeNormal: 11,
                      //         fontweight: FontWeight.w400,
                      //         color: gray,
                      //         text: showDetailsProvider
                      //                 .reviewList?[index].comment
                      //                 .toString() ??
                      //             ""),
                      //     // Row(
                      //     //   children: [
                      //     //     if (showDetailsProvider.reviewList?[index].userId
                      //     //             .toString() ==
                      //     //         Constant.userID)
                      //     //       InkWell(
                      //     //         onTap: () {
                      //     //           openReviewRatingDialog(
                      //     //               index,
                      //     //               showDetailsProvider
                      //     //                   .reviewList?[index].id);
                      //     //         },
                      //     //         child: MyImage(
                      //     //           imagePath: 'ic_edit.png',
                      //     //           height: 20,
                      //     //           width: 20,
                      //     //         ),
                      //     //       )
                      //     //     else
                      //     //       const SizedBox.shrink(),
                      //     //     const SizedBox(
                      //     //       width: 10,
                      //     //     ),
                      //     //     if (showDetailsProvider.reviewList?[index].userId
                      //     //             .toString() ==
                      //     //         Constant.userID)
                      //     //       InkWell(
                      //     //         onTap: () async {
                      //     //           final commentprovider =
                      //     //               Provider.of<ShowDetailsProvider>(
                      //     //                   context,
                      //     //                   listen: false);

                      //     //           await commentprovider.getdeleteReviews(
                      //     //             commentprovider.reviewList?[index].id,
                      //     //           );
                      //     //           // if (!mounted) return;
                      //     //           // Utils().hideProgress(context);
                      //     //           if (commentprovider
                      //     //                   .deletereviewModel.status ==
                      //     //               200) {
                      //     //             commentprovider.reviewList
                      //     //                 ?.removeAt(index);
                      //     //             setState(() {});
                      //     //           }
                      //     //         },
                      //     //         child: MyImage(
                      //     //           imagePath: 'ic_delete.png',
                      //     //           height: 20,
                      //     //           width: 20,
                      //     //           color: white,
                      //     //         ),
                      //     //       )
                      //     //     else
                      //     //       const SizedBox.shrink(),
                      //     //   ],
                      //     // ),
                      //   ],
                      // ),
                    );
                  },
                ),
              ),
              Consumer<ShowDetailsProvider>(
                builder: (context, showDetailsProvider, child) {
                  if (showDetailsProvider.loadmore) {
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
          return const Center(
            child: SizedBox(
                height: 250,
                width: 250,
                child: NoData(title: 'nodata', subTitle: '')),
          );
        }
      },
    );
  }

  Widget webnovelcomment() {
    return Consumer<NovelSectionDataProvider>(
      builder: (context, novelDetailsProvider, child) {
        if (novelDetailsProvider.getReviewModel.status == 200 &&
            (novelDetailsProvider.reviewList?.length ?? 0) > 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: darkappbgcolor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      fontsizeWeb: 14,
                      color: white,
                      text: "Top Reviews",
                      fontsizeNormal: 15,
                      fontweight: FontWeight.w500,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      fontsizeWeb: 12,
                      color: white,
                      text:
                          "${novelDetailsProvider.reviewList?.length ?? 0} Comments",
                      fontsizeNormal: 11,
                      fontweight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              ResponsiveGridList(
                minItemWidth: 60,
                verticalGridSpacing: 8,
                horizontalGridSpacing: 8,
                minItemsPerRow: 1,
                maxItemsPerRow:
                    (kIsWeb && MediaQuery.of(context).size.width > 720) ? 1 : 1,
                listViewBuilderOptions: ListViewBuilderOptions(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                children: List.generate(
                  novelDetailsProvider.reviewList?.length ?? 0,
                  (index) {
                    debugPrint(
                        "Web Comment  == ${novelDetailsProvider.reviewList?[index].comment}");
                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8.0),
                      height: 100,
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                imgWidth: 46,
                                imgHeight: 46,
                                imageUrl: novelDetailsProvider
                                        .reviewList?[index].image
                                        .toString() ??
                                    "",
                                fit: BoxFit.fill,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                    maxline: 1,
                                    fontsizeNormal: 11,
                                    fontsizeWeb: 12,
                                    fontweight: FontWeight.w400,
                                    color: gray,
                                    text: ((novelDetailsProvider
                                                    .reviewList?[index]
                                                    .fullName ??
                                                "")
                                            .isEmpty)
                                        ? (novelDetailsProvider
                                                .reviewList?[index].userName
                                                .toString() ??
                                            "")
                                        : (novelDetailsProvider
                                                .reviewList?[index].fullName
                                                .toString() ??
                                            "")),
                                const SizedBox(
                                  height: 20,
                                ),
                                MyText(
                                    maxline: 1,
                                    fontsizeNormal: 11,
                                    fontsizeWeb: 12,
                                    fontweight: FontWeight.w400,
                                    color: gray,
                                    text: novelDetailsProvider
                                            .reviewList?[index].comment
                                            .toString() ??
                                        ""),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (novelDetailsProvider.reviewList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                InkWell(
                                  onTap: () {
                                    openReviewRatingDialog(
                                        index,
                                        novelDetailsProvider
                                            .reviewList?[index].id);
                                  },
                                  child: MyImage(
                                    imagePath: 'ic_edit.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              const SizedBox(
                                width: 10,
                              ),
                              if (novelDetailsProvider.reviewList?[index].userId
                                      .toString() ==
                                  Constant.userID)
                                InkWell(
                                  onTap: () async {
                                    if (widget.type == 1) {
                                      final commentprovider =
                                          Provider.of<ShowDetailsProvider>(
                                        context,
                                        listen: false,
                                      );

                                      if (commentprovider.reviewList != null &&
                                          index <
                                              (commentprovider
                                                      .reviewList?.length ??
                                                  0)) {
                                        final itemId = commentprovider
                                            .reviewList?[index].id;

                                        await commentprovider
                                            .getdeleteReviews(itemId);

                                        if (commentprovider
                                                .deletereviewModel.status ==
                                            200) {
                                          setState(() {
                                            commentprovider.reviewList
                                                ?.removeAt(index);
                                          });
                                        }
                                      }
                                    } else {
                                      final commentprovider =
                                          Provider.of<NovelSectionDataProvider>(
                                        context,
                                        listen: false,
                                      );

                                      if (commentprovider.reviewList != null &&
                                          index <
                                              (commentprovider
                                                      .reviewList?.length ??
                                                  0)) {
                                        // Get the ID of the item to be deleted
                                        final itemId = commentprovider
                                            .reviewList?[index].id;

                                        await commentprovider
                                            .getdeleteReviews(itemId);

                                        if (commentprovider
                                                .deletereviewModel.status ==
                                            200) {
                                          // Remove the item from the list and update the UI
                                          setState(() {
                                            commentprovider.reviewList
                                                ?.removeAt(index);
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: MyImage(
                                    imagePath: 'ic_delete.png',
                                    height: 20,
                                    width: 20,
                                    color: white,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                      // title: Row(
                      //   children: [
                      //     MyText(
                      //         maxline: 1,
                      //         fontsizeNormal: 11,
                      //         fontweight: FontWeight.w400,
                      //         color: gray,
                      //         text: showDetailsProvider
                      //                 .reviewList?[index].comment
                      //                 .toString() ??
                      //             ""),
                      //     // Row(
                      //     //   children: [
                      //     //     if (showDetailsProvider.reviewList?[index].userId
                      //     //             .toString() ==
                      //     //         Constant.userID)
                      //     //       InkWell(
                      //     //         onTap: () {
                      //     //           openReviewRatingDialog(
                      //     //               index,
                      //     //               showDetailsProvider
                      //     //                   .reviewList?[index].id);
                      //     //         },
                      //     //         child: MyImage(
                      //     //           imagePath: 'ic_edit.png',
                      //     //           height: 20,
                      //     //           width: 20,
                      //     //         ),
                      //     //       )
                      //     //     else
                      //     //       const SizedBox.shrink(),
                      //     //     const SizedBox(
                      //     //       width: 10,
                      //     //     ),
                      //     //     if (showDetailsProvider.reviewList?[index].userId
                      //     //             .toString() ==
                      //     //         Constant.userID)
                      //     //       InkWell(
                      //     //         onTap: () async {
                      //     //           final commentprovider =
                      //     //               Provider.of<ShowDetailsProvider>(
                      //     //                   context,
                      //     //                   listen: false);

                      //     //           await commentprovider.getdeleteReviews(
                      //     //             commentprovider.reviewList?[index].id,
                      //     //           );
                      //     //           // if (!mounted) return;
                      //     //           // Utils().hideProgress(context);
                      //     //           if (commentprovider
                      //     //                   .deletereviewModel.status ==
                      //     //               200) {
                      //     //             commentprovider.reviewList
                      //     //                 ?.removeAt(index);
                      //     //             setState(() {});
                      //     //           }
                      //     //         },
                      //     //         child: MyImage(
                      //     //           imagePath: 'ic_delete.png',
                      //     //           height: 20,
                      //     //           width: 20,
                      //     //           color: white,
                      //     //         ),
                      //     //       )
                      //     //     else
                      //     //       const SizedBox.shrink(),
                      //     //   ],
                      //     // ),
                      //   ],
                      // ),
                    );
                  },
                ),
              ),
              Consumer<ShowDetailsProvider>(
                builder: (context, showDetailsProvider, child) {
                  if (showDetailsProvider.loadmore) {
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
          return const Center(
            child: SizedBox(
                height: 250,
                width: 250,
                child: NoData(title: 'nodata', subTitle: '')),
          );
        }
      },
    );
  }

  commentShimmr() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: darkappbgcolor,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget.roundcorner(
            height: 15,
            width: 100,
          ),
          SizedBox(
            height: 15,
          ),
          ShimmerWidget.roundcorner(
            height: 15,
            width: 75,
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              ShimmerWidget.circular(
                height: 45,
                width: 45,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: ShimmerWidget.roundcorner(
                  height: 15,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ShimmerWidget.circular(
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 5,
              ),
              ShimmerWidget.circular(
                height: 20,
                width: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentDialog(context, position, id) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
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
                        text: "reviewandrating",
                        multilanguage: true,
                        textalign: TextAlign.start,
                        fontsizeNormal: 17,
                        maxline: 1,
                        fontsizeWeb: 17,
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
                          ratingGiven = null;
                          // detailprovider.resetCommentData();
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

              /* Add Rating */
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: primaryDark,
                      text: "give_ratings",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: 16,
                      maxline: 1,
                      fontsizeWeb: 16,
                      fontweight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RatingBar(
                        initialRating: 0.0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemSize: 30,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: const Icon(
                            Icons.star,
                            color: primaryDark,
                          ),
                          half: const Icon(
                            Icons.star_half,
                            color: primaryDark,
                          ),
                          empty: const Icon(
                            Icons.star_border,
                            color: gray,
                          ),
                        ),
                        onRatingUpdate: (double value) {
                          ratingGiven = value;
                          debugPrint("ratingGiven => $ratingGiven");
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /* Add Review */
              Container(
                height: 150,
                decoration: Utils.setBGWithBorder(colorPrimary.withOpacity(0.2),
                    gray.withOpacity(0.5), 8, 0.5),
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
                child: TextFormField(
                  controller: commentController,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  textAlign: TextAlign.start,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) async {
                    // await detailprovider.notifyProvider();
                  },
                  maxLines: 10,
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
              InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () async {
                  debugPrint("Submit ratingGiven ===> $ratingGiven");
                  debugPrint(
                      "Submit comment =======> ${commentController.text}");
                  final commentprovider =
                      Provider.of<ShowDetailsProvider>(context, listen: false);

                  if (commentController.text.isNotEmpty &&
                      commentController.text != "") {
                    // Utils.showProgress(context, prDialog);
                    await commentprovider.getEditReviews(
                      id,
                      commentController.text,
                      ratingGiven ?? 0,
                    );
                    if (commentprovider.editreviewModel.status == 200) {
                      commentController.clear();
                      widget.type == 1
                          ? showDetailsProvider.getReviews(
                              widget.contentid,
                              widget.contentype,
                              showDetailsProvider.currentPage)
                          : novelDetailsProvider.getReviews(
                              widget.contentid,
                              widget.contentype,
                              novelDetailsProvider.reviewcurrentPage);

                      Navigator.of(context, rootNavigator: true).pop();
                    } else {
                      Utils.showToast("please_add_comment");
                    }
                  } else {
                    Utils.showToast("please_add_comment");
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: 150,
                  decoration: Utils.setBGWithBorder(colorAccent, gray, 5, 0.5),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Consumer<ShowDetailsProvider>(
                    builder: (context, homeProvider, child) {
                      return MyText(
                        color: (commentController.text.toString().isEmpty)
                            ? white
                            : white,
                        text: "submit",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 14,
                        maxline: 1,
                        fontsizeWeb: 16,
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
        ),
      ),
    );
  }
  /* Add Review - Reating END */

  /* Add Review - Reating START */
  openAddReviewRatingDialog(context) {
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
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  minWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: _buildADDCommentDialog(context)),
          ),
        );
      },
    );
  }

  Widget _buildADDCommentDialog(context) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
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
                        text: "reviewandrating",
                        multilanguage: true,
                        textalign: TextAlign.start,
                        fontsizeNormal: 17,
                        fontsizeWeb: 18,
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
                          ratingGiven = null;
                          // detailprovider.resetCommentData();
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

              /* Add Rating */
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                      color: primaryDark,
                      text: "give_ratings",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsizeNormal: 16,
                      fontsizeWeb: 18,
                      maxline: 1,
                      fontweight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RatingBar(
                        initialRating: 0.0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemSize: 30,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: const Icon(
                            Icons.star,
                            color: primaryDark,
                          ),
                          half: const Icon(
                            Icons.star_half,
                            color: primaryDark,
                          ),
                          empty: const Icon(
                            Icons.star_border,
                            color: gray,
                          ),
                        ),
                        onRatingUpdate: (double value) {
                          ratingGiven = value;
                          debugPrint("ratingGiven => $ratingGiven");
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /* Add Review */
              Container(
                height: 150,
                padding: const EdgeInsets.all(10),
                decoration: Utils.setBGWithBorder(colorPrimary.withOpacity(0.2),
                    gray.withOpacity(0.5), 8, 0.5),
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
                child: TextFormField(
                  controller: commentController,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  textAlign: TextAlign.start,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) async {
                    // await detailprovider.notifyProvider();
                  },
                  maxLines: 10,
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
              InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () async {
                  if (Constant.userID != null) {
                    debugPrint("Submit ratingGiven ===> $ratingGiven");
                    debugPrint(
                        "Submit comment =======> ${commentController.text}");
                    final commentprovider = Provider.of<ShowDetailsProvider>(
                        context,
                        listen: false);
                    if (widget.type == 1) {
                      if (episodeProvider.doComment == true) {
                        if (commentController.text.isNotEmpty &&
                            commentController.text != "") {
                          await commentprovider.getAddReviews(
                            widget.contentid,
                            commentController.text,
                            widget.contentype,
                            ratingGiven ?? 0,
                          );
                          if (commentprovider.addreviewModel.status == 200) {
                            commentController.clear();
                            widget.type == 1
                                ? showDetailsProvider.getReviews(
                                    widget.contentid,
                                    widget.contentype,
                                    showDetailsProvider.currentPage)
                                : novelDetailsProvider.getReviews(
                                    widget.contentid,
                                    widget.contentype,
                                    novelDetailsProvider.reviewcurrentPage);

                            Navigator.of(context, rootNavigator: true).pop();
                          } else {
                            Utils.showToast("please_add_comment");
                          }
                        } else {
                          Utils.showToast("please_add_comment");
                        }
                      } else {
                        Utils.showToast("You are not able to Comment");
                      }
                    } else {
                      if (novelDetailsProvider.doComment == true) {
                        if (commentController.text.isNotEmpty &&
                            commentController.text != "") {
                          await commentprovider.getAddReviews(
                            widget.contentid,
                            commentController.text,
                            widget.contentype,
                            ratingGiven ?? 0,
                          );
                          if (commentprovider.addreviewModel.status == 200) {
                            commentController.clear();
                            widget.type == 1
                                ? showDetailsProvider.getReviews(
                                    widget.contentid,
                                    widget.contentype,
                                    showDetailsProvider.currentPage)
                                : novelDetailsProvider.getReviews(
                                    widget.contentid,
                                    widget.contentype,
                                    novelDetailsProvider.reviewcurrentPage);

                            Navigator.of(context, rootNavigator: true).pop();
                          } else {
                            Utils.showToast("please_add_comment");
                          }
                        } else {
                          Utils.showToast("please_add_comment");
                        }
                      } else {
                        Utils.showToast("You are not able to Comment");
                      }
                    }
                  } else {
                    if (kIsWeb) {
                      Utils.buildWebAlertDialog(context, "login", "");
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginSocial(
                                    ishome: false,
                                  )));
                    }
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: 150,
                  decoration: Utils.setBGWithBorder(colorAccent, gray, 5, 0.5),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Consumer<ShowDetailsProvider>(
                    builder: (context, homeProvider, child) {
                      return MyText(
                        color: (commentController.text.toString().isEmpty)
                            ? white
                            : white,
                        text: "submit",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 14,
                        maxline: 1,
                        fontsizeWeb: 16,
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
        ),
      ),
    );
  }
  /* Add Review - Reating END */
}

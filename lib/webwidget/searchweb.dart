import 'dart:convert';
import 'dart:math';

import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/pages/mywallet.dart';
import 'package:dtpocketfm/pages/notification.dart';
import 'package:dtpocketfm/pages/profile.dart';
import 'package:dtpocketfm/provider/findprovider.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerwidget.dart';
import 'package:dtpocketfm/tvpages/webvideosbyid.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/myusernetworkimg.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dtpocketfm/model/searchlistmodel.dart';
import 'package:dtpocketfm/provider/searchprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class SearchWeb extends StatefulWidget {
  final String? searchText;
  const SearchWeb({super.key, this.searchText});

  @override
  State<SearchWeb> createState() => _SearchWebState();
}

class _SearchWebState extends State<SearchWeb> {
  late SearchProvider searchProvider;
  late FindProvider findProvider;
  late ScrollController _scrollController;
  late ProfileProvider profileProvider;
  String? mSearchText;
  final searchController = TextEditingController();

  @override
  void initState() {
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    findProvider = Provider.of<FindProvider>(context, listen: false);
    searchController.text = widget.searchText ?? "";
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // searchProvider.setLoading(true);
    _getData();
    super.initState();
  }

  List<Color> oneColorList = [
    red,
    complimentryColor,
    primaryTras75,
    yellow,
    infoBG,
    lanBgColor2,
    lanBgColor1,
    lightGreen
  ];

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (searchProvider.searchcurrentPage ?? 0) <
            (searchProvider.searchtotalPage ?? 0)) {
      debugPrint("Calling Set LoadMore");
      searchProvider.setLoadMore(true);

      await _fetchData((searchProvider.searchcurrentPage ?? 0));
    }
  }

  /* Section Data Api */
  Future<void> _fetchData(int? nextPage) async {
    getTabData(searchProvider.selectedIndex, (searchProvider.selectedIndex) + 1,
        (nextPage ?? 0) + 1);
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  Future<void> getTabData(int position, type, nextpage) async {
    debugPrint("getTabData position ====> $position");
    await setSelectedTab(position);

    searchProvider.getSearchVideo(searchController.text, type, nextpage);
  }

  Future<void> setSelectedTab(int tabPos) async {
    debugPrint("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await searchProvider.setSelectedTab(tabPos);
    debugPrint(
        "setSelectedTab selectedIndex ====> ${searchProvider.selectedIndex}");
    debugPrint(
        "setSelectedTab lastTabPosition ====> ${searchProvider.lastTabPosition}");
    if (searchProvider.lastTabPosition == tabPos) {
      return;
    } else {
      searchProvider.setTabPosition(tabPos);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    searchProvider.clearProvider();
    super.dispose();
  }

  _getData() async {
    await profileProvider.getProfile(context);
    await findProvider.getGenres();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: appBgColor,
          // resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  padding: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: Dimens.homeTabHeight,
                  color: appBgColor,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                        child: InkWell(
                          autofocus: true,
                          focusColor: gray.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            child: MyImage(
                              fit: BoxFit.fill,
                              imagePath: "backwith_bg.png",
                            ),
                          ),
                        ),
                      ),
                      Consumer<ProfileProvider>(
                        builder: (context, value, child) {
                          return InkWell(
                            onTap: () {
                              if (Constant.userID == null) {
                                if (kIsWeb) {
                                  Utils.buildWebAlertDialog(
                                      context, "login", "");
                                } else {
                                  Utils.openLogin(
                                      context: context,
                                      isHome: true,
                                      isReplace: false);
                                }
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const MyProfile(
                                              type: 'myProfile',
                                            )));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                clipBehavior: Clip.antiAlias,
                                child: MyUserNetworkImage(
                                  imageUrl:
                                      profileProvider.profileModel.status == 200
                                          ? profileProvider
                                                      .profileModel.result !=
                                                  null
                                              ? (profileProvider.profileModel
                                                      .result?[0].image ??
                                                  "")
                                              : ""
                                          : "",
                                  fit: BoxFit.fill,
                                  imgHeight: 46,
                                  imgWidth: 46,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.centerLeft,
                        height: 40,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          readOnly: false,
                          // enabled: isSearchEnable,
                          onChanged: (value) async {
                            debugPrint("value ====> $value");
                            if (value.isNotEmpty) {
                              mSearchText = value;
                              debugPrint("mSearchText ====> $mSearchText");
                              Constant.searchtext = value;
                              searchProvider.searchcontentlist = [];
                              _fetchData(0);
                            }
                          },
                          textInputAction: TextInputAction.done,
                          obscureText: false,
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          style: const TextStyle(
                            color: black,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            filled: true,
                            isCollapsed: true,
                            fillColor: transparentColor,
                            hintStyle: TextStyle(
                              color: otherColor,
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: searchHint2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Notifications()))
                              .then((value) => _getData());
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          width: 20,
                          child: MyImage(
                            imagePath: "ic_notification.png",
                            height: 46,
                            width: 46,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyWallet()))
                              .then((value) => _getData());
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          width: 20,
                          child: MyImage(
                            imagePath: "ic_wallet.png",
                            height: 46,
                            width: 46,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /* Genres */
                Consumer<FindProvider>(
                  builder: (context, findProvider, child) {
                    debugPrint(
                        "setGenresSize  ===>  ${findProvider.setGenresSize}");
                    debugPrint(
                        "genresModel Size  ===>  ${(findProvider.genresModel.result?.length ?? 0)}");

                    return Column(
                      children: [
                        /* Genres START */
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          alignment: Alignment.centerLeft,
                          child: MyText(
                            color: white,
                            text: "explore_category",
                            textalign: TextAlign.center,
                            fontsizeNormal: 15,
                            fontsizeWeb: 16,
                            fontweight: FontWeight.w600,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (findProvider.loading)
                          categoryShimmer()
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                            child: ResponsiveGridList(
                              minItemWidth: 150,
                              minItemsPerRow: 1,
                              maxItemsPerRow: 4,
                              horizontalGridSpacing: 10,
                              verticalGridSpacing: 10,
                              listViewBuilderOptions: ListViewBuilderOptions(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                              children: List.generate(
                                  findProvider.genresModel.result?.length ?? 0,
                                  (position) {
                                Color randomColor = oneColorList[
                                    Random().nextInt(oneColorList.length)];
                                return Column(
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return WebVideosByID(
                                                findProvider.genresModel
                                                        .result?[position].id ??
                                                    0,
                                                1,
                                                findProvider
                                                        .genresModel
                                                        .result?[position]
                                                        .name ??
                                                    "",
                                                "ByCategory",
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: randomColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        height: 100,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: MyText(
                                                color: white,
                                                text: findProvider
                                                        .genresModel
                                                        .result?[position]
                                                        .name ??
                                                    "",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontsizeWeb: 14,
                                                multilanguage: false,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontweight: FontWeight.w500,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: MyNetworkImage(
                                                imgWidth: 40,
                                                imgHeight: 40,
                                                imageUrl: findProvider
                                                        .genresModel
                                                        .result?[position]
                                                        .image ??
                                                    "",
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),

                        /* Genres END */

                        /* AdMob Banner */
                        const SizedBox(height: 10),
                        Utils.showBannerAd(context),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                Container(
                    width: MediaQuery.of(context).size.width,
                    color: appBgColor,
                    child: _buildSearchPage()),
                Consumer<SearchProvider>(
                  builder: (context, searchProvider, child) {
                    if (searchProvider.loadmore) {
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
        Utils.buildMusicPanel(context)
      ],
    );
  }

  Widget _buildSearchPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            constraints: BoxConstraints(
              minWidth: 0,
              maxWidth: (kIsWeb || Constant.isTV)
                  ? (MediaQuery.of(context).size.width * 0.5)
                  : MediaQuery.of(context).size.width,
            ),
            alignment: Alignment.center,
            height: (kIsWeb || Constant.isTV) ? 40 : Dimens.detailTabs,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* Video */
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: gray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        // searchProvider.setDataVisibility(true, false);
                        searchProvider.searchcontentlist = [];
                        await getTabData(0, 1, 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: MyText(
                                color: searchProvider.selectedIndex == 0
                                    ? primaryDark
                                    : white,
                                text: "audiobook",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsizeNormal: 16,
                                fontsizeWeb: 15,
                                fontweight: FontWeight.w500,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Visibility(
                              // visible: searchProvider.isVideoClick,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 2,
                                color: searchProvider.selectedIndex == 0
                                    ? primaryDark
                                    : appBgColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /* Show */
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: gray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        // searchProvider.setDataVisibility(false, true);
                        searchProvider.searchcontentlist = [];
                        await getTabData(1, 2, 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: MyText(
                                color: searchProvider.selectedIndex == 1
                                    ? primaryDark
                                    : white,
                                text: "novels",
                                textalign: TextAlign.center,
                                fontsizeNormal: 16,
                                fontsizeWeb: 15,
                                multilanguage: true,
                                fontweight: FontWeight.w500,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                            Visibility(
                              // visible: searchProvider.isVideoClick,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 2,
                                color: searchProvider.selectedIndex == 1
                                    ? primaryDark
                                    : appBgColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // searchProvider.setDataVisibility(
                      //     true, false);
                      searchProvider.searchcontentlist = [];
                      await getTabData(2, 3, 1);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MyText(
                          color: searchProvider.selectedIndex == 2
                              ? primaryDark
                              : white,
                          text: "music",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          fontsizeWeb: 15,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 2),
                        Visibility(
                          // visible: searchProvider.isVideoClick,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: searchProvider.selectedIndex == 2
                                ? primaryDark
                                : appBgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // searchProvider.setDataVisibility(
                      //     true, false);
                      searchProvider.searchcontentlist = [];
                      await getTabData(3, 4, 1);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MyText(
                          color: searchProvider.selectedIndex == 3
                              ? primaryDark
                              : white,
                          text: "artist",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          fontsizeWeb: 15,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 2),
                        Visibility(
                          visible: searchProvider.isVideoClick,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: searchProvider.selectedIndex == 3
                                ? primaryDark
                                : appBgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // searchProvider.setDataVisibility(
                      //     false, true);
                      searchProvider.searchcontentlist = [];
                      await getTabData(4, 5, 1);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MyText(
                          color: searchProvider.selectedIndex == 4
                              ? primaryDark
                              : white,
                          text: "users",
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          fontsizeWeb: 15,
                          fontweight: FontWeight.w500,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 2),
                        Visibility(
                          // visible: searchProvider.isShowClick,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: searchProvider.selectedIndex == 4
                                ? primaryDark
                                : appBgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 22),
        Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            if (searchProvider.loading && searchProvider.loadmore == false) {
              return searchSHimmer();
            } else {
              return _buildVideoUI();
            }
          },
        ),
      ],
    );
  }

  Widget categoryShimmer() {
    debugPrint("Shimmer calling");
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
      child: ResponsiveGridList(
        minItemWidth: 150,
        minItemsPerRow: 1,
        maxItemsPerRow: 4,
        horizontalGridSpacing: 10,
        verticalGridSpacing: 10,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          10,
          (position) {
            Color randomColor =
                oneColorList[Random().nextInt(oneColorList.length)];
            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return WebVideosByID(
                            findProvider.genresModel.result?[position].id ?? 0,
                            1,
                            findProvider.genresModel.result?[position].name ??
                                "",
                            "ByCategory",
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: randomColor,
                        borderRadius: BorderRadius.circular(10)),
                    height: 100,
                    child: Row(
                      children: [
                        const Expanded(
                          child: ShimmerWidget.roundcorner(
                            height: 20,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const ShimmerWidget.roundcorner(
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoUI() {
    return Consumer<SearchProvider>(builder: (context, searchProvider, child) {
      if (searchProvider.searchModel.status == 200) {
        if ((searchProvider.searchcontentlist?.length ?? 0) > 0) {
          return AlignedGridView.count(
            shrinkWrap: true,
            crossAxisCount: 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 10,
            itemCount: (searchProvider.searchcontentlist?.length ?? 0),
            padding: const EdgeInsets.only(left: 20, right: 20),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int position) {
              return Column(
                children: [
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        if (searchProvider.selectedIndex == 3) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthorProfile(
                                        artistID: searchProvider
                                            .searchcontentlist?[position].id,
                                      )));
                        } else if (searchProvider.selectedIndex == 4) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyProfile(
                                        type: 'otherUser',
                                        userid: searchProvider
                                            .searchcontentlist?[position].id
                                            .toString(),
                                      )));
                        } else if (searchProvider.selectedIndex == 0 ||
                            searchProvider.selectedIndex == 1) {
                          Utils.openDetails(
                            context: context,
                            videoId: searchProvider
                                    .searchcontentlist?[position].id ??
                                0,
                            videoType: searchProvider
                                    .searchcontentlist?[position].contentType ??
                                0,
                          );
                        } else if (searchProvider.selectedIndex == 2) {
                          playAudio(
                            playingType: searchProvider
                                    .searchcontentlist?[position].contentType
                                    .toString() ??
                                "",
                            episodeid: searchProvider
                                    .searchcontentlist?[position].id
                                    .toString() ??
                                "",
                            contentid: searchProvider
                                    .searchcontentlist?[position].id
                                    .toString() ??
                                "",
                            position: position,
                            sectionBannerList:
                                searchProvider.searchcontentlist ?? [],
                            contentName: searchProvider
                                    .searchcontentlist?[position].title
                                    .toString() ??
                                "",
                            isBuy: "1",
                          );
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: MyNetworkImage(
                              imageUrl: (searchProvider.selectedIndex == 4 ||
                                      searchProvider.selectedIndex == 3)
                                  ? (searchProvider
                                          .searchcontentlist?[position].image
                                          .toString() ??
                                      "")
                                  : (searchProvider.searchcontentlist?[position]
                                          .landscapeImg
                                          .toString() ??
                                      ""),
                              fit: BoxFit.fill,
                              imgHeight: 120,
                              imgWidth: 150,
                            ),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  maxline: 2,
                                  color: white,
                                  text: searchProvider.selectedIndex == 3
                                      ? (searchProvider
                                              .searchcontentlist?[position]
                                              .userName
                                              .toString() ??
                                          "")
                                      : searchProvider.selectedIndex == 4
                                          ? (searchProvider
                                                          .searchcontentlist?[
                                                              position]
                                                          .fullName
                                                          .toString() ??
                                                      "")
                                                  .isEmpty
                                              ? (searchProvider
                                                      .searchcontentlist?[
                                                          position]
                                                      .userName
                                                      .toString() ??
                                                  "")
                                              : (searchProvider
                                                      .searchcontentlist?[
                                                          position]
                                                      .fullName
                                                      .toString() ??
                                                  "")
                                          : searchProvider
                                                  .searchcontentlist?[position]
                                                  .title
                                                  .toString() ??
                                              "",
                                  fontsizeNormal: 14,
                                  fontsizeWeb: 16,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                searchProvider.selectedIndex == 3 ||
                                        searchProvider.selectedIndex == 4
                                    ? const SizedBox.shrink()
                                    : searchProvider.selectedIndex == 2
                                        ? MyText(
                                            maxline: 1,
                                            fontsizeWeb: 14,
                                            color: primaryDark,
                                            text:
                                                "${formatNumber(searchProvider.searchcontentlist?[position].totalPlayed ?? 0)} Play",
                                            fontsizeNormal: 12,
                                          )
                                        : MyText(
                                            maxline: 1,
                                            fontsizeWeb: 14,
                                            color: primaryDark,
                                            text:
                                                "${formatNumber(searchProvider.searchcontentlist?[position].totalUserPlay ?? 0)} Play",
                                            fontsizeNormal: 12,
                                          ),
                                const SizedBox(
                                  height: 5,
                                ),
                                searchProvider.selectedIndex == 2 ||
                                        searchProvider.selectedIndex == 3 ||
                                        searchProvider.selectedIndex == 4
                                    ? const SizedBox.shrink()
                                    : MyText(
                                        maxline: 1,
                                        fontsizeWeb: 14,
                                        color: white,
                                        text:
                                            "${searchProvider.searchcontentlist?[position].totalEpisode.toString() ?? ""} Episodes",
                                        fontsizeNormal: 12,
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: gray,
                    thickness: 1,
                  )
                ],
              );
            },
          );
        } else {
          if (searchController.text.isEmpty) {
            return const SizedBox.shrink();
          } else {
            return const NoData(title: "nodata", subTitle: "");
          }
        }
      } else {
        if (searchController.text.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return const NoData(title: "nodata", subTitle: "");
        }
      }
    });
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

    /* Only Music Direct Play*/
    // if (playingType == "2") {
    if (Constant.userID != null) {
      musicManager.setInitialMusic(
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, contentid),
          false,
          0,
          isBuy ?? "",
          1,
          "searchMusic",
          "0");
    } else {
      Utils.buildWebAlertDialog(context, "login", "");
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.getAddContentPlay(3, 0, 0, contentId);
  }

  Widget searchSHimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 10,
          itemCount: 10,
          padding: const EdgeInsets.only(left: 20, right: 20),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return Column(
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerWidget.roundcorner(
                        width: 150,
                        height: 120,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShimmerWidget.roundcorner(
                              width: 180,
                              height: 20,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            searchProvider.selectedIndex == 3 ||
                                    searchProvider.selectedIndex == 4
                                ? const SizedBox.shrink()
                                : const ShimmerWidget.roundcorner(
                                    width: 150,
                                    height: 20,
                                  ),
                            const SizedBox(
                              height: 5,
                            ),
                            searchProvider.selectedIndex == 3 ||
                                    searchProvider.selectedIndex == 4
                                ? const SizedBox.shrink()
                                : const ShimmerWidget.roundcorner(
                                    width: 180,
                                    height: 20,
                                  ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: gray,
                  thickness: 1,
                )
              ],
            );
          },
        ),
      ],
    );
  }
}

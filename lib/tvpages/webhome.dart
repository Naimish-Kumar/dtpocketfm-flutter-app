import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/pages/mywallet.dart';
import 'package:dtpocketfm/pages/notification.dart';
import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/subscription/subscription.dart';
import 'package:dtpocketfm/tvpages/webaudiobook.dart';
import 'package:dtpocketfm/tvpages/webmusic.dart';
import 'package:dtpocketfm/tvpages/webnovel.dart';
import 'package:dtpocketfm/provider/searchprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/tvpages/webthread.dart';
import 'package:dtpocketfm/tvpages/webviewall.dart';
import 'package:dtpocketfm/tvpages/webwishlist.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/model/sectionlistmodel.dart';
import 'package:dtpocketfm/model/genresmodel.dart' as type;
import 'package:dtpocketfm/model/sectionlistmodel.dart' as list;
import 'package:dtpocketfm/model/sectionbannermodel.dart' as banner;
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/tvpages/webvideosbyid.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/sectiondataprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/webwidget/footerweb.dart';
import 'package:dtpocketfm/webwidget/searchweb.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WebHome extends StatefulWidget {
  final String? pageName;
  const WebHome({super.key, required this.pageName});

  @override
  State<WebHome> createState() => WebHomeState();
}

class WebHomeState extends State<WebHome> {
  late ProfileProvider profileProvider;
  late SectionDataProvider sectionDataProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPref = SharedPre();
  final TextEditingController searchController = TextEditingController();
  late HomeProvider homeProvider;
  late SearchProvider searchProvider;
  CarouselController carouselController = CarouselController();
  int? videoId, videoType, typeId;
  final tabScrollController = ScrollController();
  bool isSearchEnable = false;
  String? currentPage, langCatName, mSearchText;
  late ScrollController _scrollController;

  _onItemTapped(String page) async {
    debugPrint("_onItemTapped -----------------> $page");
    await homeProvider.setCurrentPage(page);
    if (page != "") {
      await setSelectedTab(0);
      debugPrint("HomeProvider.selctedIndex == ${homeProvider.selectedIndex}");
    }
    if (page != "search") {
      isSearchEnable = false;
      mSearchText = "";
      searchController.clear();
      searchProvider.clearProvider();
      await searchProvider.notifyProvider();
    }
    setState(() {
      currentPage = page;
    });
  }

  @override
  void initState() {
    currentPage = widget.pageName ?? "";
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
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
        (sectionDataProvider.currentPage ?? 0) <
            (sectionDataProvider.totalPage ?? 0)) {
      sectionDataProvider.setLoadMore(true);

      _fetchData(
          sectionDataProvider.currentPage ?? 0, homeProvider.selectedIndex);
    }
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  _fetchData(pageno, position) {
    debugPrint("POsition IS ==$position");
    getTabData(position, homeProvider.genresModel.result, pageno + 1);
  }

  _getData() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await profileProvider.getProfile(context);
    Constant.userID = await sharedPref.read("userid");

    Utils.getCurrencySymbol();

    debugPrint('userID ==> ${Constant.userID}');

    await homeProvider.setLoading(true);
    await homeProvider.getGenres();
    if (!homeProvider.loading) {
      if (homeProvider.genresModel.status == 200 &&
          homeProvider.genresModel.result != null) {
        if ((homeProvider.genresModel.result?.length ?? 0) > 0) {
          if ((sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
                  0 ||
              (sectionDataProvider.sectionListModel.result?.length ?? 0) == 0) {
            getTabData(0, homeProvider.genresModel.result, 1);
          }
        }
      }
    }

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    if (!mounted) return;
    generalProvider.getGeneralsetting(context);
  }

  Future<void> setSelectedTab(int tabPos) async {
    if (!context.mounted) return;
    await homeProvider.setSelectedTab(tabPos);
    debugPrint("position position 2 is == $tabPos");
    debugPrint("getTabData position ====> $tabPos");
    debugPrint(
        "getTabData lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList, pageno) async {
    await setSelectedTab(position);
    debugPrint("position position 1 is == $position");
    await sectionDataProvider.setLoading(true);
    await sectionDataProvider.getSectionBanner(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
    await sectionDataProvider.getSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2",
        pageno);
  }

  openDetailPage(
    String pageName,
    int videoId,
    int videoType,
  ) async {
    debugPrint("pageName =======> $pageName");
    debugPrint("videoId ========> $videoId");

    debugPrint("videoType ======> $videoType");
    if (pageName != "" && (kIsWeb || Constant.isTV)) {
      await setSelectedTab(-1);
    }
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      videoType: videoType,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _clickToRedirect({required String pageName}) {
    switch (pageName) {
      case "channel":
        return const WebAudioBook();
      case "store":
        return const WebNovel();
      // case "search":
      //   return SearchWeb(searchText: mSearchText);
      case "thread":
        return const WebThreads();
      case "music":
        return const WebMusic();
      default:
        return tabItem(homeProvider.genresModel.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appBgColor,
        body: SafeArea(
          child: _webAppBarWithDetails(),
        ),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget _webAppBarWithDetails() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.genresModel.status == 200) {
        if (homeProvider.genresModel.result != null ||
            (homeProvider.genresModel.result?.length ?? 0) > 0) {
          return Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _clickToRedirect(pageName: currentPage ?? ""),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildAppBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.webhomeTabHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      color: appBgColor,
      child: SizedBox(
        height: Dimens.webhomeTabHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* Menu */
            (MediaQuery.of(context).size.width < 950)
                ? Container(
                    constraints: const BoxConstraints(
                      minWidth: 25,
                    ),
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Consumer<HomeProvider>(
                      builder: (context, homeProvider, child) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            // Specify the type for DropdownButton2
                            isDense: true,
                            isExpanded: true,
                            customButton: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: MyImage(
                                height: 40,
                                imagePath: "ic_menu.png",
                                fit: BoxFit.contain,
                                color: white,
                              ),
                            ),
                            items: _buildWebDropDownItems(),
                            onChanged: (String? value) async {
                              if (value == "Home") {
                                _onItemTapped("home");
                              } else if (value == "AudioBook") {
                                _onItemTapped("channel");
                              } else if (value == "Novel") {
                                _onItemTapped("store");
                              } else if (value == "Threads") {
                                _onItemTapped("thread");
                              } else if (value == "Music") {
                                _onItemTapped("music");
                              } else if (value == "Wishlist") {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const WebWishList(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return child;
                                      },
                                    ));
                              } else if (value == "Notification") {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const Notifications(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return child;
                                      },
                                    ));
                              } else if (value == "Wallet") {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const MyWallet(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return child;
                                      },
                                    ));
                              }
                            },
                            dropdownStyleData: DropdownStyleData(
                              width: 180,
                              useSafeArea: true,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              decoration: Utils.setBackground(lightBlack, 5),
                              elevation: 8,
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              overlayColor: WidgetStateProperty.resolveWith(
                                (states) {
                                  if (states.contains(WidgetState.focused)) {
                                    return white.withOpacity(0.5);
                                  }
                                  return transparentColor;
                                },
                              ),
                            ),
                            buttonStyleData: ButtonStyleData(
                              decoration: Utils.setBGWithBorder(
                                transparentColor,
                                white,
                                20,
                                1,
                              ),
                              overlayColor: WidgetStateProperty.resolveWith(
                                (states) {
                                  if (states.contains(WidgetState.focused) ||
                                      states.contains(WidgetState.hovered)) {
                                    return white.withOpacity(0.5);
                                  }
                                  return transparentColor;
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),

            /* App Icon */
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                focusColor: white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  if (Constant.isTV) _onItemTapped("");
                  await getTabData(0, homeProvider.genresModel.result, 1);
                },
                child: MyImage(
                    // fit: BoxFit.fill,
                    width:
                        (MediaQuery.of(context).size.width < 950) ? 120 : 160,
                    height: 120,
                    imagePath: "appicon.png"),
              ),
            ),
            (MediaQuery.of(context).size.width > 820)
                ? const SizedBox(width: 10)
                : const SizedBox.shrink(),

            /* Feature buttons */
            /* Home Button */
            (MediaQuery.of(context).size.width > 950)
                ? Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        _onItemTapped("home");
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<HomeProvider>(
                          builder: (context, homeProvider, child) {
                            return MyText(
                              color: homeProvider.currentPage == "home"
                                  ? colorPrimary
                                  : white,
                              multilanguage: false,
                              text: bottomView1,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontsizeNormal: 14,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 12,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            /* Channels */
            (MediaQuery.of(context).size.width > 950)
                ? Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        _onItemTapped("channel");
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<HomeProvider>(
                          builder: (context, homeProvider, child) {
                            return MyText(
                              color: homeProvider.currentPage == "channel"
                                  ? colorPrimary
                                  : white,
                              multilanguage: false,
                              text: bottomView2,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontsizeNormal: 14,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 12,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            /* Rent */
            (MediaQuery.of(context).size.width > 950)
                ? Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        _onItemTapped("store");
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<HomeProvider>(
                          builder: (context, homeProvider, child) {
                            return MyText(
                              color: homeProvider.currentPage == "store"
                                  ? colorPrimary
                                  : white,
                              multilanguage: false,
                              text: bottomView3,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontsizeNormal: 14,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 12,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            /* Thread */
            (MediaQuery.of(context).size.width > 950)
                ? Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        _onItemTapped("thread");
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<HomeProvider>(
                          builder: (context, homeProvider, child) {
                            return MyText(
                              color: homeProvider.currentPage == "thread"
                                  ? colorPrimary
                                  : white,
                              multilanguage: false,
                              text: bottomView4,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontsizeNormal: 14,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 12,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            /* Music */
            (MediaQuery.of(context).size.width > 950)
                ? Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        _onItemTapped("music");
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Consumer<HomeProvider>(
                          builder: (context, homeProvider, child) {
                            return MyText(
                              color: homeProvider.currentPage == "music"
                                  ? colorPrimary
                                  : white,
                              multilanguage: false,
                              text: bottomView5,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontsizeNormal: 14,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 12,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            const Spacer(),
            /* Search */
            currentPage == "thread" || currentPage == "music"
                ? const SizedBox.shrink()
                : Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SearchWeb(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return child;
                              },
                            )).then((value) => _getData());
                      },
                      child: Container(
                        height: 25,
                        constraints:
                            const BoxConstraints(minWidth: 60, maxWidth: 130),
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        decoration: BoxDecoration(
                          color: white,
                          border: Border.all(
                            color: colorPrimary,
                            width: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                alignment: Alignment.center,
                                child: TextField(
                                  readOnly: true,
                                  enabled: isSearchEnable,
                                  onChanged: (value) async {
                                    debugPrint("value ====> $value");
                                    if (value.isNotEmpty) {
                                      mSearchText = value;
                                      debugPrint(
                                          "mSearchText ====> $mSearchText");
                                      Constant.searchtext = value;
                                      _onItemTapped("search");
                                      await searchProvider.setLoading(true);
                                      // await searchProvider.getSearchVideo(mSearchText);
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
                                  onSubmitted: (value) {
                                    if (isSearchEnable) {
                                      isSearchEnable = false;
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                    isCollapsed: true,
                                    fillColor: white,
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
                            ),
                            Consumer<SearchProvider>(
                              builder: (context, searchProvider, child) {
                                if (searchController.text
                                    .toString()
                                    .isNotEmpty) {
                                  return Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      focusColor: white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(5),
                                      onTap: () async {
                                        debugPrint("Click on Clear!");
                                        _onItemTapped("");
                                        searchController.clear();
                                        if (isSearchEnable) {
                                          isSearchEnable = false;
                                          FocusScope.of(context).unfocus();
                                        }
                                        await searchProvider.clearProvider();
                                        await searchProvider.notifyProvider();
                                        setState(() {});
                                      },
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 25,
                                          maxWidth: 25,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        child: MyImage(
                                          height: 23,
                                          color: white,
                                          fit: BoxFit.contain,
                                          imagePath: "ic_close.png",
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      focusColor: white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(5),
                                      onTap: () async {
                                        debugPrint("Click on Search!");
                                        if (searchController.text
                                            .toString()
                                            .isNotEmpty) {
                                          if (isSearchEnable) {
                                            isSearchEnable = false;
                                            FocusScope.of(context).unfocus();
                                          }
                                          mSearchText =
                                              searchController.text.toString();
                                          debugPrint(
                                              "mSearchText ====> $mSearchText");
                                          _onItemTapped("search");
                                          await searchProvider.setLoading(true);
                                          // await searchProvider
                                          //     .getSearchVideo(mSearchText);
                                          setState(() {});
                                        }
                                      },
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 25,
                                          maxWidth: 25,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        child: MyImage(
                                          height: 23,
                                          color: white,
                                          fit: BoxFit.contain,
                                          imagePath: "ic_find.png",
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            MediaQuery.of(context).size.width > 950
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const Notifications(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          )).then((value) => _getData());
                    },
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 20,
                      child: MyImage(
                        imagePath: "ic_notification.png",
                        height: 46,
                        width: 46,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            MediaQuery.of(context).size.width > 950
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const WebWishList(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          )).then((value) => _getData());
                    },
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 20,
                      child: MyImage(
                        color: white,
                        fit: BoxFit.cover,
                        imagePath: "watchlist.png",
                        height: 25,
                        width: 40,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            MediaQuery.of(context).size.width > 950
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const MyWallet(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          )).then((value) => _getData());
                    },
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 20,
                      child: MyImage(
                        imagePath: "ic_wallet.png",
                        height: 46,
                        width: 46,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            /* Login / MyProfile */

            Consumer<HomeProvider>(
              builder: (context, homeProvider, child) {
                if (Constant.userID != null) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () {
                        Utils.buildWebAlertDialog(context, "profile", "");
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyText(
                          color: (homeProvider.currentPage == "profile")
                              ? colorPrimary
                              : white,
                          multilanguage: false,
                          text: myProfile,
                          fontsizeNormal: 14,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 12,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        Utils.buildWebAlertDialog(context, "login", "")
                            .then((value) => _getData());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyText(
                          color: (homeProvider.currentPage == "login")
                              ? colorPrimary
                              : white,
                          multilanguage: true,
                          text: "login",
                          fontsizeNormal: 14,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 14,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),

            /* Logout */
            Consumer<HomeProvider>(
              builder: (context, homeProvider, child) {
                if (Constant.userID != null) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      focusColor: white.withOpacity(0.5),
                      onTap: () async {
                        if (Constant.userID != null) {
                          _buildLogoutDialog();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyText(
                          color: white,
                          multilanguage: true,
                          text: "sign_out",
                          fontsizeNormal: 14,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 12,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget tabTitle(List<type.Result>? sectionTypeList) {
    return ListView.separated(
      itemCount: (sectionTypeList?.length ?? 0) + 1,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(13, 3, 13, 3),
      separatorBuilder: (context, index) => const SizedBox(width: 5),
      itemBuilder: (BuildContext context, int index) {
        return Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                autofocus: true,
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  debugPrint("index ===========> $index");
                  sectionDataProvider.sectionListData = [];
                  await getTabData(index, homeProvider.genresModel.result, 1);
                },
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 32),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: homeProvider.selectedIndex == index
                                    ? primaryDark
                                    : transparentColor))),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                    child: MyText(
                      color: homeProvider.selectedIndex == index
                          ? primaryDark
                          : white,
                      multilanguage: false,
                      text: index == 0
                          ? "Home"
                          : index > 0
                              ? (sectionTypeList?[index - 1].name.toString() ??
                                  "")
                              : "",
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w500,
                      fontsizeWeb: 11,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<DropdownMenuItem<String>> _buildWebDropDownItems() {
    List<String> typeDropDownList1 = [
      "Home",
      "AudioBook",
      "Novel",
      "Threads",
      "Music",
      "Wishlist",
      "Notification",
      "Wallet"
    ];

    return typeDropDownList1.map<DropdownMenuItem<String>>((value) {
      return DropdownMenuItem<String>(
        value: value,
        alignment: Alignment.center,
        child: FittedBox(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 35, minWidth: 100),
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: MyText(
              color: white,
              multilanguage: false,
              text: value,
              fontsizeNormal: 14,
              fontweight: FontWeight.w600,
              fontsizeWeb: 15,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget tabItem(List<type.Result>? sectionTypeList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              height: Dimens.homeTabHeight,
              child: tabTitle(homeProvider.genresModel.result),
            ),
            /* Banner */
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadingBanner) {
                  if ((kIsWeb || Constant.isTV) &&
                      MediaQuery.of(context).size.width > 720) {
                    return ShimmerUtils.bannerWeb(context);
                  } else {
                    return ShimmerUtils.bannerMobile(context);
                  }
                } else {
                  if (sectionDataProvider.sectionBannerModel.status == 200 &&
                      sectionDataProvider.sectionBannerModel.result != null) {
                    if ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720) {
                      return _webHomeBanner(
                          sectionDataProvider.sectionBannerModel.result);
                    } else {
                      return _mobileHomeBanner(
                          sectionDataProvider.sectionBannerModel.result);
                    }
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),

            /* Continue Watching & Remaining Sections */
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadingSection &&
                    sectionDataProvider.loadmore == false) {
                  return sectionShimmer();
                } else {
                  if (sectionDataProvider.sectionListModel.status == 200) {
                    return Column(
                      children: [
                        /* Remaining Sections */
                        (sectionDataProvider.sectionListModel.result != null)
                            ? setSectionByType(
                                sectionDataProvider.sectionListData)
                            : const SizedBox.shrink(),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadmore) {
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
            /* Web Footer */
            kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return Column(
      children: [
        /* Continue Watching */
        if (Constant.userID != null && homeProvider.selectedIndex == 0)
          ShimmerUtils.continueWatching(context),

        /* Remaining Sections */
        ListView.builder(
          itemCount: 10, // itemCount must be greater than 5
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 1) {
              return ShimmerUtils.setHomeSections(context, "potrait");
            } else if (index == 2) {
              return ShimmerUtils.setHomeSections(context, "small_square");
            } else if (index == 3) {
              return ShimmerUtils.setHomeSections(context, "langGen");
            } else {
              return ShimmerUtils.setHomeSections(context, "landscape");
            }
          },
        ),
      ],
    );
  }

  Widget _webHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.homeWebBanner,
        child: Stack(children: [
          CarouselSlider.builder(
            itemCount: (sectionBannerList?.length ?? 0),
            carouselController: carouselController,
            options: CarouselOptions(
              initialPage: 0,
              height: Dimens.homeWebBanner,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayCurve: Curves.easeInOutQuart,
              enableInfiniteScroll: true,
              autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
              autoPlayAnimationDuration:
                  Duration(milliseconds: Constant.animationDuration),
              viewportFraction: 1,
              onPageChanged: (val, _) async {
                await sectionDataProvider.setCurrentBanner(val);
              },
            ),
            itemBuilder: (BuildContext context, int index, int pageViewIndex) {
              return InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  openDetailPage(
                    "showdetail",
                    sectionBannerList?[index].id ?? 0,
                    sectionBannerList?[index].contentType ?? 0,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          //  *
                          //     (Dimens.webBannerImgPr),
                          height: Dimens.homeWebBanner,
                          child: MyNetworkImage(
                            imageUrl:
                                (sectionBannerList?[index].webBannerImage ?? "")
                                        .isNotEmpty
                                    ? (sectionBannerList?[index]
                                            .webBannerImage ??
                                        "")
                                    : sectionBannerList?[index].landscapeImg ??
                                        "",
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeWebBanner,
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
                        Positioned.fill(
                          bottom: 50,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 200,
                                    ),
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
                                      text: "playnow",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 16,
                                      fontsizeWeb: 16,
                                      fontweight: FontWeight.w700,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 260,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: transparentColor,
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        MyImage(
                                          imagePath: "ic_info.png",
                                          height: 12,
                                          width: 12,
                                          color: white,
                                        ),
                                        MyText(
                                          color: white,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          multilanguage: true,
                                          text: "moreinfo",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 15,
                                          fontsizeWeb: 15,
                                          fontweight: FontWeight.w700,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  return AnimatedSmoothIndicator(
                    count: (sectionBannerList?.length ?? 0),
                    activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                    effect: const ScrollingDotsEffect(
                      spacing: 8,
                      radius: 4,
                      activeDotColor: primaryDark,
                      dotColor: gray,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () {
                    debugPrint("Clicked on index ==> $index");
                    openDetailPage(
                      "showdetail",
                      sectionBannerList?[index].id ?? 0,
                      sectionBannerList?[index].contentType ?? 0,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          child: MyNetworkImage(
                            imageUrl:
                                (sectionBannerList?[index].webBannerImage ?? "")
                                        .isNotEmpty
                                    ? (sectionBannerList?[index]
                                            .webBannerImage ??
                                        "")
                                    : sectionBannerList?[index].landscapeImg ??
                                        "",
                            fit: BoxFit.fill,
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
                        Positioned.fill(
                          bottom: 50,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
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
                                      color: primaryDark,
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: MyText(
                                      color: white,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      multilanguage: true,
                                      text: "playnow",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 16,
                                      fontsizeWeb: 16,
                                      fontweight: FontWeight.w700,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    openDetailPage(
                                      "showdetail",
                                      sectionBannerList?[index].id ?? 0,
                                      sectionBannerList?[index].contentType ??
                                          0,
                                    );
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 0,
                                      maxHeight: 45,
                                      minWidth: 0,
                                      maxWidth: 150,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: transparentColor,
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        MyImage(
                                          imagePath: "ic_info.png",
                                          height: 12,
                                          width: 12,
                                          color: white,
                                        ),
                                        MyText(
                                          color: white,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          multilanguage: true,
                                          text: "moreinfo",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 15,
                                          fontsizeWeb: 15,
                                          fontweight: FontWeight.w700,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                return AnimatedSmoothIndicator(
                  count: (sectionBannerList?.length ?? 0),
                  activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                  effect: const ScrollingDotsEffect(
                    spacing: 8,
                    radius: 4,
                    activeDotColor: primaryDark,
                    dotColor: dotsDefaultColor,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget continueWatchingLayout(List<ContinueWatching>? continueWatchingList) {
    if ((continueWatchingList?.length ?? 0) > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: MyText(
              color: white,
              text: "continuewatching",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsizeNormal: 14,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.heightContiLand,
            child: ListView.separated(
              itemCount: (continueWatchingList?.length ?? 0),
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 20, right: 20),
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              separatorBuilder: (context, index) => const SizedBox(
                width: 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    focusColor: white,
                    borderRadius: BorderRadius.circular(4),
                    onTap: () async {
                      openPlayer("ContinueWatch", index, continueWatchingList);
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          width: Dimens.widthContiLand,
                          height: Dimens.heightContiLand,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: MyNetworkImage(
                              imageUrl:
                                  continueWatchingList?[index].landscape ?? "",
                              fit: BoxFit.fill,
                              imgHeight: MediaQuery.of(context).size.height,
                              imgWidth: MediaQuery.of(context).size.width,
                            ),
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
                              child: MyImage(
                                width: 30,
                                height: 30,
                                imagePath: "play.png",
                              ),
                            ),
                            Container(
                              width: Dimens.widthContiLand,
                              constraints: const BoxConstraints(minWidth: 0),
                              padding: const EdgeInsets.all(3),
                              child: LinearPercentIndicator(
                                padding: const EdgeInsets.all(0),
                                barRadius: const Radius.circular(2),
                                lineHeight: 4,
                                percent: Utils.getPercentage(
                                    continueWatchingList?[index]
                                            .videoDuration ??
                                        0,
                                    continueWatchingList?[index].stopTime ?? 0),
                                backgroundColor: secProgressColor,
                                progressColor: colorPrimary,
                              ),
                            ),
                            (continueWatchingList?[index].releaseTag != null &&
                                    (continueWatchingList?[index].releaseTag ??
                                            "")
                                        .isNotEmpty)
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: black,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                    alignment: Alignment.center,
                                    width: Dimens.widthContiLand,
                                    height: 15,
                                    child: MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: continueWatchingList?[index]
                                              .releaseTag ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 6,
                                      fontweight: FontWeight.w700,
                                      fontsizeWeb: 10,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.builder(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        color: white,
                        text: sectionList?[index].title.toString() ?? "",
                        textalign: TextAlign.left,
                        fontsizeNormal: 14,
                        fontweight: FontWeight.w600,
                        fontsizeWeb: 14,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                    sectionList?[index].viewAll == 1
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        WebViewAll(
                                      screenLayout: sectionList?[index]
                                              .screenLayout
                                              .toString() ??
                                          "",
                                      sectionId: sectionList?[index].id,
                                      title: sectionList?[index]
                                              .title
                                              .toString() ??
                                          "",
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return child;
                                    },
                                  ));
                            },
                            child: MyText(
                              color: primaryDark,
                              text: 'seeall',
                              textalign: TextAlign.center,
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w500,
                              fontsizeWeb: 13,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
              const SizedBox(height: 12),
              setSectionData(sectionList: sectionList, index: index),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show,  3-language,  4-category */
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].screenLayout ?? "") == "landscape") {
      return landscape(1, sectionList?[index].data,
          sectionList?[index].screenLayout.toString() ?? "");
    } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
      return portrait(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "small_square") {
      return square(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "grid_view") {
      return miniSeries(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "big_square") {
      return bestSellingStories(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "list_view") {
      return top10series(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "details_square") {
      return newRelease(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "round") {
      return author(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "category") {
      return categories(1, sectionList?[index].data);
    }
    // }
    else if ((sectionList?[index].screenLayout ?? "") == "language") {
      return languageLayout(1, sectionList?[index].data);
    } else {
      return landscape(1, sectionList?[index].data,
          sectionList?[index].screenLayout.toString() ?? "");
    }
  }

  double getRemainingDataHeight(String? videoType, String? layoutType) {
    if (layoutType == "landscape") {
      return Dimens.heightcontemporyRomance;
    } else if (layoutType == "grid_view") {
      return Dimens.heightMiniSeries;
    } else if (layoutType == "list_view") {
      return Dimens.heightMiniSeries;
    } else if (layoutType == "big_square") {
      return Dimens.heightbestSellingStries;
    } else if (layoutType == "portrait") {
      return Dimens.heightPort;
    } else if (layoutType == "small_square") {
      return Dimens.heightSquare;
    } else if (layoutType == "banner_view") {
      return Dimens.homeWebBanner;
    } else if (layoutType == "details_square") {
      return Dimens.webnewreleaseContainerheight;
    } else if (layoutType == "language") {
      return Dimens.webheightLangGen;
    } else {
      return Dimens.webheightLand;
    }
  }

  Widget categories(int? upCmingType, List<Datum>? sectionTypeList) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: darkappbgcolor,
      ),
      child: ListView.separated(
        itemCount: sectionTypeList?.length ?? 0,
        shrinkWrap: true,
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(13, 2, 13, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  debugPrint("index ===========> $index");
                  if (kIsWeb) _onItemTapped("");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebVideosByID(
                          sectionTypeList?[index].id ?? 0,
                          1,
                          sectionTypeList?[index].title ?? "",
                          "ByCategory",
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                  child: Card(
                    color: appBgColor,
                    elevation: 10,
                    shadowColor: primaryDark,
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [white, lightpink]),
                                borderRadius: BorderRadius.circular(50)),
                            child: MyNetworkImage(
                              imageUrl: sectionTypeList?[index]
                                      .portraitImg
                                      .toString() ??
                                  "",
                              imgHeight: 30,
                              imgWidth: 22,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                (sectionTypeList?[index].name.toString() ?? ""),
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 13,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget author(int? upcomingType, List<Datum>? sectionTypeList) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 180,
      decoration: const BoxDecoration(
        color: darkappbgcolor,
      ),
      child: ListView.separated(
        itemCount: sectionTypeList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {},
                child: SizedBox(
                  width: 90,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AuthorProfile(
                                      artistID: sectionTypeList?[index].id),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return child;
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            imageUrl:
                                sectionTypeList?[index].image.toString() ?? "",
                            imgHeight: 80,
                            imgWidth: 80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          textalign: TextAlign.center,
                          maxline: 2,
                          color: white,
                          text:
                              sectionTypeList?[index].userName.toString() ?? "",
                          fontsizeNormal: 12,
                          fontsizeWeb: 10,
                          fontweight: FontWeight.w500,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget bestSellingStories(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) > 8
          ? Dimens.heightbestSellingStries
          : Dimens.heightbestSellingStries / 1.8,
      child: AlignedGridView.count(
        crossAxisCount: (sectionDataList?.length ?? 0) > 8 ? 2 : 1,
        itemCount: (sectionDataList?.length ?? 0) > 20
            ? 20
            : (sectionDataList?.length ?? 0),
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: Dimens.imgwidthcontempory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscapeImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: Dimens.imgheightbestSellingStories,
                        imgWidth: Dimens.imgwidthbestSellingStories,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 13,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: gray,
                    text:
                        "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 13,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget newRelease(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        crossAxisCount: 2,
        itemCount: (sectionDataList?.length ?? 0) > 6
            ? 6
            : sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.vertical,
        // separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl:
                        sectionDataList?[index].landscapeImg.toString() ?? "",
                    fit: BoxFit.fill,
                    imgHeight: Dimens.newreleaseimgwidth,
                    imgWidth: Dimens.newreleaseimgheight,
                  ),
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
                      text: sectionDataList?[index].title.toString() ?? "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 16,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 13,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        MyImage(
                          color: gray,
                          imagePath: "ic_play.png",
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: MyText(
                            color: gray,
                            text:
                                "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 13,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                        MediaQuery.of(context).size.width > 720
                            ? Container(
                                height: 26,
                                width: 85,
                                constraints: const BoxConstraints(maxWidth: 85),
                                decoration: const BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24))),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    MyImage(
                                      imagePath: "Star.png",
                                      height: 18,
                                      width: 18,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        color: brown,
                                        text: sectionDataList?[index]
                                                .avgRating
                                                .toString() ??
                                            "",
                                        textalign: TextAlign.left,
                                        fontsizeNormal: 12,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 13,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: white,
                      text:
                          sectionDataList?[index].description.toString() ?? "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w400,
                      fontsizeWeb: 13,
                      multilanguage: false,
                      maxline: 3,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
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

  Widget top10series(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) > 8
          ? Dimens.heightMiniSeries
          : Dimens.heightMiniSeries / 2,
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: (sectionDataList?.length ?? 0) > 8 ? 2 : 1,
        itemCount:
            (sectionDataList?.length ?? 0) > 20 ? 20 : sectionDataList?.length,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
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
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscapeImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: Dimens.top10imgHeight,
                        imgWidth: Dimens.top10imgwidth,
                      ),
                    ),
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
                            ..color = primaryDark,
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
            ),
          );
        },
      ),
    );
  }

  Widget miniSeries(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: darkappbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length) == 1
          ? Dimens.heightMiniSeries / 3
          : (sectionDataList?.length) == 2
              ? Dimens.heightMiniSeries / 2
              : Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        crossAxisCount: (sectionDataList?.length ?? 0) > 4
            ? 4
            : (sectionDataList?.length ?? 0),
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              height: Dimens.containerHeightMiniSeries,
              width: Dimens.webcontainerwidthMiniSeries,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(left: 10),
              color: appBgColor,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].landscapeImg.toString() ?? "",
                      fit: BoxFit.fill,
                      imgHeight: Dimens.imgheightMiniSeries,
                      imgWidth: Dimens.imgwidthMiniSeries,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        color: white,
                        text: sectionDataList?[index].title.toString() ?? "",
                        textalign: TextAlign.left,
                        fontsizeNormal: 15,
                        fontweight: FontWeight.w600,
                        fontsizeWeb: 13,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          MyImage(
                            imagePath: "play.png",
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          MyText(
                            color: gray,
                            text:
                                "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 13,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ],
                  ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget landscape(
      int? upcomingType, List<Datum>? sectionDataList, String screenLayout) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) < 8
          ? Dimens.heightcontemporyRomance / 2
          : Dimens.heightcontemporyRomance,
      child: AlignedGridView.count(
        mainAxisSpacing: 10, crossAxisSpacing: 10,
        crossAxisCount: (sectionDataList?.length ?? 0) > 8 ? 2 : 1,
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        // separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              if (screenLayout == "round") {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AuthorProfile(
                        artistID: sectionDataList?[index].id,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ));
              } else {
                openDetailPage(
                  "showdetail",
                  sectionDataList?[index].id ?? 0,
                  sectionDataList?[index].contentType ?? 0,
                );
              }
            },
            child: Container(
              width: Dimens.imgwidthcontempory,
              height: Dimens.imgheightcontempory,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: (sectionDataList?[index].landscapeImg.toString() ??
                                  "")
                              .isEmpty ||
                          (sectionDataList?[index].landscapeImg) == null
                      ? (sectionDataList?[index].image.toString() ?? "")
                      : (sectionDataList?[index].landscapeImg.toString() ?? ""),
                  fit: BoxFit.fill,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthPort,
              height: Dimens.heightPort,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl:
                      sectionDataList?[index].landscapeImg.toString() ?? "",
                  fit: BoxFit.fill,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget square(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              debugPrint("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl:
                      sectionDataList?[index].landscapeImg.toString() ?? "",
                  fit: BoxFit.fill,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget languageLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.webheightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebVideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByLanguage",
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.webwidthLangGen,
                  height: Dimens.webheightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
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
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: MyText(
                      color: white,
                      text: sectionDataList?[index].name.toString() ?? "",
                      textalign: TextAlign.center,
                      fontsizeNormal: 14,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 13,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget genresLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebVideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByCategory",
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGen,
                  height: Dimens.heightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
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
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: MyText(
                  color: white,
                  text: sectionDataList?[index].name.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 13,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _buildLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: lightBlack,
          child: Container(
            padding: const EdgeInsets.all(25),
            constraints: const BoxConstraints(
              minWidth: 250,
              maxWidth: 300,
              minHeight: 100,
              maxHeight: 180,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        color: white,
                        text: "confirmsognout",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 16,
                        fontsizeWeb: 18,
                        fontweight: FontWeight.bold,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 3),
                      MyText(
                        color: white,
                        text: "areyousurewanrtosignout",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 13,
                        fontsizeWeb: 14,
                        fontweight: FontWeight.w500,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          focusColor: white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 75),
                              height: 33,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: otherColor,
                                  width: .5,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: MyText(
                                color: white,
                                text: "cancel",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsizeNormal: 16,
                                fontsizeWeb: 15,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontweight: FontWeight.w600,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          focusColor: white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                          onTap: () async {
                            // Firebase Signout
                            await auth.signOut();
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            await sectionDataProvider.clearProvider();
                            // sectionDataProvider.getSectionBanner("0", "1");
                            sectionDataProvider.getSectionList("0", "1", 1);
                            await homeProvider.homeNotifyProvider();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 75),
                              height: 33,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle,
                              ),
                              child: MyText(
                                color: black,
                                text: "sign_out",
                                textalign: TextAlign.center,
                                fontsizeNormal: 16,
                                fontsizeWeb: 15,
                                multilanguage: true,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontweight: FontWeight.w600,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ========= Open Player ========= */
  openPlayer(String playType, int index,
      List<ContinueWatching>? continueWatchingList) async {
    debugPrint("index ==========> $index");

    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      bool? isPrimiumUser =
          await _checkSubsRentLogin(index, continueWatchingList);
      debugPrint("isPrimiumUser =============> $isPrimiumUser");
      if (!isPrimiumUser) return;
    }
    /* CHECK SUBSCRIPTION */

    if (!context.mounted) return;
    /* Set-up Quality URLs */
    Utils.setQualityURLs(
      video320: (continueWatchingList?[index].video320 ?? ""),
      video480: (continueWatchingList?[index].video480 ?? ""),
      video720: (continueWatchingList?[index].video720 ?? ""),
      video1080: (continueWatchingList?[index].video1080 ?? ""),
    );
  }

  Future<bool> _checkSubsRentLogin(
      int index, List<ContinueWatching>? continueWatchingList) async {
    if (Constant.userID != null) {
      if ((continueWatchingList?[index].isPremium ?? 0) == 1 &&
          (continueWatchingList?[index].isRent ?? 0) == 1) {
        if ((continueWatchingList?[index].isBuy ?? 0) == 1 ||
            (continueWatchingList?[index].rentBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((continueWatchingList?[index].isPremium ?? 0) == 1) {
        if ((continueWatchingList?[index].isBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((continueWatchingList?[index].isRent ?? 0) == 1) {
        if ((continueWatchingList?[index].rentBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isRented = await Utils.paymentForRent(
            context: context,
            videoId: continueWatchingList?[index].id.toString() ?? '',
            rentPrice: continueWatchingList?[index].rentPrice.toString() ?? '',
            vTitle: continueWatchingList?[index].name.toString() ?? '',
            typeId: continueWatchingList?[index].typeId.toString() ?? '',
            vType: continueWatchingList?[index].videoType.toString() ?? '',
          );
          if (isRented != null && isRented == true) {
            _getData();
          }
          return false;
        }
      } else {
        return true;
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
        return false;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginSocial(
              ishome: true,
            );
          },
        ),
      );
      return false;
    }
  }
  /* ========= Open Player ========= */
}

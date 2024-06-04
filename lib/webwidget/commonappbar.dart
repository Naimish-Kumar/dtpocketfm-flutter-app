import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dtpocketfm/pages/channels.dart';
import 'package:dtpocketfm/pages/home.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/searchprovider.dart';
import 'package:dtpocketfm/model/genresmodel.dart' as type;
import 'package:dtpocketfm/provider/sectiondataprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/webwidget/searchweb.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class CommonAppBar extends StatefulWidget {
  const CommonAppBar({super.key});

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  late HomeProvider homeProvider;
  late SearchProvider searchProvider;
  int? videoId, videoType, typeId;
  String? langCatName, mSearchText;

  _onItemTapped(String page) async {
    debugPrint("_onItemTapped page -----------------> $page");
    await homeProvider.setCurrentPage(page);
    if (page != "") {
      await setSelectedTab(-1);
    }
    _clickToRedirect(pageName: page);
  }

  @override
  void initState() {
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    Utils.getCurrencySymbol();
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (!homeProvider.loading) {
      if (homeProvider.genresModel.status == 200 &&
          homeProvider.genresModel.result != null) {
        if ((homeProvider.genresModel.result?.length ?? 0) > 0) {
          if (
              // (sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
              //       0 ||
              (sectionDataProvider.sectionListModel.result?.length ?? 0) == 0) {
            getTabData(0, homeProvider.genresModel.result);
          }
        }
      }
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> setSelectedTab(int tabPos) async {
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);

    debugPrint("getTabData position ====> $tabPos");
    debugPrint(
        "getTabData selectedIndex --------> ${homeProvider.selectedIndex}");
    debugPrint(
        "getTabData lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList) async {
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);

    await setSelectedTab(position);
    await sectionDataProvider.setLoading(true);
    // await sectionDataProvider.getSectionBanner(
    //     position == 0 ? "0" : (sectionTypeList?[position - 1].id),
    //     position == 0 ? "1" : "2");
    await sectionDataProvider.getSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2",
        1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _clickToRedirect({required String pageName}) {
    switch (pageName) {
      case "channel":
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Channels();
            },
          ),
        );
      case "store":
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Channels();
            },
          ),
        );
      case "search":
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return SearchWeb(searchText: mSearchText ?? "");
            },
          ),
        );
      default:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Home(pageName: "");
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.homeTabHeight,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      color: black.withOpacity(0.75),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Menu */
          (MediaQuery.of(context).size.width < 800)
              ? Container(
                  constraints: const BoxConstraints(
                    minWidth: 25,
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Consumer<HomeProvider>(
                    builder: (context, homeProvider, child) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isDense: true,
                          isExpanded: true,
                          customButton: MyImage(
                            height: 40,
                            imagePath: "ic_menu.png",
                            fit: BoxFit.contain,
                            color: white,
                          ),
                          items: _buildWebDropDownItems(),
                          onChanged: (type.Result? value) async {
                            if (kIsWeb) {
                              _onItemTapped("");
                            }
                            debugPrint(
                                'value id ===============> ${value?.id.toString()}');
                            if (value?.id == 0) {
                              await getTabData(
                                  0, homeProvider.genresModel.result);
                            } else {
                              for (var i = 0;
                                  i <
                                      (homeProvider
                                              .genresModel.result?.length ??
                                          0);
                                  i++) {
                                if (value?.id ==
                                    homeProvider.genresModel.result?[i].id) {
                                  await getTabData(
                                      i + 1, homeProvider.genresModel.result);
                                  return;
                                }
                              }
                            }
                          },
                          dropdownStyleData: DropdownStyleData(
                            width: 180,
                            useSafeArea: true,
                            padding: const EdgeInsets.only(left: 10, right: 10),
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
                                transparentColor, white, 20, 1),
                            overlayColor: WidgetStateProperty.resolveWith(
                              (states) {
                                if (states.contains(WidgetState.focused)) {
                                  return white.withOpacity(0.5);
                                }
                                if (states.contains(WidgetState.hovered)) {
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
          InkWell(
            splashColor: transparentColor,
            highlightColor: transparentColor,
            focusColor: white,
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              if (kIsWeb || Constant.isTV) _onItemTapped("");
              await getTabData(0, homeProvider.genresModel.result);
            },
            child: MyImage(
              width: 68,
              height: 68,
              imagePath: "appicon.png",
            ),
          ),

          /* Types */
          (MediaQuery.of(context).size.width >= 800)
              ? Expanded(
                  child: tabTitle(homeProvider.genresModel.result),
                )
              : const Expanded(child: SizedBox.shrink()),
          const SizedBox(width: 10),

          /* Feature buttons */
          /* Search */
          Container(
            height: 25,
            constraints: const BoxConstraints(minWidth: 60, maxWidth: 130),
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            decoration: BoxDecoration(
              color: transparentColor,
              border: Border.all(
                color: colorPrimary,
                width: 0.5,
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
                      onChanged: (value) async {
                        debugPrint("value ====> $value");
                        if (value.isNotEmpty) {
                          mSearchText = value;
                          debugPrint("mSearchText ====> $mSearchText");
                          _onItemTapped("search");
                          await searchProvider.setLoading(true);
                          await searchProvider.getSearchVideo(
                              mSearchText, 1, 1);
                        }
                      },
                      textInputAction: TextInputAction.done,
                      obscureText: false,
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      style: const TextStyle(
                        color: white,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
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
                ),
                Consumer<SearchProvider>(
                  builder: (context, searchProvider, child) {
                    if (searchController.text.toString().isNotEmpty) {
                      return InkWell(
                        focusColor: white,
                        borderRadius: BorderRadius.circular(5),
                        onTap: () async {
                          debugPrint("Click on Clear!");
                          _onItemTapped("");
                          searchController.clear();
                          await searchProvider.clearProvider();
                          await searchProvider.notifyProvider();
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
                      );
                    } else {
                      return InkWell(
                        focusColor: white,
                        borderRadius: BorderRadius.circular(5),
                        onTap: () async {
                          debugPrint("Click on Search!");
                          if (searchController.text.toString().isNotEmpty) {
                            mSearchText = searchController.text.toString();
                            debugPrint("mSearchText ====> $mSearchText");
                            _onItemTapped("search");
                            await searchProvider.setLoading(true);
                            await searchProvider.getSearchVideo(
                                mSearchText, 1, 1);
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
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          /* Channels */
          InkWell(
            focusColor: white,
            onTap: () async {
              _onItemTapped("channel");
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, child) {
                  return MyText(
                    color: homeProvider.currentPage == "channel"
                        ? colorPrimary
                        : white,
                    multilanguage: false,
                    text: bottomView3,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 14,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  );
                },
              ),
            ),
          ),

          /* Rent */
          InkWell(
            focusColor: white,
            onTap: () async {
              _onItemTapped("store");
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, child) {
                  return MyText(
                    color: homeProvider.currentPage == "store"
                        ? colorPrimary
                        : white,
                    multilanguage: false,
                    text: bottomView4,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 14,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  );
                },
              ),
            ),
          ),

          /* Login / MyProfile */
          InkWell(
            focusColor: white,
            onTap: () async {
              if (Constant.userID != null) {
                Utils.buildWebAlertDialog(context, "profile", "");
              } else {
                Utils.buildWebAlertDialog(context, "login", "")
                    .then((value) => _getData());
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, child) {
                  return MyText(
                    color: (homeProvider.currentPage == "login" ||
                            homeProvider.currentPage == "setting")
                        ? colorPrimary
                        : white,
                    multilanguage: Constant.userID != null ? false : true,
                    text: Constant.userID != null ? myProfile : "login",
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 14,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  );
                },
              ),
            ),
          ),

          /* Logout */
          Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (Constant.userID != null) {
                return InkWell(
                  focusColor: white,
                  onTap: () async {
                    if (Constant.userID != null) {
                      _buildLogoutDialog();
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: MyText(
                      color: white,
                      multilanguage: true,
                      text: "sign_out",
                      fontsizeNormal: 14,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 14,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
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
    );
  }

  Widget tabTitle(List<type.Result>? sectionTypeList) {
    return ListView.separated(
      itemCount: (sectionTypeList?.length ?? 0) + 1,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(13, 5, 13, 5),
      separatorBuilder: (context, index) => const SizedBox(width: 5),
      itemBuilder: (BuildContext context, int index) {
        return Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(25),
              onTap: () async {
                debugPrint("index ===========> $index");
                if (kIsWeb || Constant.isTV) _onItemTapped("");
                await getTabData(index, homeProvider.genresModel.result);
              },
              child: Container(
                constraints: const BoxConstraints(maxHeight: 32),
                decoration: Utils.setBackground(
                  homeProvider.selectedIndex == index
                      ? white
                      : transparentColor,
                  20,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                child: MyText(
                  color: homeProvider.selectedIndex == index ? black : white,
                  multilanguage: false,
                  text: index == 0
                      ? "Home"
                      : index > 0
                          ? (sectionTypeList?[index - 1].name.toString() ?? "")
                          : "",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w700,
                  fontsizeWeb: 14,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<DropdownMenuItem<type.Result>>? _buildWebDropDownItems() {
    List<type.Result>? typeDropDownList = [];
    for (var i = 0;
        i < (homeProvider.genresModel.result?.length ?? 0) + 1;
        i++) {
      if (i == 0) {
        type.Result typeHomeResult = type.Result();
        typeHomeResult.id = 0;
        typeHomeResult.name = "Home";
        typeDropDownList.insert(i, typeHomeResult);
      } else {
        typeDropDownList.insert(
            i, (homeProvider.genresModel.result?[(i - 1)] ?? type.Result()));
      }
    }
    return typeDropDownList
        .map<DropdownMenuItem<type.Result>>((type.Result value) {
      return DropdownMenuItem<type.Result>(
        value: value,
        alignment: Alignment.center,
        child: FittedBox(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 35, minWidth: 100),
            decoration: Utils.setBackground(
              homeProvider.selectedIndex != -1
                  ? ((typeDropDownList[homeProvider.selectedIndex].id ?? 0) ==
                          (value.id ?? 0)
                      ? white
                      : transparentColor)
                  : transparentColor,
              20,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: MyText(
              color: homeProvider.selectedIndex != -1
                  ? ((typeDropDownList[homeProvider.selectedIndex].id ?? 0) ==
                          (value.id ?? 0)
                      ? black
                      : white)
                  : white,
              multilanguage: false,
              text: (value.name.toString()),
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
              maxHeight: 150,
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
                      const SizedBox(
                        height: 3,
                      ),
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
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 75,
                          ),
                          height: 35,
                          padding: const EdgeInsets.only(left: 10, right: 10),
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
                            fontsizeWeb: 17,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          final homeProvider =
                              Provider.of<HomeProvider>(context, listen: false);
                          final sectionDataProvider =
                              Provider.of<SectionDataProvider>(context,
                                  listen: false);
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
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 75,
                          ),
                          height: 35,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryLight,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: black,
                            text: "sign_out",
                            textalign: TextAlign.center,
                            fontsizeNormal: 16,
                            fontsizeWeb: 17,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
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
}

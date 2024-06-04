import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:dtpocketfm/pages/authorprofile.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/pages/profile.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/searchprovider.dart';
import 'package:dtpocketfm/shimmer/shimmerutils.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../model/searchlistmodel.dart';

class Search extends StatefulWidget {
  final String? searchText;
  const Search({super.key, required this.searchText});

  @override
  State<Search> createState() => SearchState();
}

class SearchState extends State<Search> {
  final searchController = TextEditingController();
  // final MusicManager musicManager = MusicManager();
  String? currentPage;
  late ScrollController _scrollController;
  late SearchProvider searchProvider;
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false, _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    _initSpeech();
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchController.text = widget.searchText ?? "";
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    searchProvider.setLoading(true);
    _getData();
    super.initState();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

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

  /// This has to happen only once per app
  void _initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    debugPrint("<============== _startListening ==============>");
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (searchController.text.toString().isEmpty) {
        Utils.showSnackbar(context, "info", "speechnotavailable", true);
        _stopListening();
      }
    });
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

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    debugPrint("<============== _stopListening ==============>");
    _lastWords = '';
    _isListening = false;
    await _speechToText.stop();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    debugPrint("<============== _onSpeechResult ==============>");
    setState(() async {
      _lastWords = result.recognizedWords;
      debugPrint("_lastWords ==============> $_lastWords");
      if (_lastWords.isNotEmpty && _isListening) {
        searchController.text = _lastWords.toString();
        _isListening = false;
        await searchProvider.getSearchVideo(
            _lastWords.toString(), 1, searchProvider.searchcurrentPage);
        _lastWords = '';
      }
    });
  }

  @override
  void dispose() {
    _stopListening();
    _scrollController.dispose();
    searchController.dispose();
    searchProvider.clearProvider();
    super.dispose();
  }

  _getData() async {
    if ((widget.searchText ?? "").isNotEmpty) {
      // getTabData(0, 1, searchProvider.searchcurrentPage ?? 0);
      _fetchData(0);
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: appBgColor,
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: appBgColor,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  /* Search Box */
                  searchBox(),
                  const SizedBox(height: 20),
                  /* Searched Data */
                  Consumer<SearchProvider>(
                      builder: (context, searchProvider, child) {
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // searchProvider.setDataVisibility(
                                    //     true, false);
                                    searchProvider.searchcontentlist = [];
                                    await getTabData(0, 1, 1);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: "audiobooks",
                                          multilanguage: true,
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 14,
                                          fontsizeWeb: 16,
                                          fontweight: FontWeight.w600,
                                          maxline: 2,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Visibility(
                                        // visible: searchProvider.isVideoClick,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 2,
                                          color:
                                              searchProvider.selectedIndex == 0
                                                  ? white
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
                                    //     true, false);\
                                    searchProvider.searchcontentlist = [];
                                    await getTabData(1, 2, 1);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: "novels",
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
                                      const SizedBox(height: 2),
                                      Visibility(
                                        // visible: searchProvider.isVideoClick,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 2,
                                          color:
                                              searchProvider.selectedIndex == 1
                                                  ? white
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
                                    await getTabData(2, 3, 1);
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: "music",
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
                                      const SizedBox(height: 2),
                                      Visibility(
                                        // visible: searchProvider.isVideoClick,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 2,
                                          color:
                                              searchProvider.selectedIndex == 2
                                                  ? white
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: "artist",
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
                                      const SizedBox(height: 2),
                                      Visibility(
                                        visible: searchProvider.isVideoClick,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 2,
                                          color:
                                              searchProvider.selectedIndex == 3
                                                  ? white
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: "users",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 14,
                                          fontsizeWeb: 16,
                                          fontweight: FontWeight.w600,
                                          multilanguage: true,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Visibility(
                                        // visible: searchProvider.isShowClick,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 2,
                                          color:
                                              searchProvider.selectedIndex == 4
                                                  ? white
                                                  : appBgColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /* AdMob Banner */
                        Utils.showBannerAd(context),
                        const SizedBox(height: 22),
                        Consumer<SearchProvider>(
                            builder: (context, searchProvider, child) {
                          if (searchProvider.loading &&
                              searchProvider.loadmore == false) {
                            return _shimmerSearch();
                          } else {
                            return _buildVideoUI();
                          }
                        }),
                      ],
                    );
                  }),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ),
      ),
      Utils.buildMusicPanel(context),
    ]);
  }

  Widget searchBox() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 50,
            height: 55,
            alignment: Alignment.center,
            child: MyImage(
              width: 16,
              height: 16,
              imagePath: "backwith_bg.png",
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 55,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              color: textFieldBG,
              // border: Border.all(
              //   color: colorPrimary,
              //   width: 0.5,
              // ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: TextField(
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    await searchProvider.setLoading(true);
                    await searchProvider.getSearchVideo(
                        value.toString(), 1, searchProvider.searchcurrentPage);
                  }
                  if (value.isEmpty) {
                    await _getData();
                  }
                },
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: searchController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: const TextStyle(
                  color: white,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: textFieldBG,
                  hintStyle: TextStyle(
                    color: gray,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: searchHint,
                ),
              ),
            ),
          ),
        ),
        Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            if (searchController.text.toString().isNotEmpty) {
              return InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () async {
                  debugPrint("Click on Clear!");
                  searchController.clear();
                  await searchProvider.clearProvider();
                  await searchProvider.notifyProvider();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.center,
                  child: MyImage(
                    imagePath: "ic_close.png",
                    color: white,
                    fit: BoxFit.fill,
                  ),
                ),
              );
            } else {
              return InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () async {
                  debugPrint("Click on Microphone!");
                  _startListening();
                },
                child: _isListening
                    ? AvatarGlow(
                        glowColor: primaryLight,
                        glowCount: 2,
                        glowRadiusFactor: 25,
                        duration: const Duration(milliseconds: 2000),
                        repeat: true,

                        // repeatPauseDuration: const Duration(milliseconds: 100),
                        child: Material(
                          elevation: 5,
                          color: transparentColor,
                          shape: const CircleBorder(),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: transparentColor,
                            padding: const EdgeInsets.all(15),
                            alignment: Alignment.center,
                            child: MyImage(
                              imagePath: "ic_voice.png",
                              color: white,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: MyImage(
                          imagePath: "ic_voice.png",
                          color: white,
                          fit: BoxFit.fill,
                        ),
                      ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildVideoUI() {
    return Consumer<SearchProvider>(builder: (context, searchProvider, child) {
      // if (searchProvider.loading) {
      //   debugPrint("SHimmer Calling ");
      //   return _shimmerSearch();
      // } else {
      if (searchProvider.searchModel.status == 200) {
        if ((searchProvider.searchcontentlist?.length ?? 0) > 0) {
          return Column(
            children: [
              AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                itemCount: (searchProvider.searchcontentlist?.length ?? 0),
                padding: const EdgeInsets.only(left: 20, right: 20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int position) {
                  return Material(
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
                          //  sectionList?[sectionindex]
                          //         .data?[index]
                          //         .isBuy
                          //         .toString() ??
                          //     "",
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: MyNetworkImage(
                                imageUrl: (searchProvider.selectedIndex == 4 ||
                                        searchProvider.selectedIndex == 3)
                                    ? (searchProvider
                                            .searchcontentlist?[position].image
                                            .toString() ??
                                        "")
                                    : (searchProvider
                                            .searchcontentlist?[position]
                                            .landscapeImg
                                            .toString() ??
                                        ""),
                                fit: BoxFit.fill,
                                imgHeight: MediaQuery.of(context).size.height,
                                imgWidth: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          MyText(
                            maxline: 2,
                            color: white,
                            text: searchProvider.selectedIndex == 3
                                ? (searchProvider
                                        .searchcontentlist?[position].userName
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
                                                .searchcontentlist?[position]
                                                .userName
                                                .toString() ??
                                            "")
                                        : (searchProvider
                                                .searchcontentlist?[position]
                                                .fullName
                                                .toString() ??
                                            "")
                                    : searchProvider
                                            .searchcontentlist?[position].title
                                            .toString() ??
                                        "",
                            fontsizeNormal: 14,
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
                                      color: primaryDark,
                                      text:
                                          "${formatNumber(searchProvider.searchcontentlist?[position].totalUserPlay ?? 0)} Play",
                                      fontsizeNormal: 12,
                                    )
                        ],
                      ),
                    ),
                  );
                },
              ),
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
          );
        } else {
          return const NoData(title: "nodata", subTitle: "");
        }
      } else {
        return const SizedBox(
            height: 500, child: NoData(title: "nodata", subTitle: ""));
      }
      // }
    });
  }

  Widget _shimmerSearch() {
    return ShimmerUtils.normalVerticalGrid(
        context, Dimens.heightLand, Dimens.widthLand, 2, kIsWeb ? 40 : 20);
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
          "music",
          "0");
    } else {
      Utils.openLogin(context: context, isHome: false, isReplace: false);
    }
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.getAddContentPlay(3, 0, 0, contentId);
  }
}

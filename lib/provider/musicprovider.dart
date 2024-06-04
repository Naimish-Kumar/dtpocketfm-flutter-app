import 'package:dtpocketfm/model/sectionlistmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:dtpocketfm/model/sectionlistmodel.dart' as section;
import 'package:dtpocketfm/model/sectionlistmodel.dart';
import 'package:flutter/material.dart';

class MusicProvider extends ChangeNotifier {
  SectionListModel sectionListModel = SectionListModel();

  bool loading = false;
  int tabindex = 0;
  int count = 0;
  double podcastListHeight = 0.0;

  /* Section List Field  */
  List<section.Result>? sectionList = [];
  bool sectionloading = false, sectionLoadMore = false;
  int? sectiontotalRows, sectiontotalPage, sectioncurrentPage;
  bool? sectionisMorePage;

  /* Get PlayList Field */
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistmorePage;
  // List<playlist.Result>? playlistData = [];
  bool playlistLoading = false, playlistLoadmore = false;
  String playlistId = "";
  int? playlistPosition;
  bool isSelectPlaylist = false;
  int isType = 0;

  setLoading(bool isLoading) {
    sectionloading = isLoading;
    notifyListeners();
  }

/* SectionList Api */
  Future<void> getSeactionList(ishomescreen, contenttype, pageNo) async {
    sectionloading = true;
    sectionListModel =
        await ApiService().musicsectionList(ishomescreen, contenttype, pageNo);
    if (sectionListModel.status == 200) {
      setSectionPaginationData(
          sectionListModel.totalRows,
          sectionListModel.totalPage,
          sectionListModel.currentPage,
          sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(sectionListModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $sectioncurrentPage');
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(sectionListModel.result?.length ?? 0)}");
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionList?.add(sectionListModel.result?[i] ?? section.Result());
          }
          final Map<int, section.Result> postMap = {};
          sectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(sectionList?.length ?? 0)}");
          setSectionLoadMore(false);
        }
      }
    }
    sectionloading = false;
    notifyListeners();
  }

  setSectionPaginationData(int? sectiontotalRows, int? sectiontotalPage,
      int? sectioncurrentPage, bool? sectionisMorePage) {
    this.sectioncurrentPage = sectioncurrentPage;
    this.sectiontotalRows = sectiontotalRows;
    this.sectiontotalPage = sectiontotalPage;
    sectionisMorePage = sectionisMorePage;
    notifyListeners();
  }

  setSectionLoadMore(sectionLoadMore) {
    this.sectionLoadMore = sectionLoadMore;
    notifyListeners();
  }

  setPlaylistPaginationData(int? playlisttotalRows, int? playlisttotalPage,
      int? playlistcurrentPage, bool? playlistmorePage) {
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalRows = playlisttotalRows;
    this.playlisttotalPage = playlisttotalPage;
    playlistmorePage = playlistmorePage;
    notifyListeners();
  }

  setPlaylistLoadMore(playlistLoadmore) {
    this.playlistLoadmore = playlistLoadmore;
    notifyListeners();
  }

  selectPlaylist(int index, isPlaylistId, isSelect) {
    playlistPosition = index;
    playlistId = isPlaylistId;
    isSelectPlaylist = isSelect;
    debugPrint("reasonId===> $playlistId");
    notifyListeners();
  }

  /* isType == 1 ==>  Public Playlist */
  /* isType == 2 ==>  Private Playlist */
  selectPrivacy({required int type}) {
    isType = type;
    notifyListeners();
  }

/* Get Playlist Created By Perticular User End */

  chageTab(int index) {
    tabindex = index;
    notifyListeners();
  }

  clearTab() {
    sectionList = [];
    sectionList?.clear();
    sectionListModel = SectionListModel();
  }

  clearProvider() {
    sectionListModel = SectionListModel();

    loading = false;
    tabindex = 0;
    count = 0;
    /* Section List Field  */
    sectionList = [];
    sectionloading = false;
    sectionLoadMore = false;
    sectiontotalRows;
    sectiontotalPage;
    sectioncurrentPage;
    sectionisMorePage;
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistLoading = false;
    playlistLoadmore = false;
    playlistId = "";
    playlistPosition;
    isSelectPlaylist = false;
    isType = 0;
  }

  clearPlaylistData() {
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistLoading = false;
    playlistLoadmore = false;
    isSelectPlaylist = false;
    playlistId = "";
    playlistPosition;
    isType = 0;
  }
}

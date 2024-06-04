import 'package:dtpocketfm/model/searchlistmodel.dart' as search;
import 'package:dtpocketfm/model/searchlistmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  SearchListModel searchModel = SearchListModel();
  List<search.Result>? searchcontentlist = [];
  bool loading = false, isVideoClick = true, isShowClick = false;
  int selectedIndex = 0;
  int? lastTabPosition;
  int? searchTotalRows, searchtotalPage, searchcurrentPage;
  bool? searchisMorePage = false;

  bool loadmore = false;

  Future<void> getSearchVideo(searchText, type, pageNo) async {
    debugPrint("getSearchVideos searchText :==> $searchText");
    loading = true;

    searchModel = await ApiService().searchContent(searchText, type, pageNo);
    debugPrint("search_video status :==> ${searchModel.status}");
    debugPrint("search_video message :==> ${searchModel.message}");
    if (searchModel.status == 200) {
      setPodcastPaginationData(searchModel.totalRows, searchModel.totalPage,
          searchModel.currentPage, searchModel.morePage);
      if (searchModel.result != null && (searchModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (searchModel.result?.length ?? 0); i++) {
          searchcontentlist?.add(searchModel.result?[i] ?? search.Result());
        }
        final Map<int, search.Result> postMap = {};
        searchcontentlist?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        searchcontentlist = postMap.values.toList();
        debugPrint(
            "contentList length :==> ${(searchcontentlist?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    debugPrint("loadmore loadmore :==> $loadmore");
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(int? searchTotalRows, int? searchtotalPage,
      int? searchcurrentPage, bool? searchisMorePage) {
    this.searchcurrentPage = searchcurrentPage;
    this.searchTotalRows = searchTotalRows;
    this.searchtotalPage = searchtotalPage;
    this.searchisMorePage = searchisMorePage;
    debugPrint("searchTotalRows message :==> $searchTotalRows");
    debugPrint("searchcurrentPage message :==> $searchcurrentPage");
    debugPrint("searchtotalPage message :==> $searchtotalPage");
    debugPrint("searchisMorePage message :==> $searchisMorePage");

    notifyListeners();
  }

  setLoading(bool isLoading) {
    debugPrint("setDataVisibility isLoading :==> $isLoading");
    loading = isLoading;
    notifyListeners();
  }

  void setDataVisibility(bool isVideoVisible, bool isShowVisible) {
    debugPrint("setDataVisibility isVideoVisible :==> $isVideoVisible");
    debugPrint("setDataVisibility isShowVisible :==> $isShowVisible");
    isVideoClick = isVideoVisible;
    isShowClick = isShowVisible;
    notifyListeners();
  }

  notifyProvider() {
    notifyListeners();
  }

  setSelectedTab(index) {
    selectedIndex = index;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("============ clearSearchProvider ============");
    searchModel = SearchListModel();
    searchcurrentPage = 0;
    searchcontentlist = [];
    isVideoClick = true;
    isShowClick = false;
    searchcurrentPage = 0;
    selectedIndex = 0;
  }
}

import 'package:dtpocketfm/model/artistprofilemodel.dart';
import 'package:dtpocketfm/model/avatarmodel.dart';
import 'package:dtpocketfm/model/getcontentbyartistmodel.dart';
import 'package:dtpocketfm/model/getcontentbyartistmodel.dart' as content;
import 'package:dtpocketfm/model/getcontentbyartistmodel.dart' as novel;
import 'package:dtpocketfm/model/getcontentbyartistmodel.dart' as music;
import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/model/threadslistmodel.dart' as thread;
import 'package:dtpocketfm/model/threadslistmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class AvatarProvider extends ChangeNotifier {
  AvatarModel avatarModel = AvatarModel();
  ArtistProfileModel artistProfileModel = ArtistProfileModel();

  SuccessModel addremovefollowModel = SuccessModel();
  GetContentByArtistMdel getcontentbyartistmodel = GetContentByArtistMdel();
  GetContentByArtistMdel getNovelbyartistmodel = GetContentByArtistMdel();
  GetContentByArtistMdel getMusicbyartistmodel = GetContentByArtistMdel();
  ThreadsListModel threadsbyartistModel = ThreadsListModel();

  bool loading = false;
  bool threadloading = false;
  bool musicloading = false;
  bool novelloading = false;

  bool isloading = false, loadMore = false;
  //content
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  List<content.Result>? contentDataList = [];

  // Music
  int? musictotalRows, musictotalPage, musiccurrentPage;
  bool? musicisMorePage;
  List<music.Result>? musicDataList = [];

  // Novel
  int? noveltotalRows, noveltotalPage, novelcurrentPage;
  bool? novelisMorePage;
  List<novel.Result>? novelDataList = [];

  // threads
  int? threadstotalRows, threadstotalPage, threadscurrentPage;
  bool? threadsisMorePage;
  List<thread.Result>? threadDataList = [];

  setContentDataPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    notifyListeners();
  }

  setMusicDataPaginationData(int? musictotalRows, int? musictotalPage,
      int? musiccurrentPage, bool? musicisMorePage) {
    this.musiccurrentPage = musiccurrentPage;
    this.musictotalRows = musictotalRows;
    this.musictotalPage = musictotalPage;
    this.musicisMorePage = musicisMorePage;
    notifyListeners();
  }

  setNovelDataPaginationData(int? noveltotalRows, int? noveltotalPage,
      int? novelcurrentPage, bool? novelisMorePage) {
    this.novelcurrentPage = novelcurrentPage;
    this.noveltotalRows = noveltotalRows;
    this.noveltotalPage = noveltotalPage;
    this.novelisMorePage = novelisMorePage;
    notifyListeners();
  }

  setThreadsDataPaginationData(int? threadstotalRows, int? threadstotalPage,
      int? threadscurrentPage, bool? threadsisMorePage) {
    this.threadscurrentPage = threadscurrentPage;
    this.threadstotalRows = threadstotalRows;
    this.threadstotalPage = threadstotalPage;
    this.threadsisMorePage = threadsisMorePage;
    notifyListeners();
  }

  setLoading(isLoading) {
    loading = isLoading;
    isloading = isLoading;
    threadloading = isLoading;
    musicloading = isLoading;
    novelloading = isLoading;
    notifyListeners();
  }

  Future<void> getAvatar() async {
    loading = true;
    avatarModel = await ApiService().getAvatar();
    debugPrint("getAvatar status :==> ${avatarModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> getArtistProfile(
    artistID,
  ) async {
    loading = true;
    artistProfileModel = await ApiService().getArtist(artistID);
    debugPrint("artistProfileModel == ${artistProfileModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  Future<void> getContentByArtistID(type, artistID, pageNo) async {
    isloading = true;
    getcontentbyartistmodel =
        await ApiService().getContentByArtist(type, artistID, pageNo);
    if (getcontentbyartistmodel.status == 200) {
      setContentDataPaginationData(
          getcontentbyartistmodel.totalRows,
          getcontentbyartistmodel.totalPage,
          getcontentbyartistmodel.currentPage,
          getcontentbyartistmodel.morePage);
      if (getcontentbyartistmodel.result != null &&
          (getcontentbyartistmodel.result?.length ?? 0) > 0) {
        debugPrint(
            "getCONTENTbyartistmodel length :==> ${(getcontentbyartistmodel.result?.length ?? 0)}");
        for (var i = 0;
            i < (getcontentbyartistmodel.result?.length ?? 0);
            i++) {
          contentDataList
              ?.add(getcontentbyartistmodel.result?[i] ?? content.Result());
        }
        final Map<int, content.Result> postMap = {};
        contentDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        contentDataList = postMap.values.toList();
        debugPrint("contentList length :==> ${(contentDataList?.length ?? 0)}");
        setLoadMore(false);
      }
    }

    isloading = false;
    notifyListeners();
  }

  Future<void> getThreadByArtist(artistID, pageNo) async {
    threadloading = true;
    threadsbyartistModel = await ApiService().threadbyartist(artistID, pageNo);
    if (threadsbyartistModel.status == 200) {
      setThreadsDataPaginationData(
          threadsbyartistModel.totalRows,
          threadsbyartistModel.totalPage,
          threadsbyartistModel.currentPage,
          threadsbyartistModel.morePage);
      if (threadsbyartistModel.result != null &&
          (threadsbyartistModel.result?.length ?? 0) > 0) {
        debugPrint(
            "getThreadbyartistmodel length :==> ${(threadsbyartistModel.result?.length ?? 0)}");
        for (var i = 0; i < (threadsbyartistModel.result?.length ?? 0); i++) {
          threadDataList
              ?.add(threadsbyartistModel.result?[i] ?? thread.Result());
        }
        final Map<int, thread.Result> postMap = {};
        threadDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        threadDataList = postMap.values.toList();
        debugPrint("contentList length :==> ${(threadDataList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    threadloading = false;
    notifyListeners();
  }

  Future<void> getNovelByArtistID(type, artistID, pageNo) async {
    novelloading = true;
    getNovelbyartistmodel =
        await ApiService().getNovelByArtist(type, artistID, pageNo);

    if (getNovelbyartistmodel.status == 200) {
      setNovelDataPaginationData(
          getNovelbyartistmodel.totalRows,
          getNovelbyartistmodel.totalPage,
          getNovelbyartistmodel.currentPage,
          getNovelbyartistmodel.morePage);
      if (getNovelbyartistmodel.result != null &&
          (getNovelbyartistmodel.result?.length ?? 0) > 0) {
        debugPrint(
            "getNovelbyartistmodel length :==> ${(getNovelbyartistmodel.result?.length ?? 0)}");
        for (var i = 0; i < (getNovelbyartistmodel.result?.length ?? 0); i++) {
          novelDataList
              ?.add(getNovelbyartistmodel.result?[i] ?? novel.Result());
        }
        final Map<int, novel.Result> postMap = {};
        novelDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        novelDataList = postMap.values.toList();
        debugPrint("contentList length :==> ${(novelDataList?.length ?? 0)}");
        setLoadMore(false);
      }
    }

    novelloading = false;
    notifyListeners();
  }

  Future<void> getMusicByArtistID(artistID, pageNo) async {
    musicloading = true;
    getMusicbyartistmodel =
        await ApiService().getMusicByArtist(artistID, pageNo);

    if (getMusicbyartistmodel.status == 200) {
      setMusicDataPaginationData(
          getMusicbyartistmodel.totalRows,
          getMusicbyartistmodel.totalPage,
          getMusicbyartistmodel.currentPage,
          getMusicbyartistmodel.morePage);
      if (getMusicbyartistmodel.result != null &&
          (getMusicbyartistmodel.result?.length ?? 0) > 0) {
        debugPrint(
            "getMusicbyartistmodel length :==> ${(getMusicbyartistmodel.result?.length ?? 0)}");
        for (var i = 0; i < (getMusicbyartistmodel.result?.length ?? 0); i++) {
          musicDataList
              ?.add(getMusicbyartistmodel.result?[i] ?? music.Result());
        }
        final Map<int, music.Result> postMap = {};
        musicDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        musicDataList = postMap.values.toList();
        debugPrint("contentList length :==> ${(musicDataList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    musicloading = false;
    notifyListeners();
  }

  addremovefollow(id) async {
    debugPrint(
        "isFoloow before the click ==${artistProfileModel.result?[0].isFollow}");
    if (artistProfileModel.result?[0].isFollow == 0) {
      artistProfileModel.result?[0].isFollow = 1;
      artistProfileModel.result?[0].followes =
          (artistProfileModel.result?[0].followes ?? 0) + 1;
      debugPrint(
          "isFoloow after the click ==${artistProfileModel.result?[0].isFollow}");
    } else {
      artistProfileModel.result?[0].isFollow = 0;
      artistProfileModel.result?[0].followes =
          (artistProfileModel.result?[0].followes ?? 0) - 1;
      debugPrint(
          "isFoloow after the click ==${artistProfileModel.result?[0].isFollow}");
      if ((artistProfileModel.result?[0].isFollow ?? 0) > 0) {}
    }
    notifyListeners();
    getAddremoveFollow(id);
  }

  getAddremoveFollow(
    artistID,
  ) async {
    // debugPrint("addremovefollowModel Calling");
    addremovefollowModel = await ApiService().addremovefollow(artistID);
    debugPrint("addremovefollowModel == ${addremovefollowModel.toJson()}");
  }

  clearProvider() {
    avatarModel = AvatarModel();
    addremovefollowModel = SuccessModel();
    getcontentbyartistmodel = GetContentByArtistMdel();
    getNovelbyartistmodel = GetContentByArtistMdel();
    getMusicbyartistmodel = GetContentByArtistMdel();
    threadsbyartistModel = ThreadsListModel();
    _selectedTab = 0;
    loading = false;
    threadloading = false;
    musicloading = false;
    novelloading = false;
    isloading = false;
    contentDataList = [];
    musicDataList = [];
    novelDataList = [];
    threadDataList = [];
    totalPage = 0;
    currentPage = 0;
    musictotalPage = 0;
    musiccurrentPage = 0;
    noveltotalPage = 0;
    novelcurrentPage = 0;
    threadstotalPage = 0;
    threadscurrentPage = 0;
  }

  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  setTabPosition(int newTabPosition) {
    _selectedTab = newTabPosition;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  musicsetLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  novelsetLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  threadssetLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }
}

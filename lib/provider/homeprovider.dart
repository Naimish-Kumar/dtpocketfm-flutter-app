import 'package:dtpocketfm/model/genresmodel.dart';
// import 'package:dtpocketfm/model/sectiontypemodel.dart';
import 'package:dtpocketfm/model/transactionlistmodel.dart' as transaction;
import 'package:dtpocketfm/model/transactionlistmodel.dart'
    as wallettransaction;
import 'package:dtpocketfm/model/transactionlistmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  // SectionTypeModel sectionTypeModel = SectionTypeModel();
  GenresModel genresModel = GenresModel();
  TransactionListModel transactionListModel = TransactionListModel();
  TransactionListModel wallettransactionListModel = TransactionListModel();
  List<transaction.Result>? walletTransactionlist = [];
  List<wallettransaction.Result>? transactionlist = [];
  bool loading = false;
  bool walletloading = false;
  int selectedIndex = 0;
  String currentPage = "home";
  int? transactionTotalRows, transactiontotalPage, transactioncurrentPage;
  bool? transactionisMorePage;

  int? wallettransactionTotalRows,
      wallettransactiontotalPage,
      wallettransactioncurrentPage;
  bool? wallettransactionisMorePage;
  bool loadmore = false;

  // Future<void> getSectionType() async {
  //   loading = true;
  //   sectionTypeModel = await ApiService().sectionType();
  //   debugPrint("get_type status :==> ${sectionTypeModel.status}");
  //   debugPrint("get_type message :==> ${sectionTypeModel.message}");
  //   loading = false;
  //   notifyListeners();
  // }

  Future<void> getGenres() async {
    loading = true;
    genresModel = await ApiService().genres();
    debugPrint("get_category status :==> ${genresModel.status}");
    debugPrint("get_category message :==> ${genresModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getWalletTransactionList(pageNo) async {
    walletloading = true;
    transactionListModel = await ApiService().transactionList(pageNo);
    debugPrint(
        "transactionListModel status :==> ${transactionListModel.status}");
    debugPrint(
        "transactionListModel message :==> ${transactionListModel.message}");
    if (transactionListModel.status == 200) {
      setPodcastPaginationData(
          transactionListModel.totalRows,
          transactionListModel.totalPage,
          transactionListModel.currentPage,
          transactionListModel.morePage);
      if (transactionListModel.result != null &&
          (transactionListModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(transactionListModel.result?.length ?? 0)}");

        if (transactionListModel.result != null &&
            (transactionListModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(transactionListModel.result?.length ?? 0)}");
          for (var i = 0; i < (transactionListModel.result?.length ?? 0); i++) {
            walletTransactionlist
                ?.add(transactionListModel.result?[i] ?? transaction.Result());
          }
          final Map<int, transaction.Result> postMap = {};
          walletTransactionlist?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          walletTransactionlist = postMap.values.toList();
          debugPrint(
              "Podcast EpisodeList length :==> ${(walletTransactionlist?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    walletloading = false;
    notifyListeners();
  }

  Future<void> getTransactionList(pageNo) async {
    walletloading = true;
    wallettransactionListModel =
        await ApiService().wallettransactionList(pageNo);
    debugPrint(
        "wallettransactionListModel status :==> ${wallettransactionListModel.status}");
    debugPrint(
        "wallettransactionListModel message :==> ${wallettransactionListModel.message}");
    if (wallettransactionListModel.status == 200) {
      settransactionPaginationData(
          wallettransactionListModel.totalRows,
          wallettransactionListModel.totalPage,
          wallettransactionListModel.currentPage,
          wallettransactionListModel.morePage);
      if (wallettransactionListModel.result != null &&
          (wallettransactionListModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(wallettransactionListModel.result?.length ?? 0)}");

        if (wallettransactionListModel.result != null &&
            (wallettransactionListModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(wallettransactionListModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (wallettransactionListModel.result?.length ?? 0);
              i++) {
            transactionlist?.add(wallettransactionListModel.result?[i] ??
                wallettransaction.Result());
          }
          final Map<int, wallettransaction.Result> postMap = {};
          transactionlist?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          transactionlist = postMap.values.toList();
          debugPrint(
              "Podcast EpisodeList length :==> ${(transactionlist?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    walletloading = false;
    notifyListeners();
  }

  int _selectedTab = 0;

  int get selectedTab => _selectedTab;
  setTabPosition(int newTabPosition) {
    _selectedTab = newTabPosition;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(int? podcasttotalRows, int? podcasttotalPage,
      int? podcastcurrentPage, bool? podcastisMorePage) {
    transactioncurrentPage = podcastcurrentPage;
    transactionTotalRows = podcasttotalRows;
    transactiontotalPage = podcasttotalPage;
    podcastisMorePage = podcastisMorePage;
    notifyListeners();
  }

  settransactionPaginationData(
      int? wallettransactionTotalRows,
      int? wallettransactiontotalPage,
      int? wallettransactioncurrentPage,
      bool? wallettransactionisMorePage) {
    this.wallettransactioncurrentPage = wallettransactioncurrentPage;
    this.wallettransactionTotalRows = wallettransactionTotalRows;
    this.wallettransactiontotalPage = wallettransactiontotalPage;
    this.wallettransactionisMorePage = wallettransactionisMorePage;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    walletloading = isLoading;
    notifyListeners();
  }

  setSelectedTab(index) {
    selectedIndex = index;
    notifyListeners();
  }

  setCurrentPage(String pageName) {
    currentPage = pageName;
    notifyListeners();
  }

  homeNotifyProvider() {
    notifyListeners();
  }

  clearProvider() {
    walletTransactionlist = [];
    transactionListModel = TransactionListModel();
    transactioncurrentPage = 0;
    transactiontotalPage = 0;
    wallettransactioncurrentPage = 0;
    wallettransactiontotalPage = 0;
    transactionlist = [];
    _selectedTab = 0;
  }
}

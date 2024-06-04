import 'package:dtpocketfm/model/audiosectionlistmodel.dart';
import 'package:dtpocketfm/model/sectionbannermodel.dart';
import 'package:dtpocketfm/model/sectionlistmodel.dart' as sectiondata;
import 'package:dtpocketfm/model/sectionlistmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SectionDataProvider extends ChangeNotifier {
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  SectionListModel sectionListModel = SectionListModel();
  AudioSectionListModel audiosectionListModel = AudioSectionListModel();
  List<sectiondata.Result>? sectionListData = [];

  bool loadingBanner = false, loadingSection = false;
  int? cBannerIndex = 0, lastTabPosition;
  int? totalrows, totalPage, currentPage;
  bool? isMorePage;

  bool loadmore = false;

  Future<void> getSectionBanner(typeId, isHomePage) async {
    debugPrint("getSectionBanner typeId :==> $typeId");
    debugPrint("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel =
        await ApiService().homesectionBanner(typeId, isHomePage);
    debugPrint("get_banner status :==> ${sectionBannerModel.status}");
    debugPrint("get_banner message :==> ${sectionBannerModel.message}");
    loadingBanner = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(
      int? totalrows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalrows = totalrows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    debugPrint("isMorePage ++ $isMorePage");
    debugPrint("totalrows ++ $totalrows");
    debugPrint("totalPage ++ $totalPage");
    debugPrint("currentPage ++ $currentPage");

    notifyListeners();
  }

  setLoading(bool flagLoading) {
    loadingBanner = flagLoading;
    loadingSection = flagLoading;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  Future<void> getSectionList(typeId, isHomePage, pageno) async {
    debugPrint("getSectionList typeId :==> $typeId");
    debugPrint("getSectionList isHomePage :==> $isHomePage");
    loadingSection = true;

    sectionListModel =
        await ApiService().sectionList(typeId, isHomePage, pageno);
    debugPrint("section_list status :==> ${sectionListModel.status}");
    debugPrint("section_list message :==> ${sectionListModel.message}");
    if (sectionListModel.status == 200) {
      setPodcastPaginationData(
          sectionListModel.totalRows,
          sectionListModel.totalPage,
          sectionListModel.currentPage,
          sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionListData
                ?.add(sectionListModel.result?[i] ?? sectiondata.Result());
          }
          final Map<int, sectiondata.Result> postMap = {};
          sectionListData?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionListData = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }
    loadingSection = false;
    notifyListeners();
  }

  Future<void> getAudioSectionList(typeId, isHomePage, pageno) async {
    debugPrint("getSectionList typeId :==> $typeId");
    debugPrint("getSectionList isHomePage :==> $isHomePage");
    loadingSection = true;
    audiosectionListModel =
        await ApiService().audiosectionList(typeId, isHomePage, pageno);
    debugPrint("section_list status :==> ${sectionListModel.status}");
    debugPrint("Audio section_list message :==> ${sectionListModel.message}");
    loadingSection = false;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("<================ clearProvider ================>");
    loadingBanner = false;
    loadingSection = false;
    currentPage = 0;
    sectionListData = [];
    // sectionListModel = SectionListModel();
    cBannerIndex = 0;
    lastTabPosition = 0;
  }
}

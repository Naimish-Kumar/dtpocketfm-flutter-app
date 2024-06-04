import 'package:dtpocketfm/model/contentdetailmodel.dart' as content;
import 'package:dtpocketfm/model/contentdetailmodel.dart';
import 'package:dtpocketfm/model/episodebycontentmodel.dart' as section;
import 'package:dtpocketfm/model/episodebycontentmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/foundation.dart';

class SeeAllProvider extends ChangeNotifier {
  ContentDetailsModel seealldetailModel = ContentDetailsModel();
  EpisodeByContentModel musicSeeAllModel = EpisodeByContentModel();
  List<content.Result>? contentList = [];
  List<section.Result>? sectionDataList = [];
  bool isLoading = false, loadMore = false;
  bool seeallLoadMore = false;
  /* Post Pagination */
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  bool loading = false;

  int? sectiondatatotalRows, sectiondatatotalPage, sectiondatacurrentPage;
  bool? sectiondataisMorePage;

  Future<void> getSeeAllData(sectionId, pageno) async {
    isLoading = true;
    seealldetailModel = ContentDetailsModel();
    seealldetailModel = await ApiService().seeall(sectionId, pageno);
    if (seealldetailModel.status == 200) {
      setPagination(seealldetailModel.totalRows, seealldetailModel.totalPage,
          seealldetailModel.currentPage, seealldetailModel.morePage);
      if (seealldetailModel.result != null &&
          (seealldetailModel.result?.length ?? 0) > 0) {
        debugPrint(
            "seealldetailModel length :==> ${(seealldetailModel.result?.length ?? 0)}");
        for (var i = 0; i < (seealldetailModel.result?.length ?? 0); i++) {
          contentList?.add(seealldetailModel.result?[i] ?? content.Result());
        }
        final Map<int, content.Result> postMap = {};
        contentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        contentList = postMap.values.toList();
        debugPrint("contentList length :==> ${(contentList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    isLoading = false;
    notifyListeners();
  }

  setSectionDataPaginationData(
      int? sectiondatatotalRows,
      int? sectiondatatotalPage,
      int? sectiondatacurrentPage,
      bool? sectiondataisMorePage) {
    this.sectiondatacurrentPage = sectiondatacurrentPage;
    this.sectiondatatotalRows = sectiondatatotalRows;
    this.sectiondatatotalPage = sectiondatatotalPage;
    this.sectiondataisMorePage = sectiondataisMorePage;
    notifyListeners();
  }

  /* SectionList Api */
  Future<void> getSeactionDetail(sectionId, pageNo) async {
    loading = true;
    musicSeeAllModel =
        await ApiService().episodeMusicBySection(sectionId, pageNo);
    if (musicSeeAllModel.status == 200) {
      setSectionDataPaginationData(
          musicSeeAllModel.totalRows,
          musicSeeAllModel.totalPage,
          musicSeeAllModel.currentPage,
          musicSeeAllModel.morePage);
      if (musicSeeAllModel.result != null &&
          (musicSeeAllModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(musicSeeAllModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $sectiondatacurrentPage');
        if (musicSeeAllModel.result != null &&
            (musicSeeAllModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(musicSeeAllModel.result?.length ?? 0)}");
          for (var i = 0; i < (musicSeeAllModel.result?.length ?? 0); i++) {
            sectionDataList
                ?.add(musicSeeAllModel.result?[i] ?? section.Result());
          }
          final Map<int, section.Result> postMap = {};
          sectionDataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionDataList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(sectionDataList?.length ?? 0)}");
          setSeeAllLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setSeeAllLoadMore(seeallLoadMore) {
    this.seeallLoadMore = seeallLoadMore;
    notifyListeners();
  }

  clearProvider() {
    seealldetailModel = ContentDetailsModel();
    contentList = [];
    sectionDataList = [];
    isLoading = false;
    currentPage = 0;
    totalPage = 0;
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }
}

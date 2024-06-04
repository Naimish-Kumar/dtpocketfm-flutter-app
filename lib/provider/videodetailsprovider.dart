import 'package:dtpocketfm/model/sectiondetailmodel.dart';
import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

class VideoDetailsProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SectionDetailModel sectionDetailModel = SectionDetailModel();

  bool loading = false;
  String tabClickedOn = "related";

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getSectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    debugPrint("getSectionDetails typeId :========> $typeId");
    debugPrint("getSectionDetails videoType :=====> $videoType");
    debugPrint("getSectionDetails videoId :=======> $videoId");
    debugPrint("getSectionDetails upcomingType :==> $upcomingType");
    loading = true;
    sectionDetailModel = await ApiService()
        .sectionDetails(typeId, videoType, videoId, upcomingType);
    debugPrint("section_detail status :==> ${sectionDetailModel.status}");
    debugPrint("section_detail message :==> ${sectionDetailModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> setBookMark(
      BuildContext context, typeId, videoType, videoId) async {
    if ((sectionDetailModel.result?.isBookmark ?? 0) == 0) {
      sectionDetailModel.result?.isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      sectionDetailModel.result?.isBookmark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    notifyListeners();
    getAddBookMark(typeId, videoType, videoId);
  }

  Future<void> getAddBookMark(typeId, videoType, videoId) async {
    debugPrint("getAddBookMark typeId :==> $typeId");
    debugPrint("getAddBookMark videoType :==> $videoType");
    debugPrint("getAddBookMark videoId :==> $videoId");
    successModel = await ApiService().addRemoveBookmark(videoType, videoId);
    debugPrint("add_remove_bookmark status :==> ${successModel.status}");
    debugPrint("add_remove_bookmark message :==> ${successModel.message}");
  }

  Future<void> removeFromContinue(
      contentId, contentType, contentEpisodeId, audiobookType) async {
    sectionDetailModel.result?.stopTime = 0;
    notifyListeners();

    successModel = await ApiService().removeContinueWatching(
        contentId, contentType, contentEpisodeId, audiobookType);
    debugPrint("removeFromContinue message :==> ${successModel.message}");
  }

  updateRentPurchase() {
    if (sectionDetailModel.result != null) {
      sectionDetailModel.result?.rentBuy == 1;
    }
  }

  updatePrimiumPurchase() {
    if (sectionDetailModel.result != null) {
      sectionDetailModel.result?.isBuy == 1;
    }
  }

  setTabClick(clickedOn) {
    debugPrint("clickedOn ===> $clickedOn");
    tabClickedOn = clickedOn;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("<================ clearProvider ================>");
    sectionDetailModel = SectionDetailModel();
    successModel = SuccessModel();
    tabClickedOn = "related";
  }
}

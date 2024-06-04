import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SuccessModel videoViewSuccessModel = SuccessModel();
  SuccessModel addcontenttoplayModel = SuccessModel();

  bool loading = false;
  String currentSubtitle = "";
  String currentQuality = "";

  setCurrentSubtitle(String subtitleName) {
    currentSubtitle = subtitleName;
    notifyListeners();
  }

  setCurrentQuality(String qualityName) {
    currentQuality = qualityName;
    notifyListeners();
  }

  Future<void> getAddContentPlay(
    contentType,
    episodeID,
    audioBookType,
    contentID,
  ) async {
    loading = true;
    addcontenttoplayModel = await ApiService().addToPlay(
      contentType,
      episodeID,
      audioBookType,
      contentID,
    );

    loading = false;
    notifyListeners();
  }

  Future<void> addVideoView(videoId, videoType, otherId) async {
    debugPrint("addVideoView videoId :====> $videoId");
    debugPrint("addVideoView otherId :====> $otherId");
    debugPrint("addVideoView videoType :==> $videoType");
    loading = true;
    videoViewSuccessModel =
        await ApiService().videoView(videoId, videoType, otherId);
    debugPrint("addVideoView message :==> ${videoViewSuccessModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> addToContinue(
      contentId, contentType, stopTime, contentEpisodeId, audiobookType) async {
    debugPrint("addToContinue stopTime :==> $stopTime");
    debugPrint("addToContinue contentId :==> $contentId");
    debugPrint("addToContinue contentType :==> $contentType");
    debugPrint("addToContinue contentEpisodeId :==> $contentEpisodeId");
    debugPrint("addToContinue audiobookType :==> $audiobookType");
    loading = true;
    successModel = await ApiService().addContinueWatching(
        contentId, contentType, stopTime, contentEpisodeId, audiobookType);
    debugPrint("addToContinue message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> removeFromContinue(
      contentId, contentType, contentEpisodeId, audiobookType) async {
    loading = true;
    successModel = await ApiService().removeContinueWatching(
        contentId, contentType, contentEpisodeId, audiobookType);
    debugPrint("remove_continue_watching message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("<================ clearProvider ================>");
    successModel = SuccessModel();
    videoViewSuccessModel = SuccessModel();
    currentSubtitle = "";
    loading = false;
  }
}

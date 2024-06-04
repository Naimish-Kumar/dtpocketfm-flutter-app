import 'package:dtpocketfm/model/episodebycontentmodel.dart' as video;
import 'package:dtpocketfm/model/episodebycontentmodel.dart' as audio;
import 'package:dtpocketfm/model/episodebycontentmodel.dart';
import 'package:dtpocketfm/model/episodebyseasonmodel.dart';
import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class EpisodeProvider extends ChangeNotifier {
  EpisodeBySeasonModel episodeBySeasonModel = EpisodeBySeasonModel();
  EpisodeByContentModel videobycontentmodel = EpisodeByContentModel();
  EpisodeByContentModel audiobycontentmodel = EpisodeByContentModel();
  SuccessModel addcontenttoplayModel = SuccessModel();
  List<video.Result>? videoList = [];
  List<audio.Result>? audioList = [];
  bool loading = false, videoloading = false;

  int? totalRows, totalPage, currentPage;
  bool isMorePage = false;
  int? audiototalRows, audiototalPage, audiocurrentPage;
  bool audioisMorePage = false;
  bool? doComment;
  bool loadmore = false;

  // Future<void> getEpisodeBySeason(seasonId, showId) async {
  //   loading = true;
  //   episodeBySeasonModel = await ApiService().episodeBySeason(seasonId, showId);
  //   loading = false;
  //   notifyListeners();
  // }

  checkIsBuy(bool checkIsBuy) {
    doComment = checkIsBuy;
    debugPrint('doComment == $doComment');
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    videoloading = isLoading;
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
    debugPrint(
        " addcontenttoplayModel status == ${addcontenttoplayModel.status}");

    loading = false;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("<================ clearProvider ================>");
    episodeBySeasonModel = EpisodeBySeasonModel();
    videobycontentmodel = EpisodeByContentModel();
    audiobycontentmodel = EpisodeByContentModel();
    videoList = [];
    audioList = [];
    currentPage = 0;
    totalPage = 0;
    audiocurrentPage = 0;
    audiototalRows = 0;
    audiototalPage = 0;
  }

  Future<void> getVideoByContent(contentId, pageno) async {
    videoloading = true;
    // videobycontentmodel = EpisodeByContentModel();
    videobycontentmodel =
        await ApiService().episodeVideoByContent(contentId, pageno);
    if (videobycontentmodel.status == 200) {
      setPodcastPaginationData(
          videobycontentmodel.totalRows,
          videobycontentmodel.totalPage,
          videobycontentmodel.currentPage,
          videobycontentmodel.morePage);
      if (videobycontentmodel.result != null &&
          (videobycontentmodel.result?.length ?? 0) > 0) {
        if (videobycontentmodel.result != null &&
            (videobycontentmodel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (videobycontentmodel.result?.length ?? 0); i++) {
            videoList?.add(videobycontentmodel.result?[i] ?? video.Result());
          }
          final Map<int, video.Result> postMap = {};
          videoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          videoList = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }
    videoloading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  videosetLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage!;
    debugPrint("podcastisMorePage ++ $isMorePage");
    debugPrint("threadTotalRows ++ $totalRows");
    debugPrint("threadtotalPage ++ $totalPage");
    debugPrint("threadcurrentPage ++ $currentPage");

    notifyListeners();
  }

  setaudioPaginationData(int? audiototalRows, int? audiototalPage,
      int? audiocurrentPage, bool? audioisMorePage) {
    this.audiocurrentPage = audiocurrentPage;
    this.audiototalRows = audiototalRows;
    this.audiototalPage = audiototalPage;
    this.audioisMorePage = audioisMorePage!;
    debugPrint("Audio  audioisMorePage ++ $audioisMorePage");
    debugPrint("Audio  audiototalRows ++ $audiototalRows");
    debugPrint("Audio  audiototalPage ++ $audiototalPage");
    debugPrint("Audio  audiocurrentPage ++ $audiocurrentPage");

    notifyListeners();
  }

  Future<void> getAudioByContent(contentId, pageno) async {
    loading = true;
    audiobycontentmodel =
        await ApiService().episodeAudioByContent(contentId, pageno);
    setaudioPaginationData(
        audiobycontentmodel.totalRows,
        audiobycontentmodel.totalPage,
        audiobycontentmodel.currentPage,
        audiobycontentmodel.morePage);
    if (audiobycontentmodel.result != null &&
        (audiobycontentmodel.result?.length ?? 0) > 0) {
      if (audiobycontentmodel.result != null &&
          (audiobycontentmodel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (audiobycontentmodel.result?.length ?? 0); i++) {
          audioList?.add(audiobycontentmodel.result?[i] ?? audio.Result());
        }
        final Map<int, audio.Result> postMap = {};
        audioList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        audioList = postMap.values.toList();

        setLoadMore(false);
      }
    }

    loading = false;
    notifyListeners();
  }
}

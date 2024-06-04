import 'package:dtpocketfm/model/artistprofilemodel.dart';
import 'package:dtpocketfm/model/commentmodel.dart' as comment;
import 'package:dtpocketfm/model/commentmodel.dart' as reply;
import 'package:dtpocketfm/model/commentmodel.dart';
import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/model/threadslistmodel.dart' as threads;
import 'package:dtpocketfm/model/threadslistmodel.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/foundation.dart';

class ThreadProvider extends ChangeNotifier {
  ThreadsListModel threadlistmodel = ThreadsListModel();
  SuccessModel uploadthreadsmodel = SuccessModel();
  SuccessModel addCommentModel = SuccessModel();
  SuccessModel likedislikeModel = SuccessModel();
  CommentModel threadCommentListModel = CommentModel();
  SuccessModel editcommentModel = SuccessModel();
  CommentModel replyCommentListModel = CommentModel();
  ArtistProfileModel suggestartistProfileModel = ArtistProfileModel();
  ArtistProfileModel artistProfileModel = ArtistProfileModel();
  SuccessModel addremovefollowModel = SuccessModel();
  SuccessModel deleteCommentModel = SuccessModel();
  bool loading = false, threaduploadLoading = false;
  bool cmtLoading = false, threadCommentLoading = false, replyLoading = false;
  List<threads.Result>? threadslist = [];
  List<comment.Result>? commentlist = [];
  dynamic threadid;
  dynamic commentid;

  int? threadTotalRows, threadtotalPage, threadcurrentPage;
  bool threadisMorePage = false;

  int? commentTotalRows, commenttotalPage, commentcurrentPage;
  bool commentisMorePage = false;

  int? replycommentTotalRows, replycommenttotalPage, replycommentcurrentPage;
  bool replycommentisMorePage = false;
  List<reply.Result>? replycommentlist = [];

  bool loadmore = false;
  Future<void> getThreadsList(pageNo) async {
    loading = true;
    threadlistmodel = await ApiService().threadssectionList(pageNo);
    debugPrint("threadlistmodel status :==> ${threadlistmodel.status}");
    debugPrint("threadlistmodel message :==> ${threadlistmodel.message}");

    if (threadlistmodel.status == 200) {
      setPodcastPaginationData(
          threadlistmodel.totalRows,
          threadlistmodel.totalPage,
          threadlistmodel.currentPage,
          threadlistmodel.morePage);
      if (threadlistmodel.result != null &&
          (threadlistmodel.result?.length ?? 0) > 0) {
        if (threadlistmodel.result != null &&
            (threadlistmodel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (threadlistmodel.result?.length ?? 0); i++) {
            threadslist?.add(threadlistmodel.result?[i] ?? threads.Result());
          }
          final Map<int, threads.Result> postMap = {};
          threadslist?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          threadslist = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  getdeleteComment(
    commentId,
  ) async {
    loading = true;
    deleteCommentModel = await ApiService().deletecomment(
      commentId,
    );
    debugPrint("deleteCommentModel == ${deleteCommentModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  getEditComment(
    commentID,
    comment,
  ) async {
    loading = true;
    editcommentModel = await ApiService().editcomment(
      commentID,
      comment,
    );
    debugPrint("editcommentModel == ${editcommentModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setCommentPaginationData(int? commentTotalRows, int? commenttotalPage,
      int? commentcurrentPage, bool? commentisMorePage) {
    this.commentcurrentPage = commentcurrentPage;
    this.commentTotalRows = commentTotalRows;
    this.commenttotalPage = commenttotalPage;
    this.commentisMorePage = commentisMorePage!;
    notifyListeners();
  }

  setreplyPaginationData(int? replycommentTotalRows, int? replycommenttotalPage,
      int? replycommentcurrentPage, bool? replycommentisMorePage) {
    this.replycommentcurrentPage = replycommentcurrentPage;
    this.replycommentTotalRows = replycommentTotalRows;
    this.replycommenttotalPage = replycommenttotalPage;
    this.replycommentisMorePage = replycommentisMorePage!;
    notifyListeners();
  }

  setPodcastPaginationData(int? threadTotalRows, int? threadtotalPage,
      int? threadcurrentPage, bool? threadisMorePage) {
    this.threadcurrentPage = threadcurrentPage;
    this.threadTotalRows = threadTotalRows;
    this.threadtotalPage = threadtotalPage;
    this.threadisMorePage = threadisMorePage!;
    debugPrint("podcastisMorePage.morePage ++ $threadisMorePage");
    debugPrint("threadTotalRows.morePage ++ $threadTotalRows");
    debugPrint("threadtotalPage.morePage ++ $threadtotalPage");
    debugPrint("threadcurrentPage.morePage ++ $threadcurrentPage");

    notifyListeners();
  }

  storeThreadID(isthreadID) async {
    threadid = isthreadID;

    notifyListeners();
  }

  storeCommentId(iscoemmetnID) async {
    commentid = iscoemmetnID;

    notifyListeners();
  }

  Future<void> uploadNewThreads(
    description,
    image,
  ) async {
    threaduploadLoading = true;
    uploadthreadsmodel = await ApiService().uploadThreads(
      description,
      image,
    );
    debugPrint("uploadthreadsmodel status :==> ${uploadthreadsmodel.status}");
    debugPrint("uploadthreadsmodel message :==> ${uploadthreadsmodel.message}");
    threaduploadLoading = false;
    notifyListeners();
  }

  Future<void> getAddRemoveLike(
    threadID,
  ) async {
    // threaduploadLoading = true;
    likedislikeModel = await ApiService().addRemoveLike(
      threadID,
    );
    debugPrint("likedislikeModel status :==> ${likedislikeModel.status}");
    debugPrint("likedislikeModel message :==> ${likedislikeModel.message}");
    // threaduploadLoading = false;
    // notifyListeners();
  }

  addremoveLike(id, position) async {
    debugPrint(
        "isFoloow before the click ==${threadslist?[position].totalLike}");
    if (threadslist?[position].isLike == 0) {
      threadslist?[position].isLike = 1;
      threadslist?[position].totalLike =
          (threadslist?[position].totalLike ?? 0) + 1;
      debugPrint("isFoloow after the click ==${threadslist?[position].isLike}");
    } else {
      threadslist?[position].isLike = 0;
      threadslist?[position].totalLike =
          (threadslist?[position].totalLike ?? 0) - 1;
      debugPrint("isFoloow after the click ==${threadslist?[position].isLike}");
      if ((threadslist?[position].isLike ?? 0) > 0) {}
    }
    notifyListeners();
    getAddRemoveLike(id);
  }

  Future<void> getSuggestArtistList() async {
    loading = true;
    suggestartistProfileModel = await ApiService().getSugestedArtist();
    debugPrint(
        "suggestartistProfileModel == ${suggestartistProfileModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  Future<void> getAddComment(
    commentID,
    comment,
    threadID,
    position,
  ) async {
    cmtLoading = true;
    addCommentModel =
        await ApiService().addComment(commentID, comment, threadID);
    debugPrint("addCommentModel status :==> ${addCommentModel.status}");
    debugPrint("addCommentModel message :==> ${addCommentModel.message}");

    threadlistmodel.result?[position].totalComment =
        (threadlistmodel.result?[position].totalComment ?? 0) + 1;
    getThreadComment(threadID, commentcurrentPage);
    cmtLoading = false;
    notifyListeners();
  }

  Future<void> getThreadComment(threadID, pageNo) async {
    threadCommentLoading = true;
    threadCommentListModel = await ApiService().getComments(threadID, pageNo);
    debugPrint(
        "threadCommentListModel status :==> ${threadCommentListModel.status}");
    debugPrint(
        "threadCommentListModel message :==> ${threadCommentListModel.message}");
    if (threadCommentListModel.status == 200) {
      setCommentPaginationData(
          threadCommentListModel.totalRows,
          threadCommentListModel.totalPage,
          threadCommentListModel.currentPage,
          threadCommentListModel.morePage);
      if (threadCommentListModel.result != null &&
          (threadCommentListModel.result?.length ?? 0) > 0) {
        if (threadCommentListModel.result != null &&
            (threadCommentListModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (threadCommentListModel.result?.length ?? 0);
              i++) {
            commentlist
                ?.add(threadCommentListModel.result?[i] ?? comment.Result());
          }
          final Map<int, comment.Result> postMap = {};
          commentlist?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          commentlist = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }
    threadCommentLoading = false;
    notifyListeners();
  }

  Future<void> getReplyComment(commentID, pageNo) async {
    replyLoading = true;
    replyCommentListModel =
        await ApiService().getReplyComments(commentID, pageNo);
    debugPrint(
        "replyCommentListModel status :==> ${replyCommentListModel.status}");
    debugPrint(
        "replyCommentListModel message :==> ${replyCommentListModel.message}");

    if (replyCommentListModel.status == 200) {
      setreplyPaginationData(
          replyCommentListModel.totalRows,
          replyCommentListModel.totalPage,
          replyCommentListModel.currentPage,
          replyCommentListModel.morePage);
      if (replyCommentListModel.result != null &&
          (replyCommentListModel.result?.length ?? 0) > 0) {
        if (replyCommentListModel.result != null &&
            (replyCommentListModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (replyCommentListModel.result?.length ?? 0);
              i++) {
            replycommentlist
                ?.add(replyCommentListModel.result?[i] ?? reply.Result());
          }
          final Map<int, reply.Result> postMap = {};
          replycommentlist?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          replycommentlist = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }
    replyLoading = false;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    loading = isLoading;
  }

  addremovefollow(id) async {
    debugPrint(
        "isFoloow before the click ==${suggestartistProfileModel.result?[0].isFollow}");
    if (suggestartistProfileModel.result?[0].isFollow == 0) {
      suggestartistProfileModel.result?[0].isFollow = 1;
      debugPrint(
          "isFoloow after the click ==${suggestartistProfileModel.result?[0].isFollow}");
    } else {
      suggestartistProfileModel.result?[0].isFollow = 0;
      debugPrint(
          "isFoloow after the click ==${suggestartistProfileModel.result?[0].isFollow}");
      if ((suggestartistProfileModel.result?[0].isFollow ?? 0) > 0) {}
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
    threadlistmodel = ThreadsListModel();
    uploadthreadsmodel = SuccessModel();
    addCommentModel = SuccessModel();
    likedislikeModel = SuccessModel();
    threadCommentListModel = CommentModel();
    replyCommentListModel = CommentModel();
    threadslist = [];
    commentlist = [];
  }
}

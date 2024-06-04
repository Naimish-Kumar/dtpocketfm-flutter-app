import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dtpocketfm/model/artistprofilemodel.dart';
import 'package:dtpocketfm/model/audiosectionlistmodel.dart';
import 'package:dtpocketfm/model/avatarmodel.dart';
import 'package:dtpocketfm/model/commentmodel.dart';
import 'package:dtpocketfm/model/contentdetailmodel.dart';
import 'package:dtpocketfm/model/couponmodel.dart';
import 'package:dtpocketfm/model/earncoinmodel.dart';
import 'package:dtpocketfm/model/earncointransactionlistmodel.dart';
import 'package:dtpocketfm/model/episodebycontentmodel.dart';
import 'package:dtpocketfm/model/getcontentbyartistmodel.dart';
import 'package:dtpocketfm/model/getnotificationmodel.dart';
import 'package:dtpocketfm/model/novelsectionlistmodel.dart';
import 'package:dtpocketfm/model/pagesmodel.dart';
import 'package:dtpocketfm/model/paymentoptionmodel.dart';
import 'package:dtpocketfm/model/paytmmodel.dart';
import 'package:dtpocketfm/model/searchlistmodel.dart';
import 'package:dtpocketfm/model/subscriptionmodel.dart';
import 'package:dtpocketfm/model/channelsectionmodel.dart';
import 'package:dtpocketfm/model/generalsettingmodel.dart';
import 'package:dtpocketfm/model/genresmodel.dart';
import 'package:dtpocketfm/model/langaugemodel.dart';
import 'package:dtpocketfm/model/loginregistermodel.dart';
import 'package:dtpocketfm/model/profilemodel.dart';
import 'package:dtpocketfm/model/rentmodel.dart';
import 'package:dtpocketfm/model/sectionbannermodel.dart';
import 'package:dtpocketfm/model/sectiondetailmodel.dart';
import 'package:dtpocketfm/model/sectionlistmodel.dart';
import 'package:dtpocketfm/model/sectiontypemodel.dart';
import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/model/threadslistmodel.dart';
import 'package:dtpocketfm/model/transactionlistmodel.dart';
import 'package:dtpocketfm/model/videobyidmodel.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../model/getwishlistmodel.dart';

class ApiService {
  String baseUrl = Constant.baseurl;

  late Dio dio;

  Options optHeaders = Options(headers: <String, dynamic>{
    'Content-Type': 'application/json',
  });

  ApiService() {
    dio = Dio();
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ),
    );
  }

  // general_setting API
  Future<GeneralSettingModel> genaralSetting() async {
    GeneralSettingModel generalSettingModel;
    String generalsetting = "general_setting";
    Response response = await dio.post(
      '$baseUrl$generalsetting',
      options: optHeaders,
    );
    generalSettingModel = GeneralSettingModel.fromJson(response.data);
    return generalSettingModel;
  }

  // get_pages API
  Future<PagesModel> getPages() async {
    PagesModel pagesModel;
    String getPagesAPI = "get_pages";
    Response response = await dio.post(
      '$baseUrl$getPagesAPI',
      options: optHeaders,
    );
    pagesModel = PagesModel.fromJson(response.data);
    return pagesModel;
  }

  /* type => 1-Facebook, 2-Google, 4-Google */
  // login API
  Future<LoginRegisterModel> loginWithSocial(
      email, String name, type, deviceType, File? profileImg) async {
    debugPrint("email :==> $email");
    debugPrint("name :==> $name");
    debugPrint("type :==> $type");
    debugPrint("profileImg :==> $profileImg");

    LoginRegisterModel loginModel;
    String gmailLogin = "login";
    Response response = await dio.post(
      '$baseUrl$gmailLogin',
      options: optHeaders,
      data: FormData.fromMap({
        'type': type,
        'email': email,
        'full_name': name,
        'device_type': deviceType,
        'image': (profileImg?.path ?? "").isNotEmpty
            ? await MultipartFile.fromFile(
                profileImg?.path ?? "",
                filename: (profileImg?.path ?? "").split('/').last,
              )
            : "",
      }),
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  /* type => 3-OTP */
  // login API
  Future<LoginRegisterModel> loginWithOTP(mobile) async {
    debugPrint("mobile :==> $mobile");

    LoginRegisterModel loginModel;
    String doctorLogin = "login";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'type': '1',
        'mobile_number': mobile,
      },
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // forgot_password API
  Future<SuccessModel> forgotPassword(email) async {
    debugPrint("email :==> $email");

    SuccessModel successModel;
    String doctorLogin = "forgot_password";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'email': email,
      },
    );

    successModel = successModelFromJson(response.data.toString());
    return successModel;
  }

  // get_profile API
  Future<ProfileModel> profile() async {
    debugPrint("profile userID :==> ${Constant.userID}");

    ProfileModel profileModel;
    String doctorLogin = "get_profile";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );

    profileModel = ProfileModel.fromJson(response.data);
    return profileModel;
  }

  // get_profile API
  Future<ProfileModel> getUserProfile(userID) async {
    ProfileModel otheruserModel;
    String otherUser = "get_profile";
    Response response = await dio.post(
      '$baseUrl$otherUser',
      options: optHeaders,
      data: {
        'user_id': userID,
      },
    );

    otheruserModel = ProfileModel.fromJson(response.data);
    return otheruserModel;
  }

  // update_profile API
  Future<SuccessModel> updateProfile(
    fullName,
    email,
    mobileNumber,
    aboutMe,
    profileFrontImg,
  ) async {
    debugPrint("updateProfile userID :==> ${Constant.userID}");
    debugPrint("updateProfile fullName :==> $fullName");
    debugPrint("updateProfile email :==> $email");
    debugPrint("updateProfile aboutMe :==> $aboutMe");

    debugPrint("profileFrontImg  :==> $profileFrontImg");

    SuccessModel successModel;
    String doctorLogin = "update_profile";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? 0,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
        'bio': aboutMe ?? "",
        "image": profileFrontImg != null
            ? (MultipartFile.fromFileSync(
                profileFrontImg?.path ?? "",
                filename: basename(profileFrontImg?.path ?? ""),
              ))
            : "",
      }),
      options: optHeaders,
    );

    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // image_upload API
  Future<SuccessModel> imageUpload(File? profileImg) async {
    debugPrint("ProfileImg Filename :==> ${profileImg?.path.split('/').last}");
    debugPrint(
        "profileImg Extension :==> ${profileImg?.path.split('/').last.split(".").last}");
    SuccessModel uploadImgModel;
    String uploadImage = "image_upload";
    debugPrint("imageUpload API :==> $baseUrl$uploadImage");
    Response response = await dio.post(
      '$baseUrl$uploadImage',
      data: FormData.fromMap({
        'id': Constant.userID,
        'image': (profileImg?.path ?? "").isNotEmpty
            ? await MultipartFile.fromFile(
                profileImg?.path ?? "",
                filename: (profileImg?.path ?? "").split('/').last,
              )
            : "",
      }),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    uploadImgModel = SuccessModel.fromJson(response.data);
    return uploadImgModel;
  }

  // update_profile API
  Future<SuccessModel> updateDataForPayment(
      fullName, email, mobileNumber) async {
    debugPrint("updateDataForPayment userID :====> ${Constant.userID}");
    debugPrint("updateDataForPayment fullName :==> $fullName");
    debugPrint("updateDataForPayment email :=====> $email");
    debugPrint("updateProfile mobileNumber :=====> $mobileNumber");

    SuccessModel responseModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
      }),
      options: optHeaders,
    );

    responseModel = SuccessModel.fromJson(response.data);
    return responseModel;
  }

  // Upload Threads API
  Future<SuccessModel> uploadThreads(
    description,
    image,
  ) async {
    debugPrint("uploadThreads userID :====> ${Constant.userID}");
    debugPrint("uploadThreads description :==> $description");
    debugPrint("uploadThreads image :=====> $image");

    SuccessModel uploadThreadsModel;
    String apiName = "upload_threads";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'description': description,
        "image": image != null
            ? (MultipartFile.fromFileSync(
                image?.path ?? "",
                filename: basename(image?.path ?? ""),
              ))
            : "",
      }),
      options: optHeaders,
    );

    uploadThreadsModel = SuccessModel.fromJson(response.data);
    return uploadThreadsModel;
  }

  // delete_threads API
  Future<SuccessModel> deleteThreads(threadsID) async {
    SuccessModel deleteThreadsModel;
    String apiName = "delete_threads";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'threads_id': threadsID,
      }),
      options: optHeaders,
    );

    deleteThreadsModel = SuccessModel.fromJson(response.data);
    return deleteThreadsModel;
  }

  // get_avatar API
  Future<AvatarModel> getAvatar() async {
    AvatarModel avatarModel;
    String getAvatar = "get_avatar";
    Response response = await dio.post(
      '$baseUrl$getAvatar',
      options: optHeaders,
      data: {},
    );
    avatarModel = AvatarModel.fromJson(response.data);
    return avatarModel;
  }

  /* type => 1-movies, 2-news, 3-sport, 4-tv show */
  // get_type API
  Future<SectionTypeModel> sectionType() async {
    SectionTypeModel sectionTypeModel;
    String sectionType = "get_type";
    Response response = await dio.post(
      '$baseUrl$sectionType',
      options: optHeaders,
    );
    sectionTypeModel = SectionTypeModel.fromJson(response.data);
    return sectionTypeModel;
  }

  // get_banner API
  Future<SectionBannerModel> homesectionBanner(
      topcategoryID, isHomePage) async {
    debugPrint('sectionBanner typeId ==>>> $topcategoryID');
    debugPrint('sectionBanner isHomePage ==>>> $isHomePage');
    SectionBannerModel sectionBannerModel;
    String sectionBanner = "get_home_banner";
    Response response = await dio.post(
      '$baseUrl$sectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': topcategoryID,
        'is_home_screen': isHomePage,
      },
    );
    sectionBannerModel = SectionBannerModel.fromJson(response.data);
    return sectionBannerModel;
  }

  // get_audiobook_banner API
  Future<SectionBannerModel> audiobooksectionBanner(
      topcategoryID, isHomePage) async {
    SectionBannerModel audiosectionBannerModel;
    String audiosectionBanner = "get_audiobook_banner";
    Response response = await dio.post(
      '$baseUrl$audiosectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': topcategoryID,
        'is_home_screen': isHomePage,
      },
    );
    audiosectionBannerModel = SectionBannerModel.fromJson(response.data);
    return audiosectionBannerModel;
  }

  // get_novel_banner API
  Future<SectionBannerModel> novelsectionBanner(
      topcategoryID, isHomePage) async {
    SectionBannerModel novelsectionBannerModel;
    String novelsectionBanner = "get_novel_banner";
    Response response = await dio.post(
      '$baseUrl$novelsectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': topcategoryID,
        'is_home_screen': isHomePage,
      },
    );
    novelsectionBannerModel = SectionBannerModel.fromJson(response.data);
    return novelsectionBannerModel;
  }

  Future<ContentDetailsModel> seeall(sectionId, pageno) async {
    debugPrint("sectionid == $sectionId");
    ContentDetailsModel seeallmodel;
    String seeall = "get_content_section_detail";
    Response response = await dio.post(
      '$baseUrl$seeall',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'section_id': sectionId,
        'page_no': pageno,
      },
    );
    seeallmodel = ContentDetailsModel.fromJson(response.data);
    return seeallmodel;
  }

  Future<SectionListModel> musicsectionList(
      ishomescreen, topCategoryId, pageNo) async {
    SectionListModel musicsectionListModel;
    String apiname = "get_music_section";
    Response response = await dio.post('$baseUrl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'is_home_screen': ishomescreen,
          'top_category_id': topCategoryId,
          'page_no': pageNo,
        }));
    musicsectionListModel = SectionListModel.fromJson(response.data);
    return musicsectionListModel;
  }

  // section_list API
  Future<SectionListModel> sectionList(typeId, isHomePage, pageno) async {
    SectionListModel sectionListModel;
    String sectionList = "get_home_section";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': typeId,
        'page_no': pageno,
        'is_home_screen': isHomePage,
      },
    );
    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  // audiobook section_list API
  Future<AudioSectionListModel> audiosectionList(
      typeId, isHomePage, pageno) async {
    AudioSectionListModel audiosectionListModel;
    String audiosectionList = "get_audiobook_section";
    Response response = await dio.post(
      '$baseUrl$audiosectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': typeId,
        'page_no': pageno,
        'is_home_screen': isHomePage,
      },
    );
    audiosectionListModel = AudioSectionListModel.fromJson(response.data);
    return audiosectionListModel;
  }

  // novel section_list API
  Future<NovelSectionListModel> novelsectionList(
      typeId, isHomePage, pageno) async {
    NovelSectionListModel novelsectionListModel;
    String novelsectionList = "get_novel_section";
    Response response = await dio.post(
      '$baseUrl$novelsectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': typeId,
        'page_no': pageno,
        'is_home_screen': isHomePage,
      },
    );
    novelsectionListModel = NovelSectionListModel.fromJson(response.data);
    return novelsectionListModel;
  }

  // Threads section_list API
  Future<ThreadsListModel> threadssectionList(pageNo) async {
    debugPrint("Page nO == $pageNo");
    ThreadsListModel threadssectionListModel;
    String threadssectionList = "get_threads_list";
    Response response = await dio.post(
      '$baseUrl$threadssectionList',
      options: optHeaders,
      data: {'user_id': Constant.userID ?? 0, 'page_no': pageNo},
    );
    threadssectionListModel = ThreadsListModel.fromJson(response.data);
    return threadssectionListModel;
  }

  //  get_threads_by_user API
  Future<ThreadsListModel> threadbyuser(userID, pageno) async {
    ThreadsListModel threadbyuserModel;
    String threadbyuserList = "get_threads_by_user";
    Response response = await dio.post(
      '$baseUrl$threadbyuserList',
      options: optHeaders,
      data: {'user_id': userID, 'page_no': pageno},
    );
    threadbyuserModel = ThreadsListModel.fromJson(response.data);
    return threadbyuserModel;
  }

  //  get_threads_by_user API
  Future<ThreadsListModel> threadbyartist(artistID, pageno) async {
    ThreadsListModel threadbyartistModel;
    String threadbyartistList = "get_threads_by_artist";
    Response response = await dio.post(
      '$baseUrl$threadbyartistList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'artist_id': artistID,
        'page_no': pageno
      },
    );
    threadbyartistModel = ThreadsListModel.fromJson(response.data);
    return threadbyartistModel;
  }

  // contentDetails API
  Future<ContentDetailsModel> contentDetails(contentid, contenttype) async {
    debugPrint("contentid == $contentid");
    debugPrint("contenttype == $contenttype");
    ContentDetailsModel contentDetailsModel;
    String contentDetails = "get_content_detail";
    Response response = await dio.post(
      '$baseUrl$contentDetails',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': contentid,
        'content_type': contenttype,
      },
    );
    contentDetailsModel = ContentDetailsModel.fromJson(response.data);
    return contentDetailsModel;
  }

  // get_video_by_content API
  Future<EpisodeByContentModel> episodeVideoByContent(seasonId, pageno) async {
    EpisodeByContentModel episodeByContentModel;
    String episodeByContentList = "get_episode_video_by_content";
    Response response = await dio.post(
      '$baseUrl$episodeByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': seasonId,
        'page_no': pageno
      },
    );
    episodeByContentModel = EpisodeByContentModel.fromJson(response.data);
    return episodeByContentModel;
  }

  // get_audio_by_content API
  Future<EpisodeByContentModel> episodeAudioByContent(seasonId, pageno) async {
    EpisodeByContentModel audioByContentModel;
    String audioByContentList = "get_episode_audio_by_content";
    Response response = await dio.post(
      '$baseUrl$audioByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': seasonId,
        'page_no': pageno
      },
    );
    audioByContentModel = EpisodeByContentModel.fromJson(response.data);
    debugPrint("audioByContentModel == ${audioByContentModel.status}");
    return audioByContentModel;
  }

  // get_music_section_detail API
  Future<EpisodeByContentModel> episodeMusicBySection(sectionID, pageno) async {
    EpisodeByContentModel musicByContentModel;
    String musicByContentList = "get_music_section_detail";
    Response response = await dio.post(
      '$baseUrl$musicByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'section_id': sectionID,
        'page_no': pageno
      },
    );
    musicByContentModel = EpisodeByContentModel.fromJson(response.data);
    debugPrint("audioByContentModel == ${musicByContentModel.status}");
    return musicByContentModel;
  }

  // get_episode_book_by_content API
  Future<EpisodeByContentModel> episodeByBook(seasonId, pageno) async {
    EpisodeByContentModel chapterByContentModel;
    String audioByContentList = "get_episode_book_by_content";
    Response response = await dio.post(
      '$baseUrl$audioByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': seasonId,
        'page_no': pageno
      },
    );
    chapterByContentModel = EpisodeByContentModel.fromJson(response.data);
    return chapterByContentModel;
  }

  // section_detail API
  Future<SectionDetailModel> sectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    SectionDetailModel sectionDetailModel;
    String sectionList = "section_detail";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'type_id': typeId,
        'video_type': videoType,
        'video_id': videoId,
        'upcoming_type': upcomingType,
      },
    );
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  // get_earn_coin API
  Future<Earncoinmodel> getearncoins() async {
    Earncoinmodel earncoinModel;
    String earncoin = "get_earn_coin";
    Response response = await dio.post(
      '$baseUrl$earncoin',
      options: optHeaders,
      data: {},
    );
    earncoinModel = Earncoinmodel.fromJson(response.data);
    return earncoinModel;
  }

  // get_earn_coin_transaction API
  Future<SuccessModel> getearntransaction(coin, type) async {
    SuccessModel earncointransactionModel;
    String earncointransaction = "get_earn_coin_transaction";
    Response response = await dio.post(
      '$baseUrl$earncointransaction',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'coin': coin, 'type': type},
    );
    earncointransactionModel = SuccessModel.fromJson(response.data);
    return earncointransactionModel;
  }

  Future<EarnCoindTransactionListModel> getearntransactionlist(pageNo) async {
    EarnCoindTransactionListModel earncointransactionlistModel;
    String earncointransactionlist = "get_earn_coin_transaction_list";
    Response response = await dio.post(
      '$baseUrl$earncointransactionlist',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    earncointransactionlistModel =
        EarnCoindTransactionListModel.fromJson(response.data);
    return earncointransactionlistModel;
  }

  // get_wallet_transaction_list API
  Future<TransactionListModel> transactionList(pageNo) async {
    TransactionListModel transactionListModel;
    String transactionList = "get_wallet_transaction_list";
    Response response = await dio.post(
      '$baseUrl$transactionList',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    transactionListModel = TransactionListModel.fromJson(response.data);
    return transactionListModel;
  }

  // get_transaction_list API
  Future<TransactionListModel> wallettransactionList(pageNo) async {
    TransactionListModel wallettransactionListModel;
    String wallettransactionList = "get_transaction_list";
    Response response = await dio.post(
      '$baseUrl$wallettransactionList',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    wallettransactionListModel = TransactionListModel.fromJson(response.data);
    return wallettransactionListModel;
  }

  // get_reviews API
  Future<CommentModel> getreviews(conetentId, contentType, pageNo) async {
    CommentModel getReviewModel;
    String getReview = "get_reviews";
    Response response = await dio.post(
      '$baseUrl$getReview',
      options: optHeaders,
      data: {
        'content_id': conetentId,
        'content_type': contentType,
        'page_no': pageNo
      },
    );
    getReviewModel = CommentModel.fromJson(response.data);
    return getReviewModel;
  }

  // get_artist_detail API
  Future<ArtistProfileModel> getArtist(
    artistId,
  ) async {
    ArtistProfileModel getArtistModel;
    String getArtist = "get_artist_detail";
    Response response = await dio.post(
      '$baseUrl$getArtist',
      options: optHeaders,
      data: {
        'artist_id': artistId,
        'user_id': Constant.userID ?? 0,
      },
    );
    getArtistModel = ArtistProfileModel.fromJson(response.data);
    return getArtistModel;
  }

  // get_artist_detail API
  Future<ArtistProfileModel> getSugestedArtist() async {
    ArtistProfileModel getSuggestArtistModel;
    String getSuggestArtist = "get_artist_suggestion_list";
    Response response = await dio.post(
      '$baseUrl$getSuggestArtist',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
      },
    );
    getSuggestArtistModel = ArtistProfileModel.fromJson(response.data);
    return getSuggestArtistModel;
  }

  // video_view API
  Future<SuccessModel> videoView(videoId, videoType, otherId) async {
    debugPrint('videoView videoId ====>>> $videoId');
    debugPrint('videoView videoType ==>>> $videoType');
    debugPrint('videoView otherId ====>>> $otherId');
    SuccessModel successModel;
    String sectionList = "video_view";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'other_id': otherId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_remove_bookmark API
  Future<SuccessModel> addRemoveBookmark(contentType, contentId) async {
    SuccessModel successModel;
    String sectionList = "add_remove_bookmark";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'content_type': contentType,
        'content_id': contentId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_content_by_artist API
  Future<GetContentByArtistMdel> getContentByArtist(
      type, artistid, pageNo) async {
    GetContentByArtistMdel getContentByArtist;
    String getContentByArtistAPI = "get_content_by_artist";
    Response response = await dio.post(
      '$baseUrl$getContentByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'type': type,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getContentByArtist = GetContentByArtistMdel.fromJson(response.data);
    return getContentByArtist;
  }

  // get_content_by_artist API
  Future<GetContentByArtistMdel> getNovelByArtist(
      type, artistid, pageNo) async {
    GetContentByArtistMdel getNovelByArtist;
    String getNovelByArtistAPI = "get_content_by_artist";
    Response response = await dio.post(
      '$baseUrl$getNovelByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'type': type,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getNovelByArtist = GetContentByArtistMdel.fromJson(response.data);
    return getNovelByArtist;
  }

  // get_music_by_artist API
  Future<GetContentByArtistMdel> getMusicByArtist(artistid, pageNo) async {
    GetContentByArtistMdel getMusicByArtist;
    String getMusicByArtistAPI = "get_music_by_artist";
    Response response = await dio.post(
      '$baseUrl$getMusicByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getMusicByArtist = GetContentByArtistMdel.fromJson(response.data);
    return getMusicByArtist;
  }

  // get_music_by_artist API
  Future<EpisodeByContentModel> getMusicByArtistPlaylist(
      artistid, pageNo) async {
    EpisodeByContentModel getMusicByArtist;
    String getMusicByArtistAPI = "get_music_by_artist";
    Response response = await dio.post(
      '$baseUrl$getMusicByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getMusicByArtist = EpisodeByContentModel.fromJson(response.data);
    return getMusicByArtist;
  }

  // add_remove_like_dislike API
  Future<SuccessModel> addRemoveLike(threadID) async {
    SuccessModel addRemoveLikeModel;
    String addremoveLike = "add_remove_like_dislike";
    Response response = await dio.post(
      '$baseUrl$addremoveLike',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'threads_id': threadID,
      },
    );
    addRemoveLikeModel = SuccessModel.fromJson(response.data);
    return addRemoveLikeModel;
  }

  // add_continue_watching API
  Future<SuccessModel> addContinueWatching(
      contentId, contentType, stopTime, contentEpisodeId, audiobookType) async {
    SuccessModel successModel;
    String continueWatching = "add_content_to_history";
    Response response = await dio.post(
      '$baseUrl$continueWatching',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': contentId,
        'content_type': contentType,
        'stop_time': stopTime,
        'content_episode_id': contentEpisodeId,
        'audiobook_type': audiobookType
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> logout() async {
    SuccessModel logoutModel;
    String logout = "logout";
    Response response = await dio.post(
      '$baseUrl$logout',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    logoutModel = SuccessModel.fromJson(response.data);
    return logoutModel;
  }

  // remove_continue_watching API
  /* user_id, video_id, video_type
     * Show :=> ("video_id" = Episode's ID)  AND  ("video_type" = "2")
     * Video :=> ("video_id" = Video's ID) */
  Future<SuccessModel> removeContinueWatching(
      contentId, contentType, contentEpisodeId, audiobookType) async {
    SuccessModel successModel;
    String removeContinueWatching = "remove_content_to_history";
    Response response = await dio.post(
      '$baseUrl$removeContinueWatching',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': contentId,
        'content_type': contentType,
        'content_episode_id': contentEpisodeId,
        'audiobook_type': audiobookType
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_category API
  Future<GenresModel> genres() async {
    GenresModel genresModel;
    String genres = "get_category";
    Response response = await dio.post(
      '$baseUrl$genres',
      options: optHeaders,
    );
    genresModel = GenresModel.fromJson(response.data);
    return genresModel;
  }

  // get_language API
  Future<LangaugeModel> language() async {
    LangaugeModel langaugeModel;
    String language = "get_language";
    Response response = await dio.post(
      '$baseUrl$language',
      options: optHeaders,
    );
    langaugeModel = LangaugeModel.fromJson(response.data);
    return langaugeModel;
  }

  // search_video API
  Future<SearchListModel> searchContent(searchText, type, pageNo) async {
    debugPrint('searchContent searchText ==>>> $searchText');
    SearchListModel searchModel;
    String search = "search_content";
    Response response = await dio.post(
      '$baseUrl$search',
      options: optHeaders,
      data: {
        'name': searchText,
        'user_id': Constant.userID ?? 0,
        'type': type,
        'page_no': pageNo
      },
    );
    searchModel = SearchListModel.fromJson(response.data);
    return searchModel;
  }

  // search_video Music API
  Future<EpisodeByContentModel> searchMusicContent(pageNo) async {
    EpisodeByContentModel searchMusicModel;
    String search = "search_content";
    Response response = await dio.post(
      '$baseUrl$search',
      options: optHeaders,
      data: {
        'name': Constant.searchtext,
        'user_id': Constant.userID ?? 0,
        'type': 3,
        'page_no': pageNo
      },
    );
    searchMusicModel = EpisodeByContentModel.fromJson(response.data);
    return searchMusicModel;
  }

  // channel_section_list API
  Future<ChannelSectionModel> channelSectionList() async {
    ChannelSectionModel channelSectionModel;
    String channelSection = "channel_section_list";
    Response response = await dio.post(
      '$baseUrl$channelSection',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    channelSectionModel = ChannelSectionModel.fromJson(response.data);
    return channelSectionModel;
  }

  // rent_video_list API
  Future<RentModel> rentVideoList() async {
    RentModel rentModel;
    String rentList = "rent_video_list";
    Response response = await dio.post(
      '$baseUrl$rentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    rentModel = RentModel.fromJson(response.data);
    return rentModel;
  }

  // add_remove_follow API
  Future<SuccessModel> addremovefollow(artistId) async {
    SuccessModel addRemoveFolloModel;
    String addremovefollow = "add_remove_follow";
    Response response = await dio.post(
      '$baseUrl$addremovefollow',
      options: optHeaders,
      data: {
        'artist_id': artistId,
        'user_id': Constant.userID,
      },
    );
    addRemoveFolloModel = SuccessModel.fromJson(response.data);
    return addRemoveFolloModel;
  }

  // add_reviews API
  Future<SuccessModel> addreviews(
      contentID, comment, contenttype, rating) async {
    SuccessModel addreviewsModel;
    String addreview = "add_reviews";
    Response response = await dio.post(
      '$baseUrl$addreview',
      options: optHeaders,
      data: {
        'content_id': contentID,
        'user_id': Constant.userID,
        'comment': comment,
        'content_type': contenttype,
        'rating': rating
      },
    );
    addreviewsModel = SuccessModel.fromJson(response.data);
    return addreviewsModel;
  }

  // add_comment API
  Future<SuccessModel> addComment(commentID, comment, threadID) async {
    SuccessModel addreviewsModel;
    String addreview = "add_comment";
    Response response = await dio.post(
      '$baseUrl$addreview',
      options: optHeaders,
      data: {
        'comment_id': commentID,
        'user_id': Constant.userID,
        'comment': comment,
        'threads_id': threadID
      },
    );
    addreviewsModel = SuccessModel.fromJson(response.data);
    return addreviewsModel;
  }

  // get_comment API
  Future<CommentModel> getComments(threadID, pageNo) async {
    CommentModel getCommentModel;
    String getComment = "get_comment";
    Response response = await dio.post(
      '$baseUrl$getComment',
      options: optHeaders,
      data: {'threads_id': threadID, 'page_no': pageNo},
    );
    getCommentModel = CommentModel.fromJson(response.data);
    return getCommentModel;
  }

  // get_reply_comment API
  Future<CommentModel> getReplyComments(commentID, pageNo) async {
    CommentModel getReplyCommentModel;
    String getReplyComment = "get_reply_comment";
    Response response = await dio.post(
      '$baseUrl$getReplyComment',
      options: optHeaders,
      data: {'comment_id': commentID, 'page_no': pageNo},
    );
    getReplyCommentModel = CommentModel.fromJson(response.data);
    return getReplyCommentModel;
  }

  Future<GetNotificationModel> notification(pageNo) async {
    GetNotificationModel getNotificationModel;
    String apiname = "get_notification";
    Response response = await dio.post('$baseUrl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    getNotificationModel = GetNotificationModel.fromJson(response.data);
    return getNotificationModel;
  }

  Future<SuccessModel> readNotification(notificationId) async {
    SuccessModel successModel;
    String apiname = "read_notification";
    Response response = await dio.post('$baseUrl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'notification_id': notificationId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // edit_reviews API
  Future<SuccessModel> editreviews(contentID, comment, rating) async {
    SuccessModel editreviewsModel;
    String editreview = "edit_reviews";
    Response response = await dio.post(
      '$baseUrl$editreview',
      options: optHeaders,
      data: {
        'review_id': contentID,
        'user_id': Constant.userID,
        'comment': comment,
        'rating': rating
      },
    );
    editreviewsModel = SuccessModel.fromJson(response.data);
    return editreviewsModel;
  }

  // edit_comment API
  Future<SuccessModel> editcomment(
    commentID,
    comment,
  ) async {
    SuccessModel editcommentModel;
    String editcomment = "edit_comment";
    Response response = await dio.post(
      '$baseUrl$editcomment',
      options: optHeaders,
      data: {
        'comment_id': commentID,
        'user_id': Constant.userID,
        'comment': comment,
      },
    );
    editcommentModel = SuccessModel.fromJson(response.data);
    return editcommentModel;
  }

  // buy_content_episode API
  Future<SuccessModel> buyEpisode(
    contentType,
    episodeID,
    audioBookType,
    contentID,
    coin,
  ) async {
    SuccessModel buyEpisodeModel;
    String buyepisode = "buy_content_episode";
    Response response = await dio.post(
      '$baseUrl$buyepisode',
      options: optHeaders,
      data: {
        'content_type': contentType,
        'user_id': Constant.userID,
        'content_episode_id': episodeID,
        'audiobook_type': audioBookType,
        'content_id': contentID,
        'coin': coin,
      },
    );
    buyEpisodeModel = SuccessModel.fromJson(response.data);
    return buyEpisodeModel;
  }

  // add_content_play API
  Future<SuccessModel> addToPlay(
    contentType,
    episodeID,
    audioBookType,
    contentID,
  ) async {
    SuccessModel addcontentplayModel;
    String addcontentplay = "add_content_play";
    Response response = await dio.post(
      '$baseUrl$addcontentplay',
      options: optHeaders,
      data: {
        'content_type': contentType,
        'user_id': Constant.userID,
        'content_episode_id': episodeID,
        'audiobook_type': audioBookType,
        'content_id': contentID,
      },
    );
    addcontentplayModel = SuccessModel.fromJson(response.data);
    return addcontentplayModel;
  }

  // delete_reviews API
  Future<SuccessModel> deletereviews(
    contentID,
  ) async {
    SuccessModel deletereviewsModel;
    String deletereview = "delete_reviews";
    Response response = await dio.post(
      '$baseUrl$deletereview',
      options: optHeaders,
      data: {
        'review_id': contentID,
      },
    );
    deletereviewsModel = SuccessModel.fromJson(response.data);
    return deletereviewsModel;
  }

  // delete_comment API
  Future<SuccessModel> deletecomment(
    commentId,
  ) async {
    SuccessModel deletecommentModel;
    String deletecomment = "delete_comment";
    Response response = await dio.post(
      '$baseUrl$deletecomment',
      options: optHeaders,
      data: {
        'comment_id': commentId,
      },
    );
    deletecommentModel = SuccessModel.fromJson(response.data);
    return deletecommentModel;
  }

  // video_by_category API
  Future<VideoByIdModel> videoByCategory(categoryID, typeId, pageNo) async {
    debugPrint('videoByCategory categoryID ==>>> $categoryID');
    debugPrint('videoByCategory typeId ====>>>>> $typeId');
    VideoByIdModel videoByIdModel;
    String byCategory = "get_content_by_category";
    Response response = await dio.post(
      '$baseUrl$byCategory',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'category_id': categoryID,
        'type': typeId,
        "page_no": pageNo
      },
    );
    videoByIdModel = VideoByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // video_by_language API
  Future<VideoByIdModel> videoByLanguage(languageID, typeId, pageNo) async {
    debugPrint('videoByLanguage languageID ==>>> $languageID');
    debugPrint('videoByLanguage typeId ====>>>>> $typeId');
    VideoByIdModel videoByIdModel;
    String byLanguage = "get_content_by_language";
    Response response = await dio.post(
      '$baseUrl$byLanguage',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'language_id': languageID,
        'type': typeId,
        "page_no": pageNo
      },
    );
    videoByIdModel = VideoByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // get_package API
  Future<SubscriptionModel> subscriptionPackage() async {
    debugPrint('subscriptionPackage userID ==>>> ${Constant.userID}');
    SubscriptionModel subscriptionModel;
    String getPackage = "get_package";
    Response response = await dio.post(
      '$baseUrl$getPackage',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    subscriptionModel = SubscriptionModel.fromJson(response.data);
    return subscriptionModel;
  }

  // get_bookmark_video API
  Future<GetWishListModel> watchlist(contentType, pageNo) async {
    debugPrint("watchlist userID :==> ${Constant.userID}");

    GetWishListModel watchlistModel;
    String getBookmarkVideo = "get_bookmark_list";
    debugPrint("getBookmarkVideo API :==> $baseUrl$getBookmarkVideo");
    Response response = await dio.post(
      '$baseUrl$getBookmarkVideo',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'content_type': contentType,
        'page_no': pageNo
      },
    );

    watchlistModel = GetWishListModel.fromJson(response.data);
    return watchlistModel;
  }

  // get_payment_option API
  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String paymentOption = "get_payment_option";
    debugPrint("paymentOption API :==> $baseUrl$paymentOption");
    Response response = await dio.post(
      '$baseUrl$paymentOption',
      options: optHeaders,
    );

    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  // apply_coupon API
  Future<CouponModel> applyPackageCoupon(couponCode, packageId) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    debugPrint("applyPackageCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'apply_coupon_type': "1",
        'unique_id': couponCode,
        'package_id': packageId,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // apply_coupon API
  Future<CouponModel> applyRentCoupon(
      couponCode, videoId, typeId, videoType, price) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    debugPrint("applyRentCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'apply_coupon_type': "2",
        'unique_id': couponCode,
        'video_id': videoId,
        'type_id': typeId,
        'video_type': videoType,
        'price': price,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // get_payment_token API
  Future<PayTmModel> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    PayTmModel payTmModel;
    String paytmToken = "get_payment_token";
    debugPrint("paytmToken API :==> $baseUrl$paytmToken");
    Response response = await dio.post(
      '$baseUrl$paytmToken',
      options: optHeaders,
      data: {
        'MID': merchantID,
        'order_id': orderId,
        'CUST_ID': custmoreID,
        'CHANNEL_ID': channelID,
        'TXN_AMOUNT': txnAmount,
        'WEBSITE': website,
        'CALLBACK_URL': callbackURL,
        'INDUSTRY_TYPE_ID': industryTypeID,
      },
    );

    payTmModel = PayTmModel.fromJson(response.data);
    return payTmModel;
  }

  // add_transaction API
  Future<SuccessModel> addTransaction(
    packageId,
    description,
    amount,
    transactionId,
    coin,
  ) async {
    debugPrint('addTransaction userID ==>>> ${Constant.userID}');
    debugPrint('addTransaction packageId ==>>> $packageId');
    debugPrint('addTransaction description ==>>> $description');
    debugPrint('addTransaction amount ==>>> $amount');
    SuccessModel successModel;
    String transaction = "add_transaction";
    Response response = await dio.post(
      '$baseUrl$transaction',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'package_id': packageId,
        'description': description,
        'price': amount,
        'coin': coin,
        // 'payment_id': paymentId,
        // 'currency_code': currencyCode,
        // 'unique_id': couponCode,
        'transaction_id': transactionId
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_rent_transaction API
  Future<SuccessModel> addRentTransaction(
      videoId, price, typeId, videoType, couponCode) async {
    debugPrint('addRentTransaction userID ==>>> ${Constant.userID}');
    debugPrint('addRentTransaction video_id ==>>> $videoId');
    debugPrint('addRentTransaction price ==>>> $price');
    debugPrint('addRentTransaction typeId ==>>> $typeId');
    debugPrint('addRentTransaction videoType ==>>> $videoType');
    debugPrint('addTransaction couponCode ==>>> $couponCode');
    SuccessModel successModel;
    String rentTransaction = "add_rent_transaction";
    Response response = await dio.post(
      '$baseUrl$rentTransaction',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'price': price,
        'type_id': typeId,
        'video_type': videoType,
        'unique_id': couponCode,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }
}

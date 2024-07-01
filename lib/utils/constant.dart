import 'package:dtpocketfm/model/qualitymodel.dart';
import 'package:dtpocketfm/model/subtitlemodel.dart';

class Constant {
  static const String baseurl =
      '';

  static String appName = "DTPocketFM";
  static String appPackageName = "com.divinetechs.dtpocketfm";
  
  static String? appleAppId = "6449582782";
  
  /* OneSignal App ID */
  
  static String oneSignalAppId = "cad6e200-61fb-4c5c-a3e0-0b695dbc3d50";

  /* Constant for TV check */
  static bool isTV = false;

  static String? userID;
  static String? musicsectionId;
  static String currencySymbol = "";
  static String currency = "";

  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";
  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";

  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=${Constant.appPackageName}";
  static String iosAppUrl =
      "https://apps.apple.com/us/app/id${Constant.appleAppId}";

  static List<QualityModel> resolutionsUrls = [];
  static List<SubTitleModel> subtitleUrls = [];

  /* Download config */
  static String videoDownloadPort = 'video_downloader_send_port';
  static String showDownloadPort = 'show_downloader_send_port';
  static String hawkVIDEOList = "myVideoList_";
  static String hawkKIDSVIDEOList = "myKidsVideoList_";
  static String hawkSHOWList = "myShowList_";
  static String hawkSEASONList = "mySeasonList_";
  static String hawkEPISODEList = "myEpisodeList_";
  /* Download config */

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static int bannerDuration = 10000; // in milliseconds
  static int animationDuration = 800; // in milliseconds

  /* Show Ad By Type */
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  static String musicType = "1";
  static String podcastType = "2";
  static String radioType = "3";
  static String? searchtext;
}

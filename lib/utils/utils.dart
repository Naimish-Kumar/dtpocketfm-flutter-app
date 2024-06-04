import 'dart:io';
import 'dart:math' as number;

import 'package:dtpocketfm/model/qualitymodel.dart';
import 'package:dtpocketfm/model/subtitlemodel.dart';
import 'package:dtpocketfm/pages/bottombar.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/pages/noveldetails.dart';
import 'package:dtpocketfm/players/player_video.dart';
import 'package:dtpocketfm/players/player_youtube.dart';
import 'package:dtpocketfm/pages/audiobookdetails.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/subscription/allpayment.dart';
import 'package:dtpocketfm/tvpages/webnoveldetails.dart';
import 'package:dtpocketfm/tvpages/webaudiobookdetails.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/webwidget/loginsocialweb.dart';
import 'package:dtpocketfm/webwidget/otpverifyweb.dart';
import 'package:dtpocketfm/webwidget/profileeditweb.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:html/parser.dart' show parse;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screen_protector/screen_protector.dart';

class Utils {
  static void enableScreenCapture() async {
    await ScreenProtector.preventScreenshotOn();
    if (Platform.isIOS) {
      await ScreenProtector.protectDataLeakageWithBlur();
    } else if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // KMB Text Generator Method
  static String kmbGenerator(int num) {
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(1)} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(0)} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(1)} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(1)} B";
    } else {
      return num.toString();
    }
  }

  static Widget buildMusicPanel(context) {
    return ValueListenableBuilder(
      valueListenable: currentlyPlaying,
      builder: (BuildContext context, AudioPlayer? audioObject, Widget? child) {
        if (audioObject?.audioSource != null) {
          return MusicDetails(
            ishomepage: false,
            contentid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.album)
                    .toString(),
            episodeid:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.id)
                    .toString(),
            stoptime: audioPlayer.position.toString(),
            contenttype:
                ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                        ?.genre)
                    .toString(),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static void openLogin(
      {required BuildContext context,
      required bool isHome,
      required bool isReplace}) async {
    currentlyPlaying.value = null;
    await audioPlayer.pause();
    await audioPlayer.stop();
    if (context.mounted) {
      debugPrint("setState");
      if (isReplace) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginSocial(
                ishome: false,
              );
            },
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginSocial(
                ishome: false,
              );
            },
          ),
        );
      }
    }
  }

  static loadAds(BuildContext context) async {
    bool? isPremiumBuy = await Utils.checkPremiumUser();
    debugPrint("loadAds isPremiumBuy :==> $isPremiumBuy");
    if (context.mounted) {
      AdHelper.getAds(context);
    }
    if (!kIsWeb && !isPremiumBuy) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

  static showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: white,
      textColor: black,
      fontSize: 16,
    );
  }

  static Future<dynamic> openDetails({
    required BuildContext context,
    required int videoId,
    required int videoType,
  }) async {
    debugPrint("openDetails videoId ========> $videoId");
    debugPrint("openDetails videoType ======> $videoType");

    if (videoType == 1) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            if (kIsWeb || Constant.isTV) {
              return WebAudioBookDetails(
                videoId,
                videoType,
              );
            } else {
              return AudioBookDetails(
                videoId,
                videoType,
              );
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    } else {
      if (videoType == 2) {
        if (!(context.mounted)) return;
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (kIsWeb || Constant.isTV) {
                return WebNovelDetails(
                  videoId,
                  videoType,
                );
              } else {
                return NovelDetails(
                  videoId,
                  videoType,
                );
                // return NovelDetails(
                //   videoId,
                //   upcomingType,
                //   videoType,
                //   typeId,
                // );
              }
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
        );
      } else if (videoType == 2) {
        if (!(context.mounted)) return;
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (kIsWeb || Constant.isTV) {
                return WebAudioBookDetails(
                  videoId,
                  videoType,
                );
              } else {
                return AudioBookDetails(
                  videoId,
                  videoType,
                );
                // return NovelDetails(
                //   videoId,
                //   upcomingType,
                //   videoType,
                //   typeId,
                // );
              }
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
        );
      }
    }
  }

  static Future<dynamic> paymentForRent({
    required BuildContext context,
    required String? videoId,
    required String? vTitle,
    required String? vType,
    required String? typeId,
    required String? rentPrice,
  }) async {
    dynamic isRented = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AllPayment(
            payType: 'Rent',
            itemId: videoId.toString(),
            price: rentPrice.toString(),
            itemTitle: vTitle.toString(),
            typeId: typeId.toString(),
            videoType: vType.toString(),
            productPackage: '',
            currency: '',
            coin: '',
          );
        },
      ),
    );
    return isRented;
  }

  static Future<void> buildWebAlertDialog(
      BuildContext context, String pageName, String? reqData) async {
    Widget? child;
    if (pageName == "login") {
      child = const LoginSocialWeb();
    } else if (pageName == "profile") {
      child = const ProfileEditWeb();
    } else if (pageName == "otp") {
      child = OTPVerifyWeb(reqData ?? "");
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: lightBlack,
          child: child,
        );
      },
    );
  }

  /* ========= Open Player ========= */
  static Future<dynamic> openPlayer(
      {required BuildContext context,
      required String? playType,
      required int? videoId,
      required int? videoType,
      int? typeId,
      // required int? otherId,
      required String? videoUrl,
      String? trailerUrl,
      required String? uploadType,
      required String? videoThumb,
      required int? vStopTime,
      required int contentID}) async {
    dynamic isContinue;
    int? vID = (videoId ?? 0);
    int? vType = (videoType ?? 0);
    int? vTypeID = (typeId ?? 0);
    // int? // vOtherID = (otherId ?? 0);
    debugPrint("vID ========> $vID");
    // debugPrint("// vOtherID ===> $// vOtherID");

    int? stopTime;
    if (playType == "startOver") {
      stopTime = 0;
    } else {
      stopTime = (vStopTime ?? 0);
    }

    String? vUrl, vUploadType;
    if (playType == "Trailer") {
      vUrl = (trailerUrl ?? "");
    } else {
      vUrl = (videoUrl ?? "");
    }
    vUploadType = (uploadType ?? "");
    debugPrint("stopTime ===> $stopTime");
    debugPrint("===>vUploadType $vUploadType");

    if (kIsWeb) {
      /* Pod Player & Youtube Player */
      if (!context.mounted) return;
      if (vUploadType.toString() == "1") {
        isContinue = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(
                contentID,
                playType == "Trailer"
                    ? "Trailer"
                    : playType == "Download"
                        ? "Download"
                        : (videoType == 2 ? "Show" : "Video"),
                vID,
                vType,
                vTypeID,
                // vOtherID,
                vUrl ?? "",
                stopTime,
                vUploadType,
                videoThumb,
              );
            },
          ),
        );
      } else if (vUploadType.toString() == "3") {
        if (vUrl.contains('youtube')) {
          isContinue = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(
                  contentID,
                  playType == "Trailer"
                      ? "Trailer"
                      : playType == "Download"
                          ? "Download"
                          : (videoType == 2 ? "Show" : "Video"),
                  vID,
                  vType,
                  vTypeID,
                  // vOtherID,
                  vUrl ?? "",
                  stopTime,
                  vUploadType,
                  videoThumb,
                );
              },
            ),
          );
        } else {
          isContinue = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(
                  contentID,
                  playType == "Trailer"
                      ? "Trailer"
                      : playType == "Download"
                          ? "Download"
                          : (videoType == 2 ? "Show" : "Video"),
                  vID,
                  vType,
                  vTypeID,
                  // vOtherID,
                  vUrl ?? "",
                  stopTime,
                  vUploadType,
                  videoThumb,
                );
              },
            ),
          );
        }
      } else {
        isContinue = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(
                contentID,
                playType == "Trailer"
                    ? "Trailer"
                    : playType == "Download"
                        ? "Download"
                        : (videoType == 2 ? "Show" : "Video"),
                vID,
                vType,
                vTypeID,
                // vOtherID,
                vUrl ?? "",
                stopTime,
                vUploadType,
                videoThumb,
              );
            },
          ),
        );
      }
    } else {
      /* Better, Youtube & Vimeo Players */
      if (vUploadType.toString() == "3") {
        isContinue = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerYoutube(
                contentID,
                playType == "Trailer"
                    ? "Trailer"
                    : playType == "Download"
                        ? "Download"
                        : (videoType == 2 ? "Show" : "Video"),
                vID,
                vType,
                vTypeID,
                // vOtherID,
                vUrl ?? "",
                stopTime,
                vUploadType,
                videoThumb,
              );
            },
          ),
        );
      } else if (vUploadType.toString() == "2") {
        isContinue = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(
                contentID,
                playType == "Trailer"
                    ? "Trailer"
                    : playType == "Download"
                        ? "Download"
                        : (videoType == 2 ? "Show" : "Video"),
                vID,
                vType,
                vTypeID,
                // vOtherID,
                vUrl ?? "",
                stopTime,
                vUploadType,
                videoThumb,
              );
            },
          ),
        );
      } else if (vUploadType.toString() == "3") {
        if (vUrl.contains('youtube')) {
          isContinue = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerYoutube(
                  contentID,
                  playType == "Trailer"
                      ? "Trailer"
                      : playType == "Download"
                          ? "Download"
                          : (videoType == 2 ? "Show" : "Video"),
                  vID,
                  vType,
                  vTypeID,
                  // vOtherID,
                  vUrl ?? "",
                  stopTime,
                  vUploadType,
                  videoThumb,
                );
              },
            ),
          );
        } else {
          isContinue = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayerVideo(
                  contentID,
                  playType == "Trailer"
                      ? "Trailer"
                      : playType == "Download"
                          ? "Download"
                          : (videoType == 2 ? "Show" : "Video"),
                  vID,
                  vType,
                  vTypeID,
                  // vOtherID,
                  vUrl ?? "",
                  stopTime,
                  vUploadType,
                  videoThumb,
                );
              },
            ),
          );
        }
      } else {
        isContinue = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerVideo(
                contentID,
                playType == "Trailer"
                    ? "Trailer"
                    : playType == "Download"
                        ? "Download"
                        : (videoType == 2 ? "Show" : "Video"),
                vID,
                vType,
                vTypeID,
                // vOtherID,
                vUrl ?? "",
                stopTime,
                vUploadType,
                videoThumb,
              );
            },
          ),
        );
      }
    }
    debugPrint("isContinue ===> $isContinue");
    return isContinue;
  }
  /* ========= Open Player ========= */

  /* ========= Set-up Quality URL START ========= */
  static void setQualityURLs({
    required String video320,
    required String video480,
    required String video720,
    required String video1080,
  }) {
    Map<String, String> qualityUrlList = <String, String>{};
    if (video320 != "") {
      qualityUrlList['320p'] = video320;
    }
    if (video480 != "") {
      qualityUrlList['480p'] = video480;
    }
    if (video720 != "") {
      qualityUrlList['720p'] = video720;
    }
    if (video1080 != "") {
      qualityUrlList['1080p'] = video1080;
    }
    debugPrint("qualityUrlList ==========> ${qualityUrlList.length}");
    Constant.resolutionsUrls.clear();
    Constant.resolutionsUrls = [];
    Constant.resolutionsUrls = qualityUrlList.entries
        .map((entry) => QualityModel(entry.key, entry.value))
        .toList();
    debugPrint(
        "resolutionsUrls ==========> ${Constant.resolutionsUrls.length}");
  }
  /* ========= Set-up Quality URL END =========== */

  static void clearQualitySubtitle() {
    Constant.resolutionsUrls.clear();
    Constant.resolutionsUrls = [];
    Constant.subtitleUrls.clear();
    Constant.subtitleUrls = [];
  }

  /* ========= Set-up Subtitle URL START ========= */
  static void setSubtitleURLs({
    required String subtitleUrl1,
    required String subtitleUrl2,
    required String subtitleUrl3,
    required String subtitleLang1,
    required String subtitleLang2,
    required String subtitleLang3,
  }) {
    Map<String, String> subtitleUrlList = <String, String>{};
    if (subtitleUrl1 != "") {
      subtitleUrlList[subtitleLang1] = subtitleUrl1;
    }
    if (subtitleUrl2 != "") {
      subtitleUrlList[subtitleLang2] = subtitleUrl2;
    }
    if (subtitleUrl3 != "") {
      subtitleUrlList[subtitleLang3] = subtitleUrl3;
    }
    debugPrint("subtitleUrlList========> ${subtitleUrlList.length}");
    Constant.subtitleUrls.clear();
    Constant.subtitleUrls = [];
    Constant.subtitleUrls = subtitleUrlList.entries
        .map((entry) => SubTitleModel(entry.key, entry.value))
        .toList();
    debugPrint("subtitleUrls ==========> ${Constant.subtitleUrls.length}");
  }
  /* ========= Set-up Subtitle URL END =========== */

  /* Update Required profile data before Payment START ************************/
  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: white,
                    text: "update_profile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 16,
                    fontsizeWeb: 16,
                    fontweight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: otherColor,
                    text: "update_profile_desc",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 13,
                    fontsizeWeb: 14,
                    fontweight: FontWeight.w500,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              _buildTextFormField(
                controller: nameController,
                hintText: "fullname",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              _buildTextFormField(
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              _buildTextFormField(
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      final profileEditProvider =
                          Provider.of<ProfileProvider>(context, listen: false);
                      if (!profileEditProvider.loadingUpdate) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: otherColor,
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: otherColor,
                        text: "cancel",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 16,
                        fontsizeWeb: 16,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  /* Submit */
                  Consumer<ProfileProvider>(
                    builder: (context, profileEditProvider, child) {
                      if (profileEditProvider.loadingUpdate) {
                        return Container(
                          width: 100,
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          alignment: Alignment.center,
                          child: pageLoader(),
                        );
                      }
                      return InkWell(
                        onTap: () async {
                          SharedPre sharedPref = SharedPre();
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          debugPrint(
                              "fullName =======> $fullName ; required ========> $isNameReq");
                          debugPrint(
                              "emailAddress ===> $emailAddress ; required ====> $isEmailReq");
                          debugPrint(
                              "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq");
                          if (isNameReq && fullName.isEmpty) {
                            Utils.showSnackbar(
                                context, "info", "enter_fullname", true);
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            Utils.showSnackbar(
                                context, "info", "enter_email", true);
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils.showSnackbar(
                                context, "info", "enter_mobile_number", true);
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils.showSnackbar(
                                context, "info", "enter_valid_email", true);
                          } else {
                            final profileEditProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            await profileEditProvider.setUpdateLoading(true);

                            await profileEditProvider.getUpdateDataForPayment(
                                fullName, emailAddress, mobileNumber);
                            if (!profileEditProvider.loadingUpdate) {
                              await profileEditProvider.setUpdateLoading(false);
                              if (profileEditProvider.successModel.status ==
                                  200) {
                                if (isNameReq) {
                                  await sharedPref.save('username', fullName);
                                }
                                if (isEmailReq) {
                                  await sharedPref.save(
                                      'useremail', emailAddress);
                                }
                                if (isMobileReq) {
                                  await sharedPref.save(
                                      'usermobile', mobileNumber);
                                }
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: black,
                            text: "submit",
                            textalign: TextAlign.center,
                            fontsizeNormal: 16,
                            fontsizeWeb: 16,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45, maxWidth: 500),
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        obscureText: false,
        maxLines: 1,
        readOnly: readOnly,
        cursorColor: colorAccent,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          filled: true,
          isDense: false,
          fillColor: transparentColor,
          focusedBorder: const GradientOutlineInputBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorPrimary, colorPrimary],
            ),
            width: 1,
          ),
          border: GradientOutlineInputBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorPrimary.withOpacity(0.5),
                colorPrimary.withOpacity(0.5)
              ],
            ),
            width: 1,
          ),
          label: MyText(
            multilanguage: true,
            color: white,
            text: hintText,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
            fontsizeNormal: 14,
            fontsizeWeb: 14,
            fontweight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 14,
            color: white,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
  /* *********************** Update Required profile data before Payment END */

  static void getCurrencySymbol() async {
    SharedPre sharedPref = SharedPre();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    debugPrint('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    debugPrint('Constant currency ==> ${Constant.currency}');
  }

  static saveUserCreds({
    required userID,
    required userName,
    required userEmail,
    required userMobile,
    required userImage,
    required userPremium,
    required userType,
  }) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
      await sharedPref.save("username", userName);
      await sharedPref.save("useremail", userEmail);
      await sharedPref.save("usermobile", userMobile);
      await sharedPref.save("userimage", userImage);
      await sharedPref.save("userpremium", userPremium);
      await sharedPref.save("usertype", userType);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
    }
    Constant.userID = await sharedPref.read("userid");
    debugPrint('setUserId userID ==> ${Constant.userID}');
  }

  static Future<bool> checkPremiumUser() async {
    SharedPre sharedPre = SharedPre();
    String? isPremiumBuy = await sharedPre.read("userpremium");
    debugPrint('checkPremiumUser isPremiumBuy ==> $isPremiumBuy');
    if (isPremiumBuy != null && isPremiumBuy == "1") {
      return true;
    } else {
      return false;
    }
  }

  otherPageAppBar(BuildContext context, String title, bool multilanguage) {
    return AppBar(
      backgroundColor: appBgColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 0,
      centerTitle: false,
      leading: InkWell(
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context).pop(false);
          debugPrint("Back Click");
        },
        child: Align(
            alignment: Alignment.center,
            child:
                MyImage(width: 30, height: 30, imagePath: "backwith_bg.png")),
      ),
      title: MyText(
          color: white,
          multilanguage: multilanguage,
          fontsizeWeb: 15,
          text: title,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          maxline: 1,
          fontweight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal),
    );
  }

  static void updatePremium(String isPremiumBuy) async {
    debugPrint('updatePremium isPremiumBuy ==> $isPremiumBuy');
    SharedPre sharedPre = SharedPre();
    await sharedPre.save("userpremium", isPremiumBuy);
    String? isPremium = await sharedPre.read("userpremium");
    debugPrint('updatePremium ===============> $isPremium');
  }

  static setUserId(userID) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
      await sharedPref.remove("lastClaimedTimestamp");
      await sharedPref.remove("lastClaimedDay");
      await sharedPref.remove("lastIndex");
    }
    Constant.userID = await sharedPref.read("userid");
    debugPrint('setUserId userID ==> ${Constant.userID}');
    debugPrint(
        'setUserId lastClaimedTimestamp ==> ${await sharedPref.read("lastClaimedTimestamp")}');
  }

  static setFirstTime(value) async {
    SharedPre sharedPref = SharedPre();
    await sharedPref.save("seen", value);
    String seenValue = await sharedPref.read("seen");
    debugPrint('setFirstTime seen ==> $seenValue');
  }

  static Future<String> getPrivacyTandCText(
      String privacyUrl, String termsConditionUrl) async {
    debugPrint('privacyUrl ==> $privacyUrl');
    debugPrint('T&C Url =====> $termsConditionUrl');

    String strPrivacyAndTNC =
        "<p style=color:white; > By continuing , I understand and agree with <a href=$privacyUrl>Privacy Policy</a> and <a href=$termsConditionUrl>Terms and Conditions</a> of ${Constant.appName}. </p>";

    debugPrint('strPrivacyAndTNC =====> $strPrivacyAndTNC');
    return strPrivacyAndTNC;
  }

  static Future<void> deleteCacheDir() async {
    if (Platform.isAndroid) {
      var tempDir = await getTemporaryDirectory();

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  }

  static BoxDecoration textFieldBGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: otherColor,
        width: .2,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration r4BGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: otherColor,
        width: .5,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradientBGWithCenter(
      Color colorStart, Color colorCenter, Color colorEnd, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[colorStart, colorCenter, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration r4DarkBGWithBorder() {
    return BoxDecoration(
      color: colorPrimaryDark,
      border: Border.all(
        color: colorPrimaryDark,
        width: .5,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration r10BGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: otherColor,
        width: .5,
      ),
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBGWithRadius(
      Color colorBg,
      double radiusTopLeft,
      double radiusTopRight,
      double radiusBottomLeft,
      double radiusBottomRight) {
    return BoxDecoration(
      color: colorBg,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radiusTopLeft),
        topRight: Radius.circular(radiusTopRight),
        bottomLeft: Radius.circular(radiusBottomLeft),
        bottomRight: Radius.circular(radiusBottomRight),
      ),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBGWithBorder(
      Color color, Color borderColor, double radius, double border) {
    return BoxDecoration(
      color: color,
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration primaryDarkButton() {
    return BoxDecoration(
      color: colorPrimaryDark,
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static Widget buildBackBtn(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      focusColor: gray.withOpacity(0.5),
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MyImage(
          height: 17,
          width: 17,
          imagePath: "backwith_bg.png",
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  static Widget buildBackBtnDesign(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: MyImage(
        height: 17,
        width: 17,
        imagePath: "backwith_bg.png",
        fit: BoxFit.contain,
      ),
    );
  }

  static AppBar myAppBar(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: appBgColor,
      centerTitle: true,
      title: MyText(
        color: white,
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsizeNormal: 16,
        fontsizeWeb: 18,
        maxline: 1,
        overflow: TextOverflow.ellipsis,
        fontweight: FontWeight.bold,
        textalign: TextAlign.center,
        fontstyle: FontStyle.normal,
      ),
    );
  }

  static AppBar myAppBarWithBack(BuildContext context, String appBarTitle,
      bool centerTitle, bool multilanguage) {
    return AppBar(
      elevation: 5,
      backgroundColor: appBgColor,
      centerTitle: centerTitle,
      leading: IconButton(
        // autofocus: true,
        // focusColor: white.withOpacity(0.5),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: MyImage(
          imagePath: "backwith_bg.png",
          fit: BoxFit.contain,
          height: kIsWeb ? 20 : 17,
          width: kIsWeb ? 20 : 17,
        ),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsizeNormal: 16,
        fontsizeWeb: 18,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.bold,
        textalign: TextAlign.center,
        color: white,
      ),
    );
  }

  static Widget pageLoader() {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPrimary,
      ),
    );
  }

  static void showSnackbar(BuildContext context, String showFor, String message,
      bool multilanguage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: showFor == "fail"
            ? failureBG
            : showFor == "info"
                ? infoBG
                : showFor == "success"
                    ? successBG
                    : complimentryColor,
        content: MyText(
          text: message,
          fontsizeNormal: 14,
          fontsizeWeb: 14,
          multilanguage: multilanguage,
          fontstyle: FontStyle.normal,
          fontweight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

  ProgressDialog? prDialog;
  void hideProgress(BuildContext context) async {
    prDialog = ProgressDialog(context);
    if (prDialog!.isShowing()) {
      prDialog!.hide();
    }
  }

  static void showProgress(
      BuildContext context, ProgressDialog prDialog) async {
    prDialog = ProgressDialog(context);
    //For normal dialog
    prDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);

    prDialog.style(
      message: pleaseWait,
      borderRadius: 5,
      progressWidget: kIsWeb
          ? Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width * 0.10,
              child: const CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(8),
              child: const CircularProgressIndicator(),
            ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );

    await prDialog.show();
  }

  static String convertToColonText(int timeInMilli) {
    String convTime = "";

    try {
      if (timeInMilli > 0) {
        int seconds = ((timeInMilli / 1000) % 60).toInt();
        int minutes = ((timeInMilli / (1000 * 60)) % 60).toInt();
        int hours = ((timeInMilli / (1000 * 60 * 60)) % 24).toInt();

        if (hours >= 1) {
          if (minutes > 0 && seconds > 0) {
            convTime = "$hours : $minutes : $seconds hr";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "$hours : $minutes : 00 hr";
          } else if (minutes == 0 && seconds > 0) {
            convTime = "$hours : 00 : $seconds hr";
          } else if (minutes == 0 && seconds == 0) {
            convTime = "$hours : 00 hr";
          }
        } else if (minutes > 0) {
          if (seconds > 0) {
            convTime = "$minutes : $seconds min";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "$minutes : 00 min";
          }
        } else if (seconds > 0) {
          convTime = "00 : $seconds sec";
        }
      } else {
        convTime = "0";
      }
    } catch (e) {
      debugPrint("ConvTimeE Exception ==> $e");
    }
    return convTime;
  }

  static String convertTimeToText(int timeInMilli) {
    String convTime = "";

    try {
      if (timeInMilli > 0) {
        double seconds = ((timeInMilli / 1000) % 60);
        double minutes = ((timeInMilli / (1000 * 60)) % 60);
        double hours = ((timeInMilli / (1000 * 60 * 60)) % 24);

        if (hours >= 1) {
          if (minutes > 0 && seconds > 0) {
            convTime =
                "${hours.toInt()} hr ${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr ${minutes.toInt()} min";
          } else if (minutes == 0 && seconds > 0) {
            convTime = "${hours.toInt()} hr ${seconds.toInt()} sec";
          } else if (minutes == 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr";
          }
        } else if (minutes > 0) {
          if (seconds > 0) {
            convTime = "${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${minutes.toInt()} min";
          }
        } else if (seconds > 0) {
          convTime = "${seconds.toInt()} sec";
        }
      } else {
        convTime = "0";
      }
    } catch (e) {
      debugPrint("ConvTimeE Exception ==> $e");
    }
    return convTime;
  }

  static String remainTimeInMin(int remainWatch) {
    String convTime = "";

    try {
      debugPrint("remainWatch ==> ${(remainWatch / 1000)}");
      if (remainWatch > 0) {
        double seconds = ((remainWatch / 1000) % 60);
        double minutes = ((remainWatch / (1000 * 60)) % 60);
        double hours = ((remainWatch / (1000 * 60 * 60)) % 24);

        if (hours >= 1) {
          if (minutes > 0 && seconds > 0) {
            convTime =
                "${hours.toInt()} hr ${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr ${minutes.toInt()} min";
          } else if (minutes == 0 && seconds > 0) {
            convTime = "${hours.toInt()} hr ${seconds.toInt()} sec";
          } else if (minutes == 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr";
          }
        } else if (minutes > 0) {
          if (seconds > 0) {
            convTime = "${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${minutes.toInt()} min";
          }
        } else if (seconds > 0) {
          convTime = "${seconds.toInt()} sec";
        }
      } else {
        convTime = "0";
      }
    } catch (e) {
      debugPrint("ConvTimeE Exception ==> $e");
    }
    return convTime;
  }

  static String convertInMin(int remainWatch) {
    String convTime = "";

    try {
      if (remainWatch > 0) {
        double minutes = ((remainWatch / (1000 * 60)) % 60);
        double seconds = ((remainWatch / 1000) % 60);
        if (minutes >= 0 && minutes < 1) {
          convTime = "${seconds.toInt()} sec";
        } else if (minutes >= 1 && minutes < 10) {
          convTime = "0${minutes.toInt()} min";
        } else {
          convTime = "${minutes.toInt()} min";
        }
      } else {
        convTime = "00 min";
      }
    } catch (e) {
      debugPrint("convertInMin Exception ==> $e");
    }
    return convTime;
  }

  static double getPercentage(int totalValue, int usedValue) {
    double percentage = 0.0;
    try {
      if (totalValue != 0) {
        percentage = ((usedValue / totalValue).clamp(0.0, 1.0) * 100);
      } else {
        percentage = 0.0;
      }
    } catch (e) {
      debugPrint("getPercentage Exception ==> $e");
      percentage = 0.0;
    }
    percentage = (percentage.round() / 100);
    return percentage;
  }

  //Convert Html to simple String
  static String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  static Future<String> getFileUrl(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  }

  static Future<File?> saveImageInStorage(imgUrl) async {
    try {
      var response = await http.get(Uri.parse(imgUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(path.join(documentDirectory?.path ?? "",
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png'));
      file.writeAsBytesSync(response.bodyBytes);
      // This is a sync operation on a real
      // app you'd probably prefer to use writeAsByte and handle its Future
      return file;
    } catch (e) {
      debugPrint("saveImageInStorage Exception ===> $e");
      return null;
    }
  }

  static Html htmlTexts(var strText) {
    return Html(
      data: strText,
      style: {
        "body": Style(
          color: otherColor,
          fontSize: FontSize(15),
          fontWeight: FontWeight.w400,
        ),
        "link": Style(
          color: red,
          fontSize: FontSize(15),
          fontWeight: FontWeight.w400,
        ),
      },
      onLinkTap: (url, _, ___) async {
        if (await canLaunchUrl(Uri.parse(url!))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.platformDefault,
          );
        } else {
          throw 'Could not launch $url';
        }
      },
      shrinkWrap: false,
    );
  }

  static Future<void> shareVideo(context, videoTitle) async {
    try {
      String? shareMessage, shareDesc;
      shareDesc =
          "Hey I'm watching $videoTitle . Check it out now on ${Constant.appName}! and more.";
      if (Platform.isAndroid) {
        shareMessage = "$shareDesc\n${Constant.androidAppUrl}";
      } else {
        shareMessage = "$shareDesc\n${Constant.iosAppUrl}";
      }
      await FlutterShare.share(
        title: Constant.appName,
        linkUrl: shareMessage,
      );
    } catch (e) {
      debugPrint("shareFile Exception ===> $e");
      return;
    }
  }

  static Future<void> redirectToUrl(String url) async {
    debugPrint("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> redirectToStore() async {
    final appId =
        Platform.isAndroid ? Constant.appPackageName : Constant.appleAppId;
    final url = Uri.parse(
      Platform.isAndroid
          ? "market://details?id=$appId"
          : "https://apps.apple.com/app/id$appId",
    );
    debugPrint("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> shareApp(shareMessage) async {
    try {
      await FlutterShare.share(
        title: Constant.appName,
        linkUrl: shareMessage,
      );
    } catch (e) {
      debugPrint("shareFile Exception ===> $e");
      return;
    }
  }

  /* ***************** generate Unique OrderID START ***************** */
  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    debugPrint("fixFourDigit =>>> ${Constant.fixFourDigit}");
    debugPrint("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    debugPrint("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    debugPrint("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    debugPrint("getRandomNumber =>>> $getRandomNumber");

    finalOID = "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    debugPrint("finalOID =>>> $finalOID");

    return finalOID;
  }
  /* ***************** generate Unique OrderID END ***************** */

  /* ***************** Download ***************** */
  static Future<bool> checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status == PermissionStatus.granted) {
        return true;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      // final result = await Permission.storage.request();
      debugPrint("result ========1========> ${statuses[Permission.storage]}");
      if (statuses[Permission.storage] != PermissionStatus.granted) {
        statuses = await [Permission.storage].request();
        debugPrint("result =======2=======> ${statuses[Permission.storage]}");
      }
      return (statuses[Permission.storage] == PermissionStatus.granted);
    }

    throw StateError('unknown platform');
  }

  static Future<String> prepareSaveDir() async {
    String localPath = (await _getSavedDir())!;
    debugPrint("localPath ------------> $localPath");
    final savedDir = Directory(localPath);
    debugPrint("savedDir -------------> $savedDir");
    debugPrint("is exists ? ----------> ${savedDir.existsSync()}");
    if (!(await savedDir.exists())) {
      await savedDir.create(recursive: true);
    }
    return localPath;
  }

  static Future<String?> _getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      try {
        externalStorageDirPath = "${directory?.absolute.path}/downloads/";
      } catch (err, st) {
        debugPrint('failed to get downloads path: $err, $st');
        externalStorageDirPath = "${directory?.absolute.path}/downloads/";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    debugPrint("externalStorageDirPath ------------> $externalStorageDirPath");
    return externalStorageDirPath;
  }

  static Future<String> prepareShowSaveDir(
      String showName, String seasonName) async {
    debugPrint("showName -------------> $showName");
    debugPrint("seasonName -------------> $seasonName");
    String localPath = (await _getShowSavedDir(showName, seasonName))!;
    final savedDir = Directory(localPath);
    debugPrint("savedDir -------------> $savedDir");
    debugPrint("savedDir path --------> ${savedDir.path}");
    if (!savedDir.existsSync()) {
      await savedDir.create(recursive: true);
    }
    return localPath;
  }

  static Future<String?> _getShowSavedDir(
      String showName, String seasonName) async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath =
            "${directory?.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
      } catch (err, st) {
        debugPrint('failed to get downloads path: $err, $st');
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath =
            "${directory?.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          "${(await getApplicationDocumentsDirectory()).absolute.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
    }
    return externalStorageDirPath;
  }
}

import 'package:dtpocketfm/pages/aboutprivacyterms.dart';
import 'package:dtpocketfm/pages/loginsocial.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/pages/mywatchlist.dart';
import 'package:dtpocketfm/pages/profileedit.dart';
import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/sectiondataprovider.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mynetworkimg.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => SettingState();
}

class SettingState extends State<Setting> {
  bool? isSwitched;
  String? userName, userType, userMobileNo;
  late GeneralProvider generalProvider;
  late ProfileProvider profileProvider;
  SharedPre sharedPref = SharedPre();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    getUserData();
    super.initState();
  }

  toggleSwitch(bool value) async {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
    debugPrint('toggleSwitch isSwitched ==> $isSwitched');
    if (!kIsWeb) {
      if ((isSwitched ?? false)) {
        OneSignal.User.pushSubscription.optIn();
      } else {
        OneSignal.User.pushSubscription.optOut();
      }
      await sharedPref.saveBool("PUSH", isSwitched);
    }
  }

  getUserData() async {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.getProfile(context);
    userName = await sharedPref.read("username");
    userType = await sharedPref.read("usertype");
    userMobileNo = await sharedPref.read("usermobile");

    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userType ==> $userType');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    await generalProvider.getPages();

    isSwitched = await sharedPref.readBool("PUSH");
    debugPrint('getUserData isSwitched ==> $isSwitched');
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appBgColor,
        appBar: Utils.myAppBarWithBack(context, "setting", true, true),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(22),
              child: Column(
                children: [
                  getMyProfile(),
                  _buildLine(2, 5),
                  /* Account Details */
                  // _buildSettingButton(
                  //   title: 'accountdetails',
                  //   subTitle: 'manageprofile',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () {
                  //     AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                  //         () async {
                  //       if (Constant.userID != null) {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const ProfileEdit(),
                  //           ),
                  //         );
                  //       } else {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const LoginSocial(),
                  //           ),
                  //         );
                  //       }
                  //     });
                  //   },
                  //   imagePath: 'ic_notification.png',
                  // ),
                  // _buildLine(16.0, 16.0),

                  // /* Active TV */
                  // _buildSettingButton(
                  //   title: 'activetv',
                  //   subTitle: 'activetv_desc',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () {
                  //     AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                  //         () async {
                  //       if (Constant.userID != null) {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const ActiveTV(),
                  //           ),
                  //         );
                  //       } else {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const LoginSocial(),
                  //           ),
                  //         );
                  //       }
                  //     });
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  /* Watchlist */
                  _buildSettingButton(
                    title: 'watchlist',
                    subTitle: 'view_your_watchlist',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    onClick: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () async {
                        if (Constant.userID != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MyWatchlist(),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginSocial(
                                ishome: false,
                              ),
                            ),
                          );
                        }
                      });
                    },
                    imagePath: 'watchlist.png',
                    type: 1,
                  ),
                  // _buildLine(16.0, 16.0),

                  // /* Purchases */
                  // _buildSettingButton(
                  //   title: 'purchases',
                  //   subTitle: 'view_your_purchases',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () {
                  //     AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                  //         () async {
                  //       if (Constant.userID != null) {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const MyPurchaselist(),
                  //           ),
                  //         );
                  //       } else {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const LoginSocial(),
                  //           ),
                  //         );
                  //       }
                  //     });
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  // /* Downloads */
                  // _buildSettingButton(
                  //   title: 'downloads',
                  //   subTitle: 'view_your_downloads',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () {
                  //     AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                  //         () async {
                  //       if (Constant.userID != null) {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const MyDownloads(),
                  //           ),
                  //         );
                  //       } else {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const LoginSocial(),
                  //           ),
                  //         );
                  //       }
                  //     });
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  // /* Subscription */
                  // _buildSettingButton(
                  //   title: 'subsciption',
                  //   subTitle: 'subsciptionnotes',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () {
                  //     AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                  //         () async {
                  //       if (Constant.userID != null) {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const Subscription(),
                  //           ),
                  //         );
                  //       } else {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const LoginSocial(),
                  //           ),
                  //         );
                  //       }
                  //     });
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  // /* Transactions */
                  // _buildSettingButton(
                  //   title: 'transactions',
                  //   subTitle: 'transactions_notes',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () {
                  //     AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                  //         () async {
                  //       if (Constant.userID != null) {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const SubscriptionHistory(),
                  //           ),
                  //         );
                  //       } else {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const LoginSocial(),
                  //           ),
                  //         );
                  //       }
                  //     });
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  /* MaltiLanguage */
                  _buildSettingButton(
                    title: 'change_language',
                    subTitle: 'change_language_desc',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    onClick: () {
                      _languageChangeDialog();
                    },
                    imagePath: 'ic_changeLanguage.png',
                    type: 1,
                  ),
                  // _buildLine(16.0, 16.0),

                  /* Push Notification enable/disable */
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Expanded(
                  //       child: _buildSettingButton(
                  //         title: 'notification',
                  //         subTitle: 'recivepushnotification',
                  //         titleMultilang: true,
                  //         subTitleMultilang: true,
                  //         onClick: () {
                  //           toggleSwitch(!(isSwitched ?? false));
                  //         },
                  //       ),
                  //     ),
                  //     Switch(
                  //       activeColor: primaryDark,
                  //       activeTrackColor: primaryLight,
                  //       inactiveTrackColor: gray,
                  //       value: isSwitched ?? true,
                  //       onChanged: toggleSwitch,
                  //     ),
                  //   ],
                  // ),
                  // _buildLine(16.0, 16.0),

                  /* Clear Cache */
                  // if (!Platform.isIOS)
                  //   Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Expanded(
                  //         child: _buildSettingButton(
                  //           title: 'clearcatch',
                  //           subTitle: 'clearlocallycatch',
                  //           titleMultilang: true,
                  //           subTitleMultilang: true,
                  //           onClick: () async {
                  //             if (!(kIsWeb) || !(Constant.isTV)) {
                  //               Utils.deleteCacheDir();
                  //             }
                  //             if (!context.mounted) return;
                  //             Utils.showSnackbar(
                  //                 context, "success", "cacheclearmsg", true);
                  //           },
                  //         ),
                  //       ),
                  //       MyImage(
                  //         width: 28,
                  //         height: 28,
                  //         imagePath: "ic_clear.png",
                  //         color: colorPrimary,
                  //       ),
                  //     ],
                  //   ),
                  // if (!Platform.isIOS) _buildLine(16.0, 16.0),

                  /* SignIn / SignOut */
                  _buildSettingButton(
                    type: 1,
                    title: Constant.userID == null
                        ? youAreNotSignIn
                        : (userType == "3" && (userName ?? "").isEmpty)
                            ? ("$signedInAs ${userMobileNo ?? ""}")
                            : ("$signedInAs ${userName ?? ""}"),
                    subTitle: Constant.userID == null ? "sign_in" : "sign_out",
                    titleMultilang: false,
                    subTitleMultilang: true,
                    onClick: () async {
                      if (Constant.userID != null) {
                        audioPlayer.pause();
                        logoutConfirmDialog();
                      } else {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginSocial(
                              ishome: false,
                            ),
                          ),
                        );
                        setState(() {});
                      }
                    },
                    imagePath: 'ic_login.png',
                  ),

                  // _buildLine(16.0, 16.0),

                  // /* Rate App */
                  // _buildSettingButton(
                  //   title: 'rateus',
                  //   subTitle: 'rateourapp',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () async {
                  //     debugPrint("Clicked on rateApp");
                  //     await Utils.redirectToStore();
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  // /* Share App */
                  // _buildSettingButton(
                  //   title: 'shareapp',
                  //   subTitle: 'sharewithfriends',
                  //   titleMultilang: true,
                  //   subTitleMultilang: true,
                  //   onClick: () async {
                  //     await Utils.shareApp(Platform.isIOS
                  //         ? Constant.iosAppShareUrlDesc
                  //         : Constant.androidAppShareUrlDesc);
                  //   },
                  // ),
                  // _buildLine(16.0, 16.0),

                  /* Delete Account */
                  if (Constant.userID != null)
                    _buildSettingButton(
                      type: 1,
                      title: 'delete_account',
                      subTitle: 'delete_account_desc',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () async {
                        if (Constant.userID != null) {
                          audioPlayer.pause();
                          deleteConfirmDialog();
                        } else {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginSocial(
                                ishome: false,
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      },
                      imagePath: 'ic_delete.png',
                    ),
                  // if (Constant.userID != null) _buildLine(16.0, 16.0),

                  /* Pages */
                  _buildPages(),
                ],
              ),
            ),
          ),
        ),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget getMyProfile() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.loading) {
          return Container();
          // return ShimmerUtils.buildFindShimmer(context);
        } else {
          if (profileProvider.profileModel.status == 200) {
            if (profileProvider.profileModel.result != null &&
                (profileProvider.profileModel.result?.length ?? 0) > 0) {
              return Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                height: 60,
                padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                        imageUrl: profileProvider.profileModel.result?[0].image
                                .toString() ??
                            "",
                        fit: BoxFit.fill,
                        imgHeight: 50,
                        imgWidth: 50,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MyText(
                            maxline: 1,
                            color: white,
                            text: profileProvider
                                    .profileModel.result?[0].userName
                                    .toString() ??
                                "",
                            fontsizeNormal: 16,
                            fontweight: FontWeight.w500,
                            fontsizeWeb: 15,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () {
                              AdHelper.showFullscreenAd(
                                  context, Constant.rewardAdType, () async {
                                if (Constant.userID != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileEdit(),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginSocial(
                                        ishome: false,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                            child: MyText(
                              multilanguage: true,
                              color: red,
                              text: "taptoedit",
                              fontsizeNormal: 14,
                              fontsizeWeb: 15,
                              fontweight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _buildPages() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          itemCount: (generalProvider.pagesModel.result?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return Column(
              children: [
                _buildSettingButton(
                  type: 2,
                  title:
                      generalProvider.pagesModel.result?[position].title ?? '',
                  subTitle:
                      generalProvider.pagesModel.result?[position].pageName ??
                          '',
                  titleMultilang: false,
                  subTitleMultilang: false,
                  onClick: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AboutPrivacyTerms(
                          appBarTitle: generalProvider
                                  .pagesModel.result?[position].pageName ??
                              '',
                          loadURL: generalProvider
                                  .pagesModel.result?[position].url ??
                              '',
                        ),
                      ),
                    );
                  },
                  imagePath:
                      generalProvider.pagesModel.result?[position].icon ?? '',
                ),
                // _buildLine(16.0, 0.0),
              ],
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildSettingButton(
      {required String title,
      required String subTitle,
      required bool titleMultilang,
      required bool subTitleMultilang,
      required String imagePath,
      required Function() onClick,
      required int type}) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onClick,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          minHeight: Dimens.minHeightSettings,
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            type == 2
                ? MyNetworkImage(
                    imageUrl: imagePath,
                    imgHeight: 20,
                    imgWidth: 20,
                    fit: BoxFit.fill,
                  )
                : MyImage(
                    color: white,
                    imagePath: imagePath,
                    height: 20,
                    width: 20,
                  ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: MyText(
                color: white,
                text: title,
                fontsizeNormal: 15,
                fontsizeWeb: 15,
                maxline: 1,
                multilanguage: titleMultilang,
                overflow: TextOverflow.ellipsis,
                fontweight: FontWeight.w400,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(double topMargin, double bottomMargin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.5,
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
      color: otherColor,
    );
  }

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparentColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: lightBlack,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: "changelanguage",
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeWeb: 15,
                                fontsizeNormal: 16,
                                fontweight: FontWeight.bold,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 3),
                              MyText(
                                color: white,
                                text: "selectyourlanguage",
                                fontsizeWeb: 12,
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeNormal: 12,
                                fontweight: FontWeight.w500,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              )
                            ],
                          ),
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Afrikaans */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Afrikaans",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('af');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Arabic */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Arabic",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('ar');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* German */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "German",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('de');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Gujarati */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Gujarati",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('gu');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Hindi */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Hindi",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('hi');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Indonesian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Indonesian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('id');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Dutch */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Dutch",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('nl');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Portuguese (Brazil) */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Portuguese (Brazil)",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('pt');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Albanian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Albanian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('sq');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Turkish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Turkish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('tr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Vietnamese */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Vietnamese",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('vi');
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryLight,
            width: .5,
          ),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          fontsizeWeb: 15,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  logoutConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: lightBlack,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirmsognout",
                          fontsizeWeb: 15,
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "areyousurewanrtosignout",
                          fontsizeWeb: 12,
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'sign_out',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false);
                            final sectionDataProvider =
                                Provider.of<SectionDataProvider>(context,
                                    listen: false);
                            final logoutptovider = Provider.of<GeneralProvider>(
                                context,
                                listen: false);
                            await logoutptovider.getsignout();
                            await homeProvider.setSelectedTab(0);
                            await sectionDataProvider.clearProvider();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            // sectionDataProvider.getSectionBanner("0", "1");
                            sectionDataProvider.getSectionList("0", "1", 1);
                            if (!context.mounted) return;
                            Utils.loadAds(context);
                            getUserData();
                            Navigator.pop(context);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(
                                  ishome: false,
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
          ],
        );
      },
    ).then((value) {
      if (!context.mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  deleteConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: lightBlack,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirm_delete_account",
                          fontsizeWeb: 15,
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "delete_account_msg",
                          multilanguage: true,
                          fontsizeWeb: 12,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'delete',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false);
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            final sectionDataProvider =
                                Provider.of<SectionDataProvider>(context,
                                    listen: false);
                            await homeProvider.setSelectedTab(0);
                            await sectionDataProvider.clearProvider();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            // sectionDataProvider.getSectionBanner("0", "1");
                            sectionDataProvider.getSectionList("0", "1", 1);
                            if (!context.mounted) return;
                            Utils.loadAds(context);
                            getUserData();
                            Navigator.pop(context);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(
                                  ishome: false,
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
          ],
        );
      },
    ).then((value) {
      if (!context.mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: Utils.setBGWithBorder(
            isPositive ? primaryLight : transparentColor,
            isPositive ? transparentColor : otherColor,
            5,
            0.5),
        child: MyText(
          color: isPositive ? black : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeWeb: 15,
          fontsizeNormal: 16,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }
}

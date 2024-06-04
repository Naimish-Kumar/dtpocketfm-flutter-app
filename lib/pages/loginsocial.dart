import 'dart:convert';

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dtpocketfm/pages/bottombar.dart';
import 'package:dtpocketfm/pages/otpverify.dart';
import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/sectiondataprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class LoginSocial extends StatefulWidget {
  final bool? ishome;
  const LoginSocial({super.key,required this.ishome});

  @override
  State<LoginSocial> createState() => LoginSocialState();
}

class LoginSocialState extends State<LoginSocial> {
  late ProgressDialog prDialog;
  late GeneralProvider generalProvider;

  final numberController = TextEditingController();
  String? mobileNumber,
      email,
      userName,
      strType,
      strDeviceType,
      strDeviceToken,
      strPrivacyAndTNC;
  File? mProfileImg;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail = "";

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    prDialog = ProgressDialog(context);
    _getDeviceToken();
    _getData();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        // final status = await OneSignal.shared.getDeviceState();
        // strDeviceToken = status?.userId;
      }
    } catch (e) {
      debugPrint("_getDeviceToken Exception ===> $e");
    }
    debugPrint("===>strDeviceToken $strDeviceToken");
    debugPrint("===>strDeviceType $strDeviceType");
  }

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (generalProvider.pagesModel.result?.length ?? 0);
              i++) {
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("privacy")) {
              privacyUrl = generalProvider.pagesModel.result?[i].url;
            }
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl = generalProvider.pagesModel.result?[i].url;
            }
          }
        }
      }
    }
    debugPrint('privacyUrl ==> $privacyUrl');
    debugPrint('termsConditionUrl ==> $termsConditionUrl');

    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
        privacyUrl ?? "", termsConditionUrl ?? "");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/otpbg.png"))),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Stack(children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    stops: const [0.1, 0.2, 0.6],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      appBgColor.withOpacity(0.8),
                      appBgColor.withOpacity(0.8),
                      appBgColor
                    ]),
              ),
            ),
             Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: Container(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: InkWell(
                    focusColor: white.withOpacity(0.40),
                    onTap: () {
                      if (widget.ishome == true) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Bottombar()),
                          (Route route) => false,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "backwith_bg.png",
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   width: 170,
                  //   height: 60,
                  //   alignment: Alignment.centerLeft,
                  //   child: MyImage(
                  //     fit: BoxFit.fill,
                  //     imagePath: "appicon.png",
                  //   ),
                  // ),
                  const SizedBox(height: 25),
                  MyText(
                    color: white,
                    text: "welcomeback",
                    fontsizeNormal: 20,
                    fontsizeWeb: 25,
                    multilanguage: true,
                    fontweight: FontWeight.bold,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 7),
                  MyText(
                    color: white,
                    text: "login_note",
                    fontsizeNormal: 14,
                    fontsizeWeb: 15,
                    multilanguage: true,
                    fontweight: FontWeight.w500,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 30),

                  /* Enter Mobile Number */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: white,
                        width: 0.7,
                      ),
                      color: transparentColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(11),
                      ),
                    ),
                    child: IntlPhoneField(
                      disableLengthCheck: true,
                      textAlignVertical: TextAlignVertical.center,
                      autovalidateMode: AutovalidateMode.disabled,
                      controller: numberController,
                      style: const TextStyle(fontSize: 16, color: white),
                      showCountryFlag: false,
                      showDropdownIcon: false,
                      initialCountryCode: 'IN',
                      dropdownTextStyle: GoogleFonts.inter(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        hintStyle: GoogleFonts.inter(
                          color: otherColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: enterYourMobileNumber,
                      ),
                      onChanged: (phone) {
                        debugPrint('===> ${phone.completeNumber}');
                        debugPrint('===> ${numberController.text}');
                        mobileNumber = phone.completeNumber;
                        debugPrint('===>mobileNumber $mobileNumber');
                      },
                      onCountryChanged: (country) {
                        debugPrint('===> ${country.name}');
                        debugPrint('===> ${country.code}');
                      },
                    ),
                  ),
                  const SizedBox(height: 25),

                  /* Login Button */
                  InkWell(
                    onTap: () {
                      debugPrint("Click mobileNumber ==> $mobileNumber");
                      if (numberController.text.toString().isEmpty) {
                        Utils.showSnackbar(
                            context, "info", "login_with_mobile_note", true);
                      } else {
                        // prDialog.hide();
                        debugPrint("mobileNumber ==> $mobileNumber");
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OTPVerify(mobileNumber ?? ""),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            primaryDark,
                            colorPrimary,
                          ],
                          begin: FractionalOffset(0.0, 0.0),
                          end: FractionalOffset(1.0, 0.2),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: MyText(
                        color: white,
                        text: "login",
                        multilanguage: true,
                        fontsizeNormal: 17,
                        fontsizeWeb: 19,
                        fontweight: FontWeight.w700,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /* Privacy & TermsCondition link */
                  if (strPrivacyAndTNC != null)
                    Utils.htmlTexts(strPrivacyAndTNC),
                  const SizedBox(height: 10),

                  /* Or */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 1,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              white.withOpacity(0.6),
                              colorPrimaryDark.withOpacity(1),
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                        color: otherColor,
                        text: "or",
                        multilanguage: true,
                        fontsizeNormal: 14,
                        fontsizeWeb: 16,
                        fontweight: FontWeight.w500,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 80,
                        height: 1,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              white.withOpacity(0.6),
                              colorPrimaryDark.withOpacity(1),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  /* Google Login Button */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 52,
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        color: gmailLogincolor,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(width: 1, color: white)),
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        debugPrint("Clicked on : ====> loginWith Google");
                        _gmailLogin();
                      },
                      borderRadius: BorderRadius.circular(26),
                      child: Row(
                        children: [
                          MyImage(
                            width: 30,
                            height: 30,
                            imagePath: "ic_google.png",
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 15),
                          MyText(
                            color: white,
                            text: "loginwithgoogle",
                            fontsizeNormal: 14,
                            fontsizeWeb: 16,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  /* Apple Login Button */
                  if (Platform.isIOS)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                          color: gmailLogincolor,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(width: 1, color: white)),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          debugPrint("Clicked on : ====> loginWith Apple");
                          signInWithApple();
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Row(
                          children: [
                            MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "ic_apple.png",
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 15),
                            MyText(
                              color: black,
                              text: "loginwithapple",
                              fontsizeNormal: 14,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                    ),
                    

                  /* Facebook Login Button */
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 52,
                  //   padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  //   decoration: BoxDecoration(
                  //     color: white,
                  //     borderRadius: BorderRadius.circular(26),
                  //   ),
                  //   alignment: Alignment.center,
                  //   child: InkWell(
                  //     onTap: () {
                  //       debugPrint("Clicked on : ====> loginWith Facebook");
                  //       facebookLogin();
                  //     },
                  //     borderRadius: BorderRadius.circular(26),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         MyImage(
                  //           width: 30,
                  //           height: 30,
                  //           imagePath: "ic_facebook.png",
                  //           fit: BoxFit.contain,
                  //         ),
                  //         const SizedBox(width: 30),
                  //         MyText(
                  //           color: black,
                  //           text: "loginwithfacebook",
                  //           fontsizeNormal: 14,
                  //           fontsizeWeb: 16,
                  //           multilanguage: true,
                  //           fontweight: FontWeight.w600,
                  //           maxline: 1,
                  //           overflow: TextOverflow.ellipsis,
                  //           textalign: TextAlign.center,
                  //           fontstyle: FontStyle.normal,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /* Google Login */
  Future<void> _gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    debugPrint('GoogleSignIn ===> id : ${user.id}');
    debugPrint('GoogleSignIn ===> email : ${user.email}');
    debugPrint('GoogleSignIn ===> displayName : ${user.displayName}');
    debugPrint('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    if (!mounted) return;
    Utils.showProgress(context, prDialog);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      debugPrint("User Name: ${userCredential.user?.displayName}");
      debugPrint("User Email ${userCredential.user?.email}");
      debugPrint("User photoUrl ${userCredential.user?.photoURL}");
      debugPrint("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      debugPrint('firebasedid :===> $firebasedid');

      /* Save PhotoUrl in File */
      mProfileImg =
          await Utils.saveImageInStorage(userCredential.user?.photoURL ?? "");
      debugPrint('mProfileImg :===> $mProfileImg');

      checkAndNavigate(user.email, user.displayName ?? "", "2");
    } on FirebaseAuthException catch (e) {
      debugPrint('===>Exp${e.code.toString()}');
      debugPrint('===>Exp${e.message.toString()}');
      if (e.code.toString() == "user-not-found") {
      } else if (e.code == 'wrong-password') {
        // Hide Progress Dialog
        await prDialog.hide();
        debugPrint('Wrong password provided.');
        Utils.showToast('Wrong password provided.');
      } else {
        // Hide Progress Dialog
        await prDialog.hide();
      }
    }
  }

  /* Apple Login */
  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await _auth.signInWithCredential(oauthCredential);

      String? displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      userEmail = authResult.user?.email.toString() ?? "";
      debugPrint("===>userEmail $userEmail");
      debugPrint("===>displayName $displayName");

      final firebaseUser = authResult.user;

      dynamic firebasedId;
      if (userEmail.isNotEmpty || userEmail != 'null') {
        await firebaseUser?.updateDisplayName(displayName);
        await firebaseUser
            ?.updateEmail(authResult.user?.email.toString() ?? "");
      } else {
        userEmail = firebaseUser?.email.toString() ?? "";
        firebasedId = firebaseUser?.uid.toString();
        displayName = firebaseUser?.displayName.toString();
        debugPrint("===>userEmail-else $userEmail");
        debugPrint("===>displayName-else $displayName");
      }

      debugPrint("userEmail =====FINAL==> $userEmail");
      debugPrint("firebasedId ===FINAL==> $firebasedId");
      debugPrint("displayName ===FINAL==> $displayName");

      checkAndNavigate(userEmail, displayName ?? "", "3");
    } catch (exception) {
      debugPrint("Apple Login exception =====> $exception");
    }
    return null;
  }

  checkAndNavigate(String mail, String displayName, String type) async {
    email = mail;
    userName = displayName;
    strType = type;
    debugPrint('checkAndNavigate email ==>> $email');
    debugPrint('checkAndNavigate userName ==>> $userName');
    debugPrint('checkAndNavigate strType ==>> $strType');
    debugPrint('checkAndNavigate mProfileImg :===> $mProfileImg');
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await generalProvider.loginWithSocial(
        email, userName,type,  strDeviceType, mProfileImg);
    debugPrint('checkAndNavigate loading ==>> ${generalProvider.loading}');

    if (!generalProvider.loading) {
      if (generalProvider.loginSocialModel.status == 200) {
        debugPrint('Login Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.loginSocialModel.result?[0].id.toString(),
          userName: generalProvider.loginSocialModel.result?[0].name.toString(),
          userEmail:
              generalProvider.loginSocialModel.result?[0].email.toString(),
          userMobile:
              generalProvider.loginSocialModel.result?[0].mobile.toString(),
          userImage:
              generalProvider.loginSocialModel.result?[0].image.toString(),
          userPremium:
              generalProvider.loginSocialModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginSocialModel.result?[0].type.toString(),
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginSocialModel.result?[0].id.toString();
        debugPrint('Constant userID ==>> ${Constant.userID}');

        await homeProvider.setSelectedTab(0);
        // await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", 1);

        // Hide Progress Dialog
        await prDialog.hide();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Hide Progress Dialog
        await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(context, "fail",
            "${generalProvider.loginSocialModel.message}", false);
      }
    }
  }
}

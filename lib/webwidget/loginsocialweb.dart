import 'dart:io';

import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/sectiondataprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class LoginSocialWeb extends StatefulWidget {
  const LoginSocialWeb({super.key});

  @override
  State<LoginSocialWeb> createState() => _LoginSocialWebState();
}

class _LoginSocialWebState extends State<LoginSocialWeb> {
  SharedPre sharedPref = SharedPre();
  final numberController = TextEditingController();
  String? mobileNumber, email, userName, strType;
  File? mProfileImg;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      constraints: const BoxConstraints(
        minWidth: 300,
        minHeight: 0,
        maxWidth: 450,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 30,
                  alignment: Alignment.centerLeft,
                  child: MyImage(
                    fit: BoxFit.contain,
                    imagePath: "appicon.png",
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  focusColor: white.withOpacity(0.5),
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: MyImage(
                      fit: BoxFit.contain,
                      imagePath: "ic_close.png",
                      color: otherColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            MyText(
              color: white,
              text: "welcomeback",
              fontsizeNormal: 16,
              fontsizeWeb: 18,
              multilanguage: true,
              fontweight: FontWeight.bold,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 7),
            MyText(
              color: otherColor,
              text: "login_with_mobile_note",
              fontsizeNormal: 13,
              fontsizeWeb: 14,
              multilanguage: true,
              fontweight: FontWeight.w500,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 20),

            /* Enter Mobile Number */
            Container(
              width: MediaQuery.of(context).size.width,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary,
                  width: 0.7,
                ),
                color: edtBG,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: IntlPhoneField(
                disableLengthCheck: true,
                controller: numberController,
                textAlignVertical: TextAlignVertical.center,
                autovalidateMode: AutovalidateMode.disabled,
                style: const TextStyle(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                showCountryFlag: false,
                showDropdownIcon: false,
                initialCountryCode: 'IN',
                dropdownTextStyle: GoogleFonts.montserrat(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.montserrat(
                    color: otherColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: enterYourMobileNumber,
                ),
                onChanged: (phone) {
                  debugPrint('===> ${phone.completeNumber}');
                  mobileNumber = phone.completeNumber;
                  debugPrint('===>mobileNumber $mobileNumber');
                },
                onCountryChanged: (country) {
                  debugPrint('===> ${country.name}');
                  debugPrint('===> ${country.code}');
                },
              ),
            ),
            const SizedBox(height: 30),

            /* Login Button */
            InkWell(
              onTap: () {
                debugPrint("Click mobileNumber ==> $mobileNumber");
                if (numberController.text.toString().isEmpty) {
                  Utils.showSnackbar(
                      context, "info", "login_with_mobile_note", true);
                } else {
                  debugPrint("mobileNumber ==> $mobileNumber");
                  Utils.buildWebAlertDialog(context, "otp", mobileNumber);
                }
              },
              focusColor: white,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        primaryLight,
                        primaryDark,
                      ],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: MyText(
                    color: white,
                    text: "login",
                    multilanguage: true,
                    fontsizeNormal: 15,
                    fontsizeWeb: 14,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 1,
                  color: colorAccent,
                ),
                const SizedBox(width: 15),
                MyText(
                  color: otherColor,
                  text: "or",
                  multilanguage: true,
                  fontsizeNormal: 14,
                  fontsizeWeb: 14,
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
                  color: colorAccent,
                ),
              ],
            ),
            const SizedBox(height: 25),

            /* Google Login Button */
            InkWell(
              onTap: () {
                debugPrint("Clicked on : ====> loginWith Google");
                _gmailLogin();
              },
              focusColor: colorPrimary,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyImage(
                        width: 20,
                        height: 20,
                        imagePath: "ic_google.png",
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 25),
                      Flexible(
                        child: MyText(
                          color: black,
                          text: "loginwithgoogle",
                          fontsizeNormal: 14,
                          fontsizeWeb: 12,
                          multilanguage: true,
                          fontweight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* Google(Gmail) Login */
  Future<void> _gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn().onError(
        (error, stackTrace) async => await GoogleSignIn().signInSilently());
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    debugPrint('GoogleSignIn ===> id : ${user.id}');
    debugPrint('GoogleSignIn ===> email : ${user.email}');
    debugPrint('GoogleSignIn ===> displayName : ${user.displayName}');
    debugPrint('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

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
        // registerFirebaseUser(user.email, user.displayName ?? "", "2");
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
        Utils.showToast('Wrong password provided.');
      } else {}
    }
  }

  void checkAndNavigate(String mail, String displayName, String type) async {
    email = mail;
    userName = displayName;
    strType = type;
    debugPrint('checkAndNavigate email ==>> $email');
    debugPrint('checkAndNavigate userName ==>> $userName');
    debugPrint('checkAndNavigate strType ==>> $strType');
    debugPrint('checkAndNavigate mProfileImg :===> $mProfileImg');
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await generalProvider.loginWithSocial(
        email, userName, type, type, mProfileImg);
    debugPrint('checkAndNavigate loading ==>> ${generalProvider.loading}');

    if (!generalProvider.loading) {
      if (generalProvider.loginSocialModel.status == 200) {
        debugPrint('Login Successfull!');
        await sharedPref.save("userid",
            generalProvider.loginSocialModel.result?[0].id.toString());
        await sharedPref.save("username",
            generalProvider.loginSocialModel.result?[0].name.toString() ?? "");
        await sharedPref.save("userimage",
            generalProvider.loginSocialModel.result?[0].image.toString() ?? "");
        await sharedPref.save("useremail",
            generalProvider.loginSocialModel.result?[0].email.toString() ?? "");
        await sharedPref.save(
            "usermobile",
            generalProvider.loginSocialModel.result?[0].mobile.toString() ??
                "");
        await sharedPref.save("usertype",
            generalProvider.loginSocialModel.result?[0].type.toString() ?? "");

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginSocialModel.result?[0].id.toString();
        debugPrint('Constant userID ==>> ${Constant.userID}');

        if (!mounted) return;
        Navigator.pop(context);

        await homeProvider.homeNotifyProvider();
        // await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", 1);
      } else {
        // Hide Progress Dialog
        if (!mounted) return;
        Utils.showSnackbar(context, "fail",
            "${generalProvider.loginSocialModel.message}", false);
      }
    }
  }
}

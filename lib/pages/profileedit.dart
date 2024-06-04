import 'dart:io';

import 'package:dtpocketfm/pages/profileavatar.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/myusernetworkimg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/mytextformfield.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => ProfileEditState();
}

class ProfileEditState extends State<ProfileEdit> {
  late ProgressDialog prDialog;
  SharedPre sharePref = SharedPre();
  final ImagePicker imagePicker = ImagePicker();
  late ProfileProvider profileProvider;
  File? pickedImageFile;
  bool? isSwitched;
  String? userId, userName;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final mobilenumberController = TextEditingController();

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    getUserData();

    super.initState();
  }

  void getUserData() async {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.getProfile(context);
    profileData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobilenumberController.dispose();
    bioController.dispose();
    super.dispose();
  }

  profileData() {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (!profileProvider.loading) {
      if (profileProvider.profileModel.status == 200) {
        if (profileProvider.profileModel.result != null) {
          debugPrint(
              "User Name ==> ${(profileProvider.profileModel.result?[0].name ?? "")}");
          debugPrint(
              "User ID ==> ${(profileProvider.profileModel.result?[0].id ?? 0)}");
          nameController.text =
              profileProvider.profileModel.result?[0].fullName ?? "";
          emailController.text =
              profileProvider.profileModel.result?[0].email ?? "";
          mobilenumberController.text =
              profileProvider.profileModel.result?[0].mobile ?? "";
          bioController.text =
              profileProvider.profileModel.result?[0].bio ?? "";
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(context, "editprofile", true, true),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* Profile Image */
                Consumer<ProfileProvider>(
                  builder: (context, value, child) {
                    return Column(children: [
                      Container(
                        color: appBgColor,
                        height: 130,
                        width: MediaQuery.of(context).size.width,
                        child: pickedImageFile != null
                            ? Image.file(
                                pickedImageFile!,
                                fit: BoxFit.cover,
                                height: 90,
                                width: 90,
                              )
                            : MyUserNetworkImage(
                                imageUrl:
                                    profileProvider.profileModel.status == 200
                                        ? profileProvider.profileModel.result !=
                                                null
                                            ? (profileProvider.profileModel
                                                    .result?[0].image ??
                                                "")
                                            : ""
                                        : "",
                                fit: BoxFit.cover,
                                imgHeight: 90,
                                imgWidth: MediaQuery.of(context).size.width,
                              ),
                      ),
                      Container(
                        transform:
                            Matrix4.translationValues(0, -kToolbarHeight, 0),
                        child: Center(
                          child: Stack(children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      width: 0.5, color: primaryDark)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                clipBehavior: Clip.antiAlias,
                                child: pickedImageFile != null
                                    ? Image.file(
                                        pickedImageFile!,
                                        fit: BoxFit.cover,
                                        height: 90,
                                        width: 90,
                                      )
                                    : MyUserNetworkImage(
                                        imageUrl: profileProvider
                                                    .profileModel.status ==
                                                200
                                            ? profileProvider
                                                        .profileModel.result !=
                                                    null
                                                ? (profileProvider.profileModel
                                                        .result?[0].image ??
                                                    "")
                                                : ""
                                            : "",
                                        fit: BoxFit.cover,
                                        imgHeight: 90,
                                        imgWidth: 90,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 5,
                              child: InkWell(
                                onTap: () {
                                  pickImageDialog();
                                },
                                child: MyImage(
                                  imagePath: 'ic_edit.png',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            )
                          ]),
                        ),
                      ),
                    ]);
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                /* Change Button */
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  // onTap: () {
                  //   pickImageDialog();
                  // },
                  child: Container(
                    transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
                    // constraints: const BoxConstraints(
                    //   minHeight: 35,
                    //   // maxWidth: 100,
                    // ),
                    // alignment: Alignment.center,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyText(
                            text: profileProvider
                                    .profileModel.result?[0].userName
                                    .toString() ??
                                "",
                            fontsizeNormal: 16,
                            fontsizeWeb: 16,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                            textalign: TextAlign.center,
                            color: primaryDark,
                          ),
                          MyText(
                            text: profileProvider.profileModel.result?[0].email
                                    .toString() ??
                                "",
                            fontsizeNormal: 16,
                            fontsizeWeb: 16,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                            textalign: TextAlign.center,
                            color: otherColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                    transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
                    child: textField())
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Name */
          MyText(
            text: "Name",
            fontsizeNormal: 14,
            fontsizeWeb: 16,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            fontstyle: FontStyle.normal,
            textalign: TextAlign.center,
            color: white,
          ),
          const SizedBox(height: 10),
          Container(
            height: Dimens.textFieldHeight,
            padding: const EdgeInsets.only(left: 10, right: 10),
            // decoration: Utils.textFieldBGWithBorder(),
            decoration: BoxDecoration(
              // color: white,
              border: Border.all(
                color: otherColor,
                width: .2,
              ),
              borderRadius: BorderRadius.circular(4),
              shape: BoxShape.rectangle,
            ),
            alignment: Alignment.center,
            child: MyTextFormField(
              // mHint: enterName,
              mHint: nameController.text,
              mController: nameController,
              mObscureText: false,
              mMaxLine: 1,
              mHintTextColor: white,
              mTextColor: white,
              mkeyboardType: TextInputType.name,
              mTextInputAction: TextInputAction.done,
              mInputBorder: InputBorder.none,
              mTextAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          /*Email */
          MyText(
            text: "Email",
            fontsizeNormal: 14,
            fontsizeWeb: 16,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            fontstyle: FontStyle.normal,
            textalign: TextAlign.center,
            color: white,
          ),
          const SizedBox(height: 10),
          Container(
            height: Dimens.textFieldHeight,
            padding: const EdgeInsets.only(left: 10, right: 10),
            // decoration: Utils.textFieldBGWithBorder(),
            decoration: BoxDecoration(
              // color: white,
              border: Border.all(
                color: otherColor,
                width: .2,
              ),
              borderRadius: BorderRadius.circular(4),
              shape: BoxShape.rectangle,
            ),
            alignment: Alignment.center,
            child: MyTextFormField(
              // mHint: enterEmail,
              mHint: emailController.text.toString(),
              mController: emailController,
              mObscureText: false,
              mMaxLine: 1,
              mHintTextColor: otherColor,
              mTextColor: white,
              mkeyboardType: TextInputType.name,
              mTextInputAction: TextInputAction.done,
              mInputBorder: InputBorder.none,
              mTextAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          /* password*/
          MyText(
            text: "Mobile Number",
            fontsizeNormal: 14,
            fontsizeWeb: 16,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            fontstyle: FontStyle.normal,
            textalign: TextAlign.center,
            color: white,
          ),
          const SizedBox(height: 10),
          Container(
            height: Dimens.textFieldHeight,
            padding: const EdgeInsets.only(left: 10, right: 10),
            // decoration: Utils.textFieldBGWithBorder(),
            decoration: BoxDecoration(
              // color: white,
              border: Border.all(
                color: otherColor,
                width: .2,
              ),
              borderRadius: BorderRadius.circular(4),
              shape: BoxShape.rectangle,
            ),
            alignment: Alignment.center,
            child: MyTextFormField(
              // mHint: enterPassword,
              mHint: mobilenumberController.text.toString(),
              mController: mobilenumberController,
              mObscureText: false,
              mMaxLine: 1,
              mHintTextColor: otherColor,
              mTextColor: white,
              mkeyboardType: TextInputType.name,
              mTextInputAction: TextInputAction.done,
              mInputBorder: InputBorder.none,
              mTextAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          /* bio*/
          MyText(
            text: "Bio",
            fontsizeNormal: 14,
            fontsizeWeb: 16,
            multilanguage: false,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            fontstyle: FontStyle.normal,
            textalign: TextAlign.center,
            color: white,
          ),
          const SizedBox(height: 10),
          Container(
            height: Dimens.textFieldHeight,
            padding: const EdgeInsets.only(left: 10, right: 10),
            // decoration: Utils.textFieldBGWithBorder(),
            decoration: BoxDecoration(
              // color: white,
              border: Border.all(
                color: otherColor,
                width: .2,
              ),
              borderRadius: BorderRadius.circular(4),
              shape: BoxShape.rectangle,
            ),
            alignment: Alignment.center,
            child: MyTextFormField(
              mHint: enterBio,
              mController: bioController,
              mObscureText: false,
              mMaxLine: 1,
              mHintTextColor: otherColor,
              mTextColor: white,
              mkeyboardType: TextInputType.name,
              mTextInputAction: TextInputAction.done,
              mInputBorder: InputBorder.none,
              mTextAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          /* Save */
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                // debugPrint(
                //     "nameController Name ==> ${nameController.text.toString()}");
                // debugPrint(
                //     "pickedImageFile ==> ${pickedImageFile?.path ?? "not picked"}"
                //     );
                if (nameController.text.toString().isEmpty) {
                  return Utils.showSnackbar(context, "info", enterName, false);
                }
                final profileProvider =
                    Provider.of<ProfileProvider>(context, listen: false);
                Utils.showProgress(context, prDialog);
                await sharePref.save(
                    "username", nameController.text.toString());
                // if (pickedImageFile != null) {
                //   await profileProvider.getImageUpload(pickedImageFile);
                // }
                await profileProvider.getUpdateProfile(
                    nameController.text.toString(),
                    emailController.text.toString(),
                    mobilenumberController.text.toString(),
                    bioController.text.toString(),
                    pickedImageFile);
                if (!mounted) return;
                await profileProvider.getProfile(context);
                Utils.saveUserCreds(
                  userID: profileProvider.profileModel.result?[0].id.toString(),
                  userName: profileProvider.profileModel.result?[0].fullName
                      .toString(),
                  userEmail:
                      profileProvider.profileModel.result?[0].email.toString(),
                  userMobile:
                      profileProvider.profileModel.result?[0].mobile.toString(),
                  userImage:
                      profileProvider.profileModel.result?[0].image.toString(),
                  userPremium:
                      profileProvider.profileModel.result?[0].isBuy.toString(),
                  userType:
                      profileProvider.profileModel.result?[0].type.toString(),
                );

                await prDialog.hide();
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(
                  color: saveBtnBg,
                  borderRadius: BorderRadius.circular(36),
                ),
                alignment: Alignment.center,
                child: MyText(
                  color: white,
                  text: "save",
                  multilanguage: true,
                  textalign: TextAlign.center,
                  fontsizeNormal: 15,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w600,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickImageDialog() {
    showModalBottomSheet(
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
                          text: "addphoto",
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          multilanguage: true,
                          text: "pickimagenote",
                          textalign: TextAlign.center,
                          fontsizeNormal: 13,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /* Camera Pick */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      getFromCamera();
                    },
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
                        text: "takephoto",
                        textalign: TextAlign.center,
                        fontsizeNormal: 16,
                        multilanguage: true,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  /* Gallery Pick */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      getFromGallery();
                    },
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
                        text: "choosegallry",
                        textalign: TextAlign.center,
                        fontsizeNormal: 16,
                        multilanguage: true,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  /* Avatar Pick */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pop(context);
                      getFromAvatar();
                    },
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
                        text: "chooseanavatar",
                        textalign: TextAlign.center,
                        fontsizeNormal: 16,
                        multilanguage: true,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 75,
                          maxWidth: 80,
                        ),
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
                          color: white,
                          text: cancel,
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w500,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get from gallery
  void getFromGallery() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        pickedImageFile = File(pickedFile.path);
        debugPrint("Gallery pickedImageFile ==> ${pickedImageFile?.path}");
      });
    }
  }

  /// Get from Camera
  void getFromCamera() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      setState(() {
        pickedImageFile = File(pickedFile.path);
        debugPrint("Camera pickedImageFile ==> ${pickedImageFile?.path}");
      });
    }
  }

  /// Get from Avatar
  void getFromAvatar() async {
    final String? imageURL = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const ProfileAvatar();
        },
      ),
    );
    debugPrint("imageURL =============> $imageURL");
    if (imageURL.toString() != "") {
      File? pickedFile = await Utils.saveImageInStorage(imageURL ?? "");
      debugPrint("pickedFile =============> ${pickedFile?.path}");
      if (pickedFile != null) {
        setState(() {
          pickedImageFile = File(pickedFile.path);
          debugPrint("Avatar pickedImageFile ==> ${pickedImageFile?.path}");
        });
      }
    }
  }
}

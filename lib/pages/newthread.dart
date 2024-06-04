import 'dart:io';

import 'package:dtpocketfm/pages/profile.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/threadprovider.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/dimens.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/myusernetworkimg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class CreateThread extends StatefulWidget {
  const CreateThread({super.key});

  @override
  State<CreateThread> createState() => _CreateThreadState();
}

class _CreateThreadState extends State<CreateThread> {
  final ImagePicker imagePicker = ImagePicker();
  final descriptionController = TextEditingController();
  File? pickedImageFile;
  late ProgressDialog prDialog;
  late ProfileProvider profileProvider;
  late ThreadProvider threadProvider;
  String? _selectedImagePath;
  Uint8List? _selectedImage;
  MultipartFile? multipartFile;
  File? imageFile;

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
        imageFile = File(_selectedImagePath!);

        _selectedImage = result.files.single.bytes;
      });
      // _uploadImage();
    }
  }

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    threadProvider = Provider.of<ThreadProvider>(context, listen: false);
    prDialog = ProgressDialog(context);
    threadProvider.setLoading(true);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    await profileProvider.getProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkappbgcolor,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: MyImage(
              imagePath: 'backwith_bg.png',
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: darkappbgcolor,
        centerTitle: false,
        elevation: 0,
        title: MyText(
          multilanguage: true,
          color: white,
          text: "new_thread",
          fontsizeNormal: 16,
          fontsizeWeb: 15,
          fontweight: FontWeight.w500,
        ),
      ),
      body: kIsWeb ? webNewThread() : newThread(),
    );
  }

  Widget newThread() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, value, child) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyProfile(
                                    type: 'myProfile',
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        clipBehavior: Clip.antiAlias,
                        child: MyUserNetworkImage(
                          imageUrl: profileProvider.profileModel.status == 200
                              ? profileProvider.profileModel.result != null
                                  ? (profileProvider
                                          .profileModel.result?[0].image ??
                                      "")
                                  : ""
                              : "",
                          fit: BoxFit.cover,
                          imgHeight: 46,
                          imgWidth: 46,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer<ProfileProvider>(
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyProfile(
                                        type: 'myProfile',
                                      )));
                        },
                        child: MyText(
                          color: white,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          multilanguage: false,
                          text: (value.profileModel.result?[0].fullName ?? "")
                                      .isEmpty ||
                                  ((value.profileModel.result?[0].fullName)
                                      .toString()
                                      .contains("null"))
                              ? (value.profileModel.result?[0].userName
                                      .toString() ??
                                  "")
                              : value.profileModel.result?[0].fullName
                                      .toString() ??
                                  "",
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          fontsizeWeb: 12,
                          fontweight: FontWeight.w600,
                          fontstyle: FontStyle.normal,
                        ),
                      );
                    },
                  ),
                  TextField(
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                      } else {}
                    },
                    onChanged: (value) async {
                      if (value.isNotEmpty) {
                      } else {}
                    },
                    textInputAction: TextInputAction.done,
                    obscureText: false,
                    controller: descriptionController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: transparentColor,
                      hintStyle: TextStyle(
                        color: otherColor,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Start a thread....",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      pickImageDialog();
                    },
                    child: MyImage(
                      imagePath: "pickImg.png",
                      height: Dimens.coinImgHeight,
                      width: Dimens.coinImgWidth,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  pickedImageFile != null
                      ? Image.file(
                          height: 151,
                          width: 151,
                          pickedImageFile!,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                ],
              )),
            ],
          ),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          color: appBgColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  multilanguage: true,
                  color: white,
                  text: "your_followers_can_reply",
                  fontsizeNormal: 14,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w400,
                ),
                InkWell(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    Utils.showProgress(context, prDialog);
                    final newthread =
                        Provider.of<ThreadProvider>(context, listen: false);
                    await newthread.uploadNewThreads(
                        descriptionController.text.toString(), pickedImageFile);
                    if (newthread.uploadthreadsmodel.status == 200) {
                      if (!mounted) return;
                      Utils().hideProgress(
                        context,
                      );
                      debugPrint("Sucess Full ");
                      Utils.showToast("Your Thread Uploaded Successfully");
                      if (!mounted) return;
                      Navigator.pop(context);
                    } else {
                      if (!mounted) return;
                      Utils().hideProgress(
                        context,
                      );
                      Utils.showToast(" UnSuccessfull to Upload");
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    height: Dimens.coinPriceContHeight,
                    // width: Dimens.coinPriceContWidth,
                    decoration: BoxDecoration(
                      color: primaryDark,
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: MyText(
                      color: white,
                      multilanguage: true,
                      fontsizeWeb: 12,
                      text: "post",
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget webNewThread() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, value, child) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const MyProfile(
                              type: 'myProfile',
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        clipBehavior: Clip.antiAlias,
                        child: MyUserNetworkImage(
                          imageUrl: profileProvider.profileModel.status == 200
                              ? profileProvider.profileModel.result != null
                                  ? (profileProvider
                                          .profileModel.result?[0].image ??
                                      "")
                                  : ""
                              : "",
                          fit: BoxFit.cover,
                          imgHeight: 46,
                          imgWidth: 46,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer<ProfileProvider>(
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const MyProfile(
                                  type: 'myProfile',
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return child;
                                },
                              ));
                        },
                        child: MyText(
                          color: white,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          multilanguage: false,
                          text: value.profileModel.result?[0].fullName
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          fontsizeWeb: 12,
                          fontweight: FontWeight.w600,
                          fontstyle: FontStyle.normal,
                        ),
                      );
                    },
                  ),
                  TextField(
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        // strCouponCode = value.toString();
                        // applyCoupon();
                      } else {
                        // strCouponCode = "";
                      }
                      // debugPrint("strCouponCode ===========> $strCouponCode");
                    },
                    onChanged: (value) async {
                      if (value.isNotEmpty) {
                        // strCouponCode = value.toString();
                      } else {
                        // strCouponCode = "";
                      }
                      // debugPrint("strCouponCode ===========> $strCouponCode");
                    },
                    textInputAction: TextInputAction.done,
                    obscureText: false,
                    controller: descriptionController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: transparentColor,
                      hintStyle: TextStyle(
                        color: otherColor,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Start a thread....",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      // pickImageDialog();
                      _pickImage();
                    },
                    child: MyImage(
                      imagePath: "pickImg.png",
                      height: Dimens.coinImgHeight,
                      width: Dimens.coinImgWidth,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _selectedImage != null
                      ? Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: MemoryImage(
                                  _selectedImage!), // Use ! to assert non-null
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(),
                ],
              )),
            ],
          ),
        ),
        Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          color: appBgColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  multilanguage: true,
                  color: white,
                  text: "your_followers_can_reply",
                  fontsizeNormal: 14,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w400,
                ),
                InkWell(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();

                    Utils.showProgress(context, prDialog);
                    final newthread =
                        Provider.of<ThreadProvider>(context, listen: false);
                    await newthread.uploadNewThreads(
                        descriptionController.text.toString(),
                        _selectedImagePath);
                    if (newthread.uploadthreadsmodel.status == 200) {
                      if (!mounted) return;
                      Utils().hideProgress(
                        context,
                      );
                      debugPrint("Sucess Full ");
                      Utils.showToast("Your Thread Uploaded Successfully");
                      if (!mounted) return;
                      Navigator.pop(context);
                    } else {
                      if (!mounted) return;
                      Utils().hideProgress(
                        context,
                      );
                      Utils.showToast(" UnSuccessfull to Upload");
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    height: Dimens.coinPriceContHeight,
                    // width: Dimens.coinPriceContWidth,
                    decoration: BoxDecoration(
                      color: primaryDark,
                      borderRadius: BorderRadius.circular(38),
                    ),
                    child: MyText(
                      color: white,
                      multilanguage: true,
                      fontsizeWeb: 12,
                      text: "post",
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
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
                          fontsizeWeb: 15,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        // MyText(
                        //   color: white,
                        //   multilanguage: true,
                        //   text: "pickimagenote",
                        //   textalign: TextAlign.center,
                        //   fontsizeNormal: 13,
                        //   fontweight: FontWeight.w500,
                        //   maxline: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   fontstyle: FontStyle.normal,
                        // )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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
                        fontsizeWeb: 15,
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
                          fontsizeWeb: 15,
                          text: "cancel",
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
  
}

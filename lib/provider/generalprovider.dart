import 'dart:io';

import 'package:dtpocketfm/model/generalsettingmodel.dart';
import 'package:dtpocketfm/model/loginregistermodel.dart';
import 'package:dtpocketfm/model/pagesmodel.dart';
import 'package:dtpocketfm/model/successmodel.dart';
import 'package:dtpocketfm/utils/adhelper.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GeneralProvider extends ChangeNotifier {
  GeneralSettingModel generalSettingModel = GeneralSettingModel();
  PagesModel pagesModel = PagesModel();
  LoginRegisterModel loginSocialModel = LoginRegisterModel();
  LoginRegisterModel loginOTPModel = LoginRegisterModel();
  LoginRegisterModel loginTVModel = LoginRegisterModel();
  SuccessModel logoutmodel = SuccessModel();

  bool loading = false;
  String? appDescription;

  SharedPre sharedPre = SharedPre();

  Future<void> getGeneralsetting(BuildContext context) async {
    loading = true;
    generalSettingModel = await ApiService().genaralSetting();
    debugPrint('generalSettingData status ==> ${generalSettingModel.status}');
    if (generalSettingModel.status == 200) {
      if (generalSettingModel.result != null) {
        for (var i = 0; i < (generalSettingModel.result?.length ?? 0); i++) {
          await sharedPre.save(
            generalSettingModel.result?[i].key.toString() ?? "",
            generalSettingModel.result?[i].value.toString() ?? "",
          );
          debugPrint(
              '${generalSettingModel.result?[i].key.toString()} ==> ${generalSettingModel.result?[i].value.toString()}');
        }

        appDescription = await sharedPre.read("app_desripation") ?? "";
        debugPrint("appDescription ===========> $appDescription");
        /* Get Ads Init */
        if (context.mounted && !kIsWeb) {
          AdHelper.getAds(context);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getPages() async {
    loading = true;
    pagesModel = await ApiService().getPages();
    debugPrint("getPages status :==> ${pagesModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> getsignout() async {
    loading = true;
    logoutmodel = await ApiService().logout();
    debugPrint("getlogoutmodelPages status :==> ${logoutmodel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithSocial(
      email, name, type, deviceType, File? profileImg) async {
    debugPrint("loginWithSocial email :==> $email");
    debugPrint("loginWithSocial name :==> $name");
    debugPrint("loginWithSocial type :==> $type");
    debugPrint("loginWithSocial profileImg :==> ${profileImg?.path}");

    loading = true;
    loginSocialModel = await ApiService().loginWithSocial(
      email,
      name,
      type,
      deviceType,
      profileImg,
    );
    debugPrint("loginWithSocial status :==> ${loginSocialModel.status}");
    debugPrint("loginWithSocial message :==> ${loginSocialModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithOTP(mobile) async {
    debugPrint("getLoginOTP mobile :==> $mobile");

    loading = true;
    loginOTPModel = await ApiService().loginWithOTP(mobile);
    debugPrint("login status :==> ${loginOTPModel.status}");
    debugPrint("login message :==> ${loginOTPModel.message}");
    loading = false;
    notifyListeners();
  }
}

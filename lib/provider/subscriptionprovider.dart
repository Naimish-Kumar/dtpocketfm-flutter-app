import 'package:dtpocketfm/model/subscriptionmodel.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel subscriptionModel = SubscriptionModel();

  bool loading = false;

  Future<void> getPackages() async {
    debugPrint("getPackages userID :==> ${Constant.userID}");
    loading = true;
    subscriptionModel = await ApiService().subscriptionPackage();
    debugPrint("get_package status :==> ${subscriptionModel.status}");
    debugPrint("get_package message :==> ${subscriptionModel.message}");
    loading = false;
    notifyListeners();
  }
   setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  clearProvider() {
    debugPrint("<================ clearSubscriptionProvider ================>");
    // subscriptionModel = SubscriptionModel();
  }
}

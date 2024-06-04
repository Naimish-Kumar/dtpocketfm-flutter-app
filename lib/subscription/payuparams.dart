import 'package:dtpocketfm/utils/constant.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';

class PayUParams {
  static Map<dynamic, dynamic> createPayUConfigParams() {
    var payUCheckoutProConfig = {
      PayUCheckoutProConfigKeys.primaryColor: "#bafa34",
      PayUCheckoutProConfigKeys.secondaryColor: "#0e0e16",
      PayUCheckoutProConfigKeys.merchantName: Constant.appName,
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      PayUCheckoutProConfigKeys.autoSelectOtp: true,
      PayUCheckoutProConfigKeys.waitingTime: 30000,
      PayUCheckoutProConfigKeys.autoApprove: true,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
      PayUCheckoutProConfigKeys.showCbToolbar: true,
    };
    return payUCheckoutProConfig;
  }
}

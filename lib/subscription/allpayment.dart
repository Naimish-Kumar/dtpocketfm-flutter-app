import 'dart:async';
import 'dart:io';

import 'package:dtpocketfm/provider/channelsectionprovider.dart';
import 'package:dtpocketfm/provider/paymentprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/provider/videodetailsprovider.dart';
import 'package:dtpocketfm/subscription/payuhashservice.dart';
import 'package:dtpocketfm/subscription/payuparams.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/sharedpre.dart';
import 'package:dtpocketfm/utils/strings.dart';
import 'package:dtpocketfm/utils/utils.dart';
import 'package:dtpocketfm/widget/myimage.dart';
import 'package:dtpocketfm/widget/mytext.dart';
import 'package:dtpocketfm/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:uuid/uuid.dart';
// import 'package:uuid/uuid.dart';

final bool _kAutoConsume = Platform.isIOS || true;

class AllPayment extends StatefulWidget {
  final String? payType,
      coin,
      itemId,
      price,
      itemTitle,
      typeId,
      videoType,
      productPackage,
      currency;
  const AllPayment({
    super.key,
    required this.payType,
    required this.itemId,
    required this.price,
    required this.itemTitle,
    required this.typeId,
    required this.coin,
    required this.videoType,
    required this.productPackage,
    required this.currency,
  });

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment>
    implements PayUCheckoutProProtocol {
  final couponController = TextEditingController();
  late ProgressDialog prDialog;
  late PaymentProvider paymentProvider;
  SharedPre sharedPref = SharedPre();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;

  /* InApp Purchase */
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late List<String> _kProductIds;
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  /* Paytm */
  String paytmResult = "";

  /* Flutterwave */
  String selectedCurrency = "";
  bool isTestMode = true;

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

  /* PayU */
  late PayUCheckoutProFlutter _payUCheckoutPro;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    _getData();
    if (!kIsWeb) {
      /* PayU */
      _payUCheckoutPro = PayUCheckoutProFlutter(this);

      /* InApp Purchase */
      _kProductIds = <String>[widget.productPackage ?? ""];
      prDialog = ProgressDialog(context);
      _getData();
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
        debugPrint("onError ============> ${error.toString()}");
      });
      initStoreInfo();
    }
    super.initState();
  }

  _getData() async {
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.getPaymentOption();
    await paymentProvider.setFinalAmount(widget.price ?? "");

    if (paymentProvider.paymentOptionModel.status == 200) {
      if (paymentProvider.paymentOptionModel.result != null) {
        if (paymentProvider.paymentOptionModel.result?.flutterwave != null) {}
      }
    }

    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    debugPrint('paymentId =====================> $paymentId');

    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    debugPrint('getUserData userId ==> $userId');
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    Future.delayed(Duration.zero).then((value) {
      if (!context.mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    paymentProvider.clearProvider();
    if (!kIsWeb) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription.cancel();
    }
    couponController.dispose();
    super.dispose();
  }

  /* add_transaction API */
  Future addTransaction(
      packageId, description, amount, paymentId, currencyCode) async {
    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    final channelSectionProvider =
        Provider.of<ChannelSectionProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    Utils.showProgress(context, prDialog);
    await paymentProvider.addTransaction(
        packageId, description, amount, paymentId, widget.coin);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (!mounted) return;
        await profileProvider.getProfile(context);
        await videoDetailsProvider.updatePrimiumPurchase();
        await showDetailsProvider.updatePrimiumPurchase();
        await channelSectionProvider.updatePrimiumPurchase();
        await videoDetailsProvider.updateRentPurchase();
        await showDetailsProvider.updateRentPurchase();

        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, "info", paymentProvider.successModel.message ?? "", false);
      }
    }
  }

  /* add_rent_transaction API */
  Future addRentTransaction(videoId, amount, typeId, videoType) async {
    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);

    Utils.showProgress(context, prDialog);
    await paymentProvider.addRentTransaction(
        videoId, amount, typeId, videoType, strCouponCode);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        isPaymentDone = true;
        if (videoType == "1") {
          await videoDetailsProvider.updateRentPurchase();
        } else if (videoType == "2") {
          await showDetailsProvider.updateRentPurchase();
        }

        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, "info", paymentProvider.successModel.message ?? "", true);
      }
    }
  }

  /* apply_coupon API */
  Future applyCoupon() async {
    FocusManager.instance.primaryFocus?.unfocus();
    Utils.showProgress(context, prDialog);
    if (widget.payType == "Package") {
      /* Package Coupon */
      await paymentProvider.applyPackageCouponCode(
          strCouponCode, widget.itemId);

      if (!paymentProvider.couponLoading) {
        await prDialog.hide();
        if (paymentProvider.couponModel.status == 200) {
          couponController.clear();
          await paymentProvider.setFinalAmount(
              paymentProvider.couponModel.result?.discountAmount.toString());
          strCouponCode =
              paymentProvider.couponModel.result?.uniqueId.toString();
          debugPrint("strCouponCode =============> $strCouponCode");
          debugPrint(
              "finalAmount =============> ${paymentProvider.finalAmount}");
          if (!mounted) return;
          Utils.showSnackbar(context, "success",
              paymentProvider.couponModel.message ?? "", false);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "fail",
              paymentProvider.couponModel.message ?? "", false);
        }
      }
    } else if (widget.payType == "Rent") {
      /* Rent Coupon */
      await paymentProvider.applyRentCouponCode(strCouponCode, widget.itemId,
          widget.typeId, widget.videoType, widget.price);

      if (!paymentProvider.couponLoading) {
        await prDialog.hide();
        if (paymentProvider.couponModel.status == 200) {
          couponController.clear();
          await paymentProvider.setFinalAmount(
              paymentProvider.couponModel.result?.discountAmount.toString());
          strCouponCode =
              paymentProvider.couponModel.result?.uniqueId.toString();
          debugPrint("strCouponCode =============> $strCouponCode");
          debugPrint(
              "finalAmount =============> ${paymentProvider.finalAmount}");
          if (!mounted) return;
          Utils.showSnackbar(context, "success",
              paymentProvider.couponModel.message ?? "", false);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "fail",
              paymentProvider.couponModel.message ?? "", false);
        }
      }
    } else {
      await prDialog.hide();
    }
  }

  openPayment({required String pgName}) async {
    debugPrint("finalAmount =============> ${paymentProvider.finalAmount}");
    // if (paymentProvider.finalAmount != "0") {
    if (pgName == "paypal") {
      debugPrint("Paypal Calling");
      _paypalInit();
    } else if (pgName == "inapp") {
      _initInAppPurchase();
    } else if (pgName == "razorpay") {
      _initializeRazorpay();
    } else if (pgName == "flutterwave") {
      _flutterwaveInit();
    } else if (pgName == "payumoney") {
      _payUInit();
    } else if (pgName == "paytm") {
      _paytmInit();
    } else if (pgName == "stripe") {
      // _stripeInit();
    } else if (pgName == "paystack") {
      // _paystackInit();
    } else if (pgName == "instamojo") {
      // _initInstamojo();
    } else if (pgName == "cash") {
      if (!mounted) return;
      Utils.showSnackbar(context, "info", "cash_payment_msg", true);
    }
    // } else {
    //   if (widget.payType == "Package") {
    //     addTransaction(widget.itemId, widget.itemTitle,
    //         paymentProvider.finalAmount, paymentId, widget.currency);
    //   } else if (widget.payType == "Rent") {
    //     addRentTransaction(widget.itemId, paymentProvider.finalAmount,
    //         widget.typeId, widget.videoType);
    //   }
    // }
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        onBackPressed();
      },
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: (kIsWeb || Constant.isTV)
          ? null
          : Utils.myAppBarWithBack(context, "payment_details", true, true),
      body: SafeArea(
        child: Center(
          child: _buildMobilePage(),
        ),
      ),
    );
  }

  Widget _buildMobilePage() {
    return Container(
      width:
          ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
      margin: (kIsWeb || Constant.isTV)
          ? const EdgeInsets.fromLTRB(50, 0, 50, 50)
          : const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: (kIsWeb || Constant.isTV) ? 40 : 0),
          /* Coupon Code Box & Total Amount */
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              color: colorPrimaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 50),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    /* (!kIsWeb)
                        ? (Platform.isIOS
                            ? const SizedBox.shrink()
                            : _buildCouponBox())
                        :  */
                    _buildCouponBox(),
                    /* (!kIsWeb)
                        ? (Platform.isIOS
                            ? const SizedBox.shrink()
                            : const SizedBox(height: 20))
                        :  */
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 50),
                      decoration: Utils.setBackground(colorPrimary, 0),
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.centerLeft,
                      child: Consumer<PaymentProvider>(
                        builder: (context, paymentProvider, child) {
                          return RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: payableAmountIs,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: lightBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${Constant.currencySymbol}${paymentProvider.finalAmount ?? ""}",
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /* PGs */
          Expanded(
            child: SingleChildScrollView(
              child: paymentProvider.loading
                  ? Container(
                      height: 230,
                      padding: const EdgeInsets.all(20),
                      child: Utils.pageLoader(),
                    )
                  : paymentProvider.paymentOptionModel.status == 200
                      ? paymentProvider.paymentOptionModel.result != null
                          ? ((kIsWeb)
                              ? _buildWebPayments()
                              : _buildPaymentPage())
                          : const NoData(
                              title: 'no_payment', subTitle: 'no_payment_desc')
                      : const NoData(
                          title: 'no_payment', subTitle: 'no_payment_desc'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: primaryDark, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: TextField(
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    strCouponCode = value.toString();
                    applyCoupon();
                  } else {
                    strCouponCode = "";
                  }
                  debugPrint("strCouponCode ===========> $strCouponCode");
                },
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    strCouponCode = value.toString();
                  } else {
                    strCouponCode = "";
                  }
                  debugPrint("strCouponCode ===========> $strCouponCode");
                },
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: couponController,
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
                  hintText: couponAddHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              debugPrint("Click on Apply!");
              debugPrint("strCouponCode ===========> $strCouponCode");
              if (strCouponCode != null && (strCouponCode ?? "").isNotEmpty) {
                applyCoupon();
              } else {
                Utils.showSnackbar(context, "info", emptyCouponMsg, false);
              }
            },
            child: Container(
              height: 30,
              constraints: const BoxConstraints(minWidth: 50),
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              decoration: Utils.setBackground(white, 5),
              alignment: Alignment.center,
              child: MyText(
                color: black,
                text: "apply",
                multilanguage: true,
                fontsizeNormal: 13,
                fontsizeWeb: 14,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontweight: FontWeight.w600,
                textalign: TextAlign.end,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: whiteLight,
            text: "payment_methods",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: otherColor,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: 13,
            fontsizeWeb: 15,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: complimentryColor,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: 16,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* /* Payments */ */
          (!kIsWeb)
              ? (/* Platform.isIOS ? _buildIOSPG() :  */ _buildAndroidPG())
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildWebPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: whiteLight,
            text: "payment_methods",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: otherColor,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: 13,
            fontsizeWeb: 15,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: complimentryColor,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: 16,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* Razorpay */
          paymentProvider.paymentOptionModel.result?.razorpay != null
              ? paymentProvider
                          .paymentOptionModel.result?.razorpay?.visibility ==
                      "1"
                  ? _buildPGButton("pg_razorpay.png", "Razorpay", 35, 130,
                      onClick: () async {
                      await paymentProvider.setCurrentPayment("razorpay");
                      openPayment(pgName: "razorpay");
                    })
                  : const SizedBox.shrink()
              : const NoData(title: 'no_payment', subTitle: 'no_payment_desc'),
        ],
      ),
    );
  }

  Widget _buildIOSPG() {
    /* In-App purchase */
    return _buildIOSPGButton("In-App Purchase", 35, 110, onClick: () async {
      await paymentProvider.setCurrentPayment("inapp");
      _initInAppPurchase();
    });
  }

  Widget _buildIOSPGButton(String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: lightBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MyText(
                    color: colorPrimary,
                    text: pgName,
                    multilanguage: false,
                    fontsizeNormal: 22,
                    fontsizeWeb: 22,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 20),
                MyImage(
                  imagePath: "ic_arrow_right.png",
                  fit: BoxFit.contain,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidPG() {
    return Column(
      children: [
        /* In-App purchase */
        paymentProvider.paymentOptionModel.result?.inapppurchage != null
            ? paymentProvider
                        .paymentOptionModel.result?.inapppurchage?.visibility ==
                    "1"
                ? _buildPGButton("pg_inapp.png", "InApp Purchase", 35, 110,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("inapp");
                    openPayment(pgName: "inapp");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paypal */
        paymentProvider.paymentOptionModel.result?.paypal != null
            ? paymentProvider.paymentOptionModel.result?.paypal?.visibility ==
                    "1"
                ? _buildPGButton("pg_paypal.png", "Paypal", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("paypal");
                    openPayment(pgName: "paypal");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Razorpay */
        paymentProvider.paymentOptionModel.result?.razorpay != null
            ? paymentProvider.paymentOptionModel.result?.razorpay?.visibility ==
                    "1"
                ? _buildPGButton("pg_razorpay.png", "Razorpay", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("razorpay");
                    openPayment(pgName: "razorpay");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Paytm */
        paymentProvider.paymentOptionModel.result?.paytm != null
            ? paymentProvider.paymentOptionModel.result?.paytm?.visibility ==
                    "1"
                ? _buildPGButton("pg_paytm.png", "Paytm", 30, 90,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("paytm");
                    openPayment(pgName: "paytm");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* Flutterwave */
        paymentProvider.paymentOptionModel.result?.flutterwave != null
            ? paymentProvider
                        .paymentOptionModel.result?.flutterwave?.visibility ==
                    "1"
                ? _buildPGButton("pg_flutterwave.png", "Flutterwave", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("flutterwave");
                    openPayment(pgName: "flutterwave");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        /* PayUMoney */
        paymentProvider.paymentOptionModel.result?.payumoney != null
            ? paymentProvider
                        .paymentOptionModel.result?.payumoney?.visibility ==
                    "1"
                ? _buildPGButton("pg_payumoney.png", "PayU Money", 35, 130,
                    onClick: () async {
                    await paymentProvider.setCurrentPayment("payumoney");
                    openPayment(pgName: "payumoney");
                  })
                : const SizedBox.shrink()
            : const SizedBox.shrink(),

        // /* Instamojo */
        // paymentProvider.paymentOptionModel.result?.instamojo != null
        //     ? paymentProvider
        //                 .paymentOptionModel.result?.instamojo?.visibility ==
        //             "1"
        //         ? _buildPGButton("pg_instamojo.png", "Instamojo", 35, 130,
        //             onClick: () async {
        //             await paymentProvider.setCurrentPayment("instamojo");
        //             openPayment(pgName: "instamojo");
        //           })
        //         : const SizedBox.shrink()
        //     : const SizedBox.shrink(),

        // /* Paystack */
        // paymentProvider.paymentOptionModel.result?.paystack != null
        //     ? paymentProvider.paymentOptionModel.result?.paystack?.visibility ==
        //             "1"
        //         ? _buildPGButton("pg_paystack.png", "Paystack", 50, 100,
        //             onClick: () async {
        //             await paymentProvider.setCurrentPayment("paystack");
        //             openPayment(pgName: "paystack");
        //           })
        //         : const SizedBox.shrink()
        //     : const SizedBox.shrink(),

        // /* Cash */
        // paymentProvider.paymentOptionModel.result?.cash != null
        //     ? paymentProvider.paymentOptionModel.result?.cash?.visibility == "1"
        //         ? _buildPGButton("pg_cash.png", "Cash", 40, 40,
        //             onClick: () async {
        //             await paymentProvider.setCurrentPayment("cash");
        //             openPayment(pgName: "cash");
        //           })
        //         : const SizedBox.shrink()
        //     : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildPGButton(
      String imageName, String pgName, double imgHeight, double imgWidth,
      {required Function() onClick}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        color: lightBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onClick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MyImage(
                  imagePath: imageName,
                  fit: BoxFit.contain,
                  height: imgHeight,
                  width: imgWidth,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: pgName,
                    multilanguage: false,
                    fontsizeNormal: 14,
                    fontsizeWeb: 15,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.end,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(width: 15),
                MyImage(
                  imagePath: "ic_arrow_right.png",
                  fit: BoxFit.fill,
                  height: 22,
                  width: 20,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ********* InApp purchase START ********* */
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {});
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {});
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {});
      return;
    }
    setState(() {});
  }

  _initInAppPurchase() async {
    debugPrint(
        "_initInAppPurchase _kProductIds ============> ${_kProductIds[0].toString()}");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      Utils.showToast("Please check SKU");
      return;
    }
    debugPrint("productID ============> ${response.productDetails[0].id}");
    late PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      purchaseParam =
          GooglePlayPurchaseParam(productDetails: response.productDetails[0]);
    } else {
      purchaseParam = PurchaseParam(productDetails: response.productDetails[0]);
    }
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint(
              "purchaseDetails ============> ${purchaseDetails.error.toString()}");
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint("===> status ${purchaseDetails.status}");
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kProductIds[0]) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          debugPrint(
              "===> pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}");
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    debugPrint("===> productID ${purchaseDetails.productID}");
    if (purchaseDetails.productID == _kProductIds[0]) {
      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, paymentProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
      setState(() {});
    } else {
      debugPrint("===> consumables else $purchaseDetails");
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void showPendingUI() {
    setState(() {});
  }

  void handleError(IAPError error) {
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    debugPrint("invalid Purchase ===> $purchaseDetails");
  }
  /* ********* InApp purchase END ********* */

  /* ********* Razorpay START ********* */
  void _initializeRazorpay() {
    if (paymentProvider.paymentOptionModel.result?.razorpay != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.razorpay?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        testKey2: "",
      );
      debugPrint(
          "Livekey 1 ==>> ${paymentProvider.paymentOptionModel.result?.razorpay?.key1}");
      debugPrint(
          "Livekey 2 ==>> ${paymentProvider.paymentOptionModel.result?.razorpay?.key2}");
      debugPrint(
          "TestKey 1 ==>> ${paymentProvider.paymentOptionModel.result?.razorpay?.key1}");
      debugPrint(
          "TestKey 2 ==>> ${paymentProvider.paymentOptionModel.result?.razorpay?.key2}");
      if (!isContinue) return;
      /* Check Keys */

      Razorpay razorpay = Razorpay();
      var options = {
        'key': (paymentProvider.paymentOptionModel.result?.razorpay?.isLive ==
                "1")
            ? (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? "")
            : (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        'currency': Constant.currency,
        'amount': (double.parse(paymentProvider.finalAmount ?? "") * 100),
        'name': widget.itemTitle ?? "",
        'description': widget.itemTitle ?? "",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'external': {
          'wallets': ['paytm']
        }
      };
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

      try {
        razorpay.open(options);
      } catch (e) {
        debugPrint('Razorpay Error :=========> $e');
      }
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    Utils.showSnackbar(context, "fail", "payment_fail", true);
    await paymentProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    paymentId = response.paymentId.toString();
    debugPrint("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "success", "payment_success", true);
    if (widget.payType == "Package") {
      addTransaction(widget.itemId, widget.itemTitle,
          paymentProvider.finalAmount, paymentId, widget.currency);
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType);
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    debugPrint("============ External Wallet Selected ============");
  }
  /* ********* Razorpay END ********* */

  /* ********* Paytm START ********* */
  Future<void> _paytmInit() async {
    if (paymentProvider.paymentOptionModel.result?.paytm != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.paytm?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */

      bool payTmIsStaging;
      String payTmMerchantID,
          payTmOrderId,
          payTmCustmoreID,
          payTmChannelID,
          payTmTxnAmount,
          payTmWebsite,
          payTmCallbackURL,
          payTmIndustryTypeID;

      payTmOrderId = paymentId ?? "";
      payTmCustmoreID = "${Constant.userID}_$paymentId";
      payTmChannelID = "WAP";
      payTmTxnAmount = "${(paymentProvider.finalAmount ?? "")}.00";
      payTmIndustryTypeID = "Retail";

      if (paymentProvider.paymentOptionModel.result?.paytm?.isLive == "1") {
        payTmMerchantID =
            paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? "";
        payTmIsStaging = false;
        payTmWebsite = "DEFAULT";
        payTmCallbackURL =
            "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
      } else {
        payTmMerchantID =
            paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? "";
        payTmIsStaging = true;
        payTmWebsite = "WEBSTAGING";
        payTmCallbackURL =
            "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
      }
      var sendMap = <String, dynamic>{
        "mid": payTmMerchantID,
        "orderId": payTmOrderId,
        "amount": payTmTxnAmount,
        "txnToken": paymentProvider.payTmModel.result?.paytmChecksum ?? "",
        "callbackUrl": payTmCallbackURL,
        "isStaging": payTmIsStaging,
        "restrictAppInvoke": true,
        "enableAssist": true,
      };
      debugPrint("sendMap ===> $sendMap");

      /* Generate CheckSum from Backend */
      await paymentProvider.getPaytmToken(
        payTmMerchantID,
        payTmOrderId,
        payTmCustmoreID,
        payTmChannelID,
        payTmTxnAmount,
        payTmWebsite,
        payTmCallbackURL,
        payTmIndustryTypeID,
      );

      if (!paymentProvider.loading) {
        if (paymentProvider.payTmModel.result != null) {
          if (paymentProvider.payTmModel.result?.paytmChecksum != null) {
            try {
              var response = AllInOneSdk.startTransaction(
                payTmMerchantID,
                payTmOrderId,
                payTmTxnAmount,
                paymentProvider.payTmModel.result?.paytmChecksum ?? "",
                payTmCallbackURL,
                payTmIsStaging,
                true,
                true,
              );
              response.then((value) {
                debugPrint("value ====> $value");
                setState(() {
                  paytmResult = value.toString();
                });
              }).catchError((onError) {
                if (onError is PlatformException) {
                  setState(() {
                    paytmResult = "${onError.message} \n  ${onError.details}";
                  });
                } else {
                  setState(() {
                    paytmResult = onError.toString();
                  });
                }
              });
            } catch (err) {
              paytmResult = err.toString();
            }
          } else {
            if (!mounted) return;
            Utils.showSnackbar(context, "", "payment_not_processed", true);
          }
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "", "payment_not_processed", true);
        }
      }
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }
  /* ********* Paytm END ********* */

  /* ********* Paypal START ********* */
  Future<void> _paypalInit() async {
    if (paymentProvider.paymentOptionModel.result?.paypal != null) {
      debugPrint("Paypal Calling 2 ");
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.paypal?.isLive ?? ""),
        isBothKeyReq: true,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
        testKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
        testKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
      );
      if (!isContinue) return;
      /* Check Keys */
      debugPrint("Paypal Calling 3 ");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
              sandboxMode:
                  (paymentProvider.paymentOptionModel.result?.paypal?.isLive ??
                              "") ==
                          "1"
                      ? false
                      : true,
              clientId: (paymentProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1")
                  ? (paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
                      "")
                  : (paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
                      ""),
              secretKey: (paymentProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1")
                  ? (paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
                      "")
                  : (paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
                      ""),
              returnURL: "return.example.com",
              cancelURL: "cancel.example.com",
              transactions: [
                {
                  "amount": {
                    "total": '${paymentProvider.finalAmount}',
                    "currency": Constant.currency,
                    "details": {
                      "subtotal": '${paymentProvider.finalAmount}',
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": widget.payType ?? "",
                  "item_list": {
                    "items": [
                      {
                        "name": "${widget.itemTitle}",
                        "quantity": 1,
                        "price": '${paymentProvider.finalAmount}',
                        "currency": Constant.currency
                      }
                    ],
                  }
                }
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (params) async {
                debugPrint("onSuccess: ${params["paymentId"]}");
                if (widget.payType == "Package") {
                  addTransaction(
                      widget.itemId,
                      widget.itemTitle,
                      paymentProvider.finalAmount,
                      params["paymentId"],
                      widget.currency);
                } else if (widget.payType == "Rent") {
                  addRentTransaction(widget.itemId, paymentProvider.finalAmount,
                      widget.typeId, widget.videoType);
                }
              },
              onError: (params) {
                debugPrint("onError: ${params["message"]}");
                Utils.showSnackbar(
                    context, "fail", params["message"].toString(), false);
              },
              onCancel: (params) {
                debugPrint('cancelled: $params');
                Utils.showSnackbar(context, "fail", params.toString(), false);
              }),
        ),
      );
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }
  /* ********* Paypal END ********* */

  // /* ********* Stripe START ********* */
  // Future<void> _stripeInit() async {
  //   if (paymentProvider.paymentOptionModel.result?.stripe != null) {
  //     stripe.Stripe.publishableKey = (paymentProvider
  //                 .paymentOptionModel.result?.stripe?.isLive ==
  //             "1")
  //         ? (paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? "")
  //         : (paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? "");
  //     try {
  //       //STEP 1: Create Payment Intent
  //       paymentIntent = await createPaymentIntent(
  //           paymentProvider.finalAmount ?? "", Constant.currency);

  //       //STEP 2: Initialize Payment Sheet
  //       await stripe.Stripe.instance
  //           .initPaymentSheet(
  //               paymentSheetParameters: stripe.SetupPaymentSheetParameters(
  //             paymentIntentClientSecret: paymentIntent?['client_secret'],
  //             style: ThemeMode.light,
  //             merchantDisplayName: Constant.appName,
  //           ))
  //           .then((value) {});

  //       //STEP 3: Display Payment sheet
  //       displayPaymentSheet();
  //     } catch (err) {
  //       throw Exception(err);
  //     }
  //   } else {
  //     Utils.showSnackbar(context, "", "payment_not_processed", true);
  //   }
  // }

  // createPaymentIntent(String amount, String currency) async {
  //   try {
  //     //Request body
  //     Map<String, dynamic> body = {
  //       'amount': calculateAmount(amount),
  //       'currency': currency,
  //       'description': widget.itemTitle,
  //     };

  //     //Make post request to Stripe
  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization':
  //             'Bearer ${(paymentProvider.paymentOptionModel.result?.stripe?.isLive == "1") ? (paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? "") : (paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? "")}',
  //         'Content-Type': 'application/x-www-form-urlencoded'
  //       },
  //       body: body,
  //     );
  //     return json.decode(response.body);
  //   } catch (err) {
  //     throw Exception(err.toString());
  //   }
  // }

  // calculateAmount(String amount) {
  //   final calculatedAmout = (int.parse(amount)) * 100;
  //   return calculatedAmout.toString();
  // }

  // displayPaymentSheet() async {
  //   try {
  //     await stripe.Stripe.instance.presentPaymentSheet().then((value) {
  //       Utils.showSnackbar(context, "success", "payment_success", true);
  //       if (widget.payType == "Package") {
  //         addTransaction(widget.itemId, widget.itemTitle,
  //             paymentProvider.finalAmount, paymentId, widget.currency);
  //       } else if (widget.payType == "Rent") {
  //         addRentTransaction(widget.itemId, paymentProvider.finalAmount,
  //             widget.typeId, widget.videoType);
  //       }

  //       paymentIntent = null;
  //     }).onError((error, stackTrace) {
  //       throw Exception(error);
  //     });
  //   } on stripe.StripeException catch (e) {
  //     debugPrint('Error is:---> $e');
  //     const AlertDialog(
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.cancel,
  //                 color: Colors.red,
  //               ),
  //               Text("Payment Failed"),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  // }
  // /* ********* Stripe END ********* */

  /* ********* Flutterwave START ********* */
  _flutterwaveInit() async {
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive: (paymentProvider.paymentOptionModel.result?.flutterwave?.isLive ??
          ""),
      isBothKeyReq: false,
      liveKey1:
          (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? ""),
      liveKey2: "",
      testKey1:
          (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? ""),
      testKey2: "",
    );
    if (!isContinue) return;
    /* Check Keys */

    final Customer customer = Customer(
        email: userEmail ?? "",
        name: userName ?? "",
        phoneNumber: userMobileNo ?? '');

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: (paymentProvider
                  .paymentOptionModel.result?.flutterwave?.isLive ==
              "1")
          ? (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? "")
          : (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ??
              ""),
      currency: Constant.currency,
      redirectUrl: 'https://www.divinetechs.com',
      txRef: const Uuid().v1(),
      amount: widget.price.toString().trim(),
      customer: customer,
      paymentOptions: "card, payattitude, barter, bank transfer, ussd",
      customization: Customization(title: widget.itemTitle),
      isTestMode:
          paymentProvider.paymentOptionModel.result?.flutterwave?.isLive != "1",
    );
    ChargeResponse? response = await flutterwave.charge();
    debugPrint("Flutterwave response =====> ${response.toJson()}");
    if (response.status == "success" && response.success == true) {
      paymentId = response.transactionId.toString();
      debugPrint("paymentId ========> $paymentId");
      if (!mounted) return;
      Utils.showSnackbar(context, "success", "payment_success", true);

      if (widget.payType == "Package") {
        addTransaction(widget.itemId, widget.itemTitle,
            paymentProvider.finalAmount, paymentId, widget.currency);
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, paymentProvider.finalAmount,
            widget.typeId, widget.videoType);
      }
    } else if (response.status == "cancel" && response.status == "cancelled") {
      if (!mounted) return;
      Utils.showSnackbar(context, "info", "payment_cancel", true);
    } else {
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "payment_fail", true);
    }
  }
  /* ********* Flutterwave END ********* */

  /* ********* PayU START ********* */
  _payUInit() async {
    debugPrint(
        "_payUInit isLive ======> ${paymentProvider.paymentOptionModel.result?.payumoney?.isLive}");
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive:
          (paymentProvider.paymentOptionModel.result?.payumoney?.isLive ?? ""),
      isBothKeyReq: false,
      liveKey1:
          (paymentProvider.paymentOptionModel.result?.payumoney?.key3 ?? ""),
      liveKey2:
          (paymentProvider.paymentOptionModel.result?.payumoney?.key2 ?? ""),
      testKey1:
          (paymentProvider.paymentOptionModel.result?.payumoney?.key3 ?? ""),
      testKey2:
          (paymentProvider.paymentOptionModel.result?.payumoney?.key2 ?? ""),
    );
    if (!isContinue) return;
    /* Check Keys */

    Map<dynamic, dynamic> additionalParam = {
      PayUAdditionalParamKeys.udf1: "udf1",
      PayUAdditionalParamKeys.udf2: "udf2",
      PayUAdditionalParamKeys.udf3: "udf3",
      PayUAdditionalParamKeys.udf4: "udf4",
      PayUAdditionalParamKeys.udf5: "udf5",
    };

    Map<dynamic, dynamic> payUPaymentParams = {
      PayUPaymentParamKey.key: (paymentProvider
                  .paymentOptionModel.result?.payumoney?.isLive ==
              "1")
          ? (paymentProvider.paymentOptionModel.result?.payumoney?.key2 ?? "")
          : (paymentProvider.paymentOptionModel.result?.payumoney?.key2 ?? ""),
      PayUPaymentParamKey.transactionId: paymentId ?? "",
      PayUPaymentParamKey.amount: double.parse(widget.price ?? "0").toString(),
      PayUPaymentParamKey.productInfo: widget.itemTitle ?? "",
      PayUPaymentParamKey.firstName: userName ?? "",
      PayUPaymentParamKey.email: userEmail ?? "",
      PayUPaymentParamKey.phone: userMobileNo ?? "",
      PayUPaymentParamKey.ios_surl: "https://payu.herokuapp.com/ios_success",
      PayUPaymentParamKey.ios_furl: "https://payu.herokuapp.com/ios_failure",
      PayUPaymentParamKey.android_surl: "https://payu.herokuapp.com/success",
      PayUPaymentParamKey.android_furl: "https://payu.herokuapp.com/failure",
      PayUPaymentParamKey.environment:
          (paymentProvider.paymentOptionModel.result?.payumoney?.isLive == "1")
              ? "0"
              : "1", //0 => Production, 1 => Test
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.userCredential:
          ('${(paymentProvider.paymentOptionModel.result?.payumoney?.isLive == "1") ? (paymentProvider.paymentOptionModel.result?.payumoney?.key2 ?? "") : (paymentProvider.paymentOptionModel.result?.payumoney?.key2 ?? "")}:${userEmail ?? ""}')
    };
    debugPrint("payUPaymentParams ======> ${payUPaymentParams.toString()}");

    try {
      _payUCheckoutPro.openCheckoutScreen(
        payUPaymentParams: payUPaymentParams,
        payUCheckoutProConfig: PayUParams.createPayUConfigParams(),
      );
    } on Exception catch (e) {
      debugPrint("_payUInit Exception ======> ${e.toString()}");
    }
  }

  @override
  generateHash(Map response) {
    // Pass response param to your backend server
    // Backend will generate the hash and will callback to
    Map<dynamic, dynamic> hashResponse = PayUHashService((paymentProvider
                    .paymentOptionModel.result?.payumoney?.isLive ==
                "1")
            ? (paymentProvider.paymentOptionModel.result?.payumoney?.key3 ?? "")
            : (paymentProvider.paymentOptionModel.result?.payumoney?.key3 ??
                ""))
        .generateHash(response);
    debugPrint("hashResponse =====> $hashResponse");
    _payUCheckoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  onError(Map? response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "fail", "payment_fail", true);
  }

  @override
  onPaymentCancel(Map? response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "info", "payment_cancel", true);
  }

  @override
  onPaymentFailure(response) {
    Utils.showSnackbar(context, "fail", "payment_fail", true);
  }

  @override
  onPaymentSuccess(response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "success", "payment_success", true);

    if (widget.payType == "Package") {
      addTransaction(widget.itemId, widget.itemTitle,
          paymentProvider.finalAmount, paymentId, widget.currency);
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType);
    }
  }
  /* ********* PayU END ********* */

  // /* ********* Paystack START ********* */
  // _paystackInit() async {
  //   /* Check Keys */
  //   // bool isContinue = checkKeysAndContinue(
  //   //   isLive:
  //   //       (paymentProvider.paymentOptionModel.result?.paystack?.isLive ?? ""),
  //   //   isBothKeyReq: false,
  //   //   liveKey1:
  //   //       (paymentProvider.paymentOptionModel.result?.paystack?.key1 ?? ""),
  //   //   liveKey2:
  //   //       (paymentProvider.paymentOptionModel.result?.paystack?.key2 ?? ""),
  //   //   testKey1:
  //   //       (paymentProvider.paymentOptionModel.result?.paystack?.key1 ?? ""),
  //   //   testKey2:
  //   //       (paymentProvider.paymentOptionModel.result?.paystack?.key2 ?? ""),
  //   // );
  //   // if (!isContinue) return;
  //   /* Check Keys */

  //   debugPrint("_paystackInit price ========> ${widget.price}");
  //   debugPrint("_paystackInit currency =====> ${Constant.currency}");
  //   PayWithPayStack().now(
  //     context: context,
  //     customerEmail: userEmail ?? "",
  //     reference: DateTime.now().microsecondsSinceEpoch.toString(),
  //     currency: Constant.currency,
  //     amount: (int.parse(widget.price ?? "0") * 100).toString(),
  //     secretKey: (paymentProvider.paymentOptionModel.result?.paystack?.isLive ==
  //             "1")
  //         ? (paymentProvider.paymentOptionModel.result?.paystack?.key1 ?? "")
  //         : (paymentProvider.paymentOptionModel.result?.paystack?.key1 ?? ""),
  //     transactionCompleted: () async {
  //       debugPrint("Transaction Successful");
  //       debugPrint("paymentId ========> $paymentId");

  //       if (!context.mounted) return;
  //       Utils.showSnackbar(context, "success", "payment_success", true);

  //       if (widget.payType == "Package") {
  //         await addTransaction(widget.itemId, widget.itemTitle,
  //             paymentProvider.finalAmount, paymentId, widget.currency);
  //       } else if (widget.payType == "Rent") {
  //         await addRentTransaction(widget.itemId, paymentProvider.finalAmount,
  //             widget.typeId, widget.videoType);
  //       }
  //       if (paymentProvider.successModel.status == 200) {
  //         if (!context.mounted) return;
  //         Navigator.pop(context, true);
  //       }
  //     },
  //     transactionNotCompleted: () {
  //       debugPrint("Transaction Not Successful!");
  //       if (!context.mounted) return;
  //       Utils.showSnackbar(context, "fail", "payment_fail", true);
  //     },
  //     callbackUrl: 'https://dtpocketfm.divinetechs.in/',
  //   );
  // }
  // /* ********* Paystack END ********* */

  // /* ********* Instamojo START ********* */
  // Future<void> _initInstamojo() async {
  //   /* Check Keys */
  //   bool isContinue = checkKeysAndContinue(
  //     isLive:
  //         (paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? ""),
  //     isBothKeyReq: false,
  //     liveKey1:
  //         (paymentProvider.paymentOptionModel.result?.instamojo?.key1 ?? ""),
  //     liveKey2:
  //         (paymentProvider.paymentOptionModel.result?.instamojo?.key2 ?? ""),
  //     testKey1:
  //         (paymentProvider.paymentOptionModel.result?.instamojo?.key1 ?? ""),
  //     testKey2:
  //         (paymentProvider.paymentOptionModel.result?.instamojo?.key2 ?? ""),
  //   );
  //   if (!isContinue) return;
  //   /* Check Keys */

  //   String apiKey =
  //       ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
  //               "1")
  //           ? (paymentProvider.paymentOptionModel.result?.instamojo?.key1 ?? "")
  //           : (paymentProvider.paymentOptionModel.result?.instamojo?.key1 ??
  //               "");
  //   String authToken =
  //       ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
  //               "1")
  //           ? (paymentProvider.paymentOptionModel.result?.instamojo?.key2 ?? "")
  //           : (paymentProvider.paymentOptionModel.result?.instamojo?.key2 ??
  //               "");
  //   String requestURL =
  //       ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
  //               "1")
  //           ? 'https://www.instamojo.com/api/1.1/payment-requests/'
  //           : 'https://test.instamojo.com/api/1.1/payment-requests/';
  //   debugPrint("_initInstamojo apiKey =========> $apiKey");
  //   debugPrint("_initInstamojo authToken ======> $authToken");
  //   debugPrint("_initInstamojo requestURL =====> $requestURL");

  //   final Map<String, dynamic> orderData = {
  //     'amount': double.parse(widget.price ?? '0').toString(), // Amount in INR
  //     'purpose': widget.payType ?? '',
  //     'buyer_name': userName ?? '',
  //     'email': userEmail ?? '',
  //     'phone': userMobileNo ?? '',
  //     'currency': Constant.currency,
  //     'send_email': 'False',
  //     'send_sms': 'False',
  //     'allow_repeated_payments': 'False',
  //   };

  //   final response = await http.post(
  //     Uri.parse(requestURL),
  //     headers: {
  //       "Accept": "application/json",
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //       "X-Api-Key": apiKey,
  //       "X-Auth-Token": authToken,
  //     },
  //     body: orderData,
  //   );

  //   debugPrint('createInstamojoOrder statusCode : ${response.statusCode}');
  //   if (response.statusCode == 201) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     final String paymentUrl = responseData['payment_request']['longurl'];
  //     final String paymentReqID = responseData['payment_request']['id'];

  //     // Now you can open this payment URL in a WebView or a browser
  //     debugPrint('Payment URL : $paymentUrl');
  //     debugPrint('Payment ID  : $paymentReqID');
  //     if (!context.mounted) return;
  //     dynamic result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (ctx) => InstamojoPG(
  //           paymentUrl: paymentUrl,
  //           paymentId: paymentReqID,
  //         ),
  //       ),
  //     );

  //     debugPrint("result =====> $result");
  //     debugPrint("paymentReqID =====> $paymentReqID");
  //     if (result != null && result == true) {
  //       _checkPaymentStatus(paymentReqID);
  //     }
  //   } else {
  //     // Handle error
  //     debugPrint('Failed to create Instamojo order');
  //     if (!context.mounted) return;
  //     Utils.showSnackbar(context, "fail", "payment_not_processed", true);
  //   }
  // }

  // _checkPaymentStatus(String id) async {
  //   debugPrint("_checkPaymentStatus id =========> $id");
  //   String apiKey =
  //       ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
  //               "1")
  //           ? (paymentProvider.paymentOptionModel.result?.instamojo?.key1 ?? "")
  //           : (paymentProvider.paymentOptionModel.result?.instamojo?.key1 ??
  //               "");
  //   String authToken =
  //       ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
  //               "1")
  //           ? (paymentProvider.paymentOptionModel.result?.instamojo?.key2 ?? "")
  //           : (paymentProvider.paymentOptionModel.result?.instamojo?.key2 ??
  //               "");
  //   String requestURL =
  //       ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
  //               "1")
  //           ? 'https://www.instamojo.com/api/1.1/payment-requests/'
  //           : 'https://test.instamojo.com/api/1.1/payment-requests/';
  //   debugPrint("_checkPaymentStatus apiKey =========> $apiKey");
  //   debugPrint("_checkPaymentStatus authToken ======> $authToken");
  //   debugPrint("_checkPaymentStatus requestURL =====> $requestURL");

  //   final response = await http.get(
  //     Uri.parse('$requestURL$id/'),
  //     headers: {
  //       "Accept": "application/json",
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //       'X-Api-Key': apiKey,
  //       'X-Auth-Token': authToken,
  //     },
  //   );

  //   debugPrint('createInstamojoOrder statusCode : ${response.statusCode}');
  //   final Map<String, dynamic> realResponse = json.decode(response.body);
  //   if (realResponse['success'] == true) {
  //     if (realResponse["payment_request"]['payments'] != null) {
  //       List<dynamic> myPayments = [];
  //       myPayments = realResponse["payment_request"]['payments'];
  //       if (myPayments.isNotEmpty) {
  //         if (myPayments[0]['status'] == "Credit") {
  //           paymentId = myPayments[0]['payment_id'];
  //           debugPrint('createInstamojoOrder paymentId : $paymentId');

  //           if (!context.mounted) return;
  //           Utils.showSnackbar(context, "success", "payment_success", true);

  //           if (widget.payType == "Package") {
  //             await addTransaction(widget.itemId, widget.itemTitle,
  //                 paymentProvider.finalAmount, paymentId, widget.currency);
  //           } else if (widget.payType == "Rent") {
  //             await addRentTransaction(widget.itemId,
  //                 paymentProvider.finalAmount, widget.typeId, widget.videoType);
  //           }
  //           debugPrint("PAYMENT STATUS SUCCESS");
  //           //payment is successful.
  //         } else {
  //           debugPrint("PAYMENT STATUS PENDING");
  //           if (!context.mounted) return;
  //           Utils.showSnackbar(context, "info", "payment_cancel", true);
  //           //payment failed or pending.
  //         }
  //       } else {
  //         debugPrint("PAYMENT STATUS PENDING");
  //         if (!context.mounted) return;
  //         Utils.showSnackbar(context, "info", "payment_cancel", true);
  //         //payment failed or pending.
  //       }
  //     } else {
  //       debugPrint("PAYMENT STATUS PENDING");
  //       if (!context.mounted) return;
  //       Utils.showSnackbar(context, "info", "payment_cancel", true);
  //       //payment failed or pending.
  //     }
  //   } else {
  //     debugPrint("PAYMENT STATUS FAILED");
  //     if (!context.mounted) return;
  //     Utils.showSnackbar(context, "fail", "payment_fail", true);
  //     //payment failed.
  //   }
  // }
  // /* ********* Instamojo END ********* */

  Future<bool> onBackPressed() async {
    if (!mounted) return Future.value(false);
    Navigator.pop(context, isPaymentDone);
    return Future.value(isPaymentDone == true ? true : false);
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
